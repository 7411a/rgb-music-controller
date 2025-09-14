plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.rgb_controller_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // RGB LED Controller App - Unique Application ID
        applicationId = "com.rgbcontroller.esp32.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 21  // Minimum for modern Android features
        targetSdk = 34  // Latest Android API
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            // Temporarily disable minification to avoid R8 issues
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // TODO: Configure proper signing for Play Store release
            // For now using debug keys - CHANGE THIS for production!
            signingConfig = signingConfigs.getByName("debug")
            
            // Release-specific configurations
            isDebuggable = false
            isJniDebuggable = false
            isPseudoLocalesEnabled = false
        }
        
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-DEBUG"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Play Core library for Play Store compatibility
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
}
