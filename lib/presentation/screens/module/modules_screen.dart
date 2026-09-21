/// Lista de módulos, con el desglose del dominio a la vista.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/charts.dart';
import 'module_screen.dart';

class ModulesScreen extends ConsumerWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        const ScreenHeader(
          title: 'Aprender',
          subtitle: 'Cuatro módulos, 23 lecciones, 16 experimentos',
          color: AppColors.indigo,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              const NoticeBox(
                'El orden recomendado es simular primero y leer después. '
                'Cada lección tiene marcado el experimento que la precede.',
                title: 'Predice → Simula → Explica',
              ),
              const SizedBox(height: 16),
              for (final m in content.modules) ...[
                _ModuleCard(moduleId: m.id),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 6),
              Text(
                'El dominio de cada módulo es 15 % lecciones + 15 % '
                'laboratorios + 70 % práctica. Para marcarlo como competente '
                'hace falta 70 % en el total y también 70 % en la práctica: '
                'leer y simular no compensan razonar mal.',
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModuleCard extends ConsumerWidget {
  final String moduleId;

  const _ModuleCard({required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final module = content.module(moduleId)!;
    final mastery = ref.watch(moduleMasteryProvider(moduleId));
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;

    return AppCard(
      accent: color,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ModuleScreen(moduleId: moduleId),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MasteryRing(value: mastery.total, color: color, size: 56),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${module.order}. ${module.name}',
                        style: t.titleLarge),
                    const SizedBox(height: 3),
                    Text(module.question, style: t.bodySmall),
                    const SizedBox(height: 6),
                    Pill(
                      mastery.levelLabel,
                      color: mastery.competent ? AppColors.success : color,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(module.description, style: t.bodyMedium),
          const SizedBox(height: 12),
          _MasteryBreakdown(moduleId: moduleId, color: color),
          const SizedBox(height: 10),
          Row(
            children: [
              _Count(
                icon: Icons.menu_book_outlined,
                value: content.lessonsOf(moduleId).length,
                label: 'lecciones',
              ),
              const SizedBox(width: 14),
              _Count(
                icon: Icons.science_outlined,
                value: content.experimentsOf(moduleId).length,
                label: 'experimentos',
              ),
              const SizedBox(width: 14),
              _Count(
                icon: Icons.edit_outlined,
                value: content.exercisesOf(moduleId).length,
                label: 'ejercicios',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MasteryBreakdown extends ConsumerWidget {
  final String moduleId;
  final Color color;

  const _MasteryBreakdown({required this.moduleId, required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(moduleMasteryProvider(moduleId));
    return Column(
      children: [
        _Bar(label: 'Lecciones (15 %)', value: m.lessonPart, color: color),
        const SizedBox(height: 6),
        _Bar(label: 'Laboratorios (15 %)', value: m.labPart, color: color),
        const SizedBox(height: 6),
        _Bar(
          label: 'Práctica (70 %)',
          value: m.practicePart,
          color: color,
          showThreshold: true,
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool showThreshold;

  const _Bar({
    required this.label,
    required this.value,
    required this.color,
    this.showThreshold = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        SizedBox(
          width: 128,
          child: Text(label, style: t.bodySmall),
        ),
        Expanded(
          child: showThreshold
              ? ThresholdBar(value: value, color: color)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    minHeight: 8,
                    color: color,
                    backgroundColor:
                        Theme.of(context).colorScheme.outline,
                  ),
                ),
        ),
        SizedBox(
          width: 42,
          child: Text(
            '${(value * 100).round()} %',
            textAlign: TextAlign.right,
            style: t.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Count extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _Count({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
