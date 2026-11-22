#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
: "${ANDROID_SDK_ROOT:?Set ANDROID_SDK_ROOT}"
: "${LINKO_KEYSTORE:?Set LINKO_KEYSTORE to the release signing keystore}"
: "${LINKO_KEY_PASSWORD:?Set LINKO_KEY_PASSWORD}"
tools="$ANDROID_SDK_ROOT/build-tools/36.0.0"
platform="$ANDROID_SDK_ROOT/platforms/android-36/android.jar"
output="${1:-Linko-Net.apk}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir "$work/classes" "$work/dex" "$work/assets"
cp index.html "$work/assets/"
"$tools/aapt2" compile --dir res -o "$work/resources.zip"
"$tools/aapt2" link -I "$platform" --manifest AndroidManifest.xml -A "$work/assets" \
  -o "$work/unaligned.apk" "$work/resources.zip"
if [[ -n "${LINKO_ECJ_JAR:-}" ]]; then
  java -jar "$LINKO_ECJ_JAR" -8 -proc:none -bootclasspath "$platform:$tools/core-lambda-stubs.jar" -d "$work/classes" src
else
  find src -name "*.java" -print0 | xargs -0 javac -source 8 -target 8 -bootclasspath "$platform:$tools/core-lambda-stubs.jar" -d "$work/classes"
fi
(cd "$work/classes" && zip -qr "$work/classes.jar" .)
"$tools/d8" --release --min-api 26 --lib "$platform" --output "$work/dex" "$work/classes.jar"
(cd "$work/dex" && zip -q "$work/unaligned.apk" classes.dex)
"$tools/zipalign" -f 4 "$work/unaligned.apk" "$work/aligned.apk"
"$tools/apksigner" sign --ks "$LINKO_KEYSTORE" --ks-key-alias linkonet \
  --ks-pass env:LINKO_KEY_PASSWORD --key-pass env:LINKO_KEY_PASSWORD --out "$output" "$work/aligned.apk"
"$tools/apksigner" verify --verbose "$output"
