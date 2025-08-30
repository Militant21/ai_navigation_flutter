import org.gradle.api.initialization.resolve.RepositoriesMode
import java.util.Properties
import java.io.FileInputStream

// --- Plugin Management: Itt definiáljuk a központi repository-kat ---
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// --- Dependency Resolution: Itt adjuk meg a projekt függőségeinek a forrásait ---
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter engine artifact-ok
        maven {
            url = uri("https://storage.googleapis.com/download.flutter.io")
        }
    }
}

// --- Flutter SDK útvonalának beolvasása és a plugin bekötése ---
val localProperties = Properties()
val localPropertiesFile = file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterSdkPath = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: throw Exception("Flutter SDK not found. Define location in local.properties or with FLUTTER_ROOT env var.")

apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/flutter.groovy")

// --- Projekt nevének és az app modulnak a beállítása ---
rootProject.name = "ai_navigation_flutter"
include(":app")
