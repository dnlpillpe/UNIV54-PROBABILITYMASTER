# Probability Master — Documento de producto

**Versión 1.0.0 (MVP) · Área: Probabilidad (transversal a todas las carreras)**

---

## 1. Identidad

| | |
|---|---|
| **Nombre** | Probability Master |
| **Lema** | Domina el azar con tus propios experimentos |
| **Promesa** | No enseña a calcular probabilidades: enseña a reconocer qué clase de problema tienes delante y a desconfiar de la intuición que falla |
| **Usuario** | Estudiante universitario de 1.º-3.º ciclo, cualquier carrera |
| **Plataforma** | Android (iOS preparado), Flutter |
| **Modelo** | Sin cuentas, sin red, sin telemetría, sin anuncios |

## 2. Propuesta de valor

Hay muchas apps que enseñan probabilidad. Casi todas son un libro digital con
un cuestionario. Esta se distingue en tres cosas concretas, y las tres son
comprobables por el usuario en los primeros cinco minutos:

**1. La simulación va antes que la teoría, y es obligatorio predecir.** El
estudiante no lee «la moneda no tiene memoria»: lo apuesta, lo simula 5 000
veces y ve que su apuesta era falsa. Los controles del laboratorio están
literalmente bloqueados hasta que registra su predicción.

**2. La app sabe qué está confundiendo, no solo qué falló.** Cada alternativa
incorrecta declara la creencia errónea que la produce. El informe no dice
«60 % de aciertos en el módulo 2»: dice «tienes activa la falacia del jugador,
y este experimento la contradice con tus propios datos».

**3. Acertar el número no basta.** En los ítems de decisión, la justificación
vale el 40 %, y el «acierto ciego» —número correcto, razón equivocada— se
reporta como indicador propio. Es la diferencia entre aprobar un examen y poder
defender un informe.

## 3. Mapa del producto

```
Inicio ─────────────► Siguiente paso (una sola recomendación, con su motivo)
  │                   Confusiones activas (con remedio enlazado)
  │                   Los cuatro módulos, con su dominio
  │
Aprender ───────────► Módulo ─► Laboratorios ─► Experimento (predice/simula/explica)
  │                            ─► Lecciones ──► Tarjetas (una idea por pantalla)
  │                            ─► Práctica ───► Ejercicios (6 tipos)
  │                            ─► Casos (solo módulo 4)
  │
Laboratorios ───────► Los 5 laboratorios, 16 experimentos
  │
Tutor ──────────────► Diagnóstico · Clasificar · Resolver
  │
Progreso ───────────► Dominio por módulo, indicadores propios, reinicio
  │
Glosario ───────────► 54 términos, con el error frecuente de cada uno
Calculadora ────────► 13 métodos, con pasos y condición de uso
```

## 4. Los cuatro módulos

| # | Módulo | La pregunta que enseña a responder | Contenido |
|---|---|---|---|
| 1 | **Fundamentos** | ¿De qué hablamos cuando decimos «probable»? | 6 lecciones · 7 experimentos · 25 ejercicios |
| 2 | **Eventos** | ¿Cómo se combinan dos sucesos sin equivocarse? | 8 lecciones · 6 experimentos · 28 ejercicios |
| 3 | **Conteo** | ¿Cuántos casos hay, y los estoy contando dos veces? | 5 lecciones · 3 experimentos · 25 ejercicios |
| 4 | **Problemas** | ¿Qué clase de problema tengo delante? | 4 lecciones · 18 ejercicios · 12 casos |

## 5. Los cinco laboratorios

| Laboratorio | Qué se manipula | Hallazgo que produce |
|---|---|---|
| **Ley de los grandes números** | p de la moneda, repeticiones, largo de racha | La proporción se estabiliza hacia los 2 500 lanzamientos; la **diferencia absoluta crece** con √n; tras 4 caras seguidas el siguiente lanzamiento sigue siendo 50 % |
| **Fábrica de espacios muestrales** | El evento marcado sobre la cuadrícula de 36, 8 o 52 celdas | Las 11 sumas de dos dados NO son equiprobables: 7 sale de 6 maneras y 12 de una |
| **Mesa de eventos** | P(A), P(B) y P(A∩B) sobre una población simulada | Excluyentes ⇒ **dependientes**; P(A\|B) y P(B\|A) comparten numerador y no denominador |
| **Urnas y evidencia** | Composición, reposición; prevalencia, sensibilidad, especificidad | Sin reposición la segunda extracción depende de la primera; con prevalencia 1 % un positivo del test «99 % fiable» vale 16,7 % |
| **Máquina de conteo** | Tamaño del grupo, bombo de lotería, n y k | 23 personas bastan para el 50 % de coincidencia; C(5,3) y P(5,3) enumerados lado a lado |

## 6. Gamificación (deliberadamente sobria)

**Hay:** racha de días, dominio por módulo con umbral visible, indicador de
intuición inicial, confusiones superadas.

**No hay:** vidas, ranking, temporizador, monedas, recompensas aleatorias. Un
cronómetro en probabilidad empuja exactamente al comportamiento que la app
combate: responder con la primera intuición.

## 7. Identidad visual

La paleta no es decorativa; cada color tiene un significado fijo que el
estudiante aprende sin que se lo digan:

| Color | Significado | Dónde |
|---|---|---|
| **Índigo** `#4B3FD6` | Lo teórico, lo exacto, la fórmula | Línea teórica de los gráficos, módulo 1, evento A |
| **Turquesa** `#12A594` | Lo observado, lo simulado | Curva de frecuencia relativa, módulo 2 |
| **Ámbar** `#E9A13B` | El azar en bruto y los umbrales | Dados, predicción, marca del 70 % |
| **Rosa** `#DD5C82` | El evento B, los casos profesionales | Venn, módulo 4 |
| **Rojo** `#D1445C` | Confusión detectada | Nunca «respuesta incorrecta» a secas |

El par índigo/turquesa aparece en todos los gráficos de convergencia: la línea
de la fórmula y la línea de lo que realmente pasó.

**Icono.** Un dado blanco sobre una curva de convergencia turquesa que oscila y
se estabiliza, en fondo índigo, con un punto ámbar en el valor al que converge.
Dice de qué trata el producto en un solo gráfico. Lo genera
`tool/generate_icon.py` reproduciendo en Pillow el mismo dibujo que
`BrandPainter` hace en Flutter: el icono de la tienda y el logotipo de la
pantalla de inicio no pueden divergir.

## 8. Criterios de calidad (checklist del proyecto)

| Criterio | Cómo lo cumple |
|---|---|
| Tener valor educativo real | Ataca seis fallos documentados, no «cubre temas» |
| Resolver un problema específico | La intuición rota, no «aprender probabilidad» |
| Diferenciarse de un libro digital | 16 simulaciones con predicción obligatoria; el texto llega después |
| Tener un MVP viable | 2 dependencias, sin backend, compila sin secretos |
| Poder evolucionar | Adaptador de LLM definido; registro de funciones extensible |
| Documentación profesional | 8 documentos, incluido el análisis que justifica cada decisión |
| Preparada para GitHub | 2 workflows, verificación en 3 capas, release automático |
