package base

case class MonetaryValue(whole: BigInt, change: Change) {
  def toAllCents: BigInt = 100 * whole + change.toCents

}

object MonetaryValue {
  def fromAllCents(cents: BigInt): MonetaryValue = {
    val whole = cents / 100
    val rem = (cents % 100).intValue()
    val tens = rem / 10
    val ones = rem % 10
    //todo guarantee proper usage?
    val change = Change(Digit(tens), Digit(ones))
    MonetaryValue(whole, change)
  }
}

case class Change(tens: Digit, ones: Digit) {
  def toCents: BigInt = 10 * tens.id + ones.id
}

sealed trait Digit {
  def id: Int
}

object Digit {
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
}