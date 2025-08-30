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
        // Flutter binárisok (embedding) repoja
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}
rootProject.name = "ai_navigation_flutter"
include(":app")

// EZ KELL: a Flutter loader plugin
plugins {
    id("dev.flutter.flutter-plugin-loader")
}

// Ha nálad van FLUTTER_ROOT vagy local.properties-ben flutter.sdk, nem kell semmi plusz.
// (Régi: apply-from / includeBuild hackeket hagyd ki.)
