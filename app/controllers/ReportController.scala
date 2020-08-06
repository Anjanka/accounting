package controllers

import java.io.ByteArrayInputStream
import java.sql.Date

import akka.stream.scaladsl.StreamConverters
import base.Id.CompanyKey
import base.{LogicalConstants, NominalAccount, NominalAccountEntry, ReportLanguageComponents}
import db.AccountingEntryDAO.CompanyYearKey
import db._
import io.circe.Json
import javax.inject.Inject
import play.api.libs.circe.Circe
import play.api.mvc.{Action, BaseController, ControllerComponents}
import report.{JournalCreator, NominalAccountsCreator, ReportCreator}

import scala.concurrent.{ExecutionContext, Future}

class ReportController @Inject() (
    accountingEntryDAO: AccountingEntryDAO,
    companyDAO: CompanyDAO,
    accountDAO: AccountDAO,
    val controllerComponents: ControllerComponents
)(implicit
    ec: ExecutionContext
) extends BaseController
    with Circe {

  def journal(companyId: Int, accountingYear: Int): Action[Json] =
    Action.async(circe.json) { request =>
      val languageCandidate = request.body.as[ReportLanguageComponents]
      languageCandidate match {
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid report language component: $decodingFailure."))
        case Right(languageComponents) =>
          val reportCreator = ReportCreator()
          for {
            entries <- accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
              AccountingEntryDAO.compareCompanyYearKey
            )
            company <- companyDAO.dao.find(CompanyKey(companyId))
          } yield {
            val allEntries = entries.sortBy(_.id)
            val dataContent = StreamConverters.fromInputStream(() =>
              new ByteArrayInputStream(
                reportCreator
                  .createJournalPdf(
                    JournalCreator.mkJournal(languageComponents, company.get, accountingYear, allEntries)
                  )
                  .toByteArray
              )
            )
            Ok.streamed(
              dataContent,
              contentLength = None,
              inline = false,
              fileName = None
            ).withHeaders(
              CONTENT_TYPE -> "application/pdf",
              CONTENT_DISPOSITION -> "attachment"
            )
          }
      }
    }

  def nominalAccounts(companyId: Int, accountingYear: Int): Action[Json] =
    Action.async(circe.json) { request =>
      val languageCandidate = request.body.as[ReportLanguageComponents]
      languageCandidate match {
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid report language component: $decodingFailure."))
        case Right(languageComponents) =>
          val reportCreator = ReportCreator()
          for {
            entries <- accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
              AccountingEntryDAO.compareCompanyYearKey
            )
            accounts <- accountDAO.dao.findPartial(companyId)(AccountDAO.compareByCompany)
            company <- companyDAO.dao.find(CompanyKey(companyId))
          } yield {
            val allEntries = entries.sortBy(_.id)
            val allNominalAccountEntries = getNominalAccounts(allEntries, accounts)

            val dataContent = StreamConverters.fromInputStream(() =>
              new ByteArrayInputStream(
                reportCreator
                  .createNominalAccountsPdf(
                    NominalAccountsCreator.mkNominalAccounts(languageComponents, company.get, accountingYear, allNominalAccountEntries)
                  )
                  .toByteArray
              )
            )
            Ok.streamed(
              dataContent,
              contentLength = None,
              inline = false,
              fileName = Some(s"nominalAccounts $accountingYear.pdf")
            ).withHeaders(
              CONTENT_TYPE -> "application/pdf",
              CONTENT_DISPOSITION -> "attachment"
            )

          }
      }
    }

// case class DateReceiptNumberPair(date: Date, receiptNumber: String)

// implicit val date_receiptNumberOrdering: Ordering[DateReceiptNumberPair] = (x: DateReceiptNumberPair, y: DateReceiptNumberPair) => {
//   if (x.date < y.date) -1
//   else if (x.date > y.date) 1
//   else if (x.receiptNumber < y.receiptNumber) -1
//   else if (x.receiptNumber > y.receiptNumber) 1
//   else 0
// }

 implicit val dateOrdering: Ordering[Date] = (x: Date, y: Date) => {
   val localX = x.toLocalDate
   val localY = y.toLocalDate
   if (localX.getYear < localY.getYear) -1
   else if (localX.getYear > localY.getYear) 1
   else if (localX.getMonthValue < localY.getMonthValue) -1
   else if (localX.getMonthValue > localY.getMonthValue) 1
   else if (localX.getDayOfMonth < localY.getDayOfMonth) -1
   else if (localX.getDayOfMonth > localY.getDayOfMonth) 1
   else 0
 }

  def getNominalAccounts(entries: Seq[AccountingEntry], accounts: Seq[Account]): Seq[NominalAccount] = {
    val openingBalanceAccounts = accounts.filter(_.accountType == LogicalConstants.openingBalanceAccount).map(_.id)
    val lastDate = entries.maxBy(_.bookingDate).bookingDate

    entries
      .flatMap(entry =>
        List(
          entry.credit -> NominalAccountEntry.mkCreditEntry(entry),
          entry.debit -> NominalAccountEntry.mkDebitEntry(entry, openingBalanceAccounts)
        )
      )
      .groupBy(pair => pair._1)
      .map {
        case (i, tuples) =>
          NominalAccount(
            i,
            accounts.filter(i == _.id).head.title,
            lastBookingDate = lastDate,
            tuples
              .map(pair => pair._2)
              .sortBy(_.id)
          )
      }
      .toSeq
      .sortBy(_.accountId)
  }

}
