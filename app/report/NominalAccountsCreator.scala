package report

import java.sql.Date

import base.MonetaryValue
import db.{AccountingEntry, Company}

import scala.xml.Elem


object NominalAccountsCreator {

  def mkNominalAccounts(company: Company, accountingYear: Int, accountingEntries: Seq[AccountingEntry]): Elem =
    <nominalAccounts
    pageName="Nominal Accounts"
    accountingYear={accountingYear.toString}>
      {mkCompanyData(company)}
      {accountingEntries.map(mkAccountingEntryData)}
    </nominalAccounts>

  def mkAccountingEntryData(accountingEntry: AccountingEntry): Elem =
      <accountingEntry
      number={accountingEntry.id.toString}
      date={showDate(accountingEntry.bookingDate)}
      receiptNumber={accountingEntry.receiptNumber}
      description={accountingEntry.description}
      debit={accountingEntry.debit.toString}
      credit={accountingEntry.credit.toString}
      amount={MonetaryValue.show(MonetaryValue.fromAllCents(100 * accountingEntry.amountWhole + accountingEntry.amountChange))}
      />

  def mkCompanyData(company: Company): Elem =
      <company
      name={company.name}
      address={company.address}
      taxNumber={company.taxNumber}
      revenueOffice={company.revenueOffice}
      postalCode={company.postalCode}
      city={company.city}
      country={company.country}
      />

  def showDate(date: Date): String = {
    val localDate = date.toLocalDate
    def pad(dateComponent: Int): String = if (dateComponent < 10) s"0$dateComponent" else dateComponent.toString
    List(pad(localDate.getDayOfMonth), pad(localDate.getMonthValue), localDate.getYear).mkString(".")

  }


}