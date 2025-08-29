pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.6.0"
        id("org.jetbrains.kotlin.android") version "2.0.20"
    }
}

dependencyResolutionManagement {
    // A projekt repóit részesítsük előnyben, hogy a Flutter plugin által hozzáadott repók is érvényesüljenek
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }  // ← EZ HIÁNYZIK
      }
}

// --- Flutter SDK útvonal beolvasása és a Gradle plugin bekötése ---
val props = java.util.Properties()
val lp = file("local.properties")
if (lp.exists()) {
    lp.inputStream().use { props.load(it) }
}

val flutterSdk: String? = props.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
if (flutterSdk != null) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("⚠️ A 'flutter.sdk' nincs beállítva (android/local.properties vagy FLUTTER_ROOT).")
}

rootProject.name = "ai_navigation_flutter"
include(":app")
