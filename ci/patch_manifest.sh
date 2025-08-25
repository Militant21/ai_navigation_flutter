#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"

echo "Patching: $MANIFEST"

# beszúró segéd: <application> elé tesz egy sort, ha nem létezik már
add_perm () {
  local PERM="$1"
  if ! grep -q "$PERM" "$MANIFEST"; then
    sed -i "/<application/i\    <uses-permission android:name=\"$PERM\"\/>" "$MANIFEST"
    echo "  + $PERM"
  else
    echo "  = $PERM (már megvan)"
  fi
}

# alap hálózat/állapot
add_perm "android.permission.INTERNET"
add_perm "android.permission.ACCESS_NETWORK_STATE"
add_perm "android.permission.ACCESS_WIFI_STATE"

# helymeghatározás (geolocator)
add_perm "android.permission.ACCESS_FINE_LOCATION"
add_perm "android.permission.ACCESS_COARSE_LOCATION"

# Bluetooth (új API: CONNECT; régi: BLUETOOTH/ADMIN)
add_perm "android.permission.BLUETOOTH_CONNECT"
add_perm "android.permission.BLUETOOTH"
add_perm "android.permission.BLUETOOTH_ADMIN"

# foreground service + ébren tartás
add_perm "android.permission.FOREGROUND_SERVICE"
add_perm "android.permission.WAKE_LOCK"

# opcionális tárhely (ha később kellene)
# add_perm "android.permission.READ_EXTERNAL_STORAGE"
# add_perm "android.permission.WRITE_EXTERNAL_STORAGE"

echo "Manifest patch kész."
