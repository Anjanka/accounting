name := """accounting"""
organization := "org.peabuddies"

version := "1.0-SNAPSHOT"

lazy val root = (project in file("."))
  .enablePlugins(PlayScala)
  .enablePlugins(JavaServerAppPackaging)

scalaVersion := "2.13.10"

val circeVersion = "0.14.5"

libraryDependencies ++= Seq(
  guice,
  "org.scalatestplus.play" %% "scalatestplus-play"    % "5.1.0" % Test,
  "com.typesafe.slick"     %% "slick"                 % "3.4.1",
  "com.typesafe.slick"     %% "slick-codegen"         % "3.4.1",
  "com.typesafe.slick"     %% "slick-hikaricp"        % "3.4.1",
  "org.postgresql"          % "postgresql"            % "42.5.4",
  "io.circe"               %% "circe-core"            % circeVersion,
  "io.circe"               %% "circe-generic"         % circeVersion,
  "io.circe"               %% "circe-parser"          % circeVersion,
  "org.flywaydb"           %% "flyway-play"           % "7.37.0",
  "com.typesafe.play"      %% "play-slick"            % "5.1.0",
  "com.typesafe.play"      %% "play-slick-evolutions" % "5.1.0",
  "com.dripower"           %% "play-circe"            % "2814.2",
  "com.davegurnell"        %% "bridges"               % "0.24.0",
  "com.github.pathikrit"   %% "better-files"          % "3.9.2",
  "org.scalameta"          %% "scalafmt-dynamic"      % "3.7.2",
  "org.apache.xmlgraphics"  % "fop"                   % "2.7",
  "org.scalameta"          %% "scalameta"             % "4.7.6",
  // Transitive dependency. Override added for proper version.
  "com.fasterxml.jackson.module" %% "jackson-module-scala" % "2.14.2"
)

dependencyOverrides ++= Seq(
  "com.google.inject" % "guice" % "5.1.0"
)

scalacOptions ++= Seq(
  "-Ymacro-annotations"
)

lazy val elmGenerate = Command.command("elmGenerate") { state =>
  "runMain elm.Bridge" :: state
}

lazy val dbGenerate = Command.command("dbGenerate") { state =>
  "runMain db.codegen.DbGenerator" :: state
}

commands += elmGenerate
commands += dbGenerate

Docker / maintainer    := "nikita.danilenko.is@gmail.com"
Docker / packageName   := "accounting"
Docker / version       := sys.env.getOrElse("BUILD_NUMBER", "0")
Docker / daemonUserUid := None
Docker / daemonUser    := "daemon"
dockerBaseImage        := "adoptopenjdk/openjdk11:latest"
dockerUpdateLatest     := true

// Patches and workarounds

// Docker has known issues with Play's PID file. The below command disables Play's PID file.
// cf. https://www.playframework.com/documentation/2.8.x/Deploying#Play-PID-Configuration
// The setting is a possible duplicate of the same setting in the application.conf.
Universal / javaOptions ++= Seq(
  "-Dpidfile.path=/dev/null"
)
