#!/usr/bin/env bash
# Configura la firma de release SOLO si existen los secretos.
#
# Sin secretos, el APK de release se firma con la clave de depuración: sirve
# para instalar y probar en un teléfono, pero NO para publicar en la tienda.
# Esto es deliberado: permite que CI compile desde el primer commit sin pedir
# credenciales a nadie.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ -z "${ANDROID_KEYSTORE_BASE64:-}" ]; then
  echo "Sin ANDROID_KEYSTORE_BASE64: se usará la clave de depuración."
  echo "El APK resultante NO es publicable en Google Play."
  exit 0
fi

echo "Configurando firma de release con los secretos del repositorio…"
mkdir -p android/app
echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > android/app/upload-keystore.jks

cat > android/key.properties <<PROPS
storePassword=${ANDROID_STORE_PASSWORD:-}
keyPassword=${ANDROID_KEY_PASSWORD:-}
keyAlias=${ANDROID_KEY_ALIAS:-upload}
storeFile=upload-keystore.jks
PROPS

echo "Firma configurada. Recuerda: android/key.properties no se versiona."
