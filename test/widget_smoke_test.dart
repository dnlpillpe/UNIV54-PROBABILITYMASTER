/// Pruebas de widgets: que la app arranque y que los caminos principales se
/// puedan recorrer sin romperse.
///
/// Dos decisiones de estas pruebas:
/// · El almacenamiento se sustituye por una implementación en memoria, para
///   no depender de `shared_preferences` ni de E/S.
/// · La ventana se fija en 360 × 800 px lógicos, el tamaño de un teléfono
///   modesto. Es donde aparecen los desbordes de `RenderFlex`, así que es
///   donde conviene probar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probability_master/app.dart';
import 'package:probability_master/data/local/prefs_storage.dart';
import 'package:probability_master/data/repositories/content_repository.dart';
import 'package:probability_master/domain/math/figure_registry.dart';
import 'package:probability_master/domain/math/sample_space.dart';
import 'package:probability_master/presentation/providers/app_providers.dart';
import 'package:probability_master/presentation/screens/lesson/lesson_screen.dart';
import 'package:probability_master/presentation/screens/tools/calculator_screen.dart';
import 'package:probability_master/presentation/widgets/content_text.dart';
import 'package:probability_master/presentation/widgets/sample_space_grid.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(Widget child) => ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(MemoryProgressStorage()),
      ],
      child: MaterialApp(home: child),
    );

Widget _app() => ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(MemoryProgressStorage()),
      ],
      child: const ProbabilityMasterApp(),
    );

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    250,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  const content = ContentRepository();

  testWidgets('la app arranca y muestra el inicio', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Probability Master'), findsWidgets);
    expect(find.text('Siguiente paso'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Laboratorios'), findsOneWidget);
    expect(find.text('Tutor'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sin progreso, lo primero recomendado es un laboratorio',
      (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    // La decisión D1 en acción: la simulación va antes que la teoría.
    expect(find.text('Laboratorio'), findsWidgets);
    expect(find.text('Empezar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('la navegación inferior cambia de sección', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aprender'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fundamentos'), findsWidgets);

    await tester.tap(find.text('Tutor'));
    await tester.pumpAndSettle();
    expect(find.text('Diagnóstico'), findsOneWidget);
    expect(find.text('Clasificar'), findsOneWidget);

    await tester.tap(find.text('Progreso'));
    await tester.pumpAndSettle();
    expect(find.text('DOMINIO GENERAL'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('el clasificador del tutor avanza por el árbol', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tutor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clasificar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('¿Qué te están pidiendo'), findsOneWidget);
    await _scrollTo(tester, find.textContaining('De cuántas maneras'));
    await tester.tap(find.textContaining('De cuántas maneras').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('¿Importa el orden'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('una lección se puede leer entera', (tester) async {
    _phone(tester);
    final lesson = content.lessons.first;
    await tester.pumpWidget(_wrap(LessonScreen(lessonId: lesson.id)));
    await tester.pumpAndSettle();

    expect(find.text(lesson.title), findsOneWidget);
    expect(find.text(lesson.cards.first.title), findsOneWidget);

    for (var i = 0; i < lesson.cards.length - 1; i++) {
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Terminar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('la calculadora calcula y muestra los pasos', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_wrap(const CalculatorScreen()));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Resultado'));
    expect(find.text('Resultado'), findsOneWidget);
    // 6/36 con los valores por defecto de Laplace.
    expect(find.textContaining('1/6'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('la cuadrícula del espacio muestral responde al toque',
      (tester) async {
    _phone(tester);
    final selected = <int>{};
    final space = SampleSpace.dice(2);
    await tester.pumpWidget(
      _wrap(
        StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: SingleChildScrollView(
              child: SampleSpaceGrid(
                space: space,
                selected: selected,
                onToggle: (i) => setState(() {
                  if (!selected.remove(i)) selected.add(i);
                }),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('11'), findsOneWidget); // la casilla (1,1)
    await tester.tap(find.text('11'));
    await tester.pumpAndSettle();
    expect(selected.length, 1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('ContentText sustituye las marcas por cifras', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _wrap(
        const Scaffold(
          body: ContentText(
            'La suma 7 vale {{p}} exactamente.',
            figures: [
              ContentFigure(
                id: 'p',
                fn: 'diceSum',
                args: [7],
                label: 'P(suma 7)',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('1/6'), findsOneWidget);
    expect(find.textContaining('{{'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
