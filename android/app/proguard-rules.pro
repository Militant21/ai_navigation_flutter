# ---- Alap, biztonságos keep-ek Flutter projekthez ----

# Tartsuk meg a Flutter és AndroidX lifecycle osztályokat
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.lifecycle.** { *; }

# Ha reflektív deszerializálásod van (pl. Gson/Moshi/Kotlinx), ezek hasznosak:
# (Ha nincs ilyen lib, maradhatnak – nem ártanak.)
-keep class com.google.gson.** { *; }
-keep class com.squareup.moshi.** { *; }
-keep class kotlinx.** { *; }

# Parcelize/Parcelable
-keep class ** implements android.os.Parcelable { *; }

# Retrofit/OkHttp (ha használsz)
-keep class retrofit2.** { *; }
-keep interface retrofit2.** { *; }
-dontwarn okio.**
-dontwarn javax.annotation.**

# Firebase (ha használsz)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Ne obfuszkáljuk a generált R osztályt
-keep class **.R$* { *; }

# (Opcionális) Logok stacktrace megőrzése hiba esetén
-renamesourcefileattribute SourceFile
-keepattributes SourceFile,LineNumberTable
