pluginManagement {
    // A JAVÍTÁS: A helyes relatív útvonal a projekt gyökerében lévő generált fájlhoz
    includeBuild("../ephemeral/.android/include_flutter.groovy")
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
