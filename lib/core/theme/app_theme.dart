/// Tema claro y oscuro.
///
/// Se construye deliberadamente con `ColorScheme` + `TextTheme` y nada más:
/// las clases de tema por componente (`AppBarTheme`, `CardTheme`,
/// `InputDecorationTheme`, `TabBarTheme`) han cambiado de nombre entre
/// versiones de Flutter y romperían la compilación en CI. Los componentes se
/// estilizan en su propio widget, donde además se lee mejor.
library;

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.indigo,
      onPrimary: Colors.white,
      primaryContainer: AppColors.indigoSoft,
      onPrimaryContainer: AppColors.indigoDeep,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.tealSoft,
      onSecondaryContainer: AppColors.tealDeep,
      tertiary: AppColors.amber,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.amberSoft,
      onTertiaryContainer: AppColors.amberDeep,
      error: AppColors.danger,
      onError: Colors.white,
      errorContainer: AppColors.dangerSoft,
      onErrorContainer: Color(0xFF7A1C2C),
      surface: AppColors.lightBg,
      onSurface: AppColors.lightText,
      surfaceContainerHighest: AppColors.lightCard,
      onSurfaceVariant: AppColors.lightTextSoft,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      shadow: Color(0x1A1A1830),
      scrim: Color(0x66000000),
      inverseSurface: AppColors.darkCard,
      onInverseSurface: AppColors.darkText,
      inversePrimary: Color(0xFFB9B2FF),
    );
    return _base(scheme, AppColors.lightBg);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9A90FF),
      onPrimary: Color(0xFF140F4D),
      primaryContainer: Color(0xFF322B7A),
      onPrimaryContainer: Color(0xFFDDD9FF),
      secondary: Color(0xFF4FCEBF),
      onSecondary: Color(0xFF00322C),
      secondaryContainer: Color(0xFF0F5A52),
      onSecondaryContainer: Color(0xFFCDF3EE),
      tertiary: Color(0xFFF0B96A),
      onTertiary: Color(0xFF3B2600),
      tertiaryContainer: Color(0xFF6B4A14),
      onTertiaryContainer: Color(0xFFFBE6C6),
      error: Color(0xFFEE8496),
      onError: Color(0xFF4A0A16),
      errorContainer: Color(0xFF72212F),
      onErrorContainer: Color(0xFFFBD9DF),
      surface: AppColors.darkBg,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkCard,
      onSurfaceVariant: AppColors.darkTextSoft,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: AppColors.lightCard,
      onInverseSurface: AppColors.lightText,
      inversePrimary: AppColors.indigo,
    );
    return _base(scheme, AppColors.darkBg);
  }

  static ThemeData _base(ColorScheme scheme, Color background) {
    final onSurface = scheme.onSurface;
    final onSurfaceSoft = scheme.onSurfaceVariant;
    final text = TextTheme(
      displaySmall: TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.5,
        height: 1.55,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.45,
        color: onSurfaceSoft,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12.5,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurfaceSoft,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: onSurfaceSoft,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: text,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Estilos numéricos: las cifras de probabilidad se muestran siempre con la
/// misma pinta para que el ojo las encuentre. No se usa
/// `FontFeature.tabularFigures()` a propósito: no está garantizada a través
/// del reexport de `painting.dart` en todas las versiones.
class NumStyle {
  const NumStyle._();

  static TextStyle big(BuildContext context, {Color? color}) =>
      TextStyle(
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color ?? Theme.of(context).colorScheme.primary,
      );

  static TextStyle medium(BuildContext context, {Color? color}) => TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle mono(BuildContext context, {Color? color, double size = 14}) =>
      TextStyle(
        fontSize: size,
        height: 1.4,
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Courier', 'monospace'],
        color: color ?? Theme.of(context).colorScheme.onSurface,
      );
}
