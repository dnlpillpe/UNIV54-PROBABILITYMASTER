/// Diagnóstico de confusiones (D3) y cálculo de dominio (D4).
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/data/repositories/content_repository.dart';
import 'package:probability_master/domain/models/progress.dart';
import 'package:probability_master/domain/services/diagnosis_service.dart';
import 'package:probability_master/domain/services/mastery_service.dart';

AttemptRecord _miss(String id, List<String> hits) => AttemptRecord(
      itemId: id,
      moduleId: 'm1',
      score: 0,
      choiceCorrect: false,
      misconceptionsHit: hits,
      detects: hits,
      timestamp: 0,
    );

AttemptRecord _hit(String id, List<String> detects) => AttemptRecord(
      itemId: id,
      moduleId: 'm1',
      score: 1,
      choiceCorrect: true,
      detects: detects,
      timestamp: 0,
    );

void main() {
  const content = ContentRepository();
  final diagnosis = DiagnosisService(content.misconceptions);

  group('Diagnóstico', () {
    test('un fallo activa la confusión', () {
      var scores = <String, double>{};
      scores = diagnosis.apply(scores, _miss('e1', ['falacia_jugador']));
      expect(scores['falacia_jugador'], closeTo(1.0, 1e-9));
      final active = diagnosis.active(scores);
      expect(active.length, 1);
      expect(active.first.misconception.id, 'falacia_jugador');
    });

    test('un acierto posterior la reduce', () {
      var scores = <String, double>{};
      scores = diagnosis.apply(scores, _miss('e1', ['falacia_jugador']));
      scores = diagnosis.apply(scores, _hit('e2', ['falacia_jugador']));
      expect(scores['falacia_jugador']! < 1.0, isTrue);
    });

    test('tres aciertos seguidos la desactivan', () {
      var scores = <String, double>{};
      scores = diagnosis.apply(scores, _miss('e1', ['falacia_jugador']));
      for (var i = 0; i < 3; i++) {
        scores = diagnosis.apply(scores, _hit('e$i', ['falacia_jugador']));
      }
      expect(diagnosis.active(scores), isEmpty);
    });

    test('la repetición la vuelve persistente', () {
      var scores = <String, double>{};
      for (var i = 0; i < 4; i++) {
        scores = diagnosis.apply(scores, _miss('e$i', ['falacia_jugador']));
      }
      final active = diagnosis.active(scores);
      expect(active.first.level, 3);
      expect(active.first.levelLabel, 'Persistente');
    });

    test('el decaimiento actúa sobre las no repetidas', () {
      var scores = <String, double>{};
      scores = diagnosis.apply(scores, _miss('e1', ['falacia_jugador']));
      final initial = scores['falacia_jugador']!;
      for (var i = 0; i < 10; i++) {
        scores = diagnosis.apply(scores, _miss('x$i', ['tasa_base_ignorada']));
      }
      expect(scores['falacia_jugador']! < initial, isTrue);
    });

    test('se reportan como superadas las que dejaron de aparecer', () {
      var scores = <String, double>{};
      final history = <AttemptRecord>[];
      final miss = _miss('e1', ['falacia_jugador']);
      history.add(miss);
      scores = diagnosis.apply(scores, miss);
      for (var i = 0; i < 4; i++) {
        final h = _hit('e$i', ['falacia_jugador']);
        history.add(h);
        scores = diagnosis.apply(scores, h);
      }
      final overcome = diagnosis.overcome(scores, history);
      expect(overcome.map((m) => m.id), contains('falacia_jugador'));
    });

    test('agrupa por familia', () {
      var scores = <String, double>{};
      scores = diagnosis.apply(scores, _miss('e1', ['falacia_jugador']));
      scores = diagnosis.apply(scores, _miss('e2', ['tasa_base_ignorada']));
      final grouped = diagnosis.byFamily(diagnosis.active(scores));
      expect(grouped.keys.length, 2);
    });
  });

  group('Dominio (umbral doble)', () {
    const service = MasteryService();

    ModuleMastery build(double lessons, double labs, double practice) =>
        ModuleMastery(
          moduleId: 'm1',
          lessonPart: lessons,
          labPart: labs,
          practicePart: practice,
        );

    test('la ponderación es 15/15/70', () {
      expect(build(1, 1, 1).total, closeTo(1.0, 1e-9));
      expect(build(1, 1, 0).total, closeTo(0.30, 1e-9));
      expect(build(0, 0, 1).total, closeTo(0.70, 1e-9));
    });

    test('leer y simular NO alcanza el umbral sin práctica', () {
      final m = build(1.0, 1.0, 0.62);
      expect(m.total >= 0.70, isTrue);
      expect(m.competent, isFalse,
          reason: 'el umbral doble debe impedirlo');
    });

    test('práctica suficiente y total suficiente sí lo alcanzan', () {
      expect(build(1.0, 1.0, 0.75).competent, isTrue);
    });

    test('práctica alta con total bajo tampoco alcanza', () {
      // Sin lecciones ni laboratorios, 0,72 de práctica da 0,504 de total:
      // el umbral del total también manda.
      final m = build(0, 0, 0.72);
      expect(m.practicePart >= 0.70, isTrue);
      expect(m.total, closeTo(0.504, 1e-9));
      expect(m.competent, isFalse);
    });

    test('el dominio se calcula sobre TODOS los ítems, no los intentados', () {
      final progress = UserProgress(
        bestAttempts: {
          content.exercises.first.id: _hit(content.exercises.first.id, const []),
        },
      );
      final m = service.compute(
        moduleId: 'm1',
        progress: progress,
        lessons: content.lessonsOf('m1'),
        experiments: content.experimentsOf('m1'),
        exercises: content.exercisesOf('m1'),
        caseCount: 0,
        caseIds: const [],
      );
      expect(m.practicePart < 0.2, isTrue,
          reason: 'un solo acierto no puede dar un dominio alto');
      expect(m.competent, isFalse);
    });

    test('el dominio global promedia los módulos', () {
      final list = [
        build(1, 1, 1),
        build(0, 0, 0),
      ];
      expect(service.overall(list), closeTo(0.5, 1e-9));
      expect(service.overall(const []), 0);
    });
  });
}
