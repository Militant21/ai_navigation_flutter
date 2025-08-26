#!/usr/bin/env bash
set -e
APP=android/app/build.gradle
[ -f "$APP" ] || exit 0  # ha nincs android mappa, a build.lépés fogja létrehozni és ez a script később fusson
# Ha már van release szekció, módosítjuk; ha nincs, beszúrjuk.
if grep -q "buildTypes" "$APP"; then
  sed -i '
    /buildTypes\s*{/,/}/ {
      /release\s*{/,/}/ {
        s/minifyEnabled\s*true/minifyEnabled false/g
        s/shrinkResources\s*true/shrinkResources false/g
        /signingConfig/! s/release\s*{/&\n            signingConfig signingConfigs.debug/
        /minifyEnabled/! s/release\s*{/&\n            minifyEnabled false/
        /shrinkResources/! s/release\s*{/&\n            shrinkResources false/
      }
    }
  ' "$APP"
else
  sed -i '
    s/android\s*{/android {\n    buildTypes {\n        release {\n            signingConfig signingConfigs.debug\n            minifyEnabled false\n            shrinkResources false\n        }\n    }\n/
  ' "$APP"
fi
