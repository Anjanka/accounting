package report

import better.files._
import org.apache.fop.apps.FopFactory

import java.io.{ByteArrayOutputStream, StringReader}
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamSource
import scala.xml.Elem

object ReportCreator {
  private val journalStyleFile = "conf" / "xslt" / "journal.xsl"
  private val nominalAccountsStyleFile = "conf" / "xslt" / "nominalAccounts.xsl"

  def createJournalPdf(xml: Elem): ByteArrayOutputStream = {
    createPdfWith(journalStyleFile)(xml)
  }

  def createNominalAccountsPdf(xml: Elem): ByteArrayOutputStream = {
    createPdfWith(nominalAccountsStyleFile)(xml)
  }

  private def createPdfWith(xsltFile: File)(xml: Elem): ByteArrayOutputStream = {
    val outputStream = new ByteArrayOutputStream()
    val fopFactory = FopFactory.newInstance(File(".").toJava.toURI)
    val foUserAgent = fopFactory.newFOUserAgent()
    val fop = fopFactory.newFop(org.apache.xmlgraphics.util.MimeConstants.MIME_PDF, foUserAgent, outputStream)

    val factory = TransformerFactory.newInstance()
    val transformer = factory.newTransformer(new StreamSource(xsltFile.toJava))

    val src = new StreamSource(new StringReader(xml.toString()))
    val res = new SAXResult(fop.getDefaultHandler)

    transformer.transform(src, res)
    outputStream.close()
    outputStream
  }

}
