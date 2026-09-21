# Probability Master — Especificación funcional

Qué hace cada pantalla, con qué reglas y qué estado guarda.

---

## RF-1 · Inicio

**Muestra:** marca, dominio general (anillo con el umbral del 70 % marcado),
racha de días, respuestas dadas, experimentos hechos, **una sola
recomendación** con su motivo, hasta 3 confusiones activas, los 4 módulos con
su dominio, accesos a Casos y Calculadora.

**Regla de recomendación** (orden estricto, la primera que aplique):

1. Confusión activa de nivel ≥ 2 con remedio enlazado → ese experimento o
   lección.
2. Experimento del módulo en curso sin hacer.
3. Lección pendiente del módulo en curso.
4. Práctica del módulo cuyo dominio de práctica < 0,70.
5. Todo al día → invita a los casos de otras carreras.

Nunca se recomienda sin decir el motivo. El motivo cita la cifra concreta
(«tu práctica está en 43 %»), no una frase genérica.

## RF-2 · Módulos

**Lista:** cada módulo con su anillo de dominio, la pregunta que enseña a
responder, el desglose 15/15/70 en tres barras y los recuentos de contenido.

**Detalle:** laboratorios primero (por diseño), luego lecciones, luego
práctica, y en el módulo 4 también los casos. Cada elemento muestra si está
hecho; las lecciones muestran «tarjetas vistas / total».

## RF-3 · Lección

Una tarjeta por pantalla, con `PageView`. Barra de progreso por tarjetas.
Cada tarjeta declara su tipo (Idea, Regla, Ejemplo, Confusión frecuente,
Conexión) y puede declarar qué confusión desactiva, que se muestra en un
bloque propio.

**Estado guardado:** número de tarjetas vistas por lección; la lección se marca
completa al llegar a la última.

## RF-4 · Experimento (el núcleo)

Tres pasos, en orden y sin posibilidad de saltarlos:

**Paso 1 — Predice.** Pregunta de predicción, de porcentaje (deslizador) o de
opción. Hasta responder, **el cuerpo del laboratorio no se muestra**. Al
registrarla, la app calcula si acertó y lo guarda como «intuición inicial».
No penaliza.

**Paso 2 — Simula.** Controles propios de cada laboratorio (ver
`docs/01`, sección 5), botón de simular y botón de cambiar semilla. La semilla
se muestra siempre: cualquier corrida es reproducible, y esto importa para que
un docente pueda repetir en clase lo que un alumno vio.

**Paso 3 — Explica.** El hallazgo permanece **bloqueado** hasta alcanzar
`minTrials` repeticiones acumuladas, y el bloqueo dice cuántas faltan y por
qué existe. Desbloqueado, ofrece ir a la lección que formaliza lo visto.

**Estado guardado:** experimento hecho, si la predicción fue correcta (solo la
**primera** vez: repetir sabiendo el resultado no puede mejorar el indicador),
repeticiones máximas y semilla.

## RF-5 · Práctica

Seis tipos de ejercicio, en una cola por módulo:

| Tipo | Interacción | Puntaje |
|---|---|---|
| Concepto | Alternativas | 1 / 0 |
| Cálculo | Campo de texto (fracción, decimal o porcentaje) | 1 / 0 |
| Clasificación | Alternativas, sin calcular | 1 / 0 |
| Construcción | Marcar celdas en la cuadrícula del espacio muestral | 1 / 0 |
| Decisión | Alternativa **+ justificación** | 0,6 + 0,4 |
| Auditoría | Encontrar el error en un desarrollo ajeno | 1 / 0 |

**Reglas de corrección:**

- Toda alternativa incorrecta devuelve **su propia** retroalimentación, que
  explica el razonamiento que lleva a ella. Nunca «Incorrecto».
- La respuesta numérica se lee en las tres formas y diagnostica el error:
  complemento invertido, valor fuera de [0,1], factor 2 (intersección contada
  dos veces), factor 1/2 (orden olvidado).
- La respuesta de conteo se compara como entero exacto; si el cociente entre lo
  dado y lo correcto es un factorial, se nombra: «tu resultado es 120 = 5!
  veces el correcto».
- La construcción informa cuántas celdas faltaron y cuántas sobraron, y
  muestra la probabilidad exacta del evento correcto.
- Pistas escalonadas a petición, que **nunca dan el número**.

**Estado guardado:** mejor intento por ítem (el dominio no baja por repetir),
historial completo, confusiones activadas.

## RF-6 · Casos profesionales

Escenario, datos tabulados, pregunta de decisión, alternativas y
justificaciones. Tras responder: resolución completa y un bloque separado de
**supuestos y límites** que declara qué se asumió y cuándo el resultado dejaría
de valer.

Selector de carrera que reordena la lista. Dos de los doce casos tienen como
respuesta correcta «con estos datos no corresponde calcular».

## RF-7 · Tutor

**Diagnóstico.** Confusiones activas agrupadas por familia, con nivel (leve,
marcada, persistente), la creencia en primera persona, la corrección, el
síntoma y los botones de remedio. Cuatro indicadores: activas, superadas,
aciertos ciegos, intuición inicial.

**Clasificar.** Árbol de 11 nodos y 7 preguntas distintas. Cada opción puede
llevar a otro nodo o a un método. Al llegar al método se muestran su título,
su **condición de uso** y el camino recorrido («tu razonamiento»), y se ofrece
resolverlo en la calculadora.

**Resolver.** Los 13 métodos con calculadora, cada uno con su condición.

## RF-8 · Calculadora

Selector de método, campos con valores por defecto y ayuda, validación
(una probabilidad fuera de [0,1] se rechaza explicando que es un error de
método), resultado en las tres formas, pasos numerados con expresión y nota, y
advertencias de supuestos.

## RF-9 · Progreso

Cuatro casillas de resumen, dominio por módulo con la barra del umbral,
advertencia explícita cuando el total llega al 70 % pero la práctica no, los
cuatro indicadores propios con su explicación, y reinicio con confirmación.

## RF-10 · Glosario

54 términos con buscador y filtro por módulo. Cada uno con definición,
notación cuando la tiene y el **error frecuente** al usarlo.

---

## Reglas transversales

**RT-1 · Dominio.** `0,15·lecciones + 0,15·laboratorios + 0,70·práctica`.
La práctica promedia el mejor intento de cada ítem **sobre el total de ítems
del módulo**, no sobre los intentados: responder tres ejercicios fáciles no
infla nada.

**RT-2 · Competencia.** Exige ≥ 0,70 en el total **y** ≥ 0,70 en la práctica.

**RT-3 · Diagnóstico.** +1 por error que activa la confusión; −0,5 por acierto
posterior en un ítem capaz de detectarla; ×0,97 por cada evento registrado.
Se reporta activa desde 0,8; leve < 1,8 ≤ marcada < 3,0 ≤ persistente.

**RT-4 · Cifras.** Todo número mostrado proviene del motor a través del
registro de funciones con nombre. El contenido no escribe números.

**RT-5 · Persistencia.** Un único JSON en `shared_preferences`. Si está
corrupto, la app arranca con progreso vacío en vez de fallar.

**RT-6 · Sin red.** La app no hace ninguna petición. No hay permisos que pedir.
