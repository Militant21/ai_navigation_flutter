#!/bin/sh
set -e

MANIFEST="android/app/src/main/AndroidManifest.xml"
[ -f "$MANIFEST" ] || exit 0

add_perm() {
  perm="$1"
  grep -q "uses-permission android:name=\"$perm\"" "$MANIFEST" || \
    sed -i "s#<application#<uses-permission android:name=\"$perm\"/>\n    <application#" "$MANIFEST"
}

add_feature() {
  name="$1"; required="$2"
  grep -q "uses-feature android:name=\"$name\"" "$MANIFEST" || \
    sed -i "s#<application#<uses-feature android:name=\"$name\" android:required=\"$required\"/>\n    <application#" "$MANIFEST"
}

# ---- Alap (online térképcsempék + helyzet) ----
add_perm "android.permission.INTERNET"
add_perm "android.permission.ACCESS_NETWORK_STATE"
add_perm "android.permission.ACCESS_COARSE_LOCATION"
add_perm "android.permission.ACCESS_FINE_LOCATION"

# ---- Opcionális: háttérhelyzet + értesítés ----
if [ "${ENABLE_BACKGROUND:-0}" = "1" ]; then
  add_perm "android.permission.ACCESS_BACKGROUND_LOCATION"
  add_perm "android.permission.FOREGROUND_SERVICE"
  add_perm "android.permission.FOREGROUND_SERVICE_LOCATION"
fi
if [ "${ENABLE_NOTIFICATIONS:-0}" = "1" ]; then
  add_perm "android.permission.POST_NOTIFICATIONS"
fi

# ---- Opcionális: Bluetooth (BLE beacon/scan, eszközkezelés) ----
if [ "${ENABLE_BLUETOOTH:-0}" = "1" ]; then
  # Android 12+ új BT engedélyek
  add_perm "android.permission.BLUETOOTH_SCAN"
  add_perm "android.permission.BLUETOOTH_CONNECT"
  # Ha hirdetni is akarsz (ritka)
  if [ "${ENABLE_BT_ADVERTISE:-0}" = "1" ]; then
    add_perm "android.permission.BLUETOOTH_ADVERTISE"
  fi
  # BLE képesség jelzése (szűrésre hasznos, nem kötelező)
  add_feature "android.hardware.bluetooth_le" "false"
  add_feature "android.hardware.bluetooth" "false"
fi

# Jelöld, hogy tudsz GPS-t használni (nem kötelező)
add_feature "android.hardware.location.gps" "false"
