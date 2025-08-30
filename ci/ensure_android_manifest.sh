#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"
APP_GRADLE="android/app/build.gradle.kts"

# Ha már van rendes manifest, nem csinálunk semmit
if [ -f "$MANIFEST" ]; then
  echo "AndroidManifest already exists at $MANIFEST – skipping."
  exit 0
fi

mkdir -p android/app/src/main

# 1) package kinyerése applicationId-ből (Kotlin DSL)
PKG="$(sed -n 's/.*applicationId[[:space:]]*=[[:space:]]*"\([^"]\+\)".*/\1/p' "$APP_GRADLE" | head -n1 || true)"

# 2) ha nincs, próbáld namespace-ből
if [ -z "${PKG:-}" ]; then
  PKG="$(sed -n 's/.*namespace[[:space:]]*=[[:space:]]*"\([^"]\+\)".*/\1/p' "$APP_GRADLE" | head -n1 || true)"
fi

# 3) ha még mindig nincs, használjuk a projektedhez illő fallbacket
if [ -z "${PKG:-}" ]; then
  PKG="com.example.ai_navigation_flutter"
fi

cat > "$MANIFEST" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="${PKG}">
    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/LaunchTheme">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

echo "Created minimal AndroidManifest for package: ${PKG}"
