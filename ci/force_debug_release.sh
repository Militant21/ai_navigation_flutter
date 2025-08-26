#!/usr/bin/env bash
set -e
APP=android/app/build.gradle
[ -f "$APP" ] || exit 0

# ha buildTypes.release már van: módosítjuk; különben beillesztjük
if grep -q "buildTypes" "$APP"; then
  sed -i \
    -e '/buildTypes\s*{.*/,/}/ {
          /release\s*{.*/,/}/ {
            s/minifyEnabled\s*true/minifyEnabled false/g
            s/shrinkResources\s*true/shrinkResources false/g
            s/signingConfig\s\+signingConfigs\.[a-zA-Z_]\+/signingConfig signingConfigs.debug/g
          }
        }' "$APP"
else
  cat >> "$APP" <<'EOGRADLE'

android {
  buildTypes {
    release {
      signingConfig signingConfigs.debug
      minifyEnabled false
      shrinkResources false
    }
  }
}
EOGRADLE
fi
