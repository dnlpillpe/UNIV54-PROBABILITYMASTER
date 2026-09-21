/// Un caso profesional: escenario, decisión, justificación y supuestos.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/services/grading_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/content_text.dart';

class CaseDetailScreen extends ConsumerStatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  ConsumerState<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends ConsumerState<CaseDetailScreen> {
  int? _option;
  int? _justification;
  GradeResult? _result;

  @override
  Widget build(BuildContext context) {
    final content = ref.read(contentProvider);
    final c = content.caseById(widget.caseId);
    if (c == null) {
      return const Scaffold(body: Center(child: Text('Caso no encontrado')));
    }
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: c.title,
            subtitle: c.career,
            color: AppColors.rose,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                AppCard(
                  child: ContentText(c.scenario, figures: c.figures),
                ),
                if (c.data.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  AppCard(
                    background: scheme.primary.withValues(alpha: 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Datos', style: t.titleSmall),
                        const SizedBox(height: 8),
                        for (final d in c.data)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('· '),
                                Expanded(
                                  child: Text(d, style: t.bodyMedium),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(c.question, style: t.titleMedium),
                const SizedBox(height: 12),
                for (var i = 0; i < c.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _Option(
                      choice: c.options[i],
                      selected: _option == i,
                      revealed: _result != null,
                      color: AppColors.rose,
                      onTap: _result != null
                          ? null
                          : () => setState(() => _option = i),
                    ),
                  ),
                if (c.justifications.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text('Justificación (0,4 de la nota)',
                      style: t.titleSmall),
                  const SizedBox(height: 9),
                  for (var i = 0; i < c.justifications.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: _Option(
                        choice: c.justifications[i],
                        selected: _justification == i,
                        revealed: _result != null,
                        color: AppColors.teal,
                        onTap: _result != null
                            ? null
                            : () => setState(() => _justification = i),
                      ),
                    ),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 18),
                  NoticeBox(
                    _result!.feedback,
                    kind: _result!.choiceCorrect
                        ? NoticeKind.success
                        : NoticeKind.danger,
                    title: 'Tu decisión',
                  ),
                  if (_result!.justificationFeedback != null) ...[
                    const SizedBox(height: 10),
                    NoticeBox(
                      _result!.justificationFeedback!,
                      kind: _result!.justificationCorrect == true
                          ? NoticeKind.success
                          : NoticeKind.warning,
                      title: 'Tu justificación',
                    ),
                  ],
                  if (_result!.blindHit) ...[
                    const SizedBox(height: 10),
                    const NoticeBox(
                      'Decidiste bien por la razón equivocada. Con otros '
                      'números, ese mismo razonamiento te lleva a la decisión '
                      'contraria.',
                      kind: NoticeKind.warning,
                      title: 'Acierto ciego',
                    ),
                  ],
                  const SizedBox(height: 14),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resolución', style: t.titleSmall),
                        const SizedBox(height: 8),
                        ContentText(c.resolution, figures: c.figures),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    accent: AppColors.amber,
                    background: AppColors.amber.withValues(alpha: 0.07),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rule_folder_outlined,
                                size: 17, color: AppColors.amberDeep),
                            const SizedBox(width: 7),
                            Text('Supuestos y límites',
                                style: t.titleSmall
                                    ?.copyWith(color: AppColors.amberDeep)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ContentText(c.assumptions),
                      ],
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
                      color: AppColors.rose,
                      onPressed: (_option != null &&
                              (c.justifications.isEmpty ||
                                  _justification != null))
                          ? () async {
                              final r = ref.read(gradingProvider).gradeCase(
                                    c,
                                    optionIndex: _option!,
                                    justificationIndex: _justification,
                                  );
                              setState(() => _result = r);
                              await ref
                                  .read(progressProvider.notifier)
                                  .recordAttempt(
                                    r.toRecord(c.id, 'm4', DateTime.now()),
                                  );
                            }
                          : null,
                    )
                  : PrimaryButton(
                      'Volver a los casos',
                      icon: Icons.arrow_back,
                      color: AppColors.rose,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final Choice choice;
  final bool selected;
  final bool revealed;
  final Color color;
  final VoidCallback? onTap;

  const _Option({
    required this.choice,
    required this.selected,
    required this.revealed,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outline;
    Color bg = scheme.surfaceContainerHighest;
    if (revealed && choice.correct) {
      border = AppColors.success;
      bg = AppColors.success.withValues(alpha: 0.12);
    } else if (revealed && selected && !choice.correct) {
      border = AppColors.danger;
      bg = AppColors.danger.withValues(alpha: 0.12);
    } else if (selected) {
      border = color;
      bg = color.withValues(alpha: 0.12);
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
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
                revealed && choice.correct
                    ? Icons.check_circle
                    : selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                size: 19,
                color: revealed && choice.correct
                    ? AppColors.success
                    : selected
                        ? color
                        : scheme.outline,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(choice.text,
                        style: Theme.of(context).textTheme.bodyMedium),
                    if (revealed && (selected || choice.correct)) ...[
                      const SizedBox(height: 7),
                      Text(
                        choice.feedback,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
