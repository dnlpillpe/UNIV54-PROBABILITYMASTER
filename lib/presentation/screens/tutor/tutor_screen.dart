/// Tutor probabilístico.
///
/// Tres funciones, ninguna de ellas «conversar»: **diagnosticar** qué
/// confusión tiene este estudiante, **clasificar** un problema con el árbol
/// de siete preguntas, y **resolver paso a paso** mostrando el porqué de
/// cada paso. Es determinista por decisión (Fase 5 del análisis): en un
/// dominio donde el error tiene la misma forma que la respuesta correcta, un
/// tutor que se equivoca el 3 % de las veces es peor que no tener tutor.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/misconception.dart';
import '../../../domain/services/diagnosis_service.dart';
import '../../../domain/tutor/problem_classifier.dart';
import '../../../domain/tutor/step_solver.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../lab/experiment_screen.dart';
import '../lesson/lesson_screen.dart';
import '../tools/calculator_screen.dart';

class TutorScreen extends ConsumerStatefulWidget {
  const TutorScreen({super.key});

  @override
  ConsumerState<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends ConsumerState<TutorScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tutorClient = ref.read(tutorClientProvider);
    return Column(
      children: [
        ScreenHeader(
          title: 'Tutor probabilístico',
          subtitle: tutorClient.available
              ? 'Diagnóstico, clasificación y resolución'
              : 'Determinista: el motor calcula, nada se inventa',
          color: AppColors.indigoDeep,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: _Segmented(
            index: _tab,
            labels: const ['Diagnóstico', 'Clasificar', 'Resolver'],
            onChanged: (i) => setState(() => _tab = i),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _tab,
            children: const [
              _DiagnosisTab(),
              _ClassifierTab(),
              _SolverTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == index ? scheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: i == index ? Colors.white : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =====================================================================
// 1 · Diagnóstico
// =====================================================================
class _DiagnosisTab extends ConsumerWidget {
  const _DiagnosisTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final active = ref.watch(activeMisconceptionsProvider);
    final overcome = ref.watch(overcomeMisconceptionsProvider);
    final progress = ref.watch(progressProvider);
    final t = Theme.of(context).textTheme;
    final diagnosis = ref.read(diagnosisProvider);
    final byFamily = diagnosis.byFamily(active);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        TileGrid(
          minTileWidth: 150,
          children: [
            StatTile(
              label: 'Confusiones activas',
              value: '${active.length}',
              color: active.isEmpty ? AppColors.success : AppColors.danger,
              hint: 'de ${content.misconceptionCount} catalogadas',
            ),
            StatTile(
              label: 'Superadas',
              value: '$overcome',
              color: AppColors.success,
              hint: 'aparecieron y ya no',
            ),
            StatTile(
              label: 'Aciertos ciegos',
              value: '${progress.blindHits}',
              color: AppColors.warning,
              hint: 'bien por la razón equivocada',
            ),
            StatTile(
              label: 'Intuición inicial',
              value: '${(progress.initialIntuition * 100).round()} %',
              color: AppColors.teal,
              hint: 'predicciones acertadas',
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (active.isEmpty)
          const NoticeBox(
            'Todavía no hay confusiones activas. El diagnóstico se alimenta '
            'de lo que fallas, así que practica un poco: acertar no aporta '
            'información, fallar de una manera concreta sí.',
            kind: NoticeKind.success,
            title: 'Sin confusiones detectadas',
          )
        else ...[
          const SectionTitle(
            'Qué estás confundiendo',
            subtitle: 'Cada una con su remedio enlazado',
          ),
          for (final entry in byFamily.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Pill(entry.key.label, color: AppColors.indigo),
            ),
            for (final a in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _MisconceptionCard(active: a),
              ),
          ],
        ],
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cómo funciona este diagnóstico', style: t.titleSmall),
              const SizedBox(height: 8),
              Text(
                'Cada alternativa incorrecta de la app declara qué confusión '
                'produce. Al fallar, esa confusión suma 1; al acertar después '
                'en un ítem capaz de detectarla, resta 0,5; y todas decaen un '
                '3 % por cada respuesta que das, para que una confusión '
                'superada desaparezca sola en vez de perseguirte.',
                style: t.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Por eso el tutor no necesita adivinar: sabe exactamente qué '
                'creíste, porque tú lo elegiste.',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MisconceptionCard extends ConsumerWidget {
  final ActiveMisconception active;

  const _MisconceptionCard({required this.active});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final m = active.misconception;
    final t = Theme.of(context).textTheme;
    final exp = m.remedyExperimentId == null
        ? null
        : content.experiment(m.remedyExperimentId!);
    final lesson =
        m.remedyLessonId == null ? null : content.lesson(m.remedyLessonId!);

    return AppCard(
      accent: AppColors.danger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(m.name, style: t.titleSmall)),
              Pill(active.levelLabel, color: AppColors.danger),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              m.belief,
              style: t.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 9),
          Text(m.correction, style: t.bodyMedium),
          const SizedBox(height: 6),
          Text('Se detecta así: ${m.symptom}', style: t.bodySmall),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (exp != null)
                GhostButton(
                  exp.title,
                  icon: Icons.science_outlined,
                  color: AppColors.teal,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExperimentScreen(experimentId: exp.id),
                    ),
                  ),
                ),
              if (lesson != null)
                GhostButton(
                  lesson.title,
                  icon: Icons.menu_book_outlined,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => LessonScreen(lessonId: lesson.id),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// 2 · Clasificador
// =====================================================================
class _ClassifierTab extends StatefulWidget {
  const _ClassifierTab();

  @override
  State<_ClassifierTab> createState() => _ClassifierTabState();
}

class _ClassifierTabState extends State<_ClassifierTab> {
  final List<String> _path = [ProblemClassifier.rootId];
  final List<int> _choices = [];
  TutorMethod? _method;
  String? _why;

  void _choose(int index) {
    final node = ProblemClassifier.node(_path.last);
    final option = node.options[index];
    setState(() {
      _choices.add(index);
      _why = option.why;
      if (option.method != null) {
        _method = option.method;
      } else if (option.next != null) {
        _path.add(option.next!);
      }
    });
  }

  void _restart() {
    setState(() {
      _path
        ..clear()
        ..add(ProblemClassifier.rootId);
      _choices.clear();
      _method = null;
      _why = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final node = ProblemClassifier.node(_path.last);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        const NoticeBox(
          'Esto no te da la respuesta: te da las preguntas que debías haberte '
          'hecho. La meta es que dejes de necesitarlo.',
          title: 'Las cuatro preguntas, desplegadas',
        ),
        const SizedBox(height: 14),
        if (_choices.isNotEmpty) ...[
          AppCard(
            background: AppColors.indigo.withValues(alpha: 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu razonamiento', style: t.titleSmall),
                const SizedBox(height: 7),
                Text(
                  ProblemClassifier.pathSummary(_path, _choices),
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_method == null) ...[
          AppCard(
            accent: AppColors.indigo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.question, style: t.titleMedium),
                if (node.help != null) ...[
                  const SizedBox(height: 7),
                  Text(node.help!, style: t.bodySmall),
                ],
                const SizedBox(height: 14),
                for (var i = 0; i < node.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(11),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => _choose(i),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(node.options[i].label,
                                    style: t.bodyMedium),
                              ),
                              const Icon(Icons.chevron_right, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_why != null) ...[
            const SizedBox(height: 12),
            NoticeBox(_why!, kind: NoticeKind.info, title: 'Por qué'),
          ],
        ] else ...[
          AppCard(
            accent: AppColors.success,
            background: AppColors.success.withValues(alpha: 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Pill('Método aplicable',
                    color: AppColors.success, icon: Icons.check),
                const SizedBox(height: 10),
                Text(_method!.title, style: t.titleMedium),
                const SizedBox(height: 12),
                Text('Condición de uso', style: t.titleSmall),
                const SizedBox(height: 5),
                Text(_method!.condition, style: t.bodyMedium),
                if (_why != null) ...[
                  const SizedBox(height: 12),
                  NoticeBox(_why!, kind: NoticeKind.info),
                ],
                const SizedBox(height: 14),
                if (StepSolver.supports(_method!))
                  PrimaryButton(
                    'Resolverlo paso a paso',
                    icon: Icons.calculate_outlined,
                    color: AppColors.teal,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            CalculatorScreen(initialMethod: _method),
                      ),
                    ),
                  )
                else
                  const NoticeBox(
                    'Este método se resuelve razonando sobre el enunciado, no '
                    'metiendo números en una fórmula.',
                    kind: NoticeKind.warning,
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        GhostButton(
          'Empezar de nuevo',
          icon: Icons.replay,
          onPressed: _restart,
        ),
      ],
    );
  }
}

// =====================================================================
// 3 · Solucionador
// =====================================================================
class _SolverTab extends StatelessWidget {
  const _SolverTab();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final methods = StepSolver.recipes.keys.toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        const NoticeBox(
          'Cada método muestra los pasos, la condición que debe cumplirse y '
          'las advertencias de supuestos. Los números salen del mismo motor '
          'que usa el resto de la app: no pueden contradecirse.',
          title: 'El motor calcula, nada se inventa',
        ),
        const SizedBox(height: 14),
        for (final m in methods)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CalculatorScreen(initialMethod: m),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: t.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          m.condition,
                          style: t.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
