pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.6.0"
        id("org.jetbrains.kotlin.android") version "2.1.0"
        id("dev.flutter.flutter-gradle-plugin")
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

// Flutter SDK bekötése (a Flutter action már írja a local.properties-t)
val props = java.util.Properties()
val lp = file("local.properties")
if (lp.exists()) {
    lp.inputStream().use { props.load(it) }
}
val flutterSdk: String? = props.getProperty("flutter.sdk") ?: System.getenv("FLUTTER_ROOT")

if (flutterSdk != null) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("⚠️ A 'flutter.sdk' nincs beállítva (android/local.properties vagy env).")
}

rootProject.name = "ai_navigation_flutter"
include(":app")
