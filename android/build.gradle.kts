import org.gradle.api.file.Directory

// --- Repositories minden modulnak ---
// (Ha a settings-ben PREFER_PROJECT van, ezek lesznek érvényben;
// ha PREFER_SETTINGS, akkor sem árt, de nem zavar be.)
subprojects {
    repositories {
        google()
        mavenCentral()
        // Flutter engine / artifacts
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

// --- Build mappa központosítása (ahogy nálad is volt) ---
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
