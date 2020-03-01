package db

import base.Account
import slick.lifted.{ProvenShape, Tag}
import slick.lifted.Shape._
import slick.jdbc.PostgresProfile.api._

object Tables {

  class AccountDB(tag: Tag) extends Table[Account](_tableTag = tag, _tableName = "account") {
    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)
    def title: Rep[String] = column[String]("title")

    override def * : ProvenShape[Account] = (id, title) <> ({ case (i, t) => Account(i, t)}, Account.unapply)
  }

  val accountTable: TableQuery[AccountDB] = TableQuery[AccountDB]



}
