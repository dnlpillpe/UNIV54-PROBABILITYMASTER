/// Paleta de Probability Master.
///
/// La temática no es decorativa: cada color tiene un significado fijo en toda
/// la app, y el estudiante lo aprende sin que se lo digan.
///
///  · **Índigo** — lo teórico, lo exacto, la fórmula.
///  · **Turquesa** — lo observado, lo simulado, la frecuencia relativa.
///  · **Ámbar** — el azar en bruto: dados, monedas, urnas, sorteos.
///  · **Rosa** — el evento B en los diagramas (A siempre es índigo).
///  · **Rojo** — la confusión detectada; nunca «respuesta incorrecta» a secas.
///
/// El contraste entre índigo (teórico) y turquesa (observado) es el par que
/// aparece en todos los gráficos de convergencia: la línea de la fórmula y la
/// línea de lo que realmente pasó.
library;

import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // --- Marca ---------------------------------------------------------
  static const Color indigo = Color(0xFF4B3FD6);
  static const Color indigoDeep = Color(0xFF2D2496);
  static const Color indigoSoft = Color(0xFFE8E6FB);

  static const Color teal = Color(0xFF12A594);
  static const Color tealDeep = Color(0xFF0B6F64);
  static const Color tealSoft = Color(0xFFDCF3F0);

  static const Color amber = Color(0xFFE9A13B);
  static const Color amberDeep = Color(0xFFB0741D);
  static const Color amberSoft = Color(0xFFFBEEDA);

  static const Color rose = Color(0xFFDD5C82);
  static const Color roseDeep = Color(0xFF9E2F52);
  static const Color roseSoft = Color(0xFFFBE4EB);

  // --- Semánticos ----------------------------------------------------
  static const Color success = Color(0xFF2E9E6B);
  static const Color successSoft = Color(0xFFE0F3E9);
  static const Color warning = Color(0xFFDC8A21);
  static const Color warningSoft = Color(0xFFFCEFDC);
  static const Color danger = Color(0xFFD1445C);
  static const Color dangerSoft = Color(0xFFFBE3E7);

  // --- Superficies (claro) -------------------------------------------
  static const Color lightBg = Color(0xFFF6F6FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E1F0);
  static const Color lightText = Color(0xFF1A1830);
  static const Color lightTextSoft = Color(0xFF5B5A73);

  // --- Superficies (oscuro) ------------------------------------------
  static const Color darkBg = Color(0xFF13121D);
  static const Color darkCard = Color(0xFF1D1B2B);
  static const Color darkBorder = Color(0xFF2E2C41);
  static const Color darkText = Color(0xFFF2F1F8);
  static const Color darkTextSoft = Color(0xFFA6A4BC);

  /// Color de cada módulo, en orden.
  static const List<Color> moduleColors = [indigo, teal, amber, rose];
  static const List<Color> moduleSoft = [
    indigoSoft,
    tealSoft,
    amberSoft,
    roseSoft
  ];
  static const List<Color> moduleDeep = [
    indigoDeep,
    tealDeep,
    amberDeep,
    roseDeep
  ];

  static Color module(int index) => moduleColors[index % moduleColors.length];
  static Color moduleTint(int index) => moduleSoft[index % moduleSoft.length];
  static Color moduleStrong(int index) => moduleDeep[index % moduleDeep.length];

  /// Serie de categorías para histogramas de más de cuatro barras.
  static const List<Color> series = [
    indigo,
    teal,
    amber,
    rose,
    Color(0xFF7A6CF0),
    Color(0xFF3FBFAF),
    Color(0xFFF0BE6A),
    Color(0xFFE88BA6),
  ];

  static Color seriesAt(int i) => series[i % series.length];

  /// Significado fijo en los gráficos.
  static const Color theoretical = indigo;
  static const Color observed = teal;
}
