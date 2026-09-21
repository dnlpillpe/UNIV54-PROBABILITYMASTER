/// Punto único de acceso al contenido.
///
/// Todo el contenido es `const` en Dart y no assets JSON: el compilador lo
/// verifica, las pruebas de widgets no dependen de E/S de archivos (cargar
/// assets grandes con `loadString` cuelga los tests) y arranca sin `await`.
library;

import '../../domain/models/case_study.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/experiment.dart';
import '../../domain/models/glossary_term.dart';
import '../../domain/models/lesson.dart';
import '../../domain/models/misconception.dart';
import '../../domain/models/module.dart';
import '../content/cases_data.dart';
import '../content/exercises_m1.dart';
import '../content/exercises_m2.dart';
import '../content/exercises_m3.dart';
import '../content/exercises_m4.dart';
import '../content/glossary_data.dart';
import '../content/labs_data.dart';
import '../content/lessons_m1.dart';
import '../content/lessons_m2.dart';
import '../content/lessons_m3.dart';
import '../content/lessons_m4.dart';
import '../content/misconceptions_data.dart';
import '../content/modules_data.dart';

class ContentRepository {
  const ContentRepository();

  List<AppModule> get modules => kModules;
  List<String> get moduleOrder => kModuleOrder;
  AppModule? module(String id) => kModulesById[id];

  List<Lesson> get lessons => [
        ...kLessonsM1,
        ...kLessonsM2,
        ...kLessonsM3,
        ...kLessonsM4,
      ];

  List<Lesson> lessonsOf(String moduleId) =>
      lessons.where((l) => l.moduleId == moduleId).toList();

  Lesson? lesson(String id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  List<Exercise> get exercises => [
        ...kExercisesM1,
        ...kExercisesM2,
        ...kExercisesM3,
        ...kExercisesM4,
      ];

  List<Exercise> exercisesOf(String moduleId) =>
      exercises.where((e) => e.moduleId == moduleId).toList();

  Exercise? exercise(String id) {
    for (final e in exercises) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<Lab> get labs => kLabs;
  List<Lab> labsOf(String moduleId) =>
      kLabs.where((l) => l.moduleId == moduleId).toList();
  Lab? lab(String id) => kLabsById[id];

  List<Experiment> get experiments => kAllExperiments;
  List<Experiment> experimentsOf(String moduleId) =>
      kAllExperiments.where((e) => e.labId.startsWith(moduleId)).toList();
  Experiment? experiment(String id) => kExperimentsById[id];

  List<CaseStudy> get cases => kCases;
  CaseStudy? caseById(String id) => kCasesById[id];

  /// Casos ordenados poniendo primero los de la carrera elegida.
  List<CaseStudy> casesFor(String? career) {
    if (career == null) return kCases;
    final mine = kCases.where((c) => c.career == career).toList();
    final rest = kCases.where((c) => c.career != career).toList();
    return [...mine, ...rest];
  }

  List<Misconception> get misconceptions => kMisconceptions;
  Misconception? misconception(String id) => kMisconceptionsById[id];

  List<GlossaryTerm> get glossary => kGlossary;

  // --- Cifras del catálogo, para la pantalla «Acerca de» --------------
  int get lessonCount => lessons.length;
  int get cardCount =>
      lessons.fold<int>(0, (a, l) => a + l.cards.length);
  int get exerciseCount => exercises.length;
  int get experimentCount => experiments.length;
  int get caseCount => cases.length;
  int get misconceptionCount => misconceptions.length;
  int get glossaryCount => glossary.length;
}
