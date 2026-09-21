/// Módulos del curso.
library;

class AppModule {
  final String id;
  final int order;
  final String name;

  /// La pregunta que el módulo enseña a responder.
  final String question;

  final String description;

  /// Nombre del icono temático (resuelto por el tema, sin dependencias).
  final String iconKey;

  /// Índice de color en la paleta de módulos.
  final int colorIndex;

  const AppModule({
    required this.id,
    required this.order,
    required this.name,
    required this.question,
    required this.description,
    required this.iconKey,
    required this.colorIndex,
  });
}
