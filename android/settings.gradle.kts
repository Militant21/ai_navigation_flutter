pluginManagement {
    repositories {
        // IDE KELL a három repo, különben nem találja a plugineket
        gradlePluginPortal()
        google()
        mavenCentral()
    }
    plugins {
        // Adjunk verziót a plugineknek itt (app/build.gradle.kts-ben NEM!)
        id("com.android.application") version "8.7.0"
        id("org.jetbrains.kotlin.android") version "1.9.25"
        // A Flutter Gradle plugint a Flutter SDK adja, ehhez nem írunk verziót
        id("dev.flutter.flutter-gradle-plugin")
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS) // központi kezelés
    repositories {
        google()
        mavenCentral()
    }
}

// --- Flutter SDK bekötése a Flutter pluginhoz ---
val props = java.util.Properties()
val lp = file("local.properties")
if (lp.exists()) {
    lp.inputStream().use { props.load(it) }
}
val flutterSdk: String? = props.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")
if (flutterSdk != null) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("⚠ A 'flutter.sdk' nincs beállítva (android/local.properties vagy FLUTTER_ROOT).")
}

rootProject.name = "ai_navigation_flutter"
include(":app")
