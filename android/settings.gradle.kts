import java.io.File
import java.util.Properties

// Beolvassuk a "local.properties" fájlt, hogy megtudjuk, hol van a Flutter SDK
val localPropertiesFile = File(rootDir, "local.properties")
val properties = Properties()
if (localPropertiesFile.exists()) {
    properties.load(java.io.FileInputStream(localPropertiesFile))
}

val flutterSdkPath = properties.getProperty("flutter.sdk")
if (flutterSdkPath == null) {
    throw GradleException("Flutter SDK not found. Define location in local.properties.")
}

// A régi, direkt módszer, ami a HELYI fájlt használja, nem a távoli tárolót
apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/flutter.gradle")

// A szokásos projektbeállítások
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
