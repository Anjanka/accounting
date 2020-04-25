package base

import java.sql.Date
import java.time.LocalDate

import cats.instances.either._
import cats.syntax.apply._
import io.circe.Decoder.Result
import io.circe.syntax._
import io.circe.{Decoder, Encoder, HCursor, Json}


object JsonCodecs {

  object Implicits {
    private val dateYear: String = "year"
    private val dateMonth: String = "month"
    private val dateDay: String = "day"
    implicit val dateDecoder: Decoder[Date] = new Decoder[Date] {
      override def apply(c: HCursor): Result[Date] = {
        (c.downField(dateYear).as[Int],
          c.downField(dateMonth).as[Int],
          c.downField(dateDay).as[Int]
          ).mapN((y, m, d) => Date.valueOf(LocalDate.of(y, m, d)))
      }
    }
    implicit val dateEncoder: Encoder[Date] = new Encoder[Date] {
      override def apply(a: Date): Json = {
        val localDate = a.toLocalDate
        Json.obj(
          (dateYear, localDate.getYear.asJson),
          (dateMonth, localDate.getMonthValue.asJson),
          (dateDay, localDate.getDayOfMonth.asJson)
        )
      }
    }
  }

}