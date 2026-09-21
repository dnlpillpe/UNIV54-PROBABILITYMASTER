/// Renderizador del contenido educativo.
///
/// El contenido usa un subconjunto mínimo de marcas: `**negrita**`, listas
/// con `•` o `-`, bloques entre triples comillas invertidas, tablas con `|`
/// y **fichas numéricas** `{{id}}`, que se sustituyen por el valor calculado
/// por el motor en tiempo de ejecución (decisión D5).
///
/// No se usa un paquete de Markdown: el subconjunto es pequeño, y así el
/// proyecto mantiene dos dependencias de producción.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/math/figure_registry.dart';

/// Sustituye las fichas `{{id}}` de un texto por su valor calculado.
String fillFigures(String source, List<ContentFigure> figures) {
  if (figures.isEmpty || !source.contains('{{')) return source;
  var out = source;
  for (final f in figures) {
    if (!out.contains('{{${f.id}}}')) continue;
    String value;
    try {
      value = FigureRegistry.render(f);
    } catch (_) {
      value = '—';
    }
    out = out.replaceAll('{{${f.id}}}', value);
  }
  return out;
}

class ContentText extends StatelessWidget {
  final String text;
  final List<ContentFigure> figures;
  final TextStyle? style;

  const ContentText(
    this.text, {
    super.key,
    this.figures = const [],
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium!;
    final filled = fillFigures(text, figures);
    final blocks = _parseBlocks(filled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildBlock(context, blocks[i], base),
        ],
      ],
    );
  }

  Widget _buildBlock(BuildContext context, _Block b, TextStyle base) {
    final scheme = Theme.of(context).colorScheme;
    switch (b.kind) {
      case _BlockKind.code:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheme.outline),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              b.lines.join('\n'),
              style: TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Courier', 'monospace'],
                fontSize: 12.5,
                height: 1.5,
                color: scheme.onSurface,
              ),
            ),
          ),
        );
      case _BlockKind.bullets:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final line in b.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: _spans(line, base),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case _BlockKind.paragraph:
        return RichText(text: _spans(b.lines.join('\n'), base));
    }
  }

  TextSpan _spans(String source, TextStyle base) {
    final children = <TextSpan>[];
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    var buffer = StringBuffer();
    var isBold = false;
    var i = 0;
    while (i < source.length) {
      if (i + 1 < source.length &&
          source[i] == '*' &&
          source[i + 1] == '*') {
        children.add(TextSpan(
          text: buffer.toString(),
          style: isBold ? bold : base,
        ));
        buffer = StringBuffer();
        isBold = !isBold;
        i += 2;
        continue;
      }
      buffer.write(source[i]);
      i++;
    }
    children.add(
      TextSpan(text: buffer.toString(), style: isBold ? bold : base),
    );
    return TextSpan(children: children);
  }

  static List<_Block> _parseBlocks(String source) {
    final lines = source.split('\n');
    final blocks = <_Block>[];
    var current = <String>[];
    var kind = _BlockKind.paragraph;
    var inCode = false;

    void flush() {
      if (current.isEmpty) return;
      blocks.add(_Block(kind, List<String>.from(current)));
      current = [];
      kind = _BlockKind.paragraph;
    }

    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().startsWith('```')) {
        if (inCode) {
          flush();
          inCode = false;
        } else {
          flush();
          inCode = true;
          kind = _BlockKind.code;
        }
        continue;
      }
      if (inCode) {
        current.add(raw);
        continue;
      }
      if (line.trim().isEmpty) {
        flush();
        continue;
      }
      final trimmed = line.trimLeft();
      final isBullet = trimmed.startsWith('• ') || trimmed.startsWith('- ');
      final isTable = trimmed.startsWith('|');
      if (isTable) {
        if (kind != _BlockKind.code) {
          flush();
          kind = _BlockKind.code;
        }
        current.add(trimmed);
        continue;
      }
      if (isBullet) {
        if (kind != _BlockKind.bullets) {
          flush();
          kind = _BlockKind.bullets;
        }
        current.add(trimmed.substring(2).trim());
        continue;
      }
      if (kind == _BlockKind.bullets || kind == _BlockKind.code) {
        flush();
      }
      if (current.isEmpty) {
        current.add(line);
      } else {
        current[current.length - 1] = '${current.last} ${line.trimLeft()}';
      }
    }
    flush();
    return blocks;
  }
}

enum _BlockKind { paragraph, bullets, code }

class _Block {
  final _BlockKind kind;
  final List<String> lines;
  const _Block(this.kind, this.lines);
}

/// Muestra una probabilidad en sus tres formas, con la tipografía de cifras
/// de la app.
class TripleValue extends StatelessWidget {
  final String fraction;
  final String decimal;
  final String percent;
  final Color? color;

  const TripleValue({
    super.key,
    required this.fraction,
    required this.decimal,
    required this.percent,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = color ?? scheme.primary;
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          fraction,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: c,
            height: 1.1,
          ),
        ),
        Text('=', style: TextStyle(color: scheme.onSurfaceVariant)),
        Text(decimal,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            )),
        Text('=', style: TextStyle(color: scheme.onSurfaceVariant)),
        Text(percent,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.teal,
            )),
      ],
    );
  }
}
