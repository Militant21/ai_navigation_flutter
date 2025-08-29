pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.7.2"
        id("com.android.library") version "8.7.2"
        id("org.jetbrains.kotlin.android") version "1.9.24"
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    }
}

include(":app")
