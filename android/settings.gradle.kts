// android/settings.gradle.kts
import java.io.File
import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

plugins {
    // NINCS verzió megadva!
    id("dev.flutter.flutter-plugin-loader")
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")

// Flutter SDK útvonal felderítése
fun flutterSdkFromLocalProperties(): String? {
    val f = File("local.properties")
    if (!f.exists()) return null
    val p = Properties()
    f.inputStream().use { p.load(it) }
    return p.getProperty("flutter.sdk")
}

val flutterSdkPath: String? =
    System.getenv("FLUTTER_ROOT")
        ?: System.getenv("FLUTTER_HOME")
        ?: flutterSdkFromLocalProperties()

if (flutterSdkPath != null) {
    println("Including Flutter gradle from: $flutterSdkPath")
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
} else {
    println("WARNING: Flutter SDK path not found.")
}
