import org.gradle.api.initialization.Settings
import java.io.File
import java.util.Properties

// --- Plugin- és függőségkezelés (ez a rész változatlan) ---
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
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")


// --- A JAVÍTOTT, ROBUSTUS Flutter SDK betöltés ---

// Egy külön funkció, ami biztonságosan megkeresi a Flutter SDK-t
fun loadFlutterSdkPath(settings: Settings): String {
    val localPropertiesFile = File(settings.rootDir, "local.properties")
    if (localPropertiesFile.exists()) {
        val properties = Properties()
        properties.load(localPropertiesFile.inputStream())
        val sdkPath = properties.getProperty("flutter.sdk")
        if (sdkPath != null) {
            return sdkPath
        }
    }
    val flutterRoot = System.getenv("FLUTTER_ROOT")
    if (flutterRoot != null) {
        return flutterRoot
    }
    throw GradleException("Flutter SDK not found. Define location in local.properties or with FLUTTER_ROOT env var.")
}

// Meghívjuk a funkciót, hogy megkapjuk az útvonalat
val flutterSdkPath = loadFlutterSdkPath(settings)

// Alkalmazzuk a Flutter beállító scriptjét a kapott útvonallal
includeBuild(File(flutterSdkPath, "packages/flutter_tools/gradle"))

