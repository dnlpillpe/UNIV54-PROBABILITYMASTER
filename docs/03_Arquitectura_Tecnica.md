# Probability Master — Arquitectura técnica

---

## 1. Stack y por qué

| Decisión | Alternativa descartada | Motivo |
|---|---|---|
| Flutter + Dart | Nativo, React Native | Un código, dos plataformas, y el `CustomPainter` da la geometría expuesta que los laboratorios necesitan |
| Riverpod | Provider, Bloc | Providers derivados sin `BuildContext`; el dominio se prueba sin arrancar Flutter |
| MVVM + Repository | MVC | Separa el motor (puro) de la interfaz; el 100 % del dominio es testeable sin widgets |
| `shared_preferences` | SQLite, Hive, Firebase | El estado cabe en un JSON; sin esquema que migrar y **CI compila sin secretos** |
| Contenido `const` en Dart | Assets JSON | El compilador lo verifica, no hay `await` al arrancar y las pruebas de widgets no dependen de E/S (`loadString` con archivos grandes cuelga los tests) |
| Pintores propios | fl_chart, syncfusion | Sombrear exactamente la intersección de dos círculos, resaltar 6 celdas de 36 y dibujar un árbol con probabilidades en las ramas no lo da una librería genérica, y pesan más que 700 líneas de `CustomPainter` |

**Dependencias de producción: dos.** `flutter_riverpod` y
`shared_preferences`. Sin `build_runner`, sin router declarativo, sin ORM, sin
librería de gráficos, sin HTTP.

## 2. Capas

```
presentation ──────► domain ◄────── data
 (Flutter)          (Dart puro)    (contenido + persistencia)
```

**La regla:** `domain/` no importa `package:flutter/*`. Todo el motor, la
corrección, el dominio, el diagnóstico, la recomendación y el tutor se ejecutan
y se prueban sin arrancar Flutter. Eso es lo que permite que 9 de las 10 suites
de test sean puras y rápidas.

```
lib/
├─ core/
│  ├─ theme/       app_colors.dart · app_theme.dart
│  ├─ utils/       formatters.dart
│  └─ constants/   app_info.dart
├─ domain/
│  ├─ math/        rational · combinatorics · sample_space ·
│  │               probability_engine · rng · simulators · figure_registry
│  ├─ models/      module · lesson · exercise · experiment · case_study ·
│  │               misconception · glossary_term · progress
│  ├─ services/    grading · mastery · diagnosis · recommendation
│  └─ tutor/       problem_classifier · step_solver · tutor_client
├─ data/
│  ├─ content/     modules · lessons_m1..m4 · exercises_m1..m4 · labs ·
│  │               cases · misconceptions · glossary · sample_space_catalog
│  ├─ repositories/ content_repository
│  └─ local/       prefs_storage
└─ presentation/
   ├─ painters/    brand_painter · chart_painters
   ├─ providers/   app_providers
   ├─ screens/     home · module · lesson · exercise · lab · cases ·
   │               tutor · progress · glossary · tools
   └─ widgets/     app_widgets · charts · content_text · sample_space_grid
```

## 3. El motor matemático

### 3.1 `Rational` — aritmética exacta sobre `BigInt`

Decisión D6. Dos motivos, uno pedagógico y uno técnico:

- **Pedagógico:** el estudiante debe ver `11/36`, no `0.3055555…`. Una
  probabilidad como fracción se puede leer como «11 casillas de 36».
- **Técnico:** `C(52,5)`, `365!/(365−23)!` y `0,98⁵⁰` desbordan o pierden
  precisión en `double`. Con `BigInt` son exactos.

Siempre normalizado (denominador positivo, fracción irreducible). Incluye
`complement`, que es la operación más usada del dominio, y
`isReadableFraction`: el problema del cumpleaños produce denominadores de más
de cien cifras, exactos pero inservibles en pantalla, y entonces `triple` los
omite y muestra decimal y porcentaje.

### 3.2 `Combinatorics`

Combinaciones calculadas de forma incremental (`r * (n−k+i) ~/ i`) para no
construir factoriales enormes. Variaciones, permutaciones con repetición,
combinaciones con repetición, circulares, subconjuntos, binomial exacta,
hipergeométrica, cumpleaños exacto, y enumeración real de combinaciones y
variaciones para el laboratorio 5.

### 3.3 `SampleSpace` — los espacios se construyen, no se suponen

Cada espacio lleva sus **pesos** cuando no es uniforme, y
`probabilityOfIndices` los usa. Esto no es un detalle de implementación: es lo
que impide que la app cometa, en su propio código, el error que enseña a
evitar. `SampleSpace.diceSum()` existe precisamente como espacio **no
equiprobable** y la interfaz lo señala.

`EventDef` da el álgebra de eventos (unión, intersección, diferencia,
complemento, disyunción) sobre conjuntos de índices.

### 3.4 `ProbabilityEngine` — el número viaja con su derivación

Cada método devuelve `ProbabilityResult`: el valor, la lista de
`SolutionStep` (título, expresión, nota, valor) y las **advertencias de
supuestos**. La competencia objetivo incluye «declarar qué supuestos asumió»,
así que los supuestos viajan con el número en vez de quedarse en la
documentación.

`laplace` siempre advierte sobre la equiprobabilidad. `productRule` advierte
cuando se invoca con `independent: true`. `totalProbability` advierte que los
Aᵢ deben formar partición.

### 3.5 `SeededRng` — reproducibilidad

xorshift128+ propio en vez de `dart:math.Random`, por una razón de producto: el
estudiante debe poder **repetir exactamente** una simulación que le sorprendió,
y el docente reproducirla en clase. La semilla se muestra en pantalla y se
guarda con el resultado del experimento.

### 3.6 `FigureRegistry` — el registro de funciones con nombre

Decisión D5. El contenido declara:

```dart
ContentFigure(id: 'p_suma7', fn: 'diceSum', args: [7],
              label: 'P(suma 7)', format: FigureFormat.triple)
```

y el texto escribe `{{p_suma7}}`. La app resuelve la marca en tiempo de
ejecución con el motor real. 24 funciones de probabilidad y 9 de conteo.

Consecuencia: **es imposible que el contenido y el motor se contradigan**, y
un cambio en el motor que altere un resultado hace fallar el test de cifras en
vez de llegar al estudiante.

## 4. Servicios de dominio

| Servicio | Responsabilidad |
|---|---|
| `GradingService` | Corrige los 6 tipos, aplica el 60/40, detecta el acierto ciego y diagnostica el error numérico o de conteo |
| `MasteryService` | 15/15/70 y umbral doble; promedia sobre TODOS los ítems del módulo |
| `DiagnosisService` | +1 / −0,5 / ×0,97; activas, superadas y agrupación por familia |
| `RecommendationService` | Una recomendación, con motivo, por prioridad estricta |

## 5. Tutor

`ProblemClassifier` es un árbol de datos (`Map<String, ClassifierNode>` const),
no código: se puede leer, auditar y ampliar sin tocar la interfaz. Cada opción
lleva opcionalmente un `why` que explica por qué esa respuesta lleva ahí.

`StepSolver` define una **receta** por método: los campos que pide y cómo los
calcula con el motor. La misma receta alimenta la calculadora y el
solucionador del tutor, así que no pueden mostrar números distintos.

`ProbabilityTutorClient` es el adaptador de LLM, con
`DeterministicTutorClient` como implementación del MVP. La interfaz solo acepta
**reformular** una explicación ya calculada: no recibe el enunciado sin el
resultado y no puede devolver números. La regla está en el tipo, no en un
comentario.

## 6. Estado (Riverpod)

Un único `StateNotifier` escribe estado: `ProgressController`. El resto son
providers derivados y sin estado propio:

```
contentProvider ─┬─► moduleMasteryProvider(id) ─┬─► overallMasteryProvider
progressProvider ┘                              └─► recommendationProvider
                 ├─► activeMisconceptionsProvider ┘
                 └─► streakProvider
```

Las pantallas leen providers y llaman métodos del controlador. Ninguna pantalla
calcula dominio, corrección ni diagnóstico.

Al registrar un intento, el controlador guarda el **mejor** intento por ítem
(el dominio no baja por repetir), añade al historial y aplica el diagnóstico.
Al registrar un experimento conserva la **primera** predicción.

## 7. Interfaz

**Tema.** Se construye con `ColorScheme` + `TextTheme` y nada más. Las clases
de tema por componente (`AppBarTheme`, `CardTheme`, `InputDecorationTheme`,
`TabBarTheme`) han cambiado de nombre entre versiones de Flutter y romperían la
compilación en CI; los componentes se estilizan en su propio widget, donde
además se lee mejor. Claro y oscuro completos.

**`TileGrid`.** Rejilla que calcula columnas según el ancho disponible, con
`FittedBox` en los valores. Evita los desbordes de `RenderFlex` en pantallas de
360 px, que es el problema recurrente de este tipo de pantallas densas.

**`ContentText`.** Renderizador de un subconjunto mínimo de marcas
(`**negrita**`, listas, bloques, tablas y `{{cifras}}`). No se usa un paquete
de Markdown: el subconjunto es pequeño y así el proyecto mantiene dos
dependencias.

**Pintores.** `BrandPainter` (marca e icono), `ConvergencePainter` (escala
logarítmica y banda de ±2 EE), `HistogramPainter`, `VennPainter` (cuatro
regiones con resaltado selectivo por `Path.combine`), `TreePainter`,
`MasteryRingPainter`.

## 8. Rendimiento

Las simulaciones más pesadas (50 000 ensayos, 200 000 personas) corren en el
hilo de UI. Medido en coste: un ensayo de Bernoulli es una llamada a xorshift y
una comparación; 50 000 son ~2 ms en un teléfono modesto. El laboratorio de
tamizaje con 100 000 personas hace dos ensayos por persona: ~15 ms. Ninguno
justifica un `Isolate`, que añadiría serialización y complejidad. Si en v2 se
suben los máximos, el corte natural es mover `Simulators` a un isolate: es
código puro sin dependencias de Flutter, así que el cambio es local.

La trayectoria de los gráficos se submuestrea a ~120 puntos: dibujar 50 000
puntos en una pantalla de 360 px no aporta información.
