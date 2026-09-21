# Probability Master — Limitaciones y evolución

Lo que esta versión **no** hace, por qué, y qué haría falta para que lo hiciera.

---

## 1. Limitaciones declaradas

### L1 · No se ha ejecutado en un dispositivo

La app se construyó **sin SDK de Flutter en el entorno**. No se compiló, no se
corrió `flutter test` y no se vio en pantalla.

**Cómo se mitigó:** tres capas de verificación (ver `docs/04`), dos de ellas
sin Flutter, incluida una réplica independiente del motor en Python que
recalcula las 70 cifras del contenido.

**Qué queda por comprobar y solo se ve compilando:** posibles desbordes de
`RenderFlex` en pantallas concretas, el rendimiento real de las simulaciones
grandes en un teléfono modesto, el aspecto del tema oscuro, y la coherencia del
icono adaptativo en distintos lanzadores de Android.

**Primera puerta:** el job `analyze_test` de `ci.yml`. Es la compilación que
convierte esta limitación en información.

### L2 · Alcance: no cubre variables aleatorias

Fuera del MVP: variables aleatorias, esperanza, varianza, distribuciones como
tema (binomial, Poisson, normal), variables continuas.

**Por qué:** es el siguiente curso. Incluirlo duplicaría el alcance y diluiría
los cuatro temas que el encargo pide. El motor ya calcula binomial e
hipergeométrica, pero se usan como **modelos** en el módulo 4, no como tema con
lecciones propias.

### L3 · El tutor no conversa

Diagnostica, clasifica y resuelve paso a paso. No responde preguntas abiertas
escritas por el estudiante.

**Por qué, otra vez:** en un dominio donde el error tiene la misma forma que la
respuesta correcta —una fracción plausible—, un modelo que acierta el 97 % es
peor que no tener tutor, porque el estudiante no puede detectar el 3 %
restante. El análisis lo desarrolla en la Fase 5.

### L4 · Los casos no están auditados por especialistas

Los 12 casos son verosímiles y sus números son correctos y verificados. Pero la
**representatividad del escenario** —si así se trabaja realmente en una
auditoría, en una mina o en un laboratorio de biología— no ha sido revisada por
un docente de cada área.

**Antes de un uso institucional:** revisión por un docente de cada una de las
11 carreras. Es media hora por caso.

### L5 · Un solo idioma

No hay infraestructura de internacionalización. Todo el contenido está en
español, incluido el de la interfaz.

### L6 · Sin modo docente ni panel de grupo

El progreso es local y privado. No hay forma de que un docente vea el avance de
su clase.

**Por qué:** exigiría backend, cuentas y una política de datos de menores. El
MVP lo descarta a propósito, y esa decisión es también lo que permite que CI
compile sin secretos y que la app no pida ningún permiso.

### L7 · Simulaciones en el hilo de UI

Los máximos actuales (50 000 ensayos, 200 000 personas) se ejecutan en el hilo
principal. La medición dice que ninguno pasa de ~15 ms, así que no se
justificaba un `Isolate`. Si v2 sube los máximos, el corte natural está claro:
`Simulators` es Dart puro sin dependencias de Flutter, así que moverlo a un
isolate es un cambio local.

### L8 · Accesibilidad no verificada

Los contrastes de la paleta se eligieron con criterio, pero **no se han medido
con un verificador WCAG**, y no se ha probado con lector de pantalla. Los
gráficos con `CustomPainter` no tienen etiquetas semánticas: un usuario con
lector de pantalla puede usar las lecciones y los ejercicios, pero no los
laboratorios.

Es la limitación que más incomoda de esta lista, porque tiene solución conocida
y no se ha aplicado: `Semantics` alrededor de cada gráfico con una descripción
textual del hallazgo.

---

## 2. Roadmap

### v1.1 — Cerrar lo que quedó abierto

| Ítem | Esfuerzo | Por qué primero |
|---|---|---|
| Compilar y probar en dispositivo real | Bajo | Convierte L1 en información |
| Etiquetas `Semantics` en los 6 pintores | Medio | Cierra la mitad de L8 |
| Verificación de contraste WCAG AA | Bajo | Cierra la otra mitad |
| Revisión de los 12 casos por docentes | Medio | Cierra L4; es lo que separa «verosímil» de «validado» |
| Clave de firma de producción | Bajo | Requisito para publicar |

### v1.2 — Más contenido sobre la misma arquitectura

Todo lo siguiente se añade **sin tocar código**, solo declarando contenido:

- 30-40 ejercicios más, sobre todo de construcción y decisión, que son los
  tipos con menos ítems (5 y 6 respectivamente).
- 6-8 casos profesionales más, para tener al menos dos por carrera.
- Un laboratorio más: *Simulación de Montecarlo* (aproximar una probabilidad
  difícil simulando), que encaja con el motor existente.
- Modo repaso espaciado sobre las confusiones superadas, para comprobar que
  siguen superadas un mes después.

### v2 — Lo que exige arquitectura nueva

**Tutor conversacional, con la regla intacta.** Activar
`ProbabilityTutorClient` con un modelo de lenguaje, bajo la regla que ya está
escrita en el tipo: **el modelo redacta, el motor calcula**. El modelo recibe
la explicación determinista ya generada y los pasos ya computados, y solo puede
reformularla al nivel del estudiante. No recibe el enunciado sin el resultado y
no puede devolver números.

Antes de activarlo hace falta: un evaluador de reformulaciones que verifique
que el texto generado no contiene cifras nuevas, y una decisión sobre dónde
corre el modelo (en el dispositivo, con las limitaciones que eso impone, o en
un servidor, con las implicaciones de privacidad que el MVP hoy no tiene).

**Variables aleatorias y distribuciones.** Módulos 5 y 6. El motor ya tiene la
base exacta; haría falta un pintor de función de masa y densidad, y decidir si
la app sigue siendo «fundamentos» o se convierte en un curso completo.

**Modo docente.** Requiere backend, cuentas y política de datos. Es el cambio
que más altera la naturaleza del producto, y conviene decidirlo como producto
antes que como técnica.

**Internacionalización.** El contenido está separado del código, así que
traducir es traducir `data/content/`. El trabajo real no es técnico: es que la
retroalimentación por alternativa está escrita con mucho cuidado y una
traducción literal la estropea.

---

## 3. Deuda técnica conocida

| Deuda | Dónde | Coste de arreglarla |
|---|---|---|
| El árbol del clasificador no cubre espacios continuos | `problem_classifier.dart` | Bajo; hoy no hace falta porque el MVP no los cubre |
| `ContentText` no soporta tablas reales (las muestra monoespaciadas) | `content_text.dart` | Medio; funciona bien y no ha molestado |
| La trayectoria de los gráficos se submuestrea a 120 puntos fijos | `simulators.dart` | Bajo; es una constante |
| No hay animación al revelar la corrección de un ejercicio | `exercise_screen.dart` | Bajo; es pulido, no función |
| `MasteryService.compute` recibe `caseCount` y no lo usa | `mastery_service.dart` | Trivial; queda del diseño anterior |

## 4. Lo que NO se piensa hacer

Vale la pena dejarlo escrito, porque son las peticiones que suelen llegar:

- **Ranking entre estudiantes.** Empuja a responder rápido, que es exactamente
  el comportamiento que la app combate.
- **Temporizador por ejercicio.** Ídem.
- **Vidas o rachas que se pierden.** Castigar el error en una app cuyo
  mecanismo central es fallar la predicción sería incoherente.
- **Un LLM que calcule.** Ni con supervisión. La regla «el modelo redacta, el
  motor calcula» no es una fase del roadmap: es una restricción permanente.
- **Generar ejercicios automáticamente.** El valor de estos 96 está en las 319
  retroalimentaciones escritas una por una, cada una explicando el razonamiento
  que lleva a esa alternativa. Un generador produciría cantidad y perdería
  exactamente lo que hace que la app funcione.
