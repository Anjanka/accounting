package elm

import base.Account
import bridges.elm._
import bridges.core._
import bridges.core.syntax._
import shapeless.Lazy

import scala.reflect.runtime.universe.TypeTag
import better.files._
import bridges.core.Type.Ref
import db.{DBAccountingEntry, DBAccountingEntryTemplate}

object Bridge {

  val elmModule: String = "Api.Types"
  val elmModuleFilePath: File = "frontend" / "src" / "Api" / "Types"

  def mkElmBridge[A](withDateReplacement: Boolean = true)
                    (implicit tpeTag: TypeTag[A],
                     encoder: Lazy[Encoder[A]]): (String, String) = {
    val replacements: Map[Ref, TypeReplacement] =
      if (withDateReplacement)
        Map(
          Ref("Date") -> TypeReplacement(
            "Date",
            imports = s"import $elmModule.Date exposing (..)",
            encoder = "encoderDate",
            decoder = "decoderDate"
          )
        )
      else Map.empty
    val (fileName, content) = Elm.buildFile(
      module = elmModule,
      decls = List(
        decl[A]
      ),
      customTypeReplacements = replacements
    )
    fileName ->
      /* The bridge library puts a no longer existing function call here,
         which is why we manually replace it with the correct function.*/
      content.replaceAll(" decode ", " Decode.succeed ")
  }

  def mkAndWrite[A](withDateReplacement: Boolean = true)
                   (implicit tpeTag: TypeTag[A],
                    encoder: Lazy[Encoder[A]]): Unit = {
    val (filePath, content) = mkElmBridge[A](withDateReplacement)
    val file = (
      elmModuleFilePath /
        filePath
      ).createIfNotExists(createParents = true)
    file.write(content)
  }

  def main(args: Array[String]): Unit = {
    mkAndWrite[Date](withDateReplacement = false)
    mkAndWrite[Account]()
    mkAndWrite[DBAccountingEntry]()
    mkAndWrite[DBAccountingEntryTemplate]()
  }

}
