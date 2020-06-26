package db.codegen

import slick.codegen.SourceCodeGenerator
import slick.model.Model

class CustomCodeGenerator(model: Model) extends SourceCodeGenerator(model) {
  override def entityName: String => String = _.toCamelCase

  override def tableName: String => String = name => s"${entityName(name)}Table"

  override def Table = new Table(_) {
    table =>
    override def factory: String = {
      val apply = s"${TableClass.elementType}.apply"
      if (columns.size == 1) apply else s"($apply _).tupled"
    }

    override def EntityType: EntityTypeDef = new EntityTypeDef {
      override def doc: String = ""
    }

    override def TableValue: TableValueDef = new TableValueDef {
      override def rawName: String = super.rawName.uncapitalize
    }
  }

}
