/// Progreso: qué sabe, qué confunde y qué mejoró.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/charts.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final progress = ref.watch(progressProvider);
    final overall = ref.watch(overallMasteryProvider);
    final streak = ref.watch(streakProvider);
    final active = ref.watch(activeMisconceptionsProvider);
    final overcome = ref.watch(overcomeMisconceptionsProvider);
    final t = Theme.of(context).textTheme;

    final correct = progress.history.where((a) => a.choiceCorrect).length;
    final accuracy = progress.history.isEmpty
        ? 0.0
        : correct / progress.history.length;

    return Column(
      children: [
        ScreenHeader(
          title: 'Progreso',
          subtitle: 'Dominio, confusiones y consistencia',
          color: AppColors.indigo,
          trailing: MasteryRing(
            value: overall,
            color: Colors.white,
            size: 54,
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              TileGrid(
                minTileWidth: 150,
                children: [
                  StatTile(
                    label: 'Dominio general',
                    value: '${(overall * 100).round()} %',
                    color: AppColors.indigo,
                    hint: 'promedio de los 4 módulos',
                  ),
                  StatTile(
                    label: 'Racha',
                    value: '$streak',
                    color: AppColors.amber,
                    hint: streak == 1 ? 'día seguido' : 'días seguidos',
                  ),
                  StatTile(
                    label: 'Respuestas',
                    value: '${progress.totalAttempts}',
                    color: AppColors.teal,
                    hint: '${(accuracy * 100).round()} % de aciertos',
                  ),
                  StatTile(
                    label: 'Experimentos',
                    value: '${progress.experiments.length}'
                        '/${content.experimentCount}',
                    color: AppColors.rose,
                    hint: 'intuición inicial '
                        '${(progress.initialIntuition * 100).round()} %',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SectionTitle(
                'Dominio por módulo',
                subtitle: 'La marca ámbar es el umbral de competencia (70 %)',
              ),
              for (final m in content.modules)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _ModuleProgress(moduleId: m.id),
                ),
              const SizedBox(height: 16),
              const SectionTitle('Indicadores propios'),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Indicator(
                      label: 'Aciertos ciegos',
                      value: '${progress.blindHits}',
                      explanation:
                          'Veces que elegiste bien y justificaste mal. Se '
                          'reporta aparte porque en el trabajo un número '
                          'correcto por la razón equivocada no sirve: con '
                          'otros datos, el mismo razonamiento lleva a la '
                          'respuesta contraria.',
                      color: AppColors.warning,
                    ),
                    const Divider(height: 26),
                    _Indicator(
                      label: 'Intuición inicial',
                      value:
                          '${(progress.initialIntuition * 100).round()} %',
                      explanation:
                          'Predicciones de laboratorio acertadas. No suma ni '
                          'resta nota: fallar aquí es el mecanismo por el que '
                          'la simulación corrige una creencia en vez de '
                          'decorarla.',
                      color: AppColors.teal,
                    ),
                    const Divider(height: 26),
                    _Indicator(
                      label: 'Confusiones superadas',
                      value: '$overcome',
                      explanation:
                          'Confusiones que apareciste cometiendo y que hoy '
                          'están por debajo del umbral de detección. Es el '
                          'indicador que mide aprendizaje real, no actividad.',
                      color: AppColors.success,
                    ),
                    const Divider(height: 26),
                    _Indicator(
                      label: 'Confusiones activas',
                      value: '${active.length}',
                      explanation:
                          'Creencias erróneas detectadas por tus respuestas, '
                          'de ${content.misconceptionCount} catalogadas. '
                          'Míralas en la pestaña Tutor: cada una tiene su '
                          'remedio enlazado.',
                      color: active.isEmpty
                          ? AppColors.success
                          : AppColors.danger,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reiniciar progreso', style: t.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Borra respuestas, experimentos y diagnóstico de este '
                      'dispositivo. No se puede deshacer.',
                      style: t.bodySmall,
                    ),
                    const SizedBox(height: 11),
                    GhostButton(
                      'Borrar todo mi progreso',
                      icon: Icons.delete_outline,
                      color: AppColors.danger,
                      onPressed: () => _confirmReset(context, ref),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Borrar el progreso?'),
        content: const Text(
          'Se eliminarán tus respuestas, experimentos y el diagnóstico de '
          'confusiones. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(progressProvider.notifier).reset();
              Navigator.of(ctx).pop();
            },
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }
}

class _ModuleProgress extends ConsumerWidget {
  final String moduleId;

  const _ModuleProgress({required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final module = content.module(moduleId)!;
    final m = ref.watch(moduleMasteryProvider(moduleId));
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;

    return AppCard(
      accent: m.competent ? AppColors.success : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${module.order}. ${module.name}',
                    style: t.titleSmall),
              ),
              Pill(
                m.levelLabel,
                color: m.competent ? AppColors.success : color,
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              SizedBox(
                width: 76,
                child: Text('Total', style: t.bodySmall),
              ),
              Expanded(child: ThresholdBar(value: m.total, color: color)),
              SizedBox(
                width: 42,
                child: Text(
                  '${(m.total * 100).round()} %',
                  textAlign: TextAlign.right,
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              SizedBox(
                width: 76,
                child: Text('Práctica', style: t.bodySmall),
              ),
              Expanded(
                child: ThresholdBar(value: m.practicePart, color: color),
              ),
              SizedBox(
                width: 42,
                child: Text(
                  '${(m.practicePart * 100).round()} %',
                  textAlign: TextAlign.right,
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
          if (!m.competent && m.total >= 0.70 && m.practicePart < 0.70) ...[
            const SizedBox(height: 10),
            const NoticeBox(
              'Tu total llega al umbral, pero la práctica no. Leer las '
              'lecciones y hacer los laboratorios no compensa razonar mal: '
              'por eso el umbral es doble.',
              kind: NoticeKind.warning,
            ),
          ],
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final String label;
  final String value;
  final String explanation;
  final Color color;

  const _Indicator({
    required this.label,
    required this.value,
    required this.explanation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.titleSmall),
              const SizedBox(height: 3),
              Text(explanation, style: t.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
