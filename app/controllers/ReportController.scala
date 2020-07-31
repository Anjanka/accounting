package controllers

import java.io.ByteArrayInputStream
import java.sql.Date

import abstraction.{NominalAccount, NominalAccountEntry}
import akka.stream.scaladsl.StreamConverters
import base.Id.CompanyKey
import db.AccountingEntryDAO.CompanyYearKey
import db._
import javax.inject.Inject
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import report.{JournalCreator, NominalAccountsCreator, ReportCreator}
import Ordering.Implicits._

import scala.concurrent.duration.Duration
import scala.concurrent.{Await, ExecutionContext}

class ReportController @Inject() (
    accountingEntryDAO: AccountingEntryDAO,
    companyDAO: CompanyDAO,
    accountDAO: AccountDAO,
    val controllerComponents: ControllerComponents
)(implicit
    ec: ExecutionContext
) extends BaseController {

  def journal(companyId: Int, accountingYear: Int): Action[AnyContent] =
    Action {
      val reportCreator = ReportCreator()
      // TODO: Use proper values here
      val allEntries = (Await.result(
        accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
          AccountingEntryDAO.compareCompanyYearKey
        ),
        Duration.Inf
      )).sortBy(_.id)
      val company = Await.result(companyDAO.dao.find(CompanyKey(companyId)), Duration.Inf).get
      val dataContent = StreamConverters.fromInputStream(() =>
        new ByteArrayInputStream(
          reportCreator.createJournalPdf(JournalCreator.mkJournal(company, accountingYear, allEntries)).toByteArray
        )
      )
      Ok.streamed(
        dataContent,
        contentLength = None,
        inline = false,
        fileName = Some(s"journal $accountingYear.pdf")
      ).withHeaders(("Content-Type", "pdf"))

    }

  def nominalAccounts(companyId: Int, accountingYear: Int): Action[AnyContent] =
    Action {
      val reportCreator = ReportCreator()
      // TODO: Use proper values here
      val allEntries = Await.result(
        accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
          AccountingEntryDAO.compareCompanyYearKey
        ),
        Duration.Inf
      )
      val allAccounts = Await.result(accountDAO.dao.findPartial(companyId)(AccountDAO.compareByCompany), Duration.Inf)
      val allNominalAccountEntries = getNominalAccounts(allEntries, allAccounts)
      val company = Await.result(companyDAO.dao.find(CompanyKey(companyId)), Duration.Inf).get
      val dataContent = StreamConverters.fromInputStream(() =>
        new ByteArrayInputStream(
          reportCreator
            .createNominalAccountsPdf(
              NominalAccountsCreator.mkNominalAccounts(company, accountingYear, allNominalAccountEntries)
            )
            .toByteArray
        )
      )
      Ok.streamed(
        dataContent,
        contentLength = None,
        inline = false,
        fileName = Some(s"nominalAccounts $accountingYear.pdf")
      ).withHeaders(("Content-Type", "pdf"))

    }



// case class DateReceiptNumberPair(date: Date, receiptNumber: String)

// implicit val date_receiptNumberOrdering: Ordering[DateReceiptNumberPair] = (x: DateReceiptNumberPair, y: DateReceiptNumberPair) => {
//   if (x.date < y.date) -1
//   else if (x.date > y.date) 1
//   else if (x.receiptNumber < y.receiptNumber) -1
//   else if (x.receiptNumber > y.receiptNumber) 1
//   else 0
// }

// implicit val dateOrdering: Ordering[Date] = (x: Date, y: Date) => {
//   val localX = x.toLocalDate
//   val localY = y.toLocalDate
//   if (localX.getYear < localY.getYear) -1
//   else if (localX.getYear > localY.getYear) 1
//   else if (localX.getMonthValue < localY.getMonthValue) -1
//   else if (localX.getMonthValue > localY.getMonthValue) 1
//   else if (localX.getDayOfMonth < localY.getDayOfMonth) -1
//   else if (localX.getDayOfMonth > localY.getDayOfMonth) 1
//   else 0
// }

  def getNominalAccounts(entries: Seq[AccountingEntry], accounts: Seq[Account]): Seq[NominalAccount] = {
    entries
      .flatMap(entry =>
        List(
          entry.credit -> NominalAccountEntry.mkCreditEntry(entry),
          entry.debit -> NominalAccountEntry.mkDebitEntry(entry)
        )
      )
      .groupBy(pair => pair._1)
      .map {
        case (i, tuples) =>
          NominalAccount(
            i,
            accounts.filter(i == _.id).head.title,
            tuples
              .map(pair => pair._2)
              .sortBy(_.id)
          )
      }
      .toSeq
      .sortBy(_.accountId)
  }

}
