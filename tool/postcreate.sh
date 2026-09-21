#!/usr/bin/env bash
# Ajustes posteriores a `flutter create`, que en este proyecto genera las
# carpetas de plataforma en CI en vez de versionarlas (ver docs/05_CI_CD.md).
#
# Todos los cambios son idempotentes y están guardados por comprobación de
# existencia: el script debe funcionar tanto si Flutter generó Gradle en
# Groovy (build.gradle) como en Kotlin DSL (build.gradle.kts).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "== postcreate: ajustando el proyecto generado =="

# 1 · El widget_test.dart de plantilla referencia un MyApp que no existe.
if [ -f test/widget_test.dart ]; then
  echo "  - eliminando test/widget_test.dart de plantilla"
  rm -f test/widget_test.dart
fi

# 2 · Nombre visible de la app en Android.
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  echo "  - nombre visible en Android: Probability Master"
  sed -i.bak 's/android:label="[^"]*"/android:label="Probability Master"/' \
    "$MANIFEST"
  rm -f "$MANIFEST.bak"
fi

# 3 · Nombre visible en iOS.
PLIST="ios/Runner/Info.plist"
if [ -f "$PLIST" ]; then
  echo "  - nombre visible en iOS: Probability Master"
  python3 - "$PLIST" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    src = fh.read()
src = re.sub(
    r"(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)",
    r"\1Probability Master\2",
    src,
)
src = re.sub(
    r"(<key>CFBundleName</key>\s*<string>)[^<]*(</string>)",
    r"\1Probability Master\2",
    src,
)
with open(path, "w", encoding="utf-8") as fh:
    fh.write(src)
PY
fi

# 4 · Orientación vertical (la app se diseñó para una mano).
if [ -f "$PLIST" ]; then
  python3 - "$PLIST" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as fh:
    src = fh.read()
src = re.sub(
    r"<key>UISupportedInterfaceOrientations</key>\s*<array>.*?</array>",
    "<key>UISupportedInterfaceOrientations</key>\n\t<array>\n"
    "\t\t<string>UIInterfaceOrientationPortrait</string>\n\t</array>",
    src,
    flags=re.S,
)
with open(path, "w", encoding="utf-8") as fh:
    fh.write(src)
PY
fi

# 5 · Overrides de Android (solo lo que es seguro en cualquier AGP).
if [ -d android ] && [ -d ci/android-overrides ]; then
  echo "  - aplicando ci/android-overrides/"
  cp -R ci/android-overrides/. android/
fi

echo "== postcreate: listo =="
