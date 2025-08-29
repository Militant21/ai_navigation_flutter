// android/settings.gradle.kts

import java.io.FileInputStream
import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    // A pluginek verziói ITT legyenek rögzítve
    plugins {
        id("com.android.application") version "8.1.4"
        id("com.android.library") version "8.1.4"
        id("org.jetbrains.kotlin.android") version "1.9.24"
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    }
}

// Flutter SDK helye a local.properties-ből
val props = Properties()
val lp = file("local.properties")
if (lp.exists()) {
    FileInputStream(lp).use { props.load(it) }
}
val flutterSdk: String? = props.getProperty("flutter.sdk")

// A Flutter gradle plugin include-buildje a Flutter SDK-ból
if (flutterSdk != null) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("⚠ 'flutter.sdk' nincs beállítva az android/local.properties-ben.")
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
