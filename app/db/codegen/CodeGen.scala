package db.codegen

import better.files.File
import com.typesafe.config.ConfigFactory
import org.scalafmt.interfaces.Scalafmt
import slick.jdbc.JdbcProfile

import scala.concurrent.Await
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration.Duration
import scala.meta._

object CodeGen {

  def runCodeGen(
      dbName: String,
      configFile: File,
      schemaFolder: File,
      schemaPackageName: String,
      modelsFolder: File,
      modelsPackageName: String,
      profile: JdbcProfile
  ): Unit = {
    val config = ConfigFactory.parseFile(configFile.toJava).resolve()
    val fullDbPath = s"slick.dbs.$dbName"
    val tablesName = "Tables"
    val name = schemaFolder / tablesName

    val url = config.getString(s"$fullDbPath.db.url")
    val driver = config.getString(s"$fullDbPath.db.driver")
    val user = config.getString(s"$fullDbPath.db.user")
    val password = config.getString(s"$fullDbPath.db.password")

    val db = profile.api.Database.forURL(url = url, driver = driver, user = user, password = password)
    val tables = slick.jdbc.meta.MTable.getTables(None, None, None, Some(Seq("TABLE")))
    val excluded = Seq("flyway_schema_history")

    val fileName = s"$name.scala"

    //Generate the code which will usually be placed into the tables file.
    val generatedFileContent = {
      val modelAction = profile
        .createModel(Some(tables.map(_.filterNot(t => excluded.contains(t.name.name)))))
        .map { model =>
          val customCodeGenerator = new CustomCodeGenerator(model)
          customCodeGenerator.packageCode(
            profile = profile.toString().init,
            pkg = schemaPackageName,
            container = tablesName,
            parentType = customCodeGenerator.parentType
          )
        }
      Await.result(db.run(modelAction), Duration.Inf)
    }

    //Separate into the case classes and everything else
    val (caseClasses, everythingElse) = generatedFileContent.linesIterator.partition(_.trim.startsWith("case class"))

    File(fileName).overwrite(everythingElse.mkString("\n"))

    caseClasses.foreach { caseClass =>
      val caseClassStat = caseClass.parse[Stat].get
      val caseClassName = caseClassStat.collect {
        case q"case class $tname (...$paramss)" => tname.value
      }.head

      val caseClassFile = modelsFolder / s"$caseClassName.scala"

      if (caseClassFile.exists) {
        val originalContent = caseClassFile.contentAsString.parse[Source].get
        val withReplaced = replaceCode(originalContent, caseClassStat, caseClassName).toString()
        caseClassFile.overwrite(format(withReplaced))
      } else {
        val newContent = List(
          s"package $modelsPackageName",
          "import io.circe.JsonCodec",
          "import base.JsonCodecs.Implicits._",
          "@JsonCodec",
          caseClass
        ).mkString("\n")
        caseClassFile.write(format(newContent))
      }
    }
  }

  private val format: String => String = {
    val scalafmt = Scalafmt.create(getClass.getClassLoader)
    val config = File(".scalafmt.conf")
    val file = File("CodeGen.scala")

    scalafmt
      .format(config.path, file.path, _)
      .replace("@JsonCodec ", "@JsonCodec\n")
  }

  private def replaceCode(originalFile: Source, caseClass: Stat, caseClassName: String): Tree = {
    originalFile.transform {
      //This is the complete case class pattern (with all possible options)
      case q"@$annot case class $tname (...$paramss) extends { ..$earlydefns } with ..$parents { $self => ..$stats }"
          if tname.value == caseClassName =>
        caseClass.transform {
          //We assume that the given case class consists only of a name and parameters, and copy everything else from the original case class
          case q"case class $sameName (...$newParamss)" =>
            q"@$annot case class $sameName (...$newParamss) extends { ..$earlydefns } with ..$parents { $self => ..$stats }"
        }
    }
  }

}
