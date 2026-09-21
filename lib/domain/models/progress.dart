/// Estado de avance del estudiante. Local, sin cuenta, serializable a JSON.
library;

/// Registro de un intento de ejercicio o caso.
class AttemptRecord {
  final String itemId;
  final String moduleId;

  /// Puntaje 0..1. En los ejercicios de decisión es 0,6·elección +
  /// 0,4·justificación (decisión D4).
  final double score;

  /// ¿La elección principal fue correcta?
  final bool choiceCorrect;

  /// ¿La justificación fue correcta? `null` si el ítem no la pide.
  final bool? justificationCorrect;

  /// Confusiones activadas por la alternativa elegida.
  final List<String> misconceptionsHit;

  /// Confusiones que este ítem podía detectar (para el descuento al acertar).
  final List<String> detects;

  final int timestamp;

  const AttemptRecord({
    required this.itemId,
    required this.moduleId,
    required this.score,
    required this.choiceCorrect,
    required this.timestamp,
    this.justificationCorrect,
    this.misconceptionsHit = const [],
    this.detects = const [],
  });

  /// Acierto ciego: eligió bien y justificó mal.
  bool get blindHit => choiceCorrect && justificationCorrect == false;

  Map<String, dynamic> toJson() => {
        'i': itemId,
        'm': moduleId,
        's': score,
        'c': choiceCorrect,
        'j': justificationCorrect,
        'h': misconceptionsHit,
        'd': detects,
        't': timestamp,
      };

  static AttemptRecord fromJson(Map<String, dynamic> j) => AttemptRecord(
        itemId: j['i'] as String,
        moduleId: j['m'] as String,
        score: (j['s'] as num).toDouble(),
        choiceCorrect: j['c'] as bool,
        justificationCorrect: j['j'] as bool?,
        misconceptionsHit:
            (j['h'] as List<dynamic>? ?? const []).map((e) => '$e').toList(),
        detects:
            (j['d'] as List<dynamic>? ?? const []).map((e) => '$e').toList(),
        timestamp: j['t'] as int,
      );
}

/// Registro de un experimento de laboratorio.
class ExperimentRecord {
  final String experimentId;
  final String labId;
  final bool predictionRecorded;

  /// ¿Acertó la predicción? No penaliza; es el indicador «intuición inicial».
  final bool predictionCorrect;
  final int trialsRun;
  final int seed;
  final int timestamp;

  const ExperimentRecord({
    required this.experimentId,
    required this.labId,
    required this.predictionRecorded,
    required this.predictionCorrect,
    required this.trialsRun,
    required this.seed,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'e': experimentId,
        'l': labId,
        'p': predictionRecorded,
        'k': predictionCorrect,
        'n': trialsRun,
        'sd': seed,
        't': timestamp,
      };

  static ExperimentRecord fromJson(Map<String, dynamic> j) => ExperimentRecord(
        experimentId: j['e'] as String,
        labId: j['l'] as String,
        predictionRecorded: j['p'] as bool? ?? true,
        predictionCorrect: j['k'] as bool? ?? false,
        trialsRun: j['n'] as int? ?? 0,
        seed: j['sd'] as int? ?? 0,
        timestamp: j['t'] as int? ?? 0,
      );
}

/// Progreso completo.
class UserProgress {
  /// Lecciones terminadas.
  final Set<String> completedLessons;

  /// Tarjetas vistas por lección (para el porcentaje parcial).
  final Map<String, int> lessonCardsSeen;

  /// Último intento por ítem (para no inflar el dominio repitiendo).
  final Map<String, AttemptRecord> bestAttempts;

  /// Historial completo, en orden.
  final List<AttemptRecord> history;

  final Map<String, ExperimentRecord> experiments;

  /// Puntaje de cada confusión (decaimiento incluido).
  final Map<String, double> misconceptionScores;

  /// Días con actividad, en formato `aaaammdd`.
  final Set<int> activeDays;

  /// Carrera elegida, para ordenar los casos.
  final String? career;

  /// Semilla preferida del usuario (0 = aleatoria en cada corrida).
  final int preferredSeed;

  const UserProgress({
    this.completedLessons = const {},
    this.lessonCardsSeen = const {},
    this.bestAttempts = const {},
    this.history = const [],
    this.experiments = const {},
    this.misconceptionScores = const {},
    this.activeDays = const {},
    this.career,
    this.preferredSeed = 0,
  });

  UserProgress copyWith({
    Set<String>? completedLessons,
    Map<String, int>? lessonCardsSeen,
    Map<String, AttemptRecord>? bestAttempts,
    List<AttemptRecord>? history,
    Map<String, ExperimentRecord>? experiments,
    Map<String, double>? misconceptionScores,
    Set<int>? activeDays,
    String? career,
    int? preferredSeed,
  }) =>
      UserProgress(
        completedLessons: completedLessons ?? this.completedLessons,
        lessonCardsSeen: lessonCardsSeen ?? this.lessonCardsSeen,
        bestAttempts: bestAttempts ?? this.bestAttempts,
        history: history ?? this.history,
        experiments: experiments ?? this.experiments,
        misconceptionScores: misconceptionScores ?? this.misconceptionScores,
        activeDays: activeDays ?? this.activeDays,
        career: career ?? this.career,
        preferredSeed: preferredSeed ?? this.preferredSeed,
      );

  int get totalAttempts => history.length;
  int get blindHits => history.where((a) => a.blindHit).length;

  /// Predicciones acertadas sobre predicciones registradas.
  double get initialIntuition {
    final recorded = experiments.values.where((e) => e.predictionRecorded);
    if (recorded.isEmpty) return 0;
    final ok = recorded.where((e) => e.predictionCorrect).length;
    return ok / recorded.length;
  }

  /// Racha de días consecutivos terminando hoy (o ayer).
  int streakFrom(DateTime today) {
    var count = 0;
    var d = DateTime(today.year, today.month, today.day);
    if (!activeDays.contains(_key(d))) {
      d = d.subtract(const Duration(days: 1));
      if (!activeDays.contains(_key(d))) return 0;
    }
    while (activeDays.contains(_key(d))) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  static int _key(DateTime d) => d.year * 10000 + d.month * 100 + d.day;
  static int dayKey(DateTime d) => _key(d);

  Map<String, dynamic> toJson() => {
        'v': 1,
        'lessons': completedLessons.toList(),
        'cards': lessonCardsSeen,
        'best': bestAttempts.map((k, v) => MapEntry(k, v.toJson())),
        'hist': history.map((a) => a.toJson()).toList(),
        'exp': experiments.map((k, v) => MapEntry(k, v.toJson())),
        'misc': misconceptionScores,
        'days': activeDays.toList(),
        'career': career,
        'seed': preferredSeed,
      };

  static UserProgress fromJson(Map<String, dynamic> j) {
    Map<String, dynamic> asMap(dynamic v) =>
        v is Map ? v.map((k, val) => MapEntry('$k', val)) : <String, dynamic>{};

    final best = asMap(j['best']).map(
      (k, v) => MapEntry(k, AttemptRecord.fromJson(asMap(v))),
    );
    final exp = asMap(j['exp']).map(
      (k, v) => MapEntry(k, ExperimentRecord.fromJson(asMap(v))),
    );
    return UserProgress(
      completedLessons:
          (j['lessons'] as List<dynamic>? ?? const []).map((e) => '$e').toSet(),
      lessonCardsSeen: asMap(j['cards'])
          .map((k, v) => MapEntry(k, (v as num).toInt())),
      bestAttempts: best,
      history: (j['hist'] as List<dynamic>? ?? const [])
          .map((e) => AttemptRecord.fromJson(asMap(e)))
          .toList(),
      experiments: exp,
      misconceptionScores: asMap(j['misc'])
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      activeDays: (j['days'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toSet(),
      career: j['career'] as String?,
      preferredSeed: (j['seed'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Dominio de un módulo, desglosado como manda la decisión D4.
class ModuleMastery {
  final String moduleId;
  final double lessonPart; // 0..1
  final double labPart; // 0..1
  final double practicePart; // 0..1

  const ModuleMastery({
    required this.moduleId,
    required this.lessonPart,
    required this.labPart,
    required this.practicePart,
  });

  /// 15 % lecciones + 15 % laboratorios + 70 % práctica.
  double get total => 0.15 * lessonPart + 0.15 * labPart + 0.70 * practicePart;

  /// Umbral doble: 0,70 en el total **y** 0,70 en la práctica.
  bool get competent => total >= 0.70 && practicePart >= 0.70;

  String get levelLabel {
    if (competent) return 'Competente';
    if (total >= 0.45) return 'En progreso';
    if (total > 0) return 'Iniciado';
    return 'Sin empezar';
  }
}
