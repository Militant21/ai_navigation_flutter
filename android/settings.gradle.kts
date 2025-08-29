// android/settings.gradle.kts

import java.io.FileInputStream
import java.util.Properties

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    // A Flutter SDK helye a local.properties-ből
    val props = Properties()
    val lp = file("local.properties")
    if (lp.exists()) {
        FileInputStream(lp).use { props.load(it) }
    }
    val flutterSdk: String? = props.getProperty("flutter.sdk")

    // Itt „drótozzuk be” a Flutter gradle plugint a Flutter SDK-ból
    if (flutterSdk != null) {
        includeBuild("$flutterSdk/packages/flutter_tools/gradle")
    } else {
        logger.warn("⚠️  'flutter.sdk' nincs beállítva a android/local.properties-ben.")
    }
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
