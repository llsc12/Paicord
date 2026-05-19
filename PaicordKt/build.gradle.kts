plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    // alias(libs.plugins.jetbrains.kotlin.serialization)
}

android {
    namespace = "com.llsc12.paicord"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        applicationId = "com.llsc12.paicord"
        minSdk = libs.versions.minSdk.get().toInt()
        targetSdk = libs.versions.targetSdk.get().toInt()
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
}

dependencies {
    implementation("org.swift.swiftkit:swiftkit-core:1.0-SNAPSHOT")
    implementation(project(":PaicordLib"))

    // Compose/Material packages
    implementation(libs.androidx.ui)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.activity.compose)

    // Navigation 3
    // implementation(libs.androidx.navigation3.ui)
    // implementation(libs.androidx.navigation3.runtime)

    // Kotlin serialization
    // implementation(libs.kotlinx.serialization.core)
}
