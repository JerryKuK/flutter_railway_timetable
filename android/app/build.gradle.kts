import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.devtools.ksp")
    id("dev.flutter.flutter-gradle-plugin")
}

val localProps = Properties()
val localPropsFile = rootProject.file("local.properties")
if (localPropsFile.exists()) {
    localPropsFile.inputStream().use { localProps.load(it) }
}

android {
    namespace = "com.example.flutter_railway_timetable"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }


    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        // Pinned to Kotlin 1.8.22 — bump together when Flutter upgrades Kotlin
        // (mapping: https://developer.android.com/jetpack/androidx/releases/compose-kotlin).
        kotlinCompilerExtensionVersion = "1.4.8"
    }

    defaultConfig {
        applicationId = "com.example.flutter_railway_timetable"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        buildConfigField("String", "TDX_CLIENT_ID",
            "\"${localProps.getProperty("TDX_CLIENT_ID", "")}\"")
        buildConfigField("String", "TDX_CLIENT_SECRET",
            "\"${localProps.getProperty("TDX_CLIENT_SECRET", "")}\"")
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// KSP 1.8.22 + Gradle 8.10 requires explicit jvmTarget via compilerOptions API
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    compilerOptions.jvmTarget.set(JvmTarget.JVM_11)
}


dependencies {
    // Glance Widget
    implementation("androidx.glance:glance-appwidget:1.0.0")

    // Room (2.5.x is the last version compatible with KSP 1.8.22-1.0.11)
    implementation("androidx.room:room-runtime:2.5.2")
    implementation("androidx.room:room-ktx:2.5.2")
    ksp("androidx.room:room-compiler:2.5.2")

    // Retrofit + OkHttp
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")

    // Test
    testImplementation("junit:junit:4.13.2")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.7.3")
    testImplementation("com.squareup.okhttp3:mockwebserver:4.12.0")
    // Real org.json for JVM unit tests (Android stubs throw "not mocked")
    testImplementation("org.json:json:20231013")
}
