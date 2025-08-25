#!/bin/sh
set -e
MANIFEST="android/app/src/main/AndroidManifest.xml"
[ -f "$MANIFEST" ] || exit 0
for perm in \
  "android.permission.INTERNET" \
  "android.permission.ACCESS_FINE_LOCATION" \
  "android.permission.ACCESS_COARSE_LOCATION" \
  "android.permission.ACCESS_BACKGROUND_LOCATION" \
  "android.permission.ACCESS_NETWORK_STATE" \
  "android.permission.ACCESS_WIFI_STATE" \
  "android.permission.CHANGE_WIFI_STATE" \
  "android.permission.BLUETOOTH" \
  "android.permission.BLUETOOTH_ADMIN" \
  "android.permission.READ_EXTERNAL_STORAGE" \
  "android.permission.WRITE_EXTERNAL_STORAGE" \
  "android.permission.MANAGE_EXTERNAL_STORAGE" \
  "android.permission.FOREGROUND_SERVICE" \
  "android.permission.WAKE_LOCK" \
  "android.permission.RECEIVE_BOOT_COMPLETED" \
  "android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS"
do
  grep -q "$perm" "$MANIFEST" || \
  sed -i "s#<application#<uses-permission android:name=\"$perm\"/>\n    <application#" "$MANIFEST"
done
