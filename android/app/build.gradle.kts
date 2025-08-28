plugins {
    id("com.android.application")
    id("kotlin-android")
    // A Flutter Gradle Plugin az Android és Kotlin plugin után legyen
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_navigation_flutter"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Stabil beállítás AGP-hez
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // <-- kell a flutter_local_notifications miatt
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Állítsd a saját csomagnevedre, ha kell
        applicationId = "com.example.ai_navigation_flutter"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Példa: debug kulccsal írjuk alá, hogy a CI tudjon release-t építeni
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // Desugaring JDK könyvtárakhoz (Java 8+ API-k régebbi Androidra)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
