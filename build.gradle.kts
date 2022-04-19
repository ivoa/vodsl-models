plugins {
    id("net.ivoa.vo-dml.vodmltools") version "0.3.6"
}

vodml {
    vodmlDir.set(file("src-gen"))
    vodmlFiles.setFrom(vodmlDir.file("lifecycleTest.vo-dml.xml"))
    bindingFiles.setFrom(file("testBinding.xml"))
}

dependencies {
    implementation("org.javastro.ivoa.vo-dml:ivoa-base:1.0-SNAPSHOT") //IMPL the "standard" base library
    // Use JUnit Jupiter for testing.
    testImplementation("org.junit.jupiter:junit-jupiter:5.7.2")
}

tasks.named<Test>("test") {
    // Use JUnit Platform for unit tests.
    useJUnitPlatform()
}

