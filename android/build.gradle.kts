// android/build.gradle.kts (root, NEM az app modul)

plugins {
    // Csak verzió-deklarációk a gyökérben; az app modulban lesznek alkalmazva
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Opcionális: CI-hoz nem muszáj a buildDir-átirányítás; elhagyható.
// Ha szeretnéd megtartani, maradhat a korábbi "build/" áthelyezős rész.

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
