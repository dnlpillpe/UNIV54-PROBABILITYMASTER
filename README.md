<div align="center">

# Probability Master

**Domina el azar con tus propios experimentos**

App móvil educativa universitaria para aprender fundamentos de probabilidad
mediante simulación de experimentos aleatorios, diagnóstico de confusiones y
casos profesionales.

Flutter · Dart · Riverpod · MVVM + Repository · sin backend · sin cuentas

</div>

---

## Qué problema resuelve

La probabilidad es la única rama elemental de la matemática donde la intuición
del estudiante no está vacía: **está ocupada por creencias erróneas estables**,
adquiridas fuera del aula y resistentes a la explicación. Un estudiante que no
sabe derivar simplemente no sabe; un estudiante que cree que «ya salieron
cuatro caras, ahora toca sello» sí sabe algo, y lo que sabe es falso.

El resultado conocido es que **se aprueba el curso calculando y se sigue
entendiendo mal**. Esta app no enseña a calcular probabilidades: enseña a
reconocer qué clase de problema se tiene delante y a desconfiar de la intuición
que falla.

El análisis completo, con los seis fallos que ataca y las seis decisiones que
definen el producto, está en [`docs/00_Analisis_Educativo.md`](docs/00_Analisis_Educativo.md).

## Cómo lo hace

**Predice → Simula → Explica.** Ningún laboratorio arranca sin que el
estudiante registre una predicción: los controles están desactivados hasta
entonces, y la conclusión permanece bloqueada hasta alcanzar el mínimo de
repeticiones. Una creencia que no se hace explícita no se corrige, porque
quien ve el resultado correcto reinterpreta su intuición previa para que
coincida.

| | |
|---|---|
| **4 módulos** | Fundamentos · Eventos · Conteo · Problemas |
| **23 lecciones** | 84 tarjetas, una idea por pantalla |
| **5 laboratorios** | 16 experimentos con predicción obligatoria |
| **96 ejercicios** | 6 tipos, 319 alternativas con retroalimentación propia |
| **12 casos** | 11 carreras; dos terminan en «no corresponde calcular» |
| **32 confusiones** | catalogadas, detectadas y con remedio enlazado |
| **54 términos** | glosario con el error frecuente de cada uno |
| **70 cifras** | ninguna escrita a mano: todas calculadas por el motor |

## Las seis decisiones que lo definen

**D1 · La predicción es obligatoria.** Ya explicada arriba.

**D2 · El espacio muestral se enumera antes de contarse.** El módulo 1 obliga a
construir a mano espacios de 4, 6, 8, 36 y 52 resultados. Cuando el módulo 3
dice «hay C(52,5) manos», el estudiante ya sabe qué objeto se está contando.

**D3 · Cada distractor declara su confusión.** 32 etiquetas enlazadas a las
alternativas incorrectas. Acertar no aporta información; fallar de una manera
concreta, sí. El diagnóstico suma 1 por error, resta 0,5 por acierto posterior
en un ítem capaz de detectarla y decae 3 % por evento.

**D4 · Regla 60/40 y umbral doble.** En los ítems de decisión la elección vale
0,6 y la justificación 0,4; el «acierto ciego» se reporta como indicador
propio. El dominio es 15 % lecciones + 15 % laboratorios + 70 % práctica, y
«competente» exige 0,70 **en el total y en la práctica**.

**D5 · Ningún número está escrito a mano.** El contenido declara
`ContentFigure(fn: 'diceSum', args: [7])` y la app lo calcula con el motor. Un
test recalcula las 70 cifras en Dart y una réplica en Python las recalcula otra
vez en CI, con motores independientes.

**D6 · Aritmética exacta.** Las probabilidades de espacios finitos son
fracciones exactas sobre `BigInt`. El estudiante ve `11/36`, no `0.3055555…`,
y C(52,5) no desborda.

## Estructura

```
probability_master/
├── lib/
│   ├── core/             tema, paleta, constantes, formateo
│   ├── domain/
│   │   ├── math/         motor: Rational, combinatoria, espacios,
│   │   │                 reglas, simuladores, registro de cifras
│   │   ├── models/       lecciones, ejercicios, experimentos, casos…
│   │   ├── services/     corrección, dominio, diagnóstico, recomendación
│   │   └── tutor/        clasificador, solucionador, adaptador de IA
│   ├── data/
│   │   ├── content/      TODO el contenido, como `const` en Dart
│   │   ├── repositories/ acceso único al contenido
│   │   └── local/        persistencia con shared_preferences
│   └── presentation/
│       ├── painters/     marca y gráficos (sin librería de charts)
│       ├── providers/    Riverpod
│       ├── screens/      12 pantallas
│       └── widgets/      componentes compartidos
├── test/                 10 suites
├── tool/                 réplica del motor, verificadores, icono, scripts
├── ci/android-overrides/ ajustes de Gradle aplicados en CI
├── docs/                 8 documentos (00 a 07)
└── .github/workflows/    ci.yml y build-apk.yml
```

## Cómo compilar

Este repositorio **no versiona las carpetas de plataforma**: se generan en CI,
lo que evita arrastrar configuración de Gradle desactualizada. Para compilar en
local:

```bash
flutter create --platforms=android,ios \
  --project-name probability_master --org com.probabilitymaster .
bash tool/postcreate.sh          # nombre visible, orientación, overrides
flutter pub get
dart run flutter_launcher_icons  # genera el icono desde assets/icon/
flutter analyze --no-fatal-infos
flutter test
flutter run                      # o: flutter build apk --release
```

Verificación que **no necesita el SDK de Flutter**:

```bash
python3 tool/probability_core.py   # comprobaciones internas del motor
python3 tool/verify_content.py     # recalcula las 70 cifras del contenido
python3 tool/static_check.py       # balance, imports, marcadores
python3 tool/generate_icon.py      # regenera el icono (requiere Pillow)
```

## CI/CD

| Workflow | Qué hace |
|---|---|
| `ci.yml` | Verifica el contenido en Python → `flutter analyze` → `flutter test` |
| `build-apk.yml` | Compila APK universal y por arquitectura, los sube como artefactos y publica release en etiquetas `v*` |

El orden importa: la verificación de contenido corre **antes** de instalar
Flutter, porque es rápida y atrapa los errores más caros. Detalles en
[`docs/05_CI_CD.md`](docs/05_CI_CD.md).

Sin secretos de firma, el APK de release se firma con la clave de depuración:
sirve para instalar y probar, **no para publicar en Google Play**. Para firmar
de verdad, define `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`,
`ANDROID_KEY_PASSWORD` y `ANDROID_KEY_ALIAS` en los secretos del repositorio.

## Sobre el tutor probabilístico

El tutor **diagnostica** qué confusión tiene este estudiante, **clasifica**
problemas con un árbol explícito de siete preguntas y **resuelve paso a paso**
mostrando la condición de uso de cada método. No conversa, y eso es una
decisión, no una limitación pendiente.

En un dominio donde un error tiene la misma forma que la respuesta correcta
—una fracción plausible—, un modelo generativo que acierta el 97 % de las veces
es peor que no tener tutor: el estudiante no puede detectar el 3 % restante. El
adaptador para un LLM está definido (`ProbabilityTutorClient`) y no activado,
con una regla fija para v2: **el modelo redacta, el motor calcula**.

El razonamiento completo está en la Fase 5 del análisis.

## Estado y limitaciones

- Construida **sin SDK de Flutter en el entorno**: verificada por réplica
  independiente del motor, recálculo de todas las cifras y verificación
  estática de los 77 archivos Dart. **No ejecutada en dispositivo**: la
  primera compilación real ocurre en GitHub Actions.
- No cubre variables aleatorias ni distribuciones como tema.
- Los casos profesionales son verosímiles y numéricamente correctos, pero no
  auditados por un especialista de cada carrera.
- Un solo idioma (español).

Lista completa y plan de evolución en
[`docs/07_Limitaciones_y_Roadmap.md`](docs/07_Limitaciones_y_Roadmap.md).

## Privacidad

Todo el progreso se guarda **solo en el dispositivo**. La app no tiene cuentas,
no pide permisos, no se conecta a ningún servidor y no recoge telemetría.

## Licencia

MIT. Ver [`LICENSE`](LICENSE).
