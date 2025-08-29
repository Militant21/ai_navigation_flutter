import java.io.FileInputStream
import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // Flutter SDK beemelése a lokalból
    val props = Properties()
    val lp = file("local.properties")
    if (lp.exists()) {
        FileInputStream(lp).use { props.load(it) }
    }
    val flutterSdk: String? = props.getProperty("flutter.sdk")
    if (flutterSdk != null) {
        includeBuild("$flutterSdk/packages/flutter_tools/gradle")
    } else {
        logger.warn("⚠ 'flutter.sdk' nincs beállítva az android/local.properties-ben.")
    }
}

// Itt KELL rögzíteni a plugin verziókat
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.4" apply false
    id("com.android.library") version "8.1.4" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
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
