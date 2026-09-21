/// Glosario con buscador y filtro por módulo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../widgets/app_widgets.dart';

class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final TextEditingController _search = TextEditingController();
  String? _moduleFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.read(contentProvider);
    final query = _search.text.trim().toLowerCase();
    final terms = content.glossary.where((g) {
      final matchesModule =
          _moduleFilter == null || g.moduleId == _moduleFilter;
      final matchesQuery = query.isEmpty ||
          g.term.toLowerCase().contains(query) ||
          g.definition.toLowerCase().contains(query);
      return matchesModule && matchesQuery;
    }).toList();
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          ScreenHeader(
            title: 'Glosario',
            subtitle: '${content.glossaryCount} términos, con su error '
                'frecuente cuando lo tienen',
            color: AppColors.teal,
            onBack: () => Navigator.of(context).pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar término o definición',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 7, top: 6),
                  child: ChoiceChip(
                    label: const Text('Todos'),
                    selected: _moduleFilter == null,
                    onSelected: (_) => setState(() => _moduleFilter = null),
                  ),
                ),
                for (final m in content.modules)
                  Padding(
                    padding: const EdgeInsets.only(right: 7, top: 6),
                    child: ChoiceChip(
                      label: Text(m.name),
                      selected: _moduleFilter == m.id,
                      onSelected: (_) =>
                          setState(() => _moduleFilter = m.id),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: terms.isEmpty
                ? Center(
                    child: Text('Sin resultados', style: t.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                    itemCount: terms.length,
                    itemBuilder: (context, i) {
                      final g = terms[i];
                      final module = content.module(g.moduleId);
                      final color = module == null
                          ? AppColors.teal
                          : AppColors.module(module.colorIndex);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(g.term, style: t.titleSmall),
                                  ),
                                  if (module != null)
                                    Pill(module.name, color: color),
                                ],
                              ),
                              if (g.notation != null) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    g.notation!,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontFamilyFallback: const [
                                        'Courier',
                                        'monospace'
                                      ],
                                      fontSize: 12.5,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 7),
                              Text(g.definition, style: t.bodyMedium),
                              if (g.caution != null) ...[
                                const SizedBox(height: 9),
                                NoticeBox(
                                  g.caution!,
                                  kind: NoticeKind.warning,
                                  title: 'Cuidado',
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
