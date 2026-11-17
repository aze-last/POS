import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.banana.pos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storePath = keystoreProperties.getProperty("storeFile")
                val storeFileObj = if (storePath != null) rootProject.file(storePath) else null
                if (storeFileObj != null && !storeFileObj.exists()) {
                    throw GradleException("Keystore file defined in android/key.properties does not exist: ${storeFileObj.absolutePath}. Release builds strictly require signing configuration per AGENTS.md §7.")
                }
                storeFile = storeFileObj
                storePassword = keystoreProperties.getProperty("storePassword")
                enableV1Signing = true
                enableV2Signing = true
            } else {
                // AGENTS.md §7: Release builds strictly fail if key.properties is missing; no debug fallback.
                val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
                if (isReleaseBuild) {
                    throw GradleException("android/key.properties is missing! Release builds strictly require signing configuration per AGENTS.md §7.")
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.banana.pos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (!keystorePropertiesFile.exists()) {
                val isReleaseBuild = gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }
                if (isReleaseBuild) {
                    throw GradleException("android/key.properties is missing! Release builds strictly require signing configuration per AGENTS.md §7.")
                }
            }
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
