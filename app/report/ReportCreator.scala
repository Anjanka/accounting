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
  private val journalStyleFile = "conf" / "xslt" / "journal.xsl"
  private val nominalAccountsStyleFile = "conf" / "xslt" / "nominalAccounts.xsl"
  private val fopFactory = FopFactory.newInstance()
  private val foUserAgent = fopFactory.newFOUserAgent()

  def createJournalPdf(xml: Elem): ByteArrayOutputStream = {
    createPdfWith(journalStyleFile)(xml)
  }

  def createNominalAccountsPdf(xml: Elem): ByteArrayOutputStream = {
    createPdfWith(nominalAccountsStyleFile)(xml)
  }

  private def createPdfWith(xsltFile: File)(xml: Elem): ByteArrayOutputStream = {
    val outputStream = new ByteArrayOutputStream()
    val fop = fopFactory.newFop(MimeConstants.MIME_PDF, foUserAgent, outputStream)

    val factory = TransformerFactory.newInstance()
    val transformer = factory.newTransformer(new StreamSource(xsltFile.toJava))

    val src = new StreamSource(new StringReader(xml.toString()))
    val res = new SAXResult(fop.getDefaultHandler)

    transformer.transform(src, res)
    outputStream.close()
    outputStream
  }

}



