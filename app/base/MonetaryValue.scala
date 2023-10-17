package base

import io.circe.generic.JsonCodec

import scala.util.Try

@JsonCodec
case class MonetaryValue(whole: BigInt, change: Change) {
  lazy val toAllCents: BigInt = {
    100 * whole + whole.signum * change.toCents
  }

}

object MonetaryValue {

  def fromAllCents(cents: BigInt): MonetaryValue = {
    val whole = cents / 100
    val rem = (cents % 100).intValue
    val tens = rem / 10
    val ones = rem % 10
    //todo guarantee proper usage?
    val change = Change(Digit(tens.abs), Digit(ones.abs))
    MonetaryValue(whole, change)
  }

  def show(amount: MonetaryValue): String = {
    s"${amount.whole},${amount.change.tens.id}${amount.change.ones.id}"
  }

  implicit val numMonetaryValue: Numeric[MonetaryValue] = new Numeric[MonetaryValue] {
    override def plus(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents + y.toAllCents)

    override def minus(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents - y.toAllCents)

    override def times(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents * y.toAllCents)

    override def negate(x: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(-x.toAllCents)

    override def fromInt(x: Int): MonetaryValue = MonetaryValue.fromAllCents(100 * x)

    override def toInt(x: MonetaryValue): Int = x.whole.intValue

    override def toLong(x: MonetaryValue): Long = toInt(x)

    override def toFloat(x: MonetaryValue): Float = x.whole.toFloat + x.change.toCents.toFloat / 100

    override def toDouble(x: MonetaryValue): Double = x.whole.toDouble + x.change.toCents.toDouble / 100

    override def compare(x: MonetaryValue, y: MonetaryValue): Int = (x - y).toAllCents.signum

    override def parseString(str: String): Option[MonetaryValue] = {
      val parts = str.split(",").toList
      // Todo: Somewhat haphazard, feel free to improve. Technically, 'Numeric' should be unnecessary,
      // better use AdditiveMonoid instead.
      parts match {
        case _ :: changeText :: Nil =>
          for {
            _ <- Try(Integer.parseInt(changeText)).toOption.filter(i => i >= 0 && i <= 99)
            allCents <- Try(BigInt(parts.mkString)).toOption
          } yield fromAllCents(allCents)
        case _ => None
      }
    }
  }

}

@JsonCodec
case class Change(tens: Digit, ones: Digit) {
  def toCents: BigInt = 10 * tens.id + ones.id
}

@JsonCodec
sealed trait Digit {
  def id: Int
}

object Digit {

  def apply(int: Int): Digit =
    int match {
      case n if n <= 0 => _0
      case 1           => _1
      case 2           => _2
      case 3           => _3
      case 4           => _4
      case 5           => _5
      case 6           => _6
      case 7           => _7
      case 8           => _8
      case _           => _9
    }

}

case object _0 extends Digit {
  override val id: Int = 0
}

case object _1 extends Digit {
  override val id: Int = 1
}

case object _2 extends Digit {
  override val id: Int = 2
}

case object _3 extends Digit {
  override val id: Int = 3
}

case object _4 extends Digit {
  override val id: Int = 4
}

case object _5 extends Digit {
  override val id: Int = 5
}

case object _6 extends Digit {
  override val id: Int = 6
}

case object _7 extends Digit {
  override val id: Int = 7
}

case object _8 extends Digit {
  override val id: Int = 8
}

case object _9 extends Digit {
  override val id: Int = 9
}
