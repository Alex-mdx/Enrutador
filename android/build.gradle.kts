allprojects {
    repositories {
        google()
        mavenCentral()
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

subprojects {
    project.buildscript.repositories {
        google()
        mavenCentral()
    }
    project.repositories {
        google()
        mavenCentral()
    }
}

tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:none")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
