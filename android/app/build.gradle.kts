plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // A Flutter Gradle plugin verziót NEM adjuk meg: a settings.gradle.kts-ből jön
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_navigation_flutter"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ai_navigation_flutter"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        debug {
            // Gyors build, nincs shrink/minify
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            // Karcsúsított APK (minify + shrink)
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

// --- ÚJ: Flutter engine verzió kiolvasása a pontos dependency-hez ---
val flutterSdkPath = providers.gradleProperty("flutter.sdk")
    .orElse(System.getenv("FLUTTER_ROOT") ?: "")
    .get()

val engineVersion = file("$flutterSdkPath/bin/internal/engine.version")
    .takeIf { it.exists() }
    ?.readText()
    ?.trim()
    ?: error("Flutter engine.version nem található: $flutterSdkPath/bin/internal/engine.version")

dependencies {
    // Java 8+ API-k desugarolása
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")

    // Explicit Flutter embedding, hogy a Kotlin fordító biztosan lássa a FlutterActivity-t
    debugImplementation("io.flutter:flutter_embedding_debug:$engineVersion")
    profileImplementation("io.flutter:flutter_embedding_profile:$engineVersion")
    releaseImplementation("io.flutter:flutter_embedding_release:$engineVersion")
}

flutter {
    // A Flutter projekt gyökere
    source = "../../.."
}
