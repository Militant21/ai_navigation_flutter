import java.io.File
import java.util.Properties
import org.gradle.api.GradleException

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // Flutter Maven repo (embedding/artifacts)
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }

    // A Flutter Gradle plugin feloldása a Flutter SDK-ból (NINCS legacy "apply")
    val localProps = File(rootDir, "local.properties")
    val props = Properties().apply {
        if (localProps.exists()) localProps.inputStream().use { load(it) }
    }
    val flutterSdk: String = props.getProperty("flutter.sdk")
        ?: System.getenv("FLUTTER_ROOT")
        ?: throw GradleException(
            "Flutter SDK not found. Set flutter.sdk in android/local.properties or FLUTTER_ROOT env var."
        )

    includeBuild(File(flutterSdk, "packages/flutter_tools/gradle"))
    plugins {
        id("dev.flutter.flutter-gradle-plugin")
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter Maven repo a runtime/artifactokhoz
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
