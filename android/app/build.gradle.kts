// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") // eski: "kotlin-android"
    // Flutter Gradle Plugin must be applied after Android/Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.arat.sifakapp"

    // Flutter wrapper'dan çekiyoruz
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.arat.sifakapp"
        // Bump minSdk to satisfy awesome_notifications (requires >=23)
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        // Java 17 önerilir
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 🔧 Kotlin DSL'de böyle:
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // TODO: prod imza
        }
    }
}

flutter {
    source = "../.."
}

// Desugaring dependency (KOTLIN DSL)
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
