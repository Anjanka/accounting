package report

import java.io.{ByteArrayOutputStream, StringReader}

import better.files._
import db.{AccountingEntry, Company}
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamSource
import org.apache.fop.apps.{FopFactory, MimeConstants}

import scala.xml.Elem

case class ReportCreator() {
  private val xsltStyleFile = "conf" / "xslt" / "test.xsl"
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
      name="Tabular report"
      accountingYear={accountingYear.toString}>
      {mkCompanyData(company)}
      {accountingEntries.map(mkAccountingEntryData)}
    </report>

  // TODO: Extract amount computation - there is probably a function that can do this already.
  def mkAccountingEntryData(accountingEntry: AccountingEntry): Elem =
    <accountingEntry
      number={accountingEntry.id.toString}
      receiptNumber={accountingEntry.receiptNumber}
      description={accountingEntry.description}
      debit={accountingEntry.debit.toString}
      credit={accountingEntry.credit.toString}
      amount={(accountingEntry.amountWhole + 0.01 * accountingEntry.amountChange).toString}
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

  def main(args: Array[String]): Unit = {
    val reportCreator = ReportCreator()
    reportCreator.createPdf(xml)
  }

}
