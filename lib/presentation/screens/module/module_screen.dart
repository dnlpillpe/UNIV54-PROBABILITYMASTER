/// Detalle de un módulo: laboratorios, lecciones y práctica, en ese orden.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/charts.dart';
import '../cases/cases_screen.dart';
import '../exercise/exercise_screen.dart';
import '../lab/experiment_screen.dart';
import '../lesson/lesson_screen.dart';

class ModuleScreen extends ConsumerWidget {
  final String moduleId;

  const ModuleScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final module = content.module(moduleId)!;
    final progress = ref.watch(progressProvider);
    final mastery = ref.watch(moduleMasteryProvider(moduleId));
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;

    final labs = content.labsOf(moduleId);
    final lessons = content.lessonsOf(moduleId);
    final exercises = content.exercisesOf(moduleId);

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: '${module.order}. ${module.name}',
            subtitle: module.question,
            color: color,
            onBack: () => Navigator.of(context).pop(),
            trailing: MasteryRing(
              value: mastery.total,
              color: Colors.white,
              size: 54,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                Text(module.description, style: t.bodyMedium),
                const SizedBox(height: 18),

                if (labs.isNotEmpty) ...[
                  const SectionTitle(
                    'Laboratorios',
                    subtitle: 'Empieza aquí: predice, simula y luego lee',
                  ),
                  for (final lab in labs) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(lab.name, style: t.titleSmall),
                    ),
                    for (final exp in lab.experiments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(13),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ExperimentScreen(experimentId: exp.id),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                progress.experiments.containsKey(exp.id)
                                    ? Icons.check_circle
                                    : Icons.science_outlined,
                                color: progress.experiments.containsKey(exp.id)
                                    ? AppColors.success
                                    : color,
                                size: 20,
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(exp.title, style: t.titleSmall),
                                    Text(exp.manipulates,
                                        style: t.bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              if (progress.experiments[exp.id]
                                      ?.predictionCorrect ==
                                  true)
                                const Pill('Predicción ✓',
                                    color: AppColors.teal),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 10),
                ],

                const SectionTitle(
                  'Lecciones',
                  subtitle: 'Cortas: una tarjeta, una idea',
                ),
                for (final l in lessons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(13),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LessonScreen(lessonId: l.id),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            progress.completedLessons.contains(l.id)
                                ? Icons.check_circle
                                : Icons.menu_book_outlined,
                            color: progress.completedLessons.contains(l.id)
                                ? AppColors.success
                                : color,
                            size: 20,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.title, style: t.titleSmall),
                                Text(
                                  l.objective,
                                  style: t.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${progress.lessonCardsSeen[l.id] ?? 0}/'
                            '${l.cardCount}',
                            style: t.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                SectionTitle(
                  'Práctica',
                  subtitle: '${exercises.length} ejercicios de seis tipos, '
                      'con retroalimentación por alternativa',
                ),
                AppCard(
                  accent: color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Dominio de práctica: '
                              '${(mastery.practicePart * 100).round()} %',
                              style: t.titleSmall,
                            ),
                          ),
                          if (mastery.practicePart >= 0.70)
                            const Pill('Umbral superado',
                                color: AppColors.success),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ThresholdBar(
                        value: mastery.practicePart,
                        color: color,
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        'Practicar',
                        icon: Icons.edit_outlined,
                        color: color,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ExerciseScreen(moduleId: moduleId),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (moduleId == 'm4') ...[
                  const SizedBox(height: 16),
                  const SectionTitle(
                    'Casos profesionales',
                    subtitle: '12 casos de 11 carreras; dos terminan en '
                        '«no corresponde calcular»',
                  ),
                  PrimaryButton(
                    'Abrir casos',
                    icon: Icons.work_outline,
                    color: AppColors.rose,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CasesScreen(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
