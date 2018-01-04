enablePlugins(ScalaJSPlugin)

name := "accounting"

version := "0.1"

scalaVersion := "2.12.4"

libraryDependencies += "org.scalacheck" %% "scalacheck" % "1.13.4" % "test"

scalaJSUseMainModuleInitializer := true