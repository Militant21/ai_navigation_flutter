#!/usr/bin/env bash
set -euo pipefail
[ -d android ] || flutter create --platforms=android . --no-pub
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ ! -f "$MANIFEST" ]; then
  mkdir -p android/app/src/main
  PKG="$(awk -F\" '/applicationId/ {print $2}' android/app/build.gradle 2>/dev/null || true)"
  [ -z "$PKG" ] && PKG="$(awk -F\" '/namespace/ {print $2}' android/app/build.gradle 2>/dev/null || true)"
  [ -z "$PKG" ] && PKG="com.example.app"
  cat > "$MANIFEST" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="$PKG">
  <application android:label="app" android:icon="@mipmap/ic_launcher">
    <activity android:name=".MainActivity">
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
      </intent-filter>
    </activity>
  </application>
</manifest>
EOF
fi
