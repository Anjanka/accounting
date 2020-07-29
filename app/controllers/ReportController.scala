package controllers

import java.io.ByteArrayInputStream

import abstraction.NominalAccountEntry.{Credit, Debit}
import abstraction.{NominalAccount, NominalAccountEntry}
import akka.stream.scaladsl.StreamConverters
import base.Id.CompanyKey
import base.MonetaryValue
import db.AccountingEntryDAO.CompanyYearKey
import db.{Account, AccountDAO, AccountingEntry, AccountingEntryDAO, CompanyDAO}
import javax.inject.Inject
import play.api.mvc.{Action, AnyContent, BaseController, ControllerComponents}
import report.{JournalCreator, NominalAccountsCreator, ReportCreator}

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
      val allEntries = Await.result(
        accountingEntryDAO.dao.findPartial(CompanyYearKey(companyId, accountingYear))(
          AccountingEntryDAO.compareCompanyYearKey
        ),
        Duration.Inf
      )
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
            .createNominalAccountsPdf(NominalAccountsCreator.mkNominalAccounts(company, accountingYear, allNominalAccountEntries))
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

  def getNominalAccounts(entries: Seq[AccountingEntry], accounts : Seq[Account]): Seq[NominalAccount] = {
    entries
      .flatMap(entry => List(entry.credit -> NominalAccountEntry.mkCreditEntry(entry), entry.debit -> NominalAccountEntry.mkDebitEntry(entry)))
      .groupBy(pair => pair._1)
      .map { case (i, tuples) => NominalAccount(i, accounts.filter(i == _.id).head.title, tuples.map(pair => pair._2)) }
      .toSeq
  }


}
