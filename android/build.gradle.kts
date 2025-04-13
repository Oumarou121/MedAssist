buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.6.0")  // Vérifiez la version compatible
        classpath("com.google.gms:google-services:4.3.10") // Plugin Firebase
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.20") // Version stable recommandée
        classpath("com.android.tools.build:gradle:")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
