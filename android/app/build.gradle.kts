plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle plugin – a verziót a settings adja
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
            isMinifyEnabled = false
            isShrinkResources = false
        }
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

// NINCS repositories blokk itt!
