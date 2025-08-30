// android/settings.gradle.kts

pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

plugins {
    // A LOADERNEK KELL A VERZIÓ!
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter binárisok (engine/artifacts) – ez maradhat
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
