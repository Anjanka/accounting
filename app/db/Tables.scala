package db
// AUTO-GENERATED Slick data model
/** Stand-alone Slick data model for immediate use */
object Tables extends {
  val profile = slick.jdbc.PostgresProfile
} with Tables

/** Slick data model trait for extension, choice of backend or usage in the cake pattern. (Make sure to initialize this late.) */
trait Tables {
  val profile: slick.jdbc.JdbcProfile
  import profile.api._
  import slick.model.ForeignKeyAction
  // NOTE: GetResult mappers for plain SQL are only generated for tables where Slick knows how to map the types of all columns.
  import slick.jdbc.{GetResult => GR}

  /** DDL for all tables. Call .create to execute. */
  lazy val schema: profile.SchemaDescription = accountingEntryTable.schema ++ accountingEntryTemplateTable.schema ++ accountTable.schema ++ companyTable.schema
  @deprecated("Use .schema instead of .ddl", "3.0")
  def ddl = schema

  /** GetResult implicit for fetching AccountingEntry objects using plain SQL queries */
  implicit def GetResultAccountingEntry(implicit e0: GR[Int], e1: GR[java.sql.Date], e2: GR[String]): GR[AccountingEntry] = GR{
    prs => import prs._
    (AccountingEntry.apply _).tupled((<<[Int], <<[Int], <<[java.sql.Date], <<[String], <<[String], <<[Int], <<[Int], <<[Int], <<[Int], <<[Int]))
  }
  /** Table description of table accounting_entry. Objects of this class serve as prototypes for rows in queries. */
  class AccountingEntryTable(_tableTag: Tag) extends profile.api.Table[AccountingEntry](_tableTag, "accounting_entry") {
    def * = (id, accountingYear, bookingDate, receiptNumber, description, credit, debit, amountWhole, amountChange, companyId) <> ((AccountingEntry.apply _).tupled, AccountingEntry.unapply)
    /** Maps whole row to an option. Useful for outer joins. */
    def ? = ((Rep.Some(id), Rep.Some(accountingYear), Rep.Some(bookingDate), Rep.Some(receiptNumber), Rep.Some(description), Rep.Some(credit), Rep.Some(debit), Rep.Some(amountWhole), Rep.Some(amountChange), Rep.Some(companyId))).shaped.<>({r=>import r._; _1.map(_=> (AccountingEntry.apply _).tupled((_1.get, _2.get, _3.get, _4.get, _5.get, _6.get, _7.get, _8.get, _9.get, _10.get)))}, (_:Any) =>  throw new Exception("Inserting into ? projection not supported."))

    /** Database column id SqlType(int4) */
    val id: Rep[Int] = column[Int]("id")
    /** Database column accounting_year SqlType(int4) */
    val accountingYear: Rep[Int] = column[Int]("accounting_year")
    /** Database column booking_date SqlType(date) */
    val bookingDate: Rep[java.sql.Date] = column[java.sql.Date]("booking_date")
    /** Database column receipt_number SqlType(text) */
    val receiptNumber: Rep[String] = column[String]("receipt_number")
    /** Database column description SqlType(text) */
    val description: Rep[String] = column[String]("description")
    /** Database column credit SqlType(int4) */
    val credit: Rep[Int] = column[Int]("credit")
    /** Database column debit SqlType(int4) */
    val debit: Rep[Int] = column[Int]("debit")
    /** Database column amount_whole SqlType(int4) */
    val amountWhole: Rep[Int] = column[Int]("amount_whole")
    /** Database column amount_change SqlType(int4) */
    val amountChange: Rep[Int] = column[Int]("amount_change")
    /** Database column company_id SqlType(int4) */
    val companyId: Rep[Int] = column[Int]("company_id")

    /** Primary key of accountingEntryTable (database name accounting_entry_pkey) */
    val pk = primaryKey("accounting_entry_pkey", (companyId, id, accountingYear))

    /** Foreign key referencing accountTable (database name accounting_entry_credit_fkey) */
    lazy val accountTableFk1 = foreignKey("accounting_entry_credit_fkey", (credit, companyId), accountTable)(r => (r.id, r.companyId), onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.NoAction)
    /** Foreign key referencing accountTable (database name accounting_entry_debit_fkey) */
    lazy val accountTableFk2 = foreignKey("accounting_entry_debit_fkey", (debit, companyId), accountTable)(r => (r.id, r.companyId), onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.NoAction)
    /** Foreign key referencing companyTable (database name accounting_entry_company_fkey) */
    lazy val companyTableFk = foreignKey("accounting_entry_company_fkey", companyId, companyTable)(r => r.id, onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.Cascade)
  }
  /** Collection-like TableQuery object for table accountingEntryTable */
  lazy val accountingEntryTable = new TableQuery(tag => new AccountingEntryTable(tag))

  /** GetResult implicit for fetching AccountingEntryTemplate objects using plain SQL queries */
  implicit def GetResultAccountingEntryTemplate(implicit e0: GR[String], e1: GR[Int]): GR[AccountingEntryTemplate] = GR{
    prs => import prs._
    (AccountingEntryTemplate.apply _).tupled((<<[String], <<[Int], <<[Int], <<[Int], <<[Int], <<[Int], <<[Int]))
  }
  /** Table description of table accounting_entry_template. Objects of this class serve as prototypes for rows in queries. */
  class AccountingEntryTemplateTable(_tableTag: Tag) extends profile.api.Table[AccountingEntryTemplate](_tableTag, "accounting_entry_template") {
    def * = (description, credit, debit, amountWhole, amountChange, companyId, id) <> ((AccountingEntryTemplate.apply _).tupled, AccountingEntryTemplate.unapply)
    /** Maps whole row to an option. Useful for outer joins. */
    def ? = ((Rep.Some(description), Rep.Some(credit), Rep.Some(debit), Rep.Some(amountWhole), Rep.Some(amountChange), Rep.Some(companyId), Rep.Some(id))).shaped.<>({r=>import r._; _1.map(_=> (AccountingEntryTemplate.apply _).tupled((_1.get, _2.get, _3.get, _4.get, _5.get, _6.get, _7.get)))}, (_:Any) =>  throw new Exception("Inserting into ? projection not supported."))

    /** Database column description SqlType(text) */
    val description: Rep[String] = column[String]("description")
    /** Database column credit SqlType(int4) */
    val credit: Rep[Int] = column[Int]("credit")
    /** Database column debit SqlType(int4) */
    val debit: Rep[Int] = column[Int]("debit")
    /** Database column amount_whole SqlType(int4) */
    val amountWhole: Rep[Int] = column[Int]("amount_whole")
    /** Database column amount_change SqlType(int4) */
    val amountChange: Rep[Int] = column[Int]("amount_change")
    /** Database column company_id SqlType(int4) */
    val companyId: Rep[Int] = column[Int]("company_id")
    /** Database column id SqlType(serial), AutoInc, PrimaryKey */
    val id: Rep[Int] = column[Int]("id", O.AutoInc, O.PrimaryKey)

    /** Foreign key referencing accountTable (database name accounting_entry_template_credit_fkey) */
    lazy val accountTableFk1 = foreignKey("accounting_entry_template_credit_fkey", (credit, companyId), accountTable)(r => (r.id, r.companyId), onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.NoAction)
    /** Foreign key referencing accountTable (database name accounting_entry_template_debit_fkey) */
    lazy val accountTableFk2 = foreignKey("accounting_entry_template_debit_fkey", (debit, companyId), accountTable)(r => (r.id, r.companyId), onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.NoAction)
    /** Foreign key referencing companyTable (database name accounting_entry_template_company_fkey) */
    lazy val companyTableFk = foreignKey("accounting_entry_template_company_fkey", companyId, companyTable)(r => r.id, onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.Cascade)
  }
  /** Collection-like TableQuery object for table accountingEntryTemplateTable */
  lazy val accountingEntryTemplateTable = new TableQuery(tag => new AccountingEntryTemplateTable(tag))

  /** GetResult implicit for fetching Account objects using plain SQL queries */
  implicit def GetResultAccount(implicit e0: GR[Int], e1: GR[String]): GR[Account] = GR{
    prs => import prs._
    (Account.apply _).tupled((<<[Int], <<[String], <<[Int], <<[Int], <<[Int]))
  }
  /** Table description of table account. Objects of this class serve as prototypes for rows in queries. */
  class AccountTable(_tableTag: Tag) extends profile.api.Table[Account](_tableTag, "account") {
    def * = (id, title, companyId, category, accountType) <> ((Account.apply _).tupled, Account.unapply)
    /** Maps whole row to an option. Useful for outer joins. */
    def ? = ((Rep.Some(id), Rep.Some(title), Rep.Some(companyId), Rep.Some(category), Rep.Some(accountType))).shaped.<>({r=>import r._; _1.map(_=> (Account.apply _).tupled((_1.get, _2.get, _3.get, _4.get, _5.get)))}, (_:Any) =>  throw new Exception("Inserting into ? projection not supported."))

    /** Database column id SqlType(int4) */
    val id: Rep[Int] = column[Int]("id")
    /** Database column title SqlType(text) */
    val title: Rep[String] = column[String]("title")
    /** Database column company_id SqlType(int4) */
    val companyId: Rep[Int] = column[Int]("company_id")
    /** Database column category SqlType(int4) */
    val category: Rep[Int] = column[Int]("category")
    /** Database column account_type SqlType(int4) */
    val accountType: Rep[Int] = column[Int]("account_type")

    /** Primary key of accountTable (database name account_pkey) */
    val pk = primaryKey("account_pkey", (companyId, id))

    /** Foreign key referencing companyTable (database name account_company_fkey) */
    lazy val companyTableFk = foreignKey("account_company_fkey", companyId, companyTable)(r => r.id, onUpdate=ForeignKeyAction.NoAction, onDelete=ForeignKeyAction.Cascade)
  }
  /** Collection-like TableQuery object for table accountTable */
  lazy val accountTable = new TableQuery(tag => new AccountTable(tag))

  /** GetResult implicit for fetching Company objects using plain SQL queries */
  implicit def GetResultCompany(implicit e0: GR[Int], e1: GR[String]): GR[Company] = GR{
    prs => import prs._
    (Company.apply _).tupled((<<[Int], <<[String], <<[String], <<[String], <<[String], <<[String], <<[String], <<[String]))
  }
  /** Table description of table company. Objects of this class serve as prototypes for rows in queries. */
  class CompanyTable(_tableTag: Tag) extends profile.api.Table[Company](_tableTag, "company") {
    def * = (id, name, address, taxNumber, revenueOffice, postalCode, city, country) <> ((Company.apply _).tupled, Company.unapply)
    /** Maps whole row to an option. Useful for outer joins. */
    def ? = ((Rep.Some(id), Rep.Some(name), Rep.Some(address), Rep.Some(taxNumber), Rep.Some(revenueOffice), Rep.Some(postalCode), Rep.Some(city), Rep.Some(country))).shaped.<>({r=>import r._; _1.map(_=> (Company.apply _).tupled((_1.get, _2.get, _3.get, _4.get, _5.get, _6.get, _7.get, _8.get)))}, (_:Any) =>  throw new Exception("Inserting into ? projection not supported."))

    /** Database column id SqlType(int4), PrimaryKey */
    val id: Rep[Int] = column[Int]("id", O.PrimaryKey)
    /** Database column name SqlType(text) */
    val name: Rep[String] = column[String]("name")
    /** Database column address SqlType(text) */
    val address: Rep[String] = column[String]("address")
    /** Database column tax_number SqlType(text) */
    val taxNumber: Rep[String] = column[String]("tax_number")
    /** Database column revenue_office SqlType(text) */
    val revenueOffice: Rep[String] = column[String]("revenue_office")
    /** Database column postal_code SqlType(text) */
    val postalCode: Rep[String] = column[String]("postal_code")
    /** Database column city SqlType(text) */
    val city: Rep[String] = column[String]("city")
    /** Database column country SqlType(text) */
    val country: Rep[String] = column[String]("country")
  }
  /** Collection-like TableQuery object for table companyTable */
  lazy val companyTable = new TableQuery(tag => new CompanyTable(tag))
}