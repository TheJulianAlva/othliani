plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.frontend"
    compileSdk = 35
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.frontend"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "rol"

    productFlavors {
        create("turista") {
            dimension = "rol"
            applicationIdSuffix = ".turista"
            resValue("string", "app_name", "Veltur Turista")
        }
        create("guia") {
            dimension = "rol"
            applicationIdSuffix = ".guia"
            resValue("string", "app_name", "Veltur Guía")
        }
        create("agencia") {
            dimension = "rol"
            applicationIdSuffix = ".agencia"
            resValue("string", "app_name", "Veltur Agencia")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            
            isMinifyEnabled = true 
            
            // NOTA: Si esto falla con ML Kit, cámbialo a 'false'
            isShrinkResources = false 

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
