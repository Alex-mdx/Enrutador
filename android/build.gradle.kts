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
    project.buildscript.repositories {
        google()
        mavenCentral()
    }
    project.repositories {
        google()
        mavenCentral()
    }

    project.afterEvaluate {
        val androidExt = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        androidExt?.compileSdkVersion(36)
    }

    project.configurations.all {
        resolutionStrategy.dependencySubstitution {
            all {
                // Previene fallos por sustituciones vacías
            }
        }
    }
    // Eliminar jcenter() si una librería antigua intenta incluirlo
    project.buildscript.repositories.all {
        if (this.name == "BintrayJCenter") {
            project.buildscript.repositories.remove(this)
        }
    }
}

tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:none")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
