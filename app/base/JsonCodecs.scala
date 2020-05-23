package base

import java.sql.Date
import java.time.LocalDate

import elm.{Date => ElmDate}
import io.circe.{Decoder, Encoder}

object JsonCodecs {

  object Implicits {
    implicit val dateDecoder: Decoder[Date] = Decoder[ElmDate].map(dateToSqlDate)
    implicit val dateEncoder: Encoder[Date] = Encoder[ElmDate].contramap(sqlDateToDate)

    private def sqlDateToDate(date: Date): ElmDate = {
      val localDate = date.toLocalDate
      ElmDate(
        year = localDate.getYear,
        month = localDate.getMonthValue,
        day = localDate.getDayOfMonth
      )
    }

    private def dateToSqlDate(date: ElmDate): Date = {
      Date.valueOf(
        LocalDate.of(
          date.year,
          date.month,
          date.day
        )
      )
    }
  }

}