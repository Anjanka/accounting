package base

import base.Digit.Digit
import spire.math.Natural


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

object Digit extends Enumeration {
  val _0, _1, _2, _3, _4, _5, _6, _7, _8, _9 = Value
  type Digit = Value
}