package report

import java.io.StringReader

import better.files._
import com.sun.xml.internal.messaging.saaj.util.ByteOutputStream
import javax.xml.transform.TransformerFactory
import javax.xml.transform.sax.SAXResult
import javax.xml.transform.stream.StreamSource
import org.apache.fop.apps.{FopFactory, MimeConstants}

import scala.xml.Elem

case class ReportCreator() {
  private val xsltStyleFile = "conf" / "xslt" / "test.xsl"
  private val fopFactory = FopFactory.newInstance()
  private val foUserAgent = fopFactory.newFOUserAgent()

  def createPdf(xml: Elem): ByteOutputStream = {
    val outputStream = new ByteOutputStream()
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

  val xml: Elem =
    <example
      name="name"
      description="description">
    </example>

  def main(args: Array[String]): Unit = {
    val reportCreator = ReportCreator()
    reportCreator.createPdf(xml)
  }

}
