import java.io.File

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

// --- A lényegi rész: Flutter SDK betöltése és script futtatása ---

// Beolvassuk a "local.properties" fájlt, hogy megtudjuk, hol van a Flutter SDK
val localPropertiesFile = rootProject.file("local.properties")
val properties = java.util.Properties()
if (localPropertiesFile.exists()) {
    properties.load(java.io.FileInputStream(localPropertiesFile))
}

// Kiolvassuk a Flutter SDK útvonalát
val flutterSdkPath = properties.getProperty("flutter.sdk")
if (flutterSdkPath == null) {
    throw GradleException("Flutter SDK not found. Define location in local.properties.")
}

// Ezzel a paranccsal futtatjuk a Flutter saját beállító scriptjét
apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/flutter.gradle")
