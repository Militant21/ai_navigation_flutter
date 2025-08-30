pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // Ez a sor mondja meg, HOL van a Flutter plugin
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Ez a sor a többi Flutter csomaghoz kell
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")

// Ez a sor mondja meg, HOGY a Flutter plugin létezik
plugins {
    id("dev.flutter.flutter-gradle-plugin").version("1.0.0").apply(false)
}
