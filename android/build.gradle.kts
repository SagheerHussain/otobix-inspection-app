import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
        // If still fails in rare cases, uncomment:
        // maven(url = "https://jitpack.io")
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

/**
 * ✅ FFmpegKit fix (IMPORTANT)
 * com.arthenica:ffmpeg-kit-https:6.0-2 is missing in repos.
 * This override MUST be at project level so it applies to ALL modules
 * including :ffmpeg_kit_flutter.
 */
subprojects {
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.arthenica" && requested.name == "ffmpeg-kit-https") {
                useTarget("io.github.maitrungduc1410:ffmpeg-kit-https:6.0.1")
            }
        }
    }
}
