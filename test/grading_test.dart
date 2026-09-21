/// Corrección: regla 60/40, acierto ciego y lectura de respuestas.
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/data/repositories/content_repository.dart';
import 'package:probability_master/domain/models/exercise.dart';
import 'package:probability_master/domain/services/grading_service.dart';

void main() {
  const grading = GradingService();
  const content = ContentRepository();

  group('Lectura de respuestas numéricas', () {
    test('acepta las tres formas', () {
      expect(GradingService.parseAnswer('3/8')!.toDouble(),
          closeTo(0.375, 1e-9));
      expect(GradingService.parseAnswer('0,375')!.toDouble(),
          closeTo(0.375, 1e-9));
      expect(GradingService.parseAnswer('0.375')!.toDouble(),
          closeTo(0.375, 1e-9));
      expect(GradingService.parseAnswer('37,5 %')!.toDouble(),
          closeTo(0.375, 1e-9));
      expect(GradingService.parseAnswer('37.5%')!.toDouble(),
          closeTo(0.375, 1e-9));
    });

    test('rechaza basura', () {
      expect(GradingService.parseAnswer(''), isNull);
      expect(GradingService.parseAnswer('no sé'), isNull);
      expect(GradingService.parseAnswer('1/0'), isNull);
    });
  });

  group('Corrección de alternativas', () {
    final mc = content.exercises
        .firstWhere((e) => e.kind == ExerciseKind.opcionMultiple);

    test('la correcta vale 1 y la incorrecta 0', () {
      final ok = grading.gradeChoice(mc, choiceIndex: mc.correctIndex);
      expect(ok.score, 1.0);
      expect(ok.choiceCorrect, isTrue);

      final wrongIndex =
          mc.choices.indexWhere((c) => !c.correct && c.misconceptionId != null);
      if (wrongIndex >= 0) {
        final bad = grading.gradeChoice(mc, choiceIndex: wrongIndex);
        expect(bad.score, 0.0);
        expect(bad.misconceptionsHit, isNotEmpty);
      }
    });

    test('índice fuera de rango lanza', () {
      expect(() => grading.gradeChoice(mc, choiceIndex: 99),
          throwsArgumentError);
    });
  });

  group('Regla 60/40 y acierto ciego (D4)', () {
    final decision = content.exercises
        .firstWhere((e) => e.kind == ExerciseKind.decisionJustificada);

    test('elección correcta + justificación correcta = 1,0', () {
      final r = grading.gradeChoice(
        decision,
        choiceIndex: decision.correctIndex,
        justificationIndex: decision.correctJustificationIndex,
      );
      expect(r.score, closeTo(1.0, 1e-9));
      expect(r.blindHit, isFalse);
    });

    test('elección correcta + justificación incorrecta = 0,6 y acierto ciego',
        () {
      final badJust =
          decision.justifications.indexWhere((c) => !c.correct);
      final r = grading.gradeChoice(
        decision,
        choiceIndex: decision.correctIndex,
        justificationIndex: badJust,
      );
      expect(r.score, closeTo(0.6, 1e-9));
      expect(r.blindHit, isTrue);
      expect(r.justificationFeedback, isNotNull);
    });

    test('elección incorrecta + justificación correcta = 0,4', () {
      final badChoice = decision.choices.indexWhere((c) => !c.correct);
      final r = grading.gradeChoice(
        decision,
        choiceIndex: badChoice,
        justificationIndex: decision.correctJustificationIndex,
      );
      expect(r.score, closeTo(0.4, 1e-9));
      expect(r.blindHit, isFalse);
    });

    test('la decisión exige justificación', () {
      expect(
        () => grading.gradeChoice(decision, choiceIndex: 0),
        throwsArgumentError,
      );
    });
  });

  group('Corrección numérica con diagnóstico', () {
    final numeric = content.exercises.firstWhere(
      (e) => e.kind == ExerciseKind.calculo && e.id == 'm1_e04',
    );

    test('acepta el valor correcto en cualquier forma', () {
      expect(grading.gradeNumeric(numeric, '1/9').score, 1.0);
      expect(grading.gradeNumeric(numeric, '0,111').score, 1.0);
      expect(grading.gradeNumeric(numeric, '11,1 %').score, 1.0);
    });

    test('detecta el complemento invertido', () {
      final r = grading.gradeNumeric(numeric, '8/9');
      expect(r.score, 0.0);
      expect(r.feedback.toLowerCase().contains('complemento'), isTrue);
      expect(r.misconceptionsHit, contains('complemento_invertido'));
    });

    test('detecta un valor imposible', () {
      final r = grading.gradeNumeric(numeric, '1,4');
      expect(r.misconceptionsHit, contains('probabilidad_mayor_que_uno'));
    });

    test('lectura ilegible no rompe nada', () {
      final r = grading.gradeNumeric(numeric, 'casi nada');
      expect(r.score, 0.0);
      expect(r.feedback.isNotEmpty, isTrue);
    });
  });

  group('Corrección de conteos', () {
    final counting = content.exercises.firstWhere((e) => e.id == 'm3_e06');

    test('acepta el entero exacto, con o sin separadores', () {
      expect(grading.gradeNumeric(counting, '2598960').score, 1.0);
      expect(grading.gradeNumeric(counting, '2 598 960').score, 1.0);
    });

    test('un factor k! delata la confusión de orden', () {
      // C(52,5) x 5! = variaciones: el error clásico.
      final r = grading.gradeNumeric(counting, '311875200');
      expect(r.score, 0.0);
      expect(r.misconceptionsHit, contains('orden_importa_confundido'));
      expect(r.feedback.contains('5!'), isTrue);
    });
  });

  group('Corrección de casos', () {
    test('un caso completo aplica 60/40', () {
      final c = content.cases.first;
      final okOption = c.options.indexWhere((o) => o.correct);
      final badJust = c.justifications.indexWhere((o) => !o.correct);
      final r = grading.gradeCase(
        c,
        optionIndex: okOption,
        justificationIndex: badJust,
      );
      expect(r.score, closeTo(0.6, 1e-9));
      expect(r.blindHit, isTrue);
    });
  });
}
