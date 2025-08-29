import java.util.Properties
import java.io.FileInputStream

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    val props = Properties()
    val lp = file("local.properties")
    if (lp.exists()) {
        FileInputStream(lp).use { props.load(it) }
    }
    val flutterSdk: String? = props.getProperty("flutter.sdk")

    if (flutterSdk != null) {
        includeBuild("$flutterSdk/packages/flutter_tools/gradle")
    } else {
        logger.warn("⚠️ 'flutter.sdk' nincs beállítva a android/local.properties-ben.")
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
