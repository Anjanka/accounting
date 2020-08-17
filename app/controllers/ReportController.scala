package controllers

import java.io.ByteArrayInputStream

import akka.stream.scaladsl.StreamConverters
import base.DateUtil.Implicits._
import base.Id.CompanyKey
import base.{ BusinessConstants, NominalAccount, NominalAccountEntry, ReportLanguageComponents }
import db.AccountingEntryDAO.CompanyYearKey
import db._
import io.circe.Json
import javax.inject.Inject
import play.api.libs.circe.Circe
import play.api.mvc.{ Action, BaseController, ControllerComponents }
import report.{ JournalCreator, NominalAccountsCreator, ReportCreator }

import scala.concurrent.{ ExecutionContext, Future }

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
      val languageComponentsCandidate = request.body.as[ReportLanguageComponents]
      languageComponentsCandidate match {
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid report language component: $decodingFailure."))
        case Right(languageComponents) =>
          for {
            entries <- accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
              AccountingEntryDAO.compareCompanyYearKey
            )
            company <- companyDAO.dao.find(CompanyKey(companyId))
          } yield {
            val allEntries = entries.sortBy(_.id)
            val dataContent = StreamConverters.fromInputStream(() =>
              new ByteArrayInputStream(
                ReportCreator
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
      val languageComponentsCandidate = request.body.as[ReportLanguageComponents]
      languageComponentsCandidate match {
        case Left(decodingFailure) =>
          Future(BadRequest(s"Could not parse ${request.body} as valid report language component: $decodingFailure."))
        case Right(languageComponents) =>
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
                ReportCreator
                  .createNominalAccountsPdf(
                    NominalAccountsCreator
                      .mkNominalAccounts(languageComponents, company.get, accountingYear, allNominalAccountEntries)
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

  def getNominalAccounts(entries: Seq[AccountingEntry], accounts: Seq[Account]): Seq[NominalAccount] = {
    val openingBalanceAccountIds = accounts.collect {
      case account if account.accountType == BusinessConstants.openingBalanceAccount => account.id
    }.toSet
    val lastDate = entries.maxBy(_.bookingDate).bookingDate
    val accountMap = accounts.map(account => account.id -> account.title).toMap
    entries
      .flatMap(entry =>
        List(
          entry.credit -> NominalAccountEntry.mkCreditEntry(entry),
          entry.debit -> NominalAccountEntry.mkDebitEntry(entry, openingBalanceAccountIds)
        )
      )
      .groupBy(pair => pair._1)
      .map {
        case (i, tuples) =>
          NominalAccount(
            i,
            accountMap(i),
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
