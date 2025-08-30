pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // EZ A SOR HIÁNYZOTT: A Flutter plugin saját helye
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
        // Ez a sor itt is kell a többi Flutter csomaghoz
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
