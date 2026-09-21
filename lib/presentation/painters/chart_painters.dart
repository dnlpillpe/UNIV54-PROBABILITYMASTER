/// Pintores de los gráficos de la app.
///
/// No se usa ninguna librería de gráficos (Fase 5 del análisis): los
/// laboratorios necesitan geometría expuesta —resaltar 6 celdas de 36,
/// sombrear exactamente la intersección de dos círculos, dibujar un árbol con
/// las probabilidades en las ramas— y eso una librería genérica no lo da.
///
/// Convención de color fija en toda la app: **índigo = valor teórico**,
/// **turquesa = valor observado**.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

TextPainter _label(String text, TextStyle style, {double maxWidth = 200}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  return tp;
}

/// Gráfico de convergencia: la frecuencia relativa observada frente a la
/// probabilidad teórica, en escala logarítmica de ensayos.
class ConvergencePainter extends CustomPainter {
  /// Pares (ensayos, frecuencia relativa).
  final List<Offset> points;
  final double theoretical;
  final Color observedColor;
  final Color theoreticalColor;
  final Color gridColor;
  final Color textColor;

  /// Banda de ±2 errores estándar alrededor del valor teórico. Es lo que
  /// convierte «se acerca» en algo comprobable.
  final bool showBand;

  const ConvergencePainter({
    required this.points,
    required this.theoretical,
    required this.observedColor,
    required this.theoreticalColor,
    required this.gridColor,
    required this.textColor,
    this.showBand = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const bottom = 22.0;
    const top = 8.0;
    final plot = Rect.fromLTRB(left, top, size.width - 6, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) return;

    final maxTrials = points.isEmpty
        ? 1.0
        : points.map((p) => p.dx).reduce(math.max).clamp(1.0, double.infinity);
    final logMax = math.log(math.max(maxTrials, 10)) / math.ln10;

    double xOf(double trials) {
      final t = math.log(math.max(trials, 1)) / math.ln10;
      return plot.left + plot.width * (t / logMax).clamp(0.0, 1.0);
    }

    double yOf(double freq) =>
        plot.bottom - plot.height * freq.clamp(0.0, 1.0);

    // Rejilla horizontal.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final v = i / 4;
      final y = yOf(v);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      final tp = _label(
        v.toStringAsFixed(2).replaceAll('.', ','),
        TextStyle(fontSize: 10, color: textColor),
      );
      tp.paint(canvas, Offset(plot.left - tp.width - 5, y - tp.height / 2));
    }

    // Banda de ±2 EE.
    if (showBand && points.isNotEmpty) {
      final band = Path();
      final back = <Offset>[];
      for (var i = 0; i < points.length; i++) {
        final n = math.max(points[i].dx, 1.0);
        final se = math.sqrt(theoretical * (1 - theoretical) / n);
        final hi = yOf(theoretical + 2 * se);
        final lo = yOf(theoretical - 2 * se);
        final x = xOf(n);
        if (i == 0) {
          band.moveTo(x, hi);
        } else {
          band.lineTo(x, hi);
        }
        back.add(Offset(x, lo));
      }
      for (var i = back.length - 1; i >= 0; i--) {
        band.lineTo(back[i].dx, back[i].dy);
      }
      band.close();
      canvas.drawPath(
        band,
        Paint()..color = theoreticalColor.withValues(alpha: 0.10),
      );
    }

    // Línea teórica.
    final yT = yOf(theoretical);
    final dash = Paint()
      ..color = theoreticalColor
      ..strokeWidth = 2;
    for (var x = plot.left; x < plot.right; x += 10) {
      canvas.drawLine(
          Offset(x, yT), Offset(math.min(x + 5, plot.right), yT), dash);
    }

    // Serie observada.
    if (points.length > 1) {
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final o = Offset(xOf(points[i].dx), yOf(points[i].dy));
        if (i == 0) {
          path.moveTo(o.dx, o.dy);
        } else {
          path.lineTo(o.dx, o.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = observedColor,
      );
      final last = points.last;
      canvas.drawCircle(
        Offset(xOf(last.dx), yOf(last.dy)),
        4,
        Paint()..color = observedColor,
      );
    }

    // Eje x logarítmico con marcas en potencias de 10.
    for (var e = 0; e <= logMax.ceil(); e++) {
      final v = math.pow(10, e).toDouble();
      if (v > maxTrials * 1.5) break;
      final x = xOf(v);
      final tp = _label(
        v >= 1000 ? '${(v / 1000).round()}k' : v.round().toString(),
        TextStyle(fontSize: 10, color: textColor),
      );
      tp.paint(canvas, Offset(x - tp.width / 2, plot.bottom + 5));
    }
  }

  @override
  bool shouldRepaint(covariant ConvergencePainter old) =>
      old.points != points || old.theoretical != theoretical;
}

/// Barra de una serie categórica.
class BarDatum {
  final String label;
  final double value;
  final double? reference;
  final Color color;

  const BarDatum(this.label, this.value, this.color, {this.reference});
}

/// Histograma vertical con marca de valor teórico por barra.
class HistogramPainter extends CustomPainter {
  final List<BarDatum> bars;
  final double maxValue;
  final Color gridColor;
  final Color textColor;
  final Color referenceColor;
  final bool showReference;

  const HistogramPainter({
    required this.bars,
    required this.maxValue,
    required this.gridColor,
    required this.textColor,
    this.referenceColor = AppColors.theoretical,
    this.showReference = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    const bottom = 20.0;
    final plot = Rect.fromLTRB(2, 6, size.width - 2, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) return;
    final slot = plot.width / bars.length;
    final barW = math.min(slot * 0.68, 46.0);
    final scale = maxValue <= 0 ? 1.0 : maxValue;

    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      Paint()
        ..color = gridColor
        ..strokeWidth = 1,
    );

    for (var i = 0; i < bars.length; i++) {
      final b = bars[i];
      final cx = plot.left + slot * (i + 0.5);
      final h = (b.value / scale).clamp(0.0, 1.0) * plot.height;
      final rect = Rect.fromLTWH(cx - barW / 2, plot.bottom - h, barW, h);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        ),
        Paint()..color = b.color,
      );
      if (showReference && b.reference != null) {
        final y =
            plot.bottom - (b.reference! / scale).clamp(0.0, 1.0) * plot.height;
        canvas.drawLine(
          Offset(cx - barW / 2 - 3, y),
          Offset(cx + barW / 2 + 3, y),
          Paint()
            ..color = referenceColor
            ..strokeWidth = 2.2,
        );
      }
      final tp = _label(
        b.label,
        TextStyle(fontSize: 10, color: textColor),
        maxWidth: slot,
      );
      tp.paint(canvas, Offset(cx - tp.width / 2, plot.bottom + 4));
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter old) =>
      old.bars != bars || old.maxValue != maxValue;
}

/// Diagrama de Venn de dos eventos, con las cuatro regiones etiquetadas.
class VennPainter extends CustomPainter {
  /// Conteos de las cuatro regiones.
  final int onlyA;
  final int both;
  final int onlyB;
  final int neither;
  final String labelA;
  final String labelB;

  /// Región resaltada: 'A', 'B', 'AB', 'union', 'none' o 'all'.
  final String highlight;
  final Color textColor;
  final Color frameColor;

  const VennPainter({
    required this.onlyA,
    required this.both,
    required this.onlyB,
    required this.neither,
    required this.textColor,
    required this.frameColor,
    this.labelA = 'A',
    this.labelB = 'B',
    this.highlight = 'none',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frame = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(frame, const Radius.circular(10)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = frameColor,
    );

    final r = math.min(size.width * 0.27, size.height * 0.36);
    final cy = size.height * 0.52;
    final ca = Offset(size.width * 0.38, cy);
    final cb = Offset(size.width * 0.62, cy);
    final pathA = Path()..addOval(Rect.fromCircle(center: ca, radius: r));
    final pathB = Path()..addOval(Rect.fromCircle(center: cb, radius: r));
    final inter = Path.combine(PathOperation.intersect, pathA, pathB);
    final union = Path.combine(PathOperation.union, pathA, pathB);

    void fill(Path p, Color c) => canvas.drawPath(p, Paint()..color = c);

    switch (highlight) {
      case 'A':
        fill(pathA, AppColors.indigo.withValues(alpha: 0.30));
        break;
      case 'B':
        fill(pathB, AppColors.rose.withValues(alpha: 0.30));
        break;
      case 'AB':
        fill(inter, AppColors.amber.withValues(alpha: 0.55));
        break;
      case 'union':
        fill(union, AppColors.teal.withValues(alpha: 0.28));
        break;
      case 'all':
        fill(
          Path()
            ..addRRect(RRect.fromRectAndRadius(
                frame, const Radius.circular(10))),
          AppColors.teal.withValues(alpha: 0.16),
        );
        break;
      case 'none':
        final outside = Path.combine(
          PathOperation.difference,
          Path()
            ..addRRect(
                RRect.fromRectAndRadius(frame, const Radius.circular(10))),
          union,
        );
        fill(outside, AppColors.teal.withValues(alpha: 0.22));
        break;
    }

    canvas.drawPath(
      pathA,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.indigo,
    );
    canvas.drawPath(
      pathB,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.rose,
    );

    void text(String s, Offset at, {FontWeight w = FontWeight.w600, Color? c}) {
      final tp = _label(
        s,
        TextStyle(fontSize: 12, fontWeight: w, color: c ?? textColor),
      );
      tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
    }

    text('$onlyA', Offset(ca.dx - r * 0.55, cy));
    text('$both', Offset((ca.dx + cb.dx) / 2, cy));
    text('$onlyB', Offset(cb.dx + r * 0.55, cy));
    text('$neither', Offset(size.width * 0.09, size.height * 0.12),
        w: FontWeight.w400);
    text(labelA, Offset(ca.dx - r * 0.75, cy - r * 0.95),
        c: AppColors.indigo);
    text(labelB, Offset(cb.dx + r * 0.75, cy - r * 0.95), c: AppColors.rose);
  }

  @override
  bool shouldRepaint(covariant VennPainter old) =>
      old.onlyA != onlyA ||
      old.both != both ||
      old.onlyB != onlyB ||
      old.neither != neither ||
      old.highlight != highlight;
}

/// Un nodo del árbol de probabilidad.
class TreeNode {
  final String label;
  final String branchLabel;
  final double probability;
  final List<TreeNode> children;
  final Color color;

  const TreeNode({
    required this.label,
    required this.probability,
    this.branchLabel = '',
    this.children = const [],
    this.color = AppColors.indigo,
  });
}

/// Árbol de probabilidad de dos niveles: el dibujo que hace visible la regla
/// del producto y la diferencia entre con y sin reposición.
class TreePainter extends CustomPainter {
  final List<TreeNode> roots;
  final Color textColor;
  final Color lineColor;

  /// Índice de la rama resaltada (camino completo), o `null`.
  final List<int>? highlightPath;

  const TreePainter({
    required this.roots,
    required this.textColor,
    required this.lineColor,
    this.highlightPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (roots.isEmpty) return;
    final leafCount = roots.fold<int>(
        0, (a, r) => a + (r.children.isEmpty ? 1 : r.children.length));
    if (leafCount == 0) return;
    final rowH = size.height / leafCount;
    final x0 = 12.0;
    final x1 = size.width * 0.40;
    final x2 = size.width * 0.78;

    var leafIndex = 0;
    final rootY = <double>[];
    for (final r in roots) {
      final n = r.children.isEmpty ? 1 : r.children.length;
      rootY.add(rowH * (leafIndex + n / 2));
      leafIndex += n;
    }

    canvas.drawCircle(
      Offset(x0, size.height / 2),
      4,
      Paint()..color = lineColor,
    );

    leafIndex = 0;
    for (var i = 0; i < roots.length; i++) {
      final r = roots[i];
      final y = rootY[i];
      final selected = highlightPath != null && highlightPath!.first == i;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3 : 1.6
        ..color = selected ? r.color : lineColor;
      canvas.drawLine(Offset(x0, size.height / 2), Offset(x1, y), paint);
      _branchText(canvas, r.branchLabel.isEmpty ? _fmt(r.probability) : r.branchLabel,
          Offset((x0 + x1) / 2, (size.height / 2 + y) / 2 - 9), r.color);
      _nodeText(canvas, r.label, Offset(x1 + 4, y), r.color);

      final kids = r.children;
      if (kids.isEmpty) {
        leafIndex++;
        continue;
      }
      for (var j = 0; j < kids.length; j++) {
        final k = kids[j];
        final ky = rowH * (leafIndex + 0.5);
        final sel = selected &&
            highlightPath!.length > 1 &&
            highlightPath![1] == j;
        canvas.drawLine(
          Offset(x1 + 26, y),
          Offset(x2, ky),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = sel ? 3 : 1.6
            ..color = sel ? k.color : lineColor,
        );
        _branchText(
          canvas,
          k.branchLabel.isEmpty ? _fmt(k.probability) : k.branchLabel,
          Offset((x1 + 26 + x2) / 2, (y + ky) / 2 - 9),
          k.color,
        );
        _nodeText(canvas, k.label, Offset(x2 + 4, ky), k.color);
        leafIndex++;
      }
    }
  }

  static String _fmt(double p) =>
      p.toStringAsFixed(p == p.roundToDouble() ? 0 : 3).replaceAll('.', ',');

  void _branchText(Canvas canvas, String s, Offset at, Color c) {
    final tp = _label(s, TextStyle(fontSize: 10.5, color: c));
    tp.paint(canvas, at - Offset(tp.width / 2, 0));
  }

  void _nodeText(Canvas canvas, String s, Offset at, Color c) {
    final tp = _label(
      s,
      TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor),
      maxWidth: 110,
    );
    tp.paint(canvas, at - Offset(0, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant TreePainter old) =>
      old.roots != roots || old.highlightPath != highlightPath;
}

/// Anillo de progreso con el umbral de competencia marcado.
class MasteryRingPainter extends CustomPainter {
  final double value;
  final double threshold;
  final Color color;
  final Color trackColor;
  final Color thresholdColor;

  const MasteryRingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    this.threshold = 0.70,
    this.thresholdColor = AppColors.amber,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: s - 8,
      height: s - 8,
    );
    const start = -math.pi / 2;
    canvas.drawArc(
      rect,
      start,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = trackColor,
    );
    canvas.drawArc(
      rect,
      start,
      math.pi * 2 * value.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7
        ..color = color,
    );
    final a = start + math.pi * 2 * threshold;
    final r = rect.width / 2;
    final c = rect.center;
    canvas.drawLine(
      c + Offset(math.cos(a) * (r - 7), math.sin(a) * (r - 7)),
      c + Offset(math.cos(a) * (r + 4), math.sin(a) * (r + 4)),
      Paint()
        ..strokeWidth = 2.4
        ..color = thresholdColor,
    );
  }

  @override
  bool shouldRepaint(covariant MasteryRingPainter old) =>
      old.value != value || old.color != color;
}
