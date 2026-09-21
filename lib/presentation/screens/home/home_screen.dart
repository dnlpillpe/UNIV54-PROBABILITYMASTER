/// Pantalla de inicio: qué hacer ahora, y por qué.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/services/recommendation_service.dart';
import '../../painters/brand_painter.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/charts.dart';
import '../cases/cases_screen.dart';
import '../exercise/exercise_screen.dart';
import '../lab/experiment_screen.dart';
import '../lesson/lesson_screen.dart';
import '../module/module_screen.dart';
import '../tools/about_screen.dart';
import '../tools/calculator_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final progress = ref.watch(progressProvider);
    final overall = ref.watch(overallMasteryProvider);
    final active = ref.watch(activeMisconceptionsProvider);
    final streak = ref.watch(streakProvider);
    final recommendation = ref.watch(recommendationProvider);
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabecera de marca -------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5B4BEA), AppColors.indigoDeep],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 46, withBackground: false),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppInfo.name,
                              style: t.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              AppInfo.tagline,
                              style: t.bodySmall?.copyWith(
                                color:
                                    Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Acerca de',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.info_outline,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      MasteryRing(
                        value: overall,
                        color: Colors.white,
                        size: 62,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dominio general',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              streak > 0
                                  ? 'Racha de $streak ${streak == 1 ? 'día' : 'días'}'
                                  : 'Sin racha activa',
                              style: t.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              '${progress.totalAttempts} respuestas · '
                              '${progress.experiments.length} de '
                              '${content.experimentCount} experimentos',
                              style: t.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Recomendación -------------------------------------
                const SectionTitle(
                  'Siguiente paso',
                  subtitle: 'Una sola cosa, y el motivo por el que es esa',
                ),
                _RecommendationCard(recommendation: recommendation),

                const SizedBox(height: 22),

                // --- Confusiones activas -------------------------------
                if (active.isNotEmpty) ...[
                  SectionTitle(
                    'Confusiones activas',
                    subtitle:
                        'Detectadas por lo que fallaste, no por lo que dejaste '
                        'de hacer',
                    trailing: Pill(
                      '${active.length}',
                      color: AppColors.danger,
                    ),
                  ),
                  for (final a in active.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        accent: AppColors.danger,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    a.misconception.name,
                                    style: t.titleSmall,
                                  ),
                                ),
                                Pill(a.levelLabel, color: AppColors.danger),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.misconception.belief,
                              style: t.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(a.misconception.correction,
                                style: t.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],

                // --- Módulos -------------------------------------------
                const SectionTitle(
                  'Los cuatro módulos',
                  subtitle: 'Cada uno responde una pregunta distinta',
                ),
                for (final m in content.modules)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ModuleRow(moduleId: m.id),
                  ),

                const SizedBox(height: 18),

                // --- Accesos -------------------------------------------
                TileGrid(
                  minTileWidth: 160,
                  children: [
                    _QuickAction(
                      label: 'Casos profesionales',
                      detail: '${content.caseCount} casos, 11 carreras',
                      icon: Icons.work_outline,
                      color: AppColors.rose,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CasesScreen(),
                        ),
                      ),
                    ),
                    _QuickAction(
                      label: 'Calculadora',
                      detail: 'Con pasos e interpretación',
                      icon: Icons.calculate_outlined,
                      color: AppColors.teal,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const CalculatorScreen(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                AppCard(
                  background: scheme.primary.withValues(alpha: 0.07),
                  accent: scheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const DieIcon(value: 5, size: 22),
                          const SizedBox(width: 8),
                          Text('Cómo funciona esta app', style: t.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(AppInfo.promise, style: t.bodyMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Por eso cada laboratorio te pide una predicción antes '
                        'de dejarte simular: una intuición que no se hace '
                        'explícita no se corrige.',
                        style: t.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  final Recommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final t = Theme.of(context).textTheme;
    final module = content.module(recommendation.moduleId);
    final color = module == null
        ? AppColors.teal
        : AppColors.module(module.colorIndex);

    late final String kindLabel;
    late final IconData icon;
    switch (recommendation.kind) {
      case RecommendationKind.experimento:
        kindLabel = 'Laboratorio';
        icon = Icons.science_outlined;
        break;
      case RecommendationKind.leccion:
        kindLabel = 'Lección';
        icon = Icons.menu_book_outlined;
        break;
      case RecommendationKind.practica:
        kindLabel = 'Práctica';
        icon = Icons.edit_outlined;
        break;
      case RecommendationKind.caso:
        kindLabel = 'Caso';
        icon = Icons.work_outline;
        break;
      case RecommendationKind.repaso:
        kindLabel = 'Repaso';
        icon = Icons.replay_outlined;
        break;
      case RecommendationKind.listo:
        kindLabel = 'Al día';
        icon = Icons.emoji_events_outlined;
        break;
    }

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
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(kindLabel, color: color),
                    const SizedBox(height: 5),
                    Text(recommendation.title, style: t.titleMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(recommendation.reason, style: t.bodyMedium),
          if (recommendation.kind != RecommendationKind.listo) ...[
            const SizedBox(height: 13),
            PrimaryButton(
              'Empezar',
              icon: Icons.play_arrow_rounded,
              color: color,
              onPressed: () => _open(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    switch (recommendation.kind) {
      case RecommendationKind.experimento:
        final exp = content.experiment(recommendation.targetId);
        if (exp == null) return;
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ExperimentScreen(experimentId: exp.id),
        ));
        break;
      case RecommendationKind.leccion:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => LessonScreen(lessonId: recommendation.targetId),
        ));
        break;
      case RecommendationKind.practica:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => ExerciseScreen(
            moduleId: recommendation.moduleId,
            startExerciseId: recommendation.targetId,
          ),
        ));
        break;
      case RecommendationKind.caso:
        Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => const CasesScreen(),
        ));
        break;
      case RecommendationKind.repaso:
      case RecommendationKind.listo:
        break;
    }
  }
}

class _ModuleRow extends ConsumerWidget {
  final String moduleId;

  const _ModuleRow({required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final module = content.module(moduleId)!;
    final mastery = ref.watch(moduleMasteryProvider(moduleId));
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ModuleScreen(moduleId: moduleId),
        ),
      ),
      child: Row(
        children: [
          MasteryRing(value: mastery.total, color: color, size: 52),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${module.order}. ${module.name}',
                        style: t.titleMedium,
                      ),
                    ),
                    if (mastery.competent)
                      const Pill('Competente', color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  module.question,
                  style: t.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.outline),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      accent: color,
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 9),
          Text(label, style: t.titleSmall),
          const SizedBox(height: 2),
          Text(detail, style: t.bodySmall, maxLines: 2),
        ],
      ),
    );
  }
}
