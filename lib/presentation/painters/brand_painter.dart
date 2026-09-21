/// La marca de Probability Master, dibujada con código.
///
/// El mismo dibujo lo reproduce `tool/generate_icon.py` en Pillow para
/// producir el icono de la app: así el icono de la tienda y el logo de la
/// pantalla de inicio no pueden divergir.
///
/// Composición, y por qué: un **dado blanco** (el azar en bruto, lo que el
/// estudiante manipula) sobre una **curva turquesa que oscila y se estabiliza**
/// (la ley de los grandes números, la idea que ordena toda la app), en un
/// fondo índigo (lo teórico). Los tres colores de la paleta dicen, en un solo
/// gráfico, de qué trata el producto.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Dibuja una cara de dado con sus puntos.
void paintDieFace(
  Canvas canvas,
  Rect rect,
  int value, {
  Color face = Colors.white,
  Color pip = AppColors.indigoDeep,
  double radiusFactor = 0.22,
  Color? border,
}) {
  final rrect = RRect.fromRectAndRadius(
    rect,
    Radius.circular(rect.width * radiusFactor),
  );
  canvas.drawRRect(rrect, Paint()..color = face);
  if (border != null) {
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rect.width * 0.035
        ..color = border,
    );
  }
  final r = rect.width * 0.085;
  final pipPaint = Paint()..color = pip;
  final cx = rect.center.dx;
  final cy = rect.center.dy;
  final dx = rect.width * 0.24;
  final dy = rect.height * 0.24;

  void dot(double x, double y) =>
      canvas.drawCircle(Offset(x, y), r, pipPaint);

  switch (value) {
    case 1:
      dot(cx, cy);
      break;
    case 2:
      dot(cx - dx, cy - dy);
      dot(cx + dx, cy + dy);
      break;
    case 3:
      dot(cx - dx, cy - dy);
      dot(cx, cy);
      dot(cx + dx, cy + dy);
      break;
    case 4:
      dot(cx - dx, cy - dy);
      dot(cx + dx, cy - dy);
      dot(cx - dx, cy + dy);
      dot(cx + dx, cy + dy);
      break;
    case 5:
      dot(cx - dx, cy - dy);
      dot(cx + dx, cy - dy);
      dot(cx, cy);
      dot(cx - dx, cy + dy);
      dot(cx + dx, cy + dy);
      break;
    default:
      dot(cx - dx, cy - dy);
      dot(cx + dx, cy - dy);
      dot(cx - dx, cy);
      dot(cx + dx, cy);
      dot(cx - dx, cy + dy);
      dot(cx + dx, cy + dy);
  }
}

/// Curva de convergencia decorativa: oscila fuerte al principio y se aplana.
Path convergencePath(Size size, {double amplitude = 0.42, int waves = 6}) {
  final path = Path();
  final mid = size.height * 0.5;
  for (var i = 0; i <= 120; i++) {
    final t = i / 120;
    final decay = math.exp(-3.1 * t);
    final y = mid -
        math.sin(t * waves * math.pi) * size.height * amplitude * decay;
    final x = t * size.width;
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  return path;
}

/// El logotipo completo.
class BrandPainter extends CustomPainter {
  final bool withBackground;
  final double dieTurns;

  const BrandPainter({this.withBackground = true, this.dieTurns = -0.055});

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final rect = Rect.fromLTWH((size.width - s) / 2, (size.height - s) / 2, s, s);

    if (withBackground) {
      final bg = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.235));
      canvas.drawRRect(
        bg,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B4BEA), AppColors.indigoDeep],
          ).createShader(rect),
      );
      canvas.save();
      canvas.clipRRect(bg);
    }

    // Curva de convergencia, en turquesa, en la mitad inferior.
    final curveRect = Rect.fromLTWH(
      rect.left + s * 0.06,
      rect.top + s * 0.50,
      s * 0.88,
      s * 0.36,
    );
    canvas.save();
    canvas.translate(curveRect.left, curveRect.top);
    final path = convergencePath(curveRect.size, amplitude: 0.46, waves: 7);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.048
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.teal,
    );
    // Línea teórica a la que converge.
    canvas.drawLine(
      Offset(0, curveRect.height * 0.5),
      Offset(curveRect.width, curveRect.height * 0.5),
      Paint()
        ..strokeWidth = s * 0.016
        ..color = Colors.white.withValues(alpha: 0.45),
    );
    // Punto ámbar al final de la curva: el valor al que se estabiliza.
    canvas.drawCircle(
      Offset(curveRect.width, curveRect.height * 0.5),
      s * 0.042,
      Paint()..color = AppColors.amber,
    );
    canvas.restore();

    // Dado blanco, ligeramente girado.
    final dieSize = s * 0.46;
    final dieCenter = Offset(rect.center.dx - s * 0.02, rect.top + s * 0.345);
    canvas.save();
    canvas.translate(dieCenter.dx, dieCenter.dy);
    canvas.rotate(dieTurns * 2 * math.pi);
    final dieRect = Rect.fromCenter(
      center: Offset.zero,
      width: dieSize,
      height: dieSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        dieRect.translate(0, dieSize * 0.06),
        Radius.circular(dieSize * 0.22),
      ),
      Paint()
        ..color = AppColors.indigoDeep.withValues(alpha: 0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, dieSize * 0.06),
    );
    paintDieFace(canvas, dieRect, 5);
    canvas.restore();

    if (withBackground) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BrandPainter oldDelegate) =>
      oldDelegate.withBackground != withBackground ||
      oldDelegate.dieTurns != dieTurns;
}

/// Widget listo para usar.
class BrandMark extends StatelessWidget {
  final double size;
  final bool withBackground;

  const BrandMark({super.key, this.size = 72, this.withBackground = true});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: BrandPainter(withBackground: withBackground),
        ),
      );
}

/// Un dado suelto, usado como viñeta en listas y encabezados.
class DieIcon extends StatelessWidget {
  final int value;
  final double size;
  final Color? face;
  final Color? pip;

  const DieIcon({
    super.key,
    required this.value,
    this.size = 28,
    this.face,
    this.pip,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiePainter(
          value: value,
          face: face ?? scheme.surfaceContainerHighest,
          pip: pip ?? scheme.primary,
        ),
      ),
    );
  }
}

class _DiePainter extends CustomPainter {
  final int value;
  final Color face;
  final Color pip;

  const _DiePainter({
    required this.value,
    required this.face,
    required this.pip,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintDieFace(
      canvas,
      Offset.zero & size,
      value,
      face: face,
      pip: pip,
      border: pip.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _DiePainter old) =>
      old.value != value || old.face != face || old.pip != pip;
}
