pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        // Android Gradle Plugin – stabil ág
        id("com.android.application") version "8.6.0"
        // Kotlin Android plugin – >= 2.1.0, hogy a Flutter warning eltűnjön
        id("org.jetbrains.kotlin.android") version "2.1.0"
        // Flutter Gradle plugin – ezt NEM itt verziózzuk (a Flutter SDK adja)
        id("dev.flutter.flutter-gradle-plugin") // version nélkül
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

// Flutter SDK bekötése a Flutter pluginhoz
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
