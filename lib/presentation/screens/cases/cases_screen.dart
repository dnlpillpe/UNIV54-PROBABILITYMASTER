/// Casos profesionales, ordenados por la carrera elegida.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';
import 'case_detail_screen.dart';

class CasesScreen extends ConsumerWidget {
  const CasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.read(contentProvider);
    final progress = ref.watch(progressProvider);
    final cases = content.casesFor(progress.career);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Casos profesionales',
            subtitle: '${cases.length} casos · elección 0,6 + justificación 0,4',
            color: AppColors.rose,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu carrera', style: t.titleSmall),
                      const SizedBox(height: 4),
                      Text(
                        'Ordena los casos poniendo primero los de tu área. '
                        'Los demás siguen disponibles: son el mejor '
                        'entrenamiento de transferencia.',
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: progress.career,
                        hint: const Text('Selecciona tu carrera'),
                        items: [
                          for (final c in AppInfo.careers)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (v) =>
                            ref.read(progressProvider.notifier).setCareer(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final c in cases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: AppCard(
                      accent: c.career == progress.career
                          ? AppColors.rose
                          : null,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CaseDetailScreen(caseId: c.id),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Pill(c.career, color: AppColors.rose),
                              ),
                              if (progress.bestAttempts[c.id] != null)
                                Pill(
                                  '${(progress.bestAttempts[c.id]!.score * 100).round()} %',
                                  color: progress.bestAttempts[c.id]!.score >=
                                          0.99
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Text(c.title, style: t.titleMedium),
                          const SizedBox(height: 5),
                          Text(
                            c.question,
                            style: t.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
