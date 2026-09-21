/// Datos fijos de la aplicación.
library;

class AppInfo {
  const AppInfo._();

  static const String name = 'Probability Master';
  static const String tagline = 'Domina el azar con tus propios experimentos';
  static const String version = '1.0.0';
  static const String buildLabel = 'MVP';

  /// Lo que la app promete enseñar, en una frase. Se muestra en «Acerca de».
  static const String promise =
      'No enseña a calcular probabilidades: enseña a reconocer qué clase de '
      'problema tienes delante y a desconfiar de la intuición que falla.';

  static const List<String> careers = [
    'Ingeniería de Minas',
    'Ingeniería de Sistemas',
    'Ingeniería Electrónica',
    'Ingeniería Ambiental',
    'Administración',
    'Economía',
    'Contabilidad',
    'Psicología',
    'Biología',
    'Humanidades',
    'Desarrollo personal',
    'Otra / sin especificar',
  ];
}
