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

    // Flutter SDK helye: env -> local.properties
    val flutterSdkPath: String? =
        System.getenv("FLUTTER_ROOT")
            ?: System.getenv("FLUTTER_HOME")
            ?: run {
                val f = File("local.properties")
                if (!f.exists()) null else Properties().let { p ->
                    f.inputStream().use { p.load(it) }
                    p.getProperty("flutter.sdk")
                }
            }

    require(!flutterSdkPath.isNullOrBlank()) {
        "Flutter SDK path not found. Állítsd be a FLUTTER_ROOT/FLUTTER_HOME változót, " +
        "vagy írj android/local.properties fájlt: flutter.sdk=/path/to/flutter"
    }

    println(">> Using Flutter SDK at: $flutterSdkPath")
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

// NINCS verzió megadva a loaderhez!
plugins {
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
