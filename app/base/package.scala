package object base {

  type Balance = MonetaryValue

  implicit val numMonetaryValue: Numeric[MonetaryValue] = new Numeric[MonetaryValue] {
    override def plus(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents + y.toAllCents)

    override def minus(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents - y.toAllCents)

    override def times(x: MonetaryValue, y: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(x.toAllCents * y.toAllCents)

    override def negate(x: MonetaryValue): MonetaryValue = MonetaryValue.fromAllCents(- x.toAllCents)

    override def fromInt(x: Int): MonetaryValue = MonetaryValue.fromAllCents(100 * x)

    override def toInt(x: MonetaryValue): Int = x.whole.intValue()

    override def toLong(x: MonetaryValue): Long = toInt(x)

    override def toFloat(x: MonetaryValue): Float = x.whole.toFloat + x.change.toCents.toFloat / 100

    override def toDouble(x: MonetaryValue): Double = x.whole.toDouble + x.change.toCents.toDouble / 100

    override def compare(x: MonetaryValue, y: MonetaryValue): Int = (x - y).toAllCents.signum
  }

}
