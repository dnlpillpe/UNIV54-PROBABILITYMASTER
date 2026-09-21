# Probability Master — Contenido y verificación

Cómo está hecho el contenido y cómo se comprueba que es correcto **sin haber
podido ejecutar la app**.

---

## 1. El problema de verificación

El proyecto se construyó **sin SDK de Flutter en el entorno**: no se pudo
compilar, ni ejecutar, ni correr `flutter test`. Un contenido educativo con 70
cifras calculadas, 96 ejercicios y 319 alternativas no se puede entregar «a
ojo».

La respuesta son tres capas de verificación, dos de las cuales no necesitan
Flutter:

| Capa | Herramienta | Qué garantiza | ¿Necesita Flutter? |
|---|---|---|---|
| 1 | `tool/probability_core.py` + `tool/verify_content.py` | Las 70 cifras son correctas, calculadas por un motor **independiente** | No |
| 2 | `tool/static_check.py` | Los 77 archivos Dart están estructuralmente sanos y sin imports rotos | No |
| 3 | `test/` (10 suites) | El motor real produce los mismos números y las reglas de negocio se cumplen | Sí, en CI |

Las capas 1 y 3 calculan **lo mismo con motores distintos** (Python con
`Fraction`, Dart con `BigInt`). Si coinciden, la probabilidad de que un error
de implementación sobreviva es muy baja.

## 2. Capa 1 — Recálculo del contenido

`tool/verify_content.py` hace cuatro cosas:

**a) Recalcula las 70 cifras.** Extrae cada `ContentFigure` del código Dart,
la evalúa con la réplica en Python y comprueba que el resultado está en [0,1]
si es probabilidad y es no negativo si es conteo. Imprime las 70 para revisión
humana.

**b) Integridad referencial.** Que toda confusión citada exista en el catálogo;
que todo remedio apunte a una lección o experimento real; que todo
`preferredExperimentId` y `lessonId` resuelva; que no haya ids duplicados; que
todo predicado de construcción esté implementado.

**c) Cobertura del catálogo.** Que **cada** confusión del catálogo sea
producida por al menos un distractor. Una confusión que ningún ejercicio puede
detectar es contenido muerto: aparece en el glosario de confusiones pero el
diagnóstico nunca la activará.

**d) Marcas.** Que ningún texto cite una marca `{{id}}` sin ficha declarada, y
avisa de las fichas declaradas que no se usan (excluyendo las que son respuesta
esperada de un ejercicio de cálculo, que no aparecen en el texto a propósito).

> **Esta comprobación encontró dos errores reales durante el desarrollo:** las
> confusiones `orden_ignorado_en_espacio` y `ninguno_es_uno_menos_p` estaban
> catalogadas, enlazadas a remedios y citadas en `detects`, pero **ningún
> distractor las producía**. Se añadieron dos alternativas que las generan
> (`m1_e13` y `m4_e05`). Sin este test habrían llegado al estudiante como
> contenido inerte.

## 3. Capa 2 — Verificación estática

`tool/static_check.py` no sustituye a `dart analyze` —eso corre en CI— pero
atrapa antes lo que más veces rompe una compilación en un proyecto con miles
de líneas de cadenas:

- **Delimitadores desbalanceados**, con un analizador que elimina comentarios y
  cadenas pero **conserva las interpolaciones `${…}`**, porque esas sí llevan
  llaves que deben cuadrar.
- **Imports que no resuelven** a un archivo existente.
- **Imports sin usar**, comparando los símbolos exportados del destino contra
  el cuerpo del importador (los archivos que solo aportan extensiones se
  excluyen: se usan por sus miembros, no por su nombre).
- Restos de `TODO`, `FIXME` o `UnimplementedError`.

## 4. Capa 3 — Suites de test

| Suite | Qué cubre |
|---|---|
| `rational_test` | Exactitud: 1/3 sumado tres veces da 1; complemento; potencias; fracciones ilegibles |
| `combinatorics_test` | Factoriales, C y P, la identidad P(n,k) = C(n,k)·k! para todo n,k ≤ 8, ΣC(n,k) = 2ⁿ, cumpleaños, binomial que suma 1 |
| `probability_engine_test` | Las reglas, el rechazo de datos incoherentes, excluyentes ⇒ dependientes, Bayes, VPP, y que **todo** resultado del motor cae en [0,1] |
| `sample_space_test` | Los espacios construidos, la no uniformidad de las sumas, el álgebra de eventos, los predicados del catálogo |
| `figures_test` | **D5**: toda función existe, toda ficha evalúa, toda marca tiene ficha, no queda ninguna sin sustituir, y cinco cifras clave una por una |
| `content_integrity_test` | Ids únicos, exactamente una alternativa correcta, retroalimentación no trivial, remedios válidos, cobertura de confusiones, eventos de construcción no vacíos |
| `grading_test` | Las tres formas de respuesta, el 60/40, el acierto ciego, el diagnóstico del complemento invertido y del factor k! |
| `diagnosis_mastery_test` | Activación, reducción, decaimiento, niveles, y el **umbral doble**: leer y simular no alcanza sin práctica |
| `simulators_test` | Reproducibilidad por semilla, convergencia, la falacia del jugador desmentida, el desbalance absoluto creciendo |
| `widget_smoke_test` | Arranque, navegación, lección completa, calculadora, cuadrícula y sustitución de cifras, a 360 × 800 px |

Las pruebas de widgets sustituyen `shared_preferences` por una implementación
en memoria y fijan la ventana en 360 × 800 px lógicos: es donde aparecen los
desbordes de `RenderFlex`, así que es donde conviene probar. Cada prueba
termina con `pumpWidget(const SizedBox())` para desmontar limpiamente.

## 5. Estructura del contenido

Todo el contenido es `const` en Dart, no assets JSON. Tres motivos:

1. El compilador verifica tipos y campos obligatorios.
2. Las pruebas de widgets no dependen de E/S (`rootBundle.loadString` con
   archivos grandes cuelga los tests).
3. La app arranca sin `await` y sin pantalla de carga.

```
data/content/
├─ modules_data.dart          4 módulos
├─ lessons_m1..m4.dart        23 lecciones, 84 tarjetas
├─ exercises_m1..m4.dart      96 ejercicios, 319 alternativas
├─ labs_data.dart             5 laboratorios, 16 experimentos
├─ cases_data.dart            12 casos profesionales
├─ misconceptions_data.dart   32 confusiones
├─ glossary_data.dart         54 términos
└─ sample_space_catalog.dart  9 espacios, 15 predicados
```

## 6. Anatomía de un ejercicio

```dart
Exercise(
  id: 'm2_e06',
  moduleId: 'm2',
  kind: ExerciseKind.opcionMultiple,
  difficulty: 3,
  prompt: 'Una enfermedad afecta al 1 %...',
  explanation: 'Con 100 000 personas: 990 verdaderos positivos y 4 950...',
  detects: ['tasa_base_ignorada', 'condicional_invertida'],
  choices: [
    Choice('Alrededor del 17 %', correct: true, feedback: '...'),
    Choice('99 %, que es lo que acierta el test',
        misconceptionId: 'tasa_base_ignorada',
        feedback: 'El 99 % es P(positivo | enfermo). Te preguntan...'),
    ...
  ],
  hints: ['Imagina 100 000 personas y cuenta...'],
)
```

Tres campos hacen el trabajo pesado:

- **`misconceptionId`** en cada distractor: convierte un fallo en un
  diagnóstico.
- **`detects`**: lista qué confusiones puede *descartar* este ítem si se
  acierta, y es lo que permite el −0,5.
- **`feedback`** por alternativa: explica el razonamiento que lleva a esa
  opción, no que sea incorrecta. Un test comprueba que ninguna tiene menos de
  20 caracteres ni dice solo «Incorrecto».

## 7. Las 70 cifras, por categoría

| Categoría | Ejemplos |
|---|---|
| Espacios elementales | P(suma 7) = 1/6 · P(2 caras de 3) = 3/8 · P(corazón o figura) = 11/26 |
| Reglas | P(A∪B) con 0,40/0,30/0,12 = 0,58 · P(al menos uno en 20 con p=0,1) = 87,8 % |
| Urnas | 2 rojas sin reposición = 2/15 · con reposición = 4/25 |
| Fiabilidad | 5 componentes al 98 % en serie = 90,4 % · 3 al 80 % en paralelo = 99,2 % |
| Bayes | VPP(1 %, 99 %, 95 %) = 16,7 % · VPP(10 %, …) = 68,8 % · P(máquina 1 \| defecto) = 0,375 |
| Conteo | C(52,5) = 2 598 960 · C(49,6) = 13 983 816 · CASAS = 30 · rutas 4×3 = 35 |
| Cumpleaños | 23 personas = 50,73 % · 30 = 70,63 % · 50 = 97,04 % |
| Hipergeométrica | 1 defectuosa en 10 de 50 con 5 = 43,1 % |

Ninguna está escrita en el texto: todas se calculan al mostrarse.

## 8. Cómo ampliar el contenido

**Un ejercicio nuevo:** añadirlo a `exercises_mX.dart`. Si usa una cifra,
declarar la `ContentFigure` con una función del registro. Si usa una confusión
nueva, añadirla a `misconceptions_data.dart` **y asegurarse de que algún
distractor la produzca**, o el test fallará.

**Una función nueva del registro:** añadirla a `FigureRegistry` (Dart) **y** a
`PROBABILITY_FNS`/`COUNT_FNS` (Python). Si se olvida la segunda, la
verificación de contenido falla en CI con el nombre de la función.

**Un predicado de construcción nuevo:** añadirlo al `Set` de nombres, al
`switch` de `predicate` y al de `describe` en `sample_space_catalog.dart`.
