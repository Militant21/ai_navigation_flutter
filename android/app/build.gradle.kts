plugins {
    id("com.android.application") version "8.5.2"
    id("org.jetbrains.kotlin.android") version "1.9.24"
    // A Flutter Gradle plugin verziót NEM adjuk meg, az includeBuild-ből jön (settings.gradle.kts)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_navigation_flutter"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.ai_navigation_flutter"
        minSdk = 24   // minimum 24 legyen (CI elvárásod alapján)
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
        // DEBUG build: nincs minify/shrink → gyors fejlesztés, nincs hibád
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }

        // RELEASE build: minify + shrink → kisebb APK
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // ideiglenesen használhatod a debug keystore-t is, ha nincs saját
            // signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    // Flutter projekt gyökér (repo root) – a szokásos elrendezéshez
    source = "../../.."
}
