package db.codegen

import better.files._
import slick.jdbc.PostgresProfile

object DbGenerator {
  def main(args: Array[String]): Unit = {
    CodeGen.runCodeGen(
      dbName = "default",
      configFile = File("conf/application.conf"),
      schemaFolder = File("app/db"),
      schemaPackageName = "db",
      modelsFolder = File("app/db"),
      modelsPackageName = "db",
      profile = PostgresProfile
    )
  }
}
