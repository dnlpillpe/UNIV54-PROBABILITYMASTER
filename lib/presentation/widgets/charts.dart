/// Envoltorios de los pintores, con leyenda y etiquetas.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../painters/chart_painters.dart';

/// Gráfico de convergencia observado vs. teórico.
class ConvergenceChart extends StatelessWidget {
  final List<Offset> points;
  final double theoretical;
  final double height;
  final String observedLabel;
  final String theoreticalLabel;

  const ConvergenceChart({
    super.key,
    required this.points,
    required this.theoretical,
    this.height = 190,
    this.observedLabel = 'Frecuencia observada',
    this.theoreticalLabel = 'Probabilidad teórica',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: ConvergencePainter(
              points: points,
              theoretical: theoretical,
              observedColor: AppColors.observed,
              theoreticalColor: AppColors.theoretical,
              gridColor: scheme.outline,
              textColor: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            _LegendDot(color: AppColors.observed, label: observedLabel),
            _LegendDot(
              color: AppColors.theoretical,
              label: '$theoreticalLabel (${Fmt.decimal(theoretical, digits: 4)})',
              dashed: true,
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Eje horizontal en escala logarítmica. La banda es ±2 errores '
          'estándar: se estrecha con √n.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;

  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: dashed ? 2.5 : 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Histograma de categorías con marca del valor teórico.
class CategoryChart extends StatelessWidget {
  final List<BarDatum> bars;
  final double height;
  final String? caption;

  const CategoryChart({
    super.key,
    required this.bars,
    this.height = 170,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var maxV = 0.0;
    for (final b in bars) {
      if (b.value > maxV) maxV = b.value;
      if (b.reference != null && b.reference! > maxV) maxV = b.reference!;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: HistogramPainter(
              bars: bars,
              maxValue: maxV * 1.12,
              gridColor: scheme.outline,
              textColor: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (caption != null) ...[
          const SizedBox(height: 6),
          Text(caption!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

/// Diagrama de Venn de dos eventos.
class VennChart extends StatelessWidget {
  final int onlyA;
  final int both;
  final int onlyB;
  final int neither;
  final String labelA;
  final String labelB;
  final String highlight;
  final double height;

  const VennChart({
    super.key,
    required this.onlyA,
    required this.both,
    required this.onlyB,
    required this.neither,
    this.labelA = 'A',
    this.labelB = 'B',
    this.highlight = 'none',
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: VennPainter(
          onlyA: onlyA,
          both: both,
          onlyB: onlyB,
          neither: neither,
          labelA: labelA,
          labelB: labelB,
          highlight: highlight,
          textColor: scheme.onSurface,
          frameColor: scheme.outline,
        ),
      ),
    );
  }
}

/// Árbol de probabilidad de dos niveles.
class TreeChart extends StatelessWidget {
  final List<TreeNode> roots;
  final double height;
  final List<int>? highlightPath;

  const TreeChart({
    super.key,
    required this.roots,
    this.height = 200,
    this.highlightPath,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: TreePainter(
          roots: roots,
          textColor: scheme.onSurface,
          lineColor: scheme.outline,
          highlightPath: highlightPath,
        ),
      ),
    );
  }
}

/// Anillo de dominio.
class MasteryRing extends StatelessWidget {
  final double value;
  final Color color;
  final double size;
  final String? centerLabel;

  const MasteryRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 64,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: MasteryRingPainter(
              value: value,
              color: color,
              trackColor: scheme.outline,
            ),
          ),
          Text(
            centerLabel ?? '${(value * 100).round()}%',
            style: TextStyle(
              fontSize: size * 0.24,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
