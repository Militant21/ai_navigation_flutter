pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")

// --- HIÁNYZÓ RÉSZ ---
// Ez a blokk megmondja a buildnek, hogy a Flutter plugin létezik
// és elérhető a projekt számára.
plugins {
    id("dev.flutter.flutter-gradle-plugin").version("1.0.0").apply(false)
}
