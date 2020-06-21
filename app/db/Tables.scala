package db


import java.sql.Date

import slick.jdbc.PostgresProfile.api._
import slick.lifted.Shape._
import slick.lifted.{ProvenShape, Tag}

object Tables {

  class AccountDB(tag: Tag) extends Table[Account](_tableTag = tag, _tableName = "account") {
    def companyId: Rep[Int] = column[Int]("companyId", O.PrimaryKey)

    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)

    def title: Rep[String] = column[String]("title")

    override def * : ProvenShape[Account] = (companyId, id, title) <> (( Account.apply _).tupled, Account.unapply)
  }

  val accountTable: TableQuery[AccountDB] = TableQuery[AccountDB]

  class AccountingEntryDB(tag: Tag) extends Table[AccountingEntry](_tableTag = tag, _tableName = "accounting_entry") {
    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)

    def accountingYear: Rep[Int] = column[Int]("accounting_year", O.PrimaryKey)

    def bookingDate: Rep[Date] = column[Date]("booking_date")

    def receiptNumber: Rep[String] = column[String]("receipt_number")

    def description: Rep[String] = column[String]("description")

    def credit: Rep[Int] = column[Int]("credit")

    def debit: Rep[Int] = column[Int]("debit")

    def amountWhole: Rep[Int] = column[Int]("amount_whole")

    def amountChange: Rep[Int] = column[Int]("amount_change")

    override def * : ProvenShape[AccountingEntry] = (id, accountingYear, bookingDate, receiptNumber, description, credit, debit, amountWhole, amountChange) <> ((AccountingEntry.apply _).tupled, AccountingEntry.unapply)
  }

  val dbAccountingEntryTable: TableQuery[AccountingEntryDB] = TableQuery[AccountingEntryDB]

  class AccountingEntryTemplateDB(tag: Tag) extends Table[AccountingEntryTemplate](_tableTag = tag, _tableName = "accounting_entry_template") {

    def description: Rep[String] = column[String]("description", O.PrimaryKey)

    def credit: Rep[Int] = column[Int]("credit")

    def debit: Rep[Int] = column[Int]("debit")

    def amountWhole: Rep[Int] = column[Int]("amount_whole")

    def amountChange: Rep[Int] = column[Int]("amount_change")

    override def * : ProvenShape[AccountingEntryTemplate] = (description, credit, debit, amountWhole, amountChange) <> ((AccountingEntryTemplate.apply _).tupled, AccountingEntryTemplate.unapply)
  }

  val dbAccountingEntryTemplateTable: TableQuery[AccountingEntryTemplateDB] = TableQuery[AccountingEntryTemplateDB]



  class CompanyDB(tag: Tag) extends Table[Company](_tableTag = tag, _tableName = "company") {
    def id: Rep[Int] = column[Int]("id", O.PrimaryKey)

    def name: Rep[String] = column[String]("name")

    def address: Rep[String] = column[String]("address")

    def taxNumber: Rep[String] = column[String]("taxNumber")

    def revenueOffice: Rep[String] = column[String]("revenueOffice")

    override def * : ProvenShape[Company] = (id, name, address, taxNumber, revenueOffice) <> ((Company.apply _).tupled, Company.unapply)
  }

  val companyTable: TableQuery[CompanyDB] = TableQuery[CompanyDB]
}

