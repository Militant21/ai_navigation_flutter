// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_navigation_flutter"

    // A Flutter plugin adja ezeket a változókat
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications miatt
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai_navigation_flutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // CI-hez „debug” kulccsal írunk alá
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Modulfüggőségek
dependencies {
    // JDK8+ API-k desugar-olása
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// A Flutter modul helye
flutter {
    source = "../.."
}

// FONTOS: NINCS repositories blokk itt!
