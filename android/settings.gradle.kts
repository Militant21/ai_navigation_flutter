// android/settings.gradle.kts
import java.util.Properties
import java.io.File

fun flutterSdkFromLocalProperties(): String? {
    val f = File("local.properties")
    if (!f.exists()) return null
    val p = Properties()
    f.inputStream().use { p.load(it) }
    return p.getProperty("flutter.sdk")
}

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }

    // >>> A Flutter SDK útvonal feloldása MÁR itt, a plugin alkalmazása ELŐTT
    val flutterSdkPath: String? =
        System.getenv("FLUTTER_ROOT")
            ?: System.getenv("FLUTTER_HOME")
            ?: flutterSdkFromLocalProperties()

    require(!flutterSdkPath.isNullOrBlank()) {
        "Flutter SDK path not found. Set FLUTTER_ROOT/FLUTTER_HOME or write android/local.properties with flutter.sdk=/path/to/flutter"
    }

    println(">> Using Flutter SDK at: $flutterSdkPath")
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
}

// >>> NINCS version megadva!
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
