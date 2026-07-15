allprojects {
    repositories {
        google()
        mavenCentral()
        // jcenter() was removed in Gradle 9; redirect any plugin that still
        // references it to mavenCentral() so the build doesn't fail.
        maven { url = uri("https://jcenter.bintray.com") }
    }
}

// Some older Flutter plugins still declare compileSdk 34 in their Android
// subprojects. Newer Flutter Android lifecycle dependencies require API 36,
// so keep every Android library aligned with the application's compileSdk.
subprojects {
    // Legacy plugins such as file_picker set their own compileSdk while their
    // build script is evaluated. Apply this after evaluation so API 36 is the
    // final value used by every Android library.
    afterEvaluate {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.api.dsl.LibraryExtension>("android") {
                compileSdk = 36
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
