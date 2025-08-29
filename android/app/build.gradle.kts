plugins {
    id("com.android.application") version "8.6.0"
    id("org.jetbrains.kotlin.android") version "2.0.20"
    // A Flutter Gradle plugin verziót NEM adjuk meg: a settings.gradle.kts-ből jön
    id("dev.flutter.flutter-plugin")
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
        // Debug: gyors, nincs shrink/minify
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        // Release: karcsúsított APK (minify + shrink)
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // Java 8+ API-k desugarolása
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    // a Flutter projekt gyökere
    source = "../../"
}
