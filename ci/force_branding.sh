#!/bin/sh
set -e

APP="android/app"
RES="$APP/src/main/res"
MANIFEST="$APP/src/main/AndroidManifest.xml"

ICON_SRC="${ICON:-assets/icon/icon.png}"
SPLASH_SRC="${SPLASH:-assets/ai_logo.png}"
SPLASH_COLOR="${SPLASH_COLOR:-#EFE7FF}"

# Ha nincs még android projekt (még nem futott a flutter create), lépjünk ki csendben
[ -f "$MANIFEST" ] || exit 0

echo "==> Force icon + splash branding"

# --- Ikon: állítsuk be a Manifestben, ha hiányzik
if ! grep -q 'android:icon=' "$MANIFEST"; then
  sed -i 's|<application |<application android:icon="@mipmap/ic_launcher" |' "$MANIFEST"
fi

# --- Ikon PNG bemásolása minden density-be (egyetlen forrásból)
for d in mipmap-mdpi mipmap-hdpi mipmap-xhdpi mipmap-xxhdpi mipmap-xxxhdpi; do
  mkdir -p "$RES/$d"
  cp -f "$ICON_SRC" "$RES/$d/ic_launcher.png"
done

# --- Splash: resource-ok
mkdir -p "$RES/drawable" "$RES/values" "$RES/values-v31"

# szín a splash-hez
cat > "$RES/values/colors.xml" <<EOF
<resources>
  <color name="splash_color">${SPLASH_COLOR}</color>
</resources>
EOF

# splash kép (középre)
cp -f "$SPLASH_SRC" "$RES/drawable/splash_image.png"

# Android < 12: háttér + középre tett kép
cat > "$RES/drawable/launch_background.xml" <<'EOF'
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
  <item android:drawable="@color/splash_color"/>
  <item>
    <bitmap
      android:gravity="center"
      android:src="@drawable/splash_image"/>
  </item>
</layer-list>
EOF

# Alap stílusok
cat > "$RES/values/styles.xml" <<'EOF'
<resources>
  <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
  </style>
  <style name="NormalTheme" parent="@android:style/Theme.Material.Light.NoActionBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
  </style>
</resources>
EOF

# Android 12+ (API 31+) SplashScreen API
cat > "$RES/values-v31/styles.xml" <<'EOF'
<resources xmlns:tools="http://schemas.android.com/tools">
  <style name="LaunchTheme" parent="Theme.SplashScreen">
    <item name="windowSplashScreenBackground">@color/splash_color</item>
    <item name="windowSplashScreenAnimatedIcon">@drawable/splash_image</item>
    <item name="postSplashScreenTheme">@style/NormalTheme</item>
  </style>
  <style name="NormalTheme" parent="Theme.Material.Light.NoActionBar"/>
</resources>
EOF

# Biztosítsuk, hogy a fő Activity a LaunchTheme-et használja (ha nincs még rajta)
if ! grep -q 'android:theme="@style/LaunchTheme"' "$MANIFEST"; then
  # az első <activity ...> után beszúrjuk a theme attribútumot
  sed -i '0,/<activity /s//& android:theme="@style\/LaunchTheme"/' "$MANIFEST"
fi

echo "==> Branding forced OK"
