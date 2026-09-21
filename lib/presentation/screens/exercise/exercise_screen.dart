/// Práctica: los seis tipos de ejercicio en una sola pantalla.
///
/// Toda alternativa incorrecta devuelve su propia retroalimentación y declara
/// la confusión que produce (decisión D3). Los ejercicios de decisión aplican
/// la regla 60/40 (decisión D4).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/content/sample_space_catalog.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/services/grading_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/content_text.dart';
import '../../widgets/sample_space_grid.dart';
import '../lab/experiment_screen.dart';
import '../lesson/lesson_screen.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  final String moduleId;
  final String? startExerciseId;

  const ExerciseScreen({
    super.key,
    required this.moduleId,
    this.startExerciseId,
  });

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  late List<Exercise> _queue;
  int _position = 0;

  int? _choice;
  int? _justification;
  final Set<int> _marked = {};
  final TextEditingController _answer = TextEditingController();
  GradeResult? _result;
  int _hintsShown = 0;

  @override
  void initState() {
    super.initState();
    final content = ref.read(contentProvider);
    _queue = content.exercisesOf(widget.moduleId);
    if (widget.startExerciseId != null) {
      final i = _queue.indexWhere((e) => e.id == widget.startExerciseId);
      if (i >= 0) _position = i;
    }
  }

  @override
  void dispose() {
    _answer.dispose();
    super.dispose();
  }

  Exercise get _current => _queue[_position];

  void _reset() {
    setState(() {
      _choice = null;
      _justification = null;
      _marked.clear();
      _answer.clear();
      _result = null;
      _hintsShown = 0;
    });
  }

  void _next() {
    if (_position < _queue.length - 1) {
      setState(() => _position++);
      _reset();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool get _canSubmit {
    final ex = _current;
    switch (ex.kind) {
      case ExerciseKind.calculo:
        return _answer.text.trim().isNotEmpty;
      case ExerciseKind.construccion:
        return _marked.isNotEmpty;
      case ExerciseKind.decisionJustificada:
        return _choice != null && _justification != null;
      default:
        return _choice != null;
    }
  }

  Future<void> _submit() async {
    final ex = _current;
    final grading = ref.read(gradingProvider);
    GradeResult result;
    switch (ex.kind) {
      case ExerciseKind.calculo:
        result = grading.gradeNumeric(ex, _answer.text);
        break;
      case ExerciseKind.construccion:
        result = _gradeBuild(ex);
        break;
      case ExerciseKind.decisionJustificada:
        result = grading.gradeChoice(
          ex,
          choiceIndex: _choice!,
          justificationIndex: _justification,
        );
        break;
      default:
        result = grading.gradeChoice(ex, choiceIndex: _choice!);
    }
    setState(() => _result = result);
    await ref.read(progressProvider.notifier).recordAttempt(
          result.toRecord(ex.id, ex.moduleId, DateTime.now()),
        );
  }

  GradeResult _gradeBuild(Exercise ex) {
    final target = ex.build!;
    final space = SampleSpaceCatalog.byId(target.spaceId);
    final solution = space.indicesWhere(
      SampleSpaceCatalog.predicate(target.predicate, target.predicateArgs),
    );
    final missing = solution.difference(_marked).length;
    final extra = _marked.difference(solution).length;
    if (missing == 0 && extra == 0) {
      return GradeResult(
        score: 1,
        choiceCorrect: true,
        feedback: 'Correcto: ${solution.length} de ${space.size} resultados, '
            'es decir ${space.probabilityOfIndices(solution).triple}.',
        detects: ex.detects,
      );
    }
    final hits = <String>[];
    if (extra > 0 && missing == 0) hits.add('espacio_incompleto');
    if (missing > 0 && extra == 0) hits.add('orden_ignorado_en_espacio');
    return GradeResult(
      score: 0,
      choiceCorrect: false,
      feedback: 'Te faltaron $missing y marcaste $extra de más. '
          'El evento tiene ${solution.length} resultados de ${space.size}: '
          '${space.probabilityOfIndices(solution).triple}.',
      misconceptionsHit: hits,
      detects: ex.detects,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.read(contentProvider);
    final module = content.module(widget.moduleId)!;
    final color = AppColors.module(module.colorIndex);
    final ex = _current;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Práctica · ${module.name}',
            subtitle: 'Ejercicio ${_position + 1} de ${_queue.length} · '
                '${ex.kind.label} · dificultad ${ex.difficulty}/3',
            color: color,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                if (ex.context != null) ...[
                  AppCard(
                    background:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: ContentText(
                      ex.context!,
                      figures: ex.figures,
                      style: t.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                ContentText(
                  ex.prompt,
                  figures: ex.figures,
                  style: t.titleMedium,
                ),
                const SizedBox(height: 18),
                ..._buildBody(ex, color),
                if (_result != null) ...[
                  const SizedBox(height: 18),
                  _FeedbackBlock(
                    exercise: ex,
                    result: _result!,
                  ),
                ],
                if (_result == null && ex.hints.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  if (_hintsShown < ex.hints.length)
                    GhostButton(
                      _hintsShown == 0 ? 'Pedir una pista' : 'Otra pista',
                      icon: Icons.lightbulb_outline,
                      color: AppColors.amber,
                      onPressed: () => setState(() => _hintsShown++),
                    ),
                  for (var i = 0; i < _hintsShown; i++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: NoticeBox(
                        ex.hints[i],
                        kind: NoticeKind.warning,
                        title: 'Pista ${i + 1}',
                      ),
                    ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: _result == null
                  ? PrimaryButton(
                      'Responder',
                      icon: Icons.check,
                      color: color,
                      onPressed: _canSubmit ? _submit : null,
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            _position < _queue.length - 1
                                ? 'Siguiente ejercicio'
                                : 'Terminar',
                            icon: Icons.arrow_forward,
                            color: color,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBody(Exercise ex, Color color) {
    switch (ex.kind) {
      case ExerciseKind.calculo:
        return _buildNumeric(ex, color);
      case ExerciseKind.construccion:
        return _buildConstruction(ex, color);
      case ExerciseKind.decisionJustificada:
        return [
          ..._buildChoices(ex.choices, _choice, (i) {
            if (_result == null) setState(() => _choice = i);
          }, color, 'Tu decisión'),
          const SizedBox(height: 18),
          Text(
            'Justificación (vale 0,4 de la nota)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._buildChoices(ex.justifications, _justification, (i) {
            if (_result == null) setState(() => _justification = i);
          }, AppColors.teal, null),
        ];
      default:
        return _buildChoices(ex.choices, _choice, (i) {
          if (_result == null) setState(() => _choice = i);
        }, color, null);
    }
  }

  List<Widget> _buildNumeric(Exercise ex, Color color) {
    final isCount = ex.numeric != null &&
        ex.numeric!.figure.format.name == 'count';
    return [
      TextField(
        controller: _answer,
        enabled: _result == null,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: isCount ? 'Número de casos' : 'Tu respuesta',
          hintText: isCount ? 'Por ejemplo 5040' : 'Por ejemplo 3/8, 0,375 o 37,5 %',
          border: const OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        isCount
            ? 'Escribe el entero, sin unidades.'
            : 'Se acepta fracción, decimal o porcentaje.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> _buildConstruction(Exercise ex, Color color) {
    final target = ex.build!;
    final space = SampleSpaceCatalog.byId(target.spaceId);
    final solution = _result == null
        ? null
        : space.indicesWhere(
            SampleSpaceCatalog.predicate(
              target.predicate,
              target.predicateArgs,
            ),
          );
    return [
      AppCard(
        accent: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(space.experiment,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('|Ω| = ${space.size} resultados',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            SampleSpaceGrid(
              space: space,
              selected: _marked,
              solution: solution,
              onToggle: _result != null
                  ? null
                  : (i) => setState(() {
                        if (!_marked.remove(i)) _marked.add(i);
                      }),
            ),
            const SizedBox(height: 10),
            Text(
              'Marcados: ${_marked.length} de ${space.size} → '
              '${space.probabilityOfIndices(_marked).asFraction}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildChoices(
    List<Choice> choices,
    int? selected,
    void Function(int) onTap,
    Color color,
    String? title,
  ) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return [
      if (title != null) ...[
        Text(title, style: t.titleSmall),
        const SizedBox(height: 8),
      ],
      for (var i = 0; i < choices.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: _ChoiceTile(
            text: choices[i].text,
            selected: selected == i,
            revealed: _result != null,
            correct: choices[i].correct,
            color: color,
            onTap: () => onTap(i),
            outline: scheme.outline,
          ),
        ),
    ];
  }
}

class _ChoiceTile extends StatelessWidget {
  final String text;
  final bool selected;
  final bool revealed;
  final bool correct;
  final Color color;
  final VoidCallback onTap;
  final Color outline;

  const _ChoiceTile({
    required this.text,
    required this.selected,
    required this.revealed,
    required this.correct,
    required this.color,
    required this.onTap,
    required this.outline,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = outline;
    Color bg = scheme.surfaceContainerHighest;
    IconData? icon;
    Color iconColor = color;

    if (revealed && correct) {
      border = AppColors.success;
      bg = AppColors.success.withValues(alpha: 0.12);
      icon = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (revealed && selected && !correct) {
      border = AppColors.danger;
      bg = AppColors.danger.withValues(alpha: 0.12);
      icon = Icons.cancel;
      iconColor = AppColors.danger;
    } else if (selected) {
      border = color;
      bg = color.withValues(alpha: 0.12);
      icon = Icons.radio_button_checked;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: revealed ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: border, width: selected ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon ?? Icons.radio_button_unchecked,
                size: 19,
                color: icon == null ? outline : iconColor,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackBlock extends ConsumerWidget {
  final Exercise exercise;
  final GradeResult result;

  const _FeedbackBlock({required this.exercise, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final t = Theme.of(context).textTheme;
    final ok = result.score >= 0.999;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoticeBox(
          result.feedback,
          kind: ok ? NoticeKind.success : NoticeKind.danger,
          title: ok
              ? 'Correcto'
              : (result.score > 0
                  ? 'Parcialmente correcto (${result.score.toStringAsFixed(1)} '
                      'de 1,0)'
                  : 'Revisa esto'),
        ),
        if (result.justificationFeedback != null) ...[
          const SizedBox(height: 10),
          NoticeBox(
            result.justificationFeedback!,
            kind: result.justificationCorrect == true
                ? NoticeKind.success
                : NoticeKind.warning,
            title: 'Sobre tu justificación',
          ),
        ],
        if (result.blindHit) ...[
          const SizedBox(height: 10),
          const NoticeBox(
            'Elegiste bien por la razón equivocada. En el trabajo eso no '
            'sirve: la próxima vez con datos distintos, el mismo razonamiento '
            'te lleva a la respuesta contraria.',
            kind: NoticeKind.warning,
            title: 'Acierto ciego',
          ),
        ],
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solución', style: t.titleSmall),
              const SizedBox(height: 8),
              ContentText(exercise.explanation, figures: exercise.figures),
            ],
          ),
        ),
        for (final id in result.misconceptionsHit)
          if (content.misconception(id) != null) ...[
            const SizedBox(height: 12),
            _RemedyCard(misconceptionId: id),
          ],
      ],
    );
  }
}

class _RemedyCard extends ConsumerWidget {
  final String misconceptionId;

  const _RemedyCard({required this.misconceptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final m = content.misconception(misconceptionId)!;
    final t = Theme.of(context).textTheme;
    final exp = m.remedyExperimentId == null
        ? null
        : content.experiment(m.remedyExperimentId!);
    final lesson =
        m.remedyLessonId == null ? null : content.lesson(m.remedyLessonId!);

    return AppCard(
      accent: AppColors.danger,
      background: AppColors.danger.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt_outlined,
                  size: 17, color: AppColors.danger),
              const SizedBox(width: 7),
              Expanded(
                child: Text('Confusión detectada: ${m.name}',
                    style: t.titleSmall?.copyWith(color: AppColors.danger)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(m.correction, style: t.bodyMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (exp != null)
                GhostButton(
                  'Experimento: ${exp.title}',
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
                  'Lección: ${lesson.title}',
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
