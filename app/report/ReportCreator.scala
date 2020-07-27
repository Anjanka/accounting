package report

import java.io.{ByteArrayOutputStream, StringReader}
import java.sql.Date

import base.MonetaryValue
import better.files._
import db.{AccountingEntry, Company}
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamSource
import org.apache.fop.apps.{FopFactory, MimeConstants}

import scala.xml.Elem

case class ReportCreator() {
  private val xsltStyleFile = "conf" / "xslt" / "journal.xsl"
  private val fopFactory = FopFactory.newInstance()
  private val foUserAgent = fopFactory.newFOUserAgent()

  def createPdf(xml: Elem): ByteArrayOutputStream = {
    val outputStream = new ByteArrayOutputStream()
    val fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, outputStream)

    val factory = TransformerFactory.newInstance()
    val transformer = factory.newTransformer(new StreamSource(xsltStyleFile.toJava))

    val src = new StreamSource(new StringReader(xml.toString()))
    val res = new SAXResult(fop.getDefaultHandler)

    transformer.transform(src, res)
    outputStream.close()
    outputStream
  }

}

object TestMe {

  val xml: Elem = {
    <report
      name="Anja"
      description="best friend"
      complany="Bisinez">
      {}
    </report>
  }

  def mkReport(company: Company, accountingYear: Int, accountingEntries: Seq[AccountingEntry]): Elem =
    <report
      pageName="Journal"
      accountingYear={accountingYear.toString}>
      {mkCompanyData(company)}
      {accountingEntries.map(mkAccountingEntryData)}
    </report>

  // TODO: Extract amount computation - there is probably a function that can do this already.
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

  def main(args: Array[String]): Unit = {
    val reportCreator = ReportCreator()
    reportCreator.createPdf(xml)
  }

}
