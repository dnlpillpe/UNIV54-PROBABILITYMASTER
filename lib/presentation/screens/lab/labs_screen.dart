/// Los cinco laboratorios.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import 'experiment_screen.dart';

class LabsScreen extends ConsumerWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final progress = ref.watch(progressProvider);
    final done = progress.experiments.length;
    final total = content.experimentCount;

    return Column(
      children: [
        ScreenHeader(
          title: 'Laboratorios',
          subtitle: '$done de $total experimentos realizados · '
              'intuición inicial ${(progress.initialIntuition * 100).round()} %',
          color: AppColors.teal,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              const NoticeBox(
                'Cada experimento te pide una predicción antes de habilitar '
                'los controles, y no muestra la conclusión hasta que hayas '
                'simulado lo suficiente. Fallar la predicción no resta: es el '
                'punto.',
                title: 'Por qué se predice primero',
              ),
              const SizedBox(height: 16),
              for (final lab in content.labs) ...[
                _LabCard(labId: lab.id),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LabCard extends ConsumerWidget {
  final String labId;

  const _LabCard({required this.labId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final lab = content.lab(labId)!;
    final module = content.module(lab.moduleId)!;
    final progress = ref.watch(progressProvider);
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;
    final doneCount = lab.experiments
        .where((e) => progress.experiments.containsKey(e.id))
        .length;

    return AppCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.science_outlined, color: color, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lab.name, style: t.titleMedium),
                    Text(lab.subtitle, style: t.bodySmall),
                  ],
                ),
              ),
              Pill('$doneCount/${lab.experiments.length}', color: color),
            ],
          ),
          const SizedBox(height: 12),
          for (final exp in lab.experiments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExperimentScreen(experimentId: exp.id),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          progress.experiments.containsKey(exp.id)
                              ? Icons.check_circle
                              : Icons.play_circle_outline,
                          size: 19,
                          color: progress.experiments.containsKey(exp.id)
                              ? AppColors.success
                              : color,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(exp.title, style: t.titleSmall),
                              Text(
                                exp.manipulates,
                                style: t.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
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
