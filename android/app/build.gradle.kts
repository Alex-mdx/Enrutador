plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.enrutador"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true  // Opcional (para APIs modernas en Android < 8.0)
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.enrutador"
        minSdk = 24
        targetSdk = 36
        versionCode = 1
        versionName = "0.0.1"
         manifestPlaceholders.apply {
            put("appAuthRedirectScheme", "com.example.enrutador")
        }
    }
    packagingOptions {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

}
dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}