// android/settings.gradle.kts

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

// Flutter SDK helye: FLUTTER_ROOT env vagy local.properties
val props = java.util.Properties()
val lp = file("local.properties")
if (lp.exists()) {
    val fis = java.io.FileInputStream(lp)
    try {
        props.load(fis)
    } finally {
        fis.close()
    }
}

val flutterSdk: String? = System.getenv("FLUTTER_ROOT") ?: props.getProperty("flutter.sdk")

if (flutterSdk != null) {
    includeBuild("$flutterSdk/packages/flutter_tools/gradle")
} else {
    logger.warn("'flutter.sdk' nincs beállítva (FLUTTER_ROOT/local.properties).")
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "ai_navigation_flutter"
include(":app")
