package report

import java.sql.Date

import base.NominalAccountEntry.{Credit, Debit}
import base.{MonetaryValue, NominalAccount, NominalAccountEntry, ReportLanguageComponents}
import db.Company

import scala.xml.Elem


object NominalAccountsCreator {

  def mkNominalAccounts(languageComponents: ReportLanguageComponents, company: Company, accountingYear: Int, nominalAccounts: Seq[NominalAccount]): Elem =
    <nominalAccounts
    pageName={languageComponents.nominalAccounts}
    accountingYear={accountingYear.toString}>
      {mkCompanyData(company)}
      {nominalAccounts.map(na => mkNominalAccountData(languageComponents, na))}
    </nominalAccounts>



  def mkNominalAccountData(languageComponents: ReportLanguageComponents, nominalAccount : NominalAccount) : Elem =
    <nominalAccount
    accountId={nominalAccount.accountId.toString}
    accountName={nominalAccount.accountName}
    balance={MonetaryValue.show(nominalAccount.balance)}
    openingBalance={MonetaryValue.show(nominalAccount.openingBalance)}
    revenue={MonetaryValue.show(nominalAccount.revenue)}
    creditBalance={MonetaryValue.show(nominalAccount.creditBalance)}
    debitBalance={MonetaryValue.show(nominalAccount.debitBalance)}
    account_l={languageComponents.account}
    debit_l={languageComponents.debit}
    credit_l={languageComponents.credit}
    date_l={languageComponents.bookingDate}
    description_l={languageComponents.description}
    receiptNumber_l={languageComponents.receiptNumber}
    offsetAccount_l={languageComponents.offsetAccount}
    openingBalance_l={languageComponents.openingBalance}
    balance_l={languageComponents.balance}
    bookedUntil_l={languageComponents.bookedUntil}
    sum_l={languageComponents.sum}>
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