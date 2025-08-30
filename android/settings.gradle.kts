pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // EZ KELL: A Flutter plugin helye
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
        // EZ IS KELL: A többi Flutter csomag helye
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")

// EZ IS KELL: Megmondja, hogy a plugin létezik
plugins {
    id("dev.flutter.flutter-gradle-plugin").version("1.0.0").apply(false)
}
