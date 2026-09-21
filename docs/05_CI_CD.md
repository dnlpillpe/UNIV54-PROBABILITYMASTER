# Probability Master — CI/CD y despliegue

---

## 1. La decisión que ordena todo: las carpetas de plataforma no se versionan

`android/`, `ios/` y las demás carpetas de plataforma están en `.gitignore` y
se generan en cada compilación con `flutter create`.

**Por qué.** Una carpeta `android/` versionada envejece: queda atada a la
combinación de AGP, Gradle y Kotlin que había el día que se generó, y al
actualizar Flutter empieza a fallar con errores que no tienen nada que ver con
el código de la app. Generarla en CI garantiza que la configuración de Gradle
siempre sea **la que la versión de Flutter en uso espera**.

**El precio.** Cualquier personalización de plataforma hay que reaplicarla, y
por eso existe `tool/postcreate.sh`, que es idempotente y funciona tanto si
Flutter generó Gradle en Groovy como en Kotlin DSL.

**La consecuencia práctica:** la versión de Flutter está **pinchada** en los
workflows (`FLUTTER_VERSION: 3.35.4`). Subirla es un cambio de una línea, pero
debe ser deliberado y verse en el historial.

> Nota sobre versiones de Gradle: la tentación es pinchar AGP, Gradle y Kotlin
> a valores concretos. Aquí se hace lo contrario —se pincha **Flutter** y se
> deja que él elija el resto— porque una combinación de AGP fijada a mano
> envejece más rápido que la propia app, y produce fallos de compilación que
> parecen del código. `ci/android-overrides/` contiene solo lo que es válido
> con cualquier AGP: memoria de la JVM, AndroidX y caché.

## 2. `ci.yml` — verificación

Se dispara en push a `main`/`master`/`develop`, en cada PR y a mano.

```
contenido ──────────────► analyze_test
(Python, ~20 s)           (Flutter, ~4 min)
```

**Job 1 · contenido.** Corre **antes** de instalar Flutter, porque tarda
segundos y atrapa los errores más caros:

1. `python3 tool/probability_core.py` — comprobaciones internas del motor
   replicado.
2. `python3 tool/verify_content.py` — recalcula las 70 cifras e integridad
   referencial.
3. `python3 tool/static_check.py` — balance de delimitadores e imports.

**Job 2 · analyze_test.** Solo si el anterior pasó:

1. Java 17 (temurin) y Flutter pinchado, con caché.
2. `flutter create --platforms=android,ios --project-name probability_master
   --org com.probabilitymaster .`
3. `bash tool/postcreate.sh`
4. `flutter pub get`
5. `dart run flutter_launcher_icons`
6. `flutter analyze --no-fatal-infos --no-fatal-warnings`
7. `flutter test --reporter expanded`

`analyze` se ejecuta sin considerar fatales los infos y warnings: el contenido
educativo usa líneas largas dentro de cadenas y comillas tipográficas, y no
tiene sentido que eso detenga una compilación.

## 3. `build-apk.yml` — APK

Se dispara en push a `main`/`master`, en etiquetas `v*` y a mano.

Mismos pasos de preparación, y además:

- **Verificación de contenido antes de compilar.** Un APK con cifras
  incorrectas es peor que no tener APK.
- **Tests informativos.** `continue-on-error: true`. Un test roto no debe
  impedir un APK de campo, pero sí debe verse en el registro. En `ci.yml` los
  tests **sí** son bloqueantes: son dos workflows con propósitos distintos.
- `flutter build apk --release --build-number=${{ github.run_number }}`
- `flutter build apk --release --split-per-abi`
- Renombrado a `ProbabilityMaster-universal.apk`,
  `ProbabilityMaster-arm64-v8a.apk`, etc.
- Subida como artefacto (30 días de retención).
- En etiquetas `v*`, release de GitHub con los APK adjuntos y notas generadas.

## 4. Firma

`tool/configure_signing.sh` configura la firma **solo si existen los
secretos**. Sin ellos, el APK de release se firma con la clave de depuración:
se instala y se prueba en un teléfono, pero **no es publicable en Google
Play**.

Esto es deliberado: permite que CI compile desde el primer commit sin pedir
credenciales a nadie, que es lo que hace que el pipeline sea útil desde el día
uno.

Para firmar de verdad, definir en *Settings → Secrets and variables →
Actions*:

| Secreto | Contenido |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | El `.jks` en base64: `base64 -w0 upload-keystore.jks` |
| `ANDROID_STORE_PASSWORD` | Contraseña del almacén |
| `ANDROID_KEY_PASSWORD` | Contraseña de la clave |
| `ANDROID_KEY_ALIAS` | Alias (por defecto `upload`) |

`android/key.properties` se genera en CI y nunca se versiona.

## 5. Publicar una versión

```bash
git tag v1.0.0
git push origin v1.0.0
```

El workflow compila, adjunta los APK y crea el release. El `versionCode` sale
de `github.run_number`, así que crece solo y nunca se repite.

## 6. Compilar en local

```bash
git clone <repo> && cd probability_master

flutter create --platforms=android,ios \
  --project-name probability_master --org com.probabilitymaster .
bash tool/postcreate.sh
flutter pub get
dart run flutter_launcher_icons

flutter analyze --no-fatal-infos
flutter test
flutter run                        # dispositivo o emulador
flutter build apk --release        # APK
flutter build appbundle --release  # AAB para Play Store
```

Verificación sin SDK (útil al revisar contenido en cualquier máquina):

```bash
python3 tool/probability_core.py
python3 tool/verify_content.py
python3 tool/static_check.py
python3 tool/generate_icon.py   # requiere Pillow
```

## 7. Problemas conocidos y su causa

| Síntoma | Causa probable | Solución |
|---|---|---|
| `flutter create` sobrescribe archivos | Es su comportamiento con `.` | Normal: solo toca carpetas de plataforma y `test/widget_test.dart`, que `postcreate.sh` borra |
| Fallo de Gradle tras subir la versión de Flutter | Cambió la combinación AGP/Kotlin esperada | Borrar `android/` y regenerar; no pinchar AGP a mano |
| `flutter_launcher_icons` no encuentra el icono | Falta `assets/icon/app_icon.png` | `python3 tool/generate_icon.py` |
| El APK se instala pero no actualiza | Firmado con clave de depuración distinta | Desinstalar el anterior, o configurar la firma real |
| CI falla en `verify_content` tras editar contenido | Una cifra, confusión o predicado no cuadra | El mensaje dice exactamente cuál; ver `docs/04` §8 |

## 8. Checklist antes de publicar en la tienda

- [ ] Sustituir la clave de depuración por una de producción (§4).
- [ ] Verificar la disponibilidad del nombre «Probability Master» en Play
      Store.
- [ ] Revisión de los 12 casos profesionales por un docente de cada área
      (ver `docs/07`).
- [ ] Política de privacidad publicada — es trivial: la app no recoge nada,
      pero Play la exige igual.
- [ ] Capturas de pantalla en 6,7" y 5,5", y gráfico de portada 1024 × 500.
- [ ] Clasificación de contenido (apta para todos) y categoría *Educación*.
