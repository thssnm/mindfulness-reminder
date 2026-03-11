plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val useKeystoreSigning = keystorePropertiesFile.exists()
if (useKeystoreSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.theissenmatthias.mindfulness_reminder"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  

    dependenciesInfo {
        includeInApk = false
        includeInBundle = false
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_11  // Von 1.8 auf 11
        targetCompatibility = JavaVersion.VERSION_11  // Von 1.8 auf 11
    }
    // For Kotlin projects
    kotlinOptions {
        jvmTarget = "11"  
    }

    signingConfigs {
        if (useKeystoreSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

defaultConfig {
    applicationId = "com.theissenmatthias.mindfulness_reminder"
    multiDexEnabled = true

    minSdk = 23
    targetSdk = 35  // Android 14
    versionCode = 3
    versionName = "1.0.2"
}    

    buildTypes {
        release {
            if (useKeystoreSigning) {
                signingConfig = signingConfigs.getByName("release")
            }

            isMinifyEnabled = false     
            isShrinkResources = false    
            ndk {
                debugSymbolLevel = "FULL"  
            }

        }
    }
}

dependencies {
    // For AGP 7.4+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}