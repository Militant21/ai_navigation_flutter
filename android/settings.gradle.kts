// android/settings.gradle.kts

import java.io.File
import org.gradle.api.GradleException

// --- Plugin források és verziók ---
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    // Itt adjuk meg a pluginverziókat, NEM az app modulban
    plugins {
        id("com.android.application") version "8.7.0"
        id("org.jetbrains.kotlin.android") version "2.1.0"
    }
}

// A függőségek központi kezelése + Flutter maven repo
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")

// --- Flutter SDK feloldása robust módon (local.properties -> FLUTTER_ROOT) ---
val flutterSdkPath: String = run {
    val localProps = File(rootDir, "local.properties")
    if (localProps.exists()) {
        val p = java.util.Properties()
        localProps.inputStream().use { p.load(it) }
        p.getProperty("flutter.sdk")?.let { return@run it }
    }
    System.getenv("FLUTTER_ROOT")
        ?: throw GradleException(
            "Flutter SDK not found. Állítsd be az android/local.properties-ben (flutter.sdk), " +
            "vagy a FLUTTER_ROOT környezeti változóban."
        )
}

// A Flutter Gradle plugin elérhetővé tétele (nincs több apply(from = ...))
includeBuild(File(flutterSdkPath, "packages/flutter_tools/gradle"))
