plugins {
    id("com.android.application") version "8.5.2"
    id("org.jetbrains.kotlin.android") version "1.9.24"
    // A verziót NEM adjuk meg: az includeBuild-ből jön (settings.gradle.kts)
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
        release {
            isMinifyEnabled = false
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
