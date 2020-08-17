package base

import java.sql.Date

object DateUtil {

  object Implicits {

    // case class DateReceiptNumberPair(date: Date, receiptNumber: String)

    // implicit val date_receiptNumberOrdering: Ordering[DateReceiptNumberPair] = (x: DateReceiptNumberPair, y: DateReceiptNumberPair) => {
    //   if (x.date < y.date) -1
    //   else if (x.date > y.date) 1
    //   else if (x.receiptNumber < y.receiptNumber) -1
    //   else if (x.receiptNumber > y.receiptNumber) 1
    //   else 0
    // }

    implicit val dateOrdering: Ordering[Date] = (x: Date, y: Date) => {
      val localX = x.toLocalDate
      val localY = y.toLocalDate
      if (localX.getYear < localY.getYear) -1
      else if (localX.getYear > localY.getYear) 1
      else if (localX.getMonthValue < localY.getMonthValue) -1
      else if (localX.getMonthValue > localY.getMonthValue) 1
      else if (localX.getDayOfMonth < localY.getDayOfMonth) -1
      else if (localX.getDayOfMonth > localY.getDayOfMonth) 1
      else 0
    }

  }

}
