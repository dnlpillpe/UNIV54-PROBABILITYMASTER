/// Lección: una tarjeta por pantalla.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/lesson.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/content_text.dart';
import '../lab/experiment_screen.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.read(contentProvider);
    final lesson = content.lesson(widget.lessonId);
    if (lesson == null) {
      return const Scaffold(body: Center(child: Text('Lección no encontrada')));
    }
    final module = content.module(lesson.moduleId)!;
    final color = AppColors.module(module.colorIndex);
    final t = Theme.of(context).textTheme;
    final experiment = lesson.preferredExperimentId == null
        ? null
        : content.experiment(lesson.preferredExperimentId!);

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: lesson.title,
            subtitle: lesson.objective,
            color: color,
            onBack: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                for (var i = 0; i < lesson.cards.length; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                          right: i == lesson.cards.length - 1 ? 0 : 4),
                      decoration: BoxDecoration(
                        color: i <= _index
                            ? color
                            : Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: lesson.cards.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                ref.read(progressProvider.notifier).recordCard(
                      lesson.id,
                      i,
                      lesson.cards.length,
                    );
              },
              itemBuilder: (context, i) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _CardView(
                  card: lesson.cards[i],
                  color: color,
                  index: i,
                  total: lesson.cards.length,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Row(
                children: [
                  if (experiment != null && _index == 0)
                    Expanded(
                      child: GhostButton(
                        'Ver el experimento',
                        icon: Icons.science_outlined,
                        color: AppColors.teal,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                ExperimentScreen(experimentId: experiment.id),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Text(
                        'Tarjeta ${_index + 1} de ${lesson.cards.length}',
                        style: t.bodySmall,
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (_index < lesson.cards.length - 1)
                    PrimaryButton(
                      'Siguiente',
                      icon: Icons.arrow_forward,
                      expand: false,
                      color: color,
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                      ),
                    )
                  else
                    PrimaryButton(
                      'Terminar',
                      icon: Icons.check,
                      expand: false,
                      color: AppColors.success,
                      onPressed: () async {
                        await ref
                            .read(progressProvider.notifier)
                            .recordCard(
                              lesson.id,
                              lesson.cards.length - 1,
                              lesson.cards.length,
                            );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardView extends ConsumerWidget {
  final LessonCard card;
  final Color color;
  final int index;
  final int total;

  const _CardView({
    required this.card,
    required this.color,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final content = ref.read(contentProvider);
    late Color kindColor;
    late String kindLabel;
    late IconData kindIcon;
    switch (card.kind) {
      case CardKind.formula:
        kindColor = AppColors.indigo;
        kindLabel = 'Regla';
        kindIcon = Icons.functions;
        break;
      case CardKind.ejemplo:
        kindColor = AppColors.teal;
        kindLabel = 'Ejemplo';
        kindIcon = Icons.calculate_outlined;
        break;
      case CardKind.alerta:
        kindColor = AppColors.danger;
        kindLabel = 'Confusión frecuente';
        kindIcon = Icons.warning_amber_rounded;
        break;
      case CardKind.conexion:
        kindColor = AppColors.amber;
        kindLabel = 'Conexión';
        kindIcon = Icons.link;
        break;
      case CardKind.idea:
        kindColor = color;
        kindLabel = 'Idea';
        kindIcon = Icons.lightbulb_outline;
        break;
    }

    final misconception = card.targetsMisconception == null
        ? null
        : content.misconception(card.targetsMisconception!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(kindLabel, color: kindColor, icon: kindIcon),
        const SizedBox(height: 12),
        Text(card.title, style: t.headlineSmall),
        const SizedBox(height: 14),
        ContentText(
          card.body,
          figures: card.figures,
          style: t.bodyLarge,
        ),
        if (misconception != null) ...[
          const SizedBox(height: 18),
          AppCard(
            accent: AppColors.danger,
            background: AppColors.danger.withValues(alpha: 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology_alt_outlined,
                        size: 17, color: AppColors.danger),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Desactiva: ${misconception.name}',
                        style: t.titleSmall
                            ?.copyWith(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  misconception.belief,
                  style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
