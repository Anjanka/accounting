package report

import java.sql.Date

import base.NominalAccountEntry.{Credit, Debit}
import base.{MonetaryValue, NominalAccount, NominalAccountEntry}
import db.Company

import scala.xml.Elem


object NominalAccountsCreator {

  def mkNominalAccounts(company: Company, accountingYear: Int, nominalAccounts: Seq[NominalAccount]): Elem =
    <nominalAccounts
    pageName="Sachkonten"
    accountingYear={accountingYear.toString}>
      {mkCompanyData(company)}
      {nominalAccounts.map(mkNominalAccountData)}
    </nominalAccounts>



  def mkNominalAccountData(nominalAccount : NominalAccount) : Elem =
    <nominalAccount
    accountId={nominalAccount.accountId.toString}
    accountName={nominalAccount.accountName}
    balance={MonetaryValue.show(nominalAccount.balance)}
    openingBalance={MonetaryValue.show(nominalAccount.openingBalance)}
    revenue={MonetaryValue.show(nominalAccount.revenue)}
    creditBalance={MonetaryValue.show(nominalAccount.creditBalance)}
    debitBalance={MonetaryValue.show(nominalAccount.debitBalance)}>
      {nominalAccount.entries.map(mkNominalAccountEntriesData)}
    </nominalAccount>


  def mkNominalAccountEntriesData(nominalAccountEntry: NominalAccountEntry): Elem =
      <nominalAccountEntry
      receiptNumber={nominalAccountEntry.receiptNumber}
      offsetAccount={nominalAccountEntry.offsetAccount.toString}
      date={showDate(nominalAccountEntry.bookingDate)}
      description={nominalAccountEntry.description}
      debitAmount={nominalAccountEntry.amount match {case Debit (value) => MonetaryValue.show(value) case _ => ""}}
      creditAmount={nominalAccountEntry.amount match {case Credit (value) => MonetaryValue.show(value) case _ => ""}}
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