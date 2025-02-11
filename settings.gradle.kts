
plugins {
    // to automatically download the toolchain jdk if missing
    id("org.gradle.toolchains.foojay-resolver-convention") version "0.6.0"
}

rootProject.name = "Lox IDE"

include(":lox")
project(":lox").projectDir = file("../vm")

