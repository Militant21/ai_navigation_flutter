#!/usr/bin/env bash
set -euo pipefail

APP=android/app/build.gradle
# Ha még nincs android mappa (első build hozza létre), lépjünk ki hibátlanul
[ -f "$APP" ] || exit 0

# Biztos, ami biztos: gradle fájl sorvégeinek normalizálása
sed -i 's/\r$//' "$APP"

# Ha van buildTypes->release: kényszerítsük debug signingre és kapcsoljuk ki a shrink/minify-t
if grep -q "buildTypes" "$APP"; then
  sed -i '
    /buildTypes\s*{/,/}/ {
      /release\s*{/,/}/ {
        s/minifyEnabled\s*true/minifyEnabled false/g
        s/shrinkResources\s*true/shrinkResources false/g
        s/signingConfig\s\+signingConfigs\.\w\+/signingConfig signingConfigs.debug/g
      }
    }
  ' "$APP"
else
  # Ha nincs, egészítsük ki egy minimális release blokkal
  cat >> "$APP" <<'EOF'
android {
  buildTypes {
    release {
      signingConfig signingConfigs.debug
      minifyEnabled false
      shrinkResources false
    }
  }
}
EOF
fi
