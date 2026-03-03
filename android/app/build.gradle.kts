plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// HIER EINFÜGEN - VOR dem android {} Block!
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.theissenmatthias.mindfulness_reminder"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // HIER: Von 26.x auf 27.x ändern

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
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

        // WICHTIG: Hier auch anpassen auf deine namespace!
defaultConfig {
    applicationId = "com.theissenmatthias.mindfulness_reminder"
    multiDexEnabled = true

    minSdk = 23
    targetSdk = 35  // Android 14
    versionCode = 15
    versionName = "1.1.5"
}    

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            isMinifyEnabled = false      // Ausschalten!
            isShrinkResources = false    // Ausschalten!
            ndk {
                debugSymbolLevel = "FULL"  // oder "SYMBOL_TABLE"
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