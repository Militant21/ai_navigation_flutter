import java.io.File
import java.util.Properties

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

// --- JAVÍTOTT RÉSZ ---

// Közvetlenül létrehozzuk a hivatkozást a "local.properties" fájlra
val localPropertiesFile = File(rootProject.rootDir, "local.properties")
val properties = Properties()

if (localPropertiesFile.exists()) {
    properties.load(java.io.FileInputStream(localPropertiesFile))
}

val flutterSdkPath = properties.getProperty("flutter.sdk")
if (flutterSdkPath == null) {
    throw GradleException("Flutter SDK not found. Define location in local.properties.")
}

apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/flutter.gradle")
