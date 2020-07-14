package report

import java.io.{BufferedOutputStream, FileOutputStream, InputStream}

import better.files._
import db.AccountingEntryDAO.CompanyYearKey
import javax.xml.transform.{TransformerFactory, stream}
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamSource
import org.apache.fop.apps.{FopFactory, MimeConstants}

import scala.xml.Elem

case class ReportCreator () {
  private val xsltStyleFile = "conf" / "xslt" / "test.xsl"
  private val pdfDirectory = "."
  private val fopFactory = FopFactory.newInstance()
  private val foUserAgent = fopFactory.newFOUserAgent()

  val xml: Elem =
    <example
    name="name"
    description="description">
  </example>

  def createPdf(companyYearKey: CompanyYearKey): Unit = {
    val resultFile = mkReportFilePath(companyYearKey)
    val outputStream = new BufferedOutputStream(resultFile.newOutputStream)
    val fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, outputStream)

    val factory = TransformerFactory.newInstance()
    val transformer = factory.newTransformer(new StreamSource(xsltStyleFile.toJava))

    val testFile = File("testFile")
    // TODO: Is this step necessary?
    val src = new StreamSource(testFile.write(xml.toString()).toJava)
    val res = new SAXResult(fop.getDefaultHandler)

    transformer.transform(src, res)
    outputStream.close()
  }

  private def mkReportFilePath(companyYearKey: CompanyYearKey): File =
    "conf" / "xslt" / s"report${companyYearKey.companyId}-${companyYearKey.accountingYear}.pdf"
}

object TestMe {
  def main(args: Array[String]): Unit = {
    val reportCreator = ReportCreator()
    reportCreator.createPdf(CompanyYearKey(1, 2020))
  }
}