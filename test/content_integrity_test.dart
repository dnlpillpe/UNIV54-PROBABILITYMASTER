/// Integridad del contenido: referencias, unicidad y cobertura.
///
/// El test que más veces ha encontrado un problema real: durante el
/// desarrollo detectó dos confusiones catalogadas que ningún distractor
/// producía, es decir, contenido muerto.
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/data/content/sample_space_catalog.dart';
import 'package:probability_master/data/repositories/content_repository.dart';
import 'package:probability_master/domain/models/exercise.dart';

void main() {
  const content = ContentRepository();

  group('Integridad del contenido', () {
    test('ids únicos', () {
      void unique(List<String> ids, String what) {
        expect(ids.toSet().length, ids.length, reason: '$what duplicados');
      }

      unique(content.lessons.map((l) => l.id).toList(), 'lecciones');
      unique(content.exercises.map((e) => e.id).toList(), 'ejercicios');
      unique(content.cases.map((c) => c.id).toList(), 'casos');
      unique(content.experiments.map((e) => e.id).toList(), 'experimentos');
      unique(content.misconceptions.map((m) => m.id).toList(), 'confusiones');
      unique(content.labs.map((l) => l.id).toList(), 'laboratorios');
    });

    test('el catálogo tiene el tamaño esperado', () {
      expect(content.modules.length, 4);
      expect(content.labs.length, 5);
      expect(content.experiments.length, 16);
      expect(content.lessons.length, greaterThanOrEqualTo(20));
      expect(content.exercises.length, greaterThanOrEqualTo(80));
      expect(content.cases.length, 12);
      expect(content.misconceptions.length, greaterThanOrEqualTo(30));
      expect(content.glossary.length, greaterThanOrEqualTo(50));
    });

    test('cada ejercicio de alternativas tiene exactamente una correcta', () {
      for (final e in content.exercises) {
        if (e.choices.isEmpty) continue;
        final correct = e.choices.where((c) => c.correct).length;
        expect(correct, 1,
            reason: '${e.id}: tiene $correct alternativas correctas');
      }
      for (final e in content.exercises) {
        if (e.justifications.isEmpty) continue;
        expect(e.justifications.where((c) => c.correct).length, 1,
            reason: '${e.id}: justificaciones mal marcadas');
      }
      for (final c in content.cases) {
        expect(c.options.where((o) => o.correct).length, 1,
            reason: '${c.id}: opciones mal marcadas');
        if (c.justifications.isNotEmpty) {
          expect(c.justifications.where((o) => o.correct).length, 1,
              reason: '${c.id}: justificaciones mal marcadas');
        }
      }
    });

    test('toda alternativa tiene retroalimentación propia', () {
      for (final e in content.exercises) {
        for (final c in [...e.choices, ...e.justifications]) {
          expect(c.feedback.trim().length, greaterThan(20),
              reason: '${e.id}: retroalimentación demasiado pobre');
          expect(c.feedback.toLowerCase().trim() == 'incorrecto', isFalse);
        }
      }
      for (final cs in content.cases) {
        for (final c in [...cs.options, ...cs.justifications]) {
          expect(c.feedback.trim().length, greaterThan(20),
              reason: '${cs.id}: retroalimentación demasiado pobre');
        }
      }
    });

    test('toda confusión citada existe en el catálogo', () {
      final ids = content.misconceptions.map((m) => m.id).toSet();
      for (final e in content.exercises) {
        for (final c in [...e.choices, ...e.justifications]) {
          if (c.misconceptionId != null) {
            expect(ids.contains(c.misconceptionId), isTrue,
                reason: '${e.id}: confusión inexistente ${c.misconceptionId}');
          }
        }
        for (final d in e.detects) {
          expect(ids.contains(d), isTrue,
              reason: '${e.id}: detects inexistente $d');
        }
      }
      for (final cs in content.cases) {
        for (final c in [...cs.options, ...cs.justifications]) {
          if (c.misconceptionId != null) {
            expect(ids.contains(c.misconceptionId), isTrue);
          }
        }
        for (final d in cs.detects) {
          expect(ids.contains(d), isTrue);
        }
      }
      for (final l in content.lessons) {
        for (final card in l.cards) {
          if (card.targetsMisconception != null) {
            expect(ids.contains(card.targetsMisconception), isTrue,
                reason: '${l.id}: confusión inexistente');
          }
        }
      }
    });

    test('toda confusión es producida por al menos un distractor', () {
      final produced = <String>{};
      for (final e in content.exercises) {
        for (final c in [...e.choices, ...e.justifications]) {
          if (c.misconceptionId != null) produced.add(c.misconceptionId!);
        }
      }
      for (final cs in content.cases) {
        for (final c in [...cs.options, ...cs.justifications]) {
          if (c.misconceptionId != null) produced.add(c.misconceptionId!);
        }
      }
      for (final m in content.misconceptions) {
        expect(produced.contains(m.id), isTrue,
            reason: 'confusión sin distractor que la produzca: ${m.id}');
      }
    });

    test('los remedios apuntan a contenido existente', () {
      final lessonIds = content.lessons.map((l) => l.id).toSet();
      final expIds = content.experiments.map((e) => e.id).toSet();
      for (final m in content.misconceptions) {
        if (m.remedyLessonId != null) {
          expect(lessonIds.contains(m.remedyLessonId), isTrue,
              reason: '${m.id}: lección de remedio inexistente');
        }
        if (m.remedyExperimentId != null) {
          expect(expIds.contains(m.remedyExperimentId), isTrue,
              reason: '${m.id}: experimento de remedio inexistente');
        }
      }
      for (final e in content.experiments) {
        if (e.lessonId != null) {
          expect(lessonIds.contains(e.lessonId), isTrue);
        }
      }
      for (final l in content.lessons) {
        if (l.preferredExperimentId != null) {
          expect(expIds.contains(l.preferredExperimentId), isTrue);
        }
      }
    });

    test('los ejercicios de construcción usan predicados implementados', () {
      for (final e in content.exercises) {
        if (e.kind != ExerciseKind.construccion) continue;
        final b = e.build;
        expect(b, isNotNull, reason: '${e.id}: sin BuildTarget');
        expect(SampleSpaceCatalog.knowsPredicate(b!.predicate), isTrue,
            reason: '${e.id}: predicado desconocido ${b.predicate}');
        final space = SampleSpaceCatalog.byId(b.spaceId);
        final solution = space.indicesWhere(
          SampleSpaceCatalog.predicate(b.predicate, b.predicateArgs),
        );
        expect(solution.isNotEmpty, isTrue,
            reason: '${e.id}: el evento a construir es vacío');
        expect(solution.length < space.size, isTrue,
            reason: '${e.id}: el evento es todo el espacio');
      }
    });

    test('los ejercicios de cálculo tienen respuesta declarada', () {
      for (final e in content.exercises) {
        if (e.kind != ExerciseKind.calculo) continue;
        expect(e.numeric, isNotNull, reason: '${e.id}: sin NumericTarget');
      }
    });

    test('los de decisión traen justificaciones', () {
      for (final e in content.exercises) {
        if (e.kind != ExerciseKind.decisionJustificada) continue;
        expect(e.justifications.length, greaterThanOrEqualTo(3),
            reason: '${e.id}: pocas justificaciones');
      }
    });

    test('cada módulo tiene los seis tipos representados en el catálogo', () {
      final kinds = content.exercises.map((e) => e.kind).toSet();
      expect(kinds.length, ExerciseKind.values.length,
          reason: 'faltan tipos de ejercicio en el catálogo');
    });

    test('cada experimento declara predicción y hallazgo', () {
      for (final e in content.experiments) {
        expect(e.prediction.question.trim().length, greaterThan(20),
            reason: '${e.id}: pregunta de predicción pobre');
        expect(e.finding.trim().length, greaterThan(80),
            reason: '${e.id}: hallazgo pobre');
        expect(e.minTrials, greaterThan(0));
        if (e.prediction.options.isNotEmpty) {
          expect(e.prediction.correctOption, greaterThanOrEqualTo(0));
          expect(e.prediction.correctOption,
              lessThan(e.prediction.options.length));
        } else {
          expect(e.prediction.correctMin, isNotNull);
          expect(e.prediction.correctMax, isNotNull);
        }
      }
    });

    test('los casos cubren 11 carreras y declaran supuestos', () {
      final careers = content.cases.map((c) => c.career).toSet();
      expect(careers.length, greaterThanOrEqualTo(11));
      for (final c in content.cases) {
        expect(c.assumptions.trim().length, greaterThan(60),
            reason: '${c.id}: supuestos sin declarar');
        expect(c.resolution.trim().length, greaterThan(80));
      }
    });

    test('el orden de casos respeta la carrera elegida', () {
      final ordered = content.casesFor('Psicología');
      expect(ordered.first.career, 'Psicología');
      expect(ordered.length, content.cases.length);
    });
  });
}
