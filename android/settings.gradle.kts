pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.6.0"
        id("org.jetbrains.kotlin.android") version "2.1.0"
        // A Flutter gradle plugin verzióját nem itt adjuk meg – a Flutter SDK-ból jön
        id("dev.flutter.flutter-gradle-plugin")
    }
}

dependencyResolutionManagement {
    // opcionális, de hasznos: dobjon hibát, ha modul szinten próbál valaki repo-t definiálni
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)

    repositories {
        google()
        mavenCentral()

        // ⬇️ EZ A FONTOS: Flutter engine Maven repo
        val props = java.util.Properties()
        val lp = file("local.properties")
        if (lp.exists()) lp.inputStream().use { props.load(it) }
        val flutterSdk = (props.getProperty("flutter.sdk")
            ?: System.getenv("FLUTTER_ROOT")) ?: ""

        if (flutterSdk.isNotEmpty()) {
            // engine artefaktok: io.flutter:flutter_embedding_*
            maven { url = uri("$flutterSdk/bin/cache/artifacts/engine") }
        }
    }
}

// Flutter SDK Gradle tooling bekötése
val props = java.util.Properties()
val lp = file("local.properties")
if (lp.exists()) lp.inputStream().use { props.load(it) }
val flutterSdk = (props.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")) ?: ""
if (flutterSdk.isNotEmpty()) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("⚠️ A 'flutter.sdk' nincs beállítva (android/local.properties vagy FLUTTER_ROOT).")
}

rootProject.name = "ai_navigation_flutter"
include(":app")
