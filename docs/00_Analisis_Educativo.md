# Probability Master — Análisis educativo y decisiones de producto

**Fases 1 a 5 de la metodología de la fábrica.** Este documento no describe la app: la justifica.
Todo lo construido después se deriva de aquí.

---

## Fase 1 — El problema real de aprendizaje

El encargo dice «enseñar fundamentos de probabilidad mediante práctica interactiva».
Eso no es todavía un problema. El problema es que **la probabilidad es la única rama
elemental de la matemática donde la intuición del estudiante no está vacía: está ocupada
por creencias erróneas estables**, resistentes a la explicación y adquiridas fuera del aula.

Un estudiante que no sabe derivar simplemente no sabe. Un estudiante que cree que
«ya salieron cuatro caras, ahora toca sello» **sí sabe algo, y lo que sabe es falso**.
Explicarle la definición de independencia no borra esa creencia: la deja convivir con
ella. En el examen usa la definición; en el problema nuevo, y fuera del aula, vuelve la
creencia. Esto está documentado desde Kahneman y Tversky (1972-1983), replicado en
población universitaria por Shaughnessy, Fischbein, Garfield y Konold, y es la razón por
la que las tasas de error en preguntas conceptuales de probabilidad apenas mejoran
después de un curso tradicional aprobado.

De ahí la definición operativa del problema que adopta esta app:

> El estudiante universitario **aprueba probabilidad calculando y la sigue entendiendo mal**.
> Aprende a ejecutar fórmulas (combinatoria, Bayes, regla de la suma) sobre problemas ya
> clasificados por el enunciado, y no adquiere lo único que se usa después: **decidir qué
> clase de problema tiene delante** y **no dejarse llevar por una intuición que falla**.

Ese problema se descompone en seis fallos tratables. Cada uno tiene un dueño en la app.

| # | Fallo | Síntoma observable | Dónde se ataca |
|---|---|---|---|
| **F1** | **La intuición frecuentista está rota** | Falacia del jugador, «ley de los promedios», creer que 20 lanzamientos ya deben mostrar el 50 % | Módulo 1 + Lab *Ley de los grandes números* |
| **F2** | **El espacio muestral no se construye, se adivina** | Sesgo de equiprobabilidad: con dos dados, «suma 7» y «suma 12» se sienten igual de probables; con tres monedas se cuentan 4 casos en vez de 8 | Módulo 1 + Lab *Fábrica de espacios muestrales* |
| **F3** | **Excluyente e independiente se confunden** | Sumar probabilidades de eventos que se solapan, multiplicar las de eventos dependientes, llamar «independientes» a eventos disjuntos | Módulo 2 + Lab *Mesa de eventos* |
| **F4** | **La condicional se invierte y la tasa base se ignora** | Leer P(A\|B) como P(B\|A); en el test médico, responder «99 %» cuando la respuesta es ≈ 9 % | Módulo 2 + Lab *Urnas y evidencia* |
| **F5** | **Se cuenta sin saber qué se cuenta** | Elegir combinación donde el orden importa (y al revés), contar con reposición cuando no la hay, no ver que el numerador y el denominador deben contarse **con el mismo criterio** | Módulo 3 + Lab *Máquina de conteo* |
| **F6** | **El problema no se clasifica** | Frente a un enunciado sin etiqueta, el estudiante busca una fórmula parecida en vez de preguntarse qué experimento es | Módulo 4 + Tutor probabilístico |

Un séptimo fallo los atraviesa y condiciona todo el diseño de evaluación:
**acertar sin entender.** En probabilidad es fácil: muchas preguntas admiten dos o tres
respuestas plausibles, y con «1/2» se acierta una cantidad indecente de veces. Por eso en
esta app **el número correcto no vale por sí solo** (ver decisión D4).

### Usuario objetivo

Estudiante universitario de 1.º-3.º ciclo que cursa Probabilidad, Estadística I,
Matemática Discreta o un curso de métodos cuantitativos, en cualquiera de las carreras del
proyecto (Minas, Sistemas, Electrónica, Ambiental, Administración, Economía, Contabilidad,
Psicología, Biología, Humanidades, Desarrollo personal). Perfil típico: llega con
secundaria débil en conteo, con calculadora en el teléfono y con las seis creencias
erróneas de arriba intactas.

Usuario secundario: el docente que necesita un material de práctica que **no sea otro
banco de preguntas**.

### Competencia profesional desarrollada

> *Modela una situación de incertidumbre: identifica el experimento aleatorio, construye o
> cuantifica su espacio muestral, expresa el suceso de interés en términos de eventos
> conocidos, elige la regla o el conteo correcto, calcula, y **declara qué supuestos asumió
> y cuándo su resultado dejaría de ser válido**.*

La segunda mitad de esa frase es la que distingue a un profesional de una calculadora, y
es la que casi nunca se evalúa.

---

## Fase 2 — Validación académica

**Cursos relacionados.** Probabilidad y Estadística (tronco común de las 11 carreras del
catálogo), Matemática Discreta (Sistemas), Estadística Aplicada, Investigación de
Operaciones, Confiabilidad (Electrónica, Minas), Epidemiología y Bioestadística
(Biología), Auditoría por muestreo (Contabilidad), Psicometría (Psicología).

**Tópicos fundamentales exigidos por el encargo** (eventos, espacio muestral, reglas,
conteo) y su lugar real en el currículo:

| Tópico | Se enseña en | Dificultad documentada |
|---|---|---|
| Experimento aleatorio, espacio muestral, evento | Semana 1-2 | Se despacha en 20 minutos y nunca se practica construyendo; luego todo lo demás falla |
| Definiciones de probabilidad (clásica, frecuentista, subjetiva) | Semana 2 | El estudiante no distingue *cuándo* aplica Laplace (requiere equiprobabilidad, y casi nadie verifica esa condición) |
| Axiomas y propiedades | Semana 3 | Se memorizan; el complemento («al menos uno») no se reconoce como atajo |
| Reglas de suma y producto | Semana 3-4 | **Máximo punto de fuga del curso**: excluyente vs. independiente |
| Probabilidad condicional | Semana 4-5 | Inversión de la condicional; tablas de contingencia mal leídas |
| Teorema de Bayes | Semana 5-6 | Se aplica como fórmula; la tasa base no se interpreta |
| Técnicas de conteo | Semana 6-7 | Se enseña *después* de las reglas, cuando se necesitaba *antes* para contar Laplace |
| Variables aleatorias | Semana 8+ | **Fuera del alcance de este MVP** (ver Fase 4) |

**Hallazgo que cambia el producto:** el orden curricular habitual (reglas → conteo) es el
inverso del orden lógico (conteo → Laplace → reglas). La app **no lo reordena** —el
estudiante necesita que coincida con su curso— pero sí hace que el módulo 1 enseñe a
contar espacios muestrales pequeños *enumerándolos*, de modo que cuando el módulo 3
introduce las fórmulas de conteo, el estudiante ya sabe **qué está contando la fórmula**.
Esa es la diferencia entre aprender combinatoria y aprender a usarla.

**Aplicación profesional** (una por carrera, materializada en los 12 casos del módulo 4):
control de calidad y muestreo de aceptación, confiabilidad de sistemas redundantes,
diagnóstico y tamizaje, riesgo de auditoría, fiabilidad de componentes en serie/paralelo,
genética mendeliana, seguridad minera, spam/clasificadores, seguros y expectativa,
inventario y demanda, prueba de hipótesis intuitiva.

---

## Fase 3 — Diseño de la experiencia educativa

### Principio rector: **Predice → Simula → Explica**

Ninguna simulación de esta app arranca sin que el estudiante registre una predicción.
Los controles del laboratorio están **desactivados** hasta que lo hace, y la conclusión
permanece bloqueada hasta alcanzar el mínimo de repeticiones.

La razón es específica de este dominio: una creencia errónea que no se hace explícita no
se corrige, porque el estudiante que ve el resultado correcto **reinterpreta su intuición
previa para que coincida** («yo pensaba eso»). Registrar la predicción antes convierte la
corrección en un hecho verificable para el propio estudiante. La app guarda el indicador
*intuición inicial* (predicciones acertadas) y **no penaliza** fallar: fallar es el punto.

### Cómo aprende el estudiante, en orden

1. **Ve** el fenómeno en un laboratorio (frecuencia relativa oscilando y estabilizándose,
   el espacio muestral llenándose, los diagramas de Venn solapándose).
2. **Predice y falla** en la pregunta trampa del laboratorio.
3. **Lee** la lección corta que nombra lo que acaba de ver (tarjetas de 1 pantalla).
4. **Practica** con ejercicios donde cada alternativa incorrecta está enlazada a una
   confusión concreta y devuelve una retroalimentación propia.
5. **Aplica** en un caso profesional de su carrera, donde debe elegir *y justificar*.
6. **Recibe diagnóstico**: el tutor le dice qué confusión tiene activa y a qué experimento
   o lección volver.

### Interacción principal

Manipulación directa de experimentos aleatorios: arrastrar el número de repeticiones,
cambiar la probabilidad de la moneda sesgada, marcar casillas en la cuadrícula de 36
resultados de dos dados, mover los círculos de Venn, elegir con o sin reposición en la
urna, construir selecciones en la máquina de conteo. **Nada de lo importante se aprende
leyendo.**

### Tipos de ejercicio (6)

| Tipo | Qué evalúa | Antídoto contra |
|---|---|---|
| Opción múltiple con confusión etiquetada | Reconocimiento conceptual | F1-F5 |
| Cálculo con tolerancia y forma (fracción / decimal / porcentaje) | Ejecución | — |
| **Clasificación de problema** (¿qué regla, qué conteo, con o sin reposición, importa el orden?) | *Solo* la decisión, sin calcular | **F6** |
| **Construcción de espacio muestral** (marcar resultados en la cuadrícula) | Conteo por enumeración | F2, F5 |
| **Elección + justificación** (60/40) | Razonamiento | acierto ciego |
| **Detección de error** (un desarrollo ajeno que hay que auditar) | Transferencia | F3, F4 |

### Gamificación: deliberadamente sobria

Racha de días, dominio por módulo, insignias por laboratorio completado con predicción
registrada. **Sin vidas, sin ranking, sin temporizador.** Un cronómetro en probabilidad
empuja exactamente al comportamiento que la app combate: responder con la primera
intuición.

---

## Fase 4 — Definición del MVP

**Dentro (v1.0):**

- 4 módulos, 23 lecciones, 84 tarjetas.
- 5 laboratorios con 16 experimentos parametrizables.
- 96 ejercicios de 6 tipos, con **319 alternativas** que llevan
  retroalimentación propia.
- 12 casos profesionales (11 carreras + 1 transversal).
- Tutor probabilístico determinista: diagnóstico de 32 confusiones,
  clasificador de problemas (árbol de 7 preguntas, 11 nodos) y solucionador
  paso a paso con 13 métodos.
- Calculadora de probabilidad y conteo, con interpretación redactada.
- Glosario de 54 términos.
- Progreso local, sin cuenta, sin red.

*(Las cifras de esta lista son las realmente entregadas y las verifica
`tool/verify_content.py` en cada compilación.)*

**Fuera (v1.x / v2), con motivo:**

| Excluido | Por qué |
|---|---|
| Variables aleatorias, esperanza, varianza | Es el siguiente curso; meterlo duplica el alcance y diluye los cuatro temas pedidos |
| Distribuciones (binomial, Poisson, normal) | Ídem. El motor ya calcula binomial para los laboratorios, pero no se enseña como tema |
| Backend, cuentas, sincronización | El MVP no necesita servidor; además permite que CI compile sin secretos |
| Modo docente / aula | Requiere backend |
| LLM en el dispositivo | Ver Fase 5 |

**Control de sobreingeniería:** dos dependencias de producción (`flutter_riverpod`,
`shared_preferences`). Sin `build_runner`, sin router declarativo, sin librería de
gráficos, sin ORM. Todo el contenido es `const` en Dart (no assets JSON): el compilador lo
verifica y las pruebas de widgets no dependen de E/S de archivos.

---

## Fase 5 — Evaluación tecnológica y decisión sobre IA

El encargo pide un **tutor probabilístico**. La pregunta correcta no es «¿ponemos IA?»
sino **«¿qué tiene que hacer el tutor, y qué tecnología lo hace mejor?»**.

Lo que el tutor tiene que hacer, en orden de valor:

1. **Saber qué confusión tiene *este* estudiante.** → Se resuelve con el historial de
   etiquetas de confusión, no con un modelo de lenguaje. Un LLM tendría que *inferir* lo
   que la app ya *sabe* con certeza.
2. **Enseñar a clasificar problemas.** → Árbol de decisión explícito de 7 preguntas, que
   además es el método que el estudiante debe internalizar. Un modelo que da la respuesta
   correcta sin exponer el árbol no enseña el árbol.
3. **Resolver paso a paso mostrando el porqué de cada paso.** → Solucionador simbólico
   sobre el registro de funciones. Produce los mismos números que la app (crítico) y nunca
   se equivoca.
4. **Conversar en lenguaje natural.** → *Esto* sí lo hace mejor un LLM, y es lo único de la
   lista que un LLM hace mejor.

**Decisión: tutor determinista en el MVP, con adaptador de LLM preparado y no activado.**

Los riesgos de poner un modelo generativo a calcular probabilidad son caros y conocidos:
alucinar un valor (el estudiante no tiene cómo detectarlo), contradecir el número que la
propia app muestra, reproducir la falacia del jugador —que abunda en el texto de
internet—, o invertir una condicional. En un dominio donde **el error tiene la misma forma
que la respuesta correcta**, un tutor que se equivoca el 3 % de las veces es peor que no
tener tutor.

El adaptador queda definido (`ProbabilityTutorClient`, inyectado por provider) con una
regla fija para v2: **el modelo redacta, el motor calcula**. El modelo nunca produce un
número ni toca el puntaje.

**Otras tecnologías evaluadas:** simulación (**sí**, es el corazón del producto: PRNG
propio con semilla reproducible); realidad aumentada (**no**, la aleatoriedad no es un
fenómeno espacial); voz (**no**); gráficos con librería (**no**, los laboratorios exigen
geometría expuesta —sombrear una región de Venn, resaltar 6 celdas de 36, dibujar un árbol
de 8 ramas— y un `CustomPainter` propio pesa menos que la librería que haría falta);
almacenamiento (**local**, `shared_preferences` con JSON).

---

## Las seis decisiones que definen el producto

**D1 · La predicción obligatoria.** Ya explicada. Es la única forma de que una simulación
cambie una creencia en vez de decorarla.

**D2 · El espacio muestral se enumera antes de contarse.** El módulo 1 obliga a construir
a mano espacios de 4, 6, 8, 36 y 52 resultados. Cuando el módulo 3 dice «hay C(52,5)
manos», el estudiante ya sabe qué objeto está siendo contado. Sin esto, la combinatoria es
un catálogo de fórmulas con nombres parecidos.

**D3 · Cada distractor declara su confusión.** 32 etiquetas (`falacia_jugador`,
`excluyente_es_independiente`, `condicional_invertida`, `tasa_base_ignorada`,
`orden_importa_confundido`, `al_menos_uno_suma`, `equiprobabilidad_asumida`…) enlazadas a
las alternativas incorrectas. Acertar no aporta información; **fallar de una manera
concreta, sí**. El diagnóstico suma 1 por error, resta 0,5 por acierto posterior en un
ítem capaz de detectar esa confusión, y decae 3 % por evento para que una confusión
superada desaparezca sola.

**D4 · Regla 60/40 y umbral doble.** En los ejercicios de decisión, la elección vale 0,6 y
la justificación 0,4; el «acierto ciego» (número correcto, razón incorrecta) se reporta
como indicador propio. El dominio de módulo es 15 % lecciones + 15 % laboratorios + 70 %
práctica, y «competente» exige **0,70 en el total y 0,70 en la práctica**: leer y simular
no compensan razonar mal.

**D5 · Todo número mostrado es calculado, ninguno está escrito a mano.** Las
probabilidades que el estudiante ve —incluidas las de los enunciados y las
retroalimentaciones— salen del motor a través de un **registro de funciones con nombre**
(`fn` + `args`). Un test recalcula las 62 cifras declaradas en el contenido con el motor
real, y una réplica en Python las vuelve a calcular de forma independiente en CI.

**D6 · Aritmética exacta donde importa.** Las probabilidades de espacios finitos se
calculan como **fracciones exactas** (`Rational`, con `BigInt`), no en punto flotante.
Motivo pedagógico y no de precisión: el estudiante debe ver `11/36`, no `0.3055555…`; y
motivo técnico: los factoriales de C(52,5) y del problema del cumpleaños desbordan `int`
en 64 bits con facilidad.

---

## Diferencia con las apps ya construidas del catálogo

| App | Pregunta que enseña a responder |
|---|---|
| *Estadística Fundamental* | ¿Qué medida describe estos datos y cómo se lee? |
| *Data Visualization Lab* | ¿Qué me está ocultando este gráfico? |
| *Inferencia Estadística* | ¿Qué puedo concluir de una muestra y con qué riesgo? |
| **Probability Master** | **¿Qué tan probable es esto, y por qué mi intuición dice otra cosa?** |

Es el **prerrequisito** de *Inferencia Estadística*: sin probabilidad condicional y sin
espacio muestral no hay p-valor que se entienda. Completa la secuencia
**describir → visualizar → cuantificar el azar → inferir**.

---

## Limitaciones declaradas

1. **No cubre variables aleatorias ni distribuciones como tema.** Un estudiante que
   necesite binomial o normal no las encontrará enseñadas aquí.
2. **Construida sin SDK de Flutter en el entorno**: verificada por réplica del motor en
   Python, recálculo de cifras y verificación estática; **no ejecutada en dispositivo**.
   La primera compilación real ocurre en GitHub Actions.
3. **El tutor no conversa.** Diagnostica, clasifica y resuelve; no responde preguntas
   abiertas escritas en lenguaje natural.
4. **Los casos profesionales son verosímiles, no auditados por un especialista de cada
   carrera.** Los números son correctos; la representatividad del escenario conviene
   revisarla con un docente del área antes de uso institucional.
5. **Un solo idioma (español).** No hay infraestructura de internacionalización en el MVP.
