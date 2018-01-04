package util

import org.scalacheck.{Prop, Properties}

class Composition extends Properties("Composition properties") {

  property("translations commute") = Prop.forAll { (t: Long, s: Long) =>
    val first = t + _
    val second = s + _

    Prop.forAll(n => Composition.comp(first, second)(n) == Composition.comp(second, first)(n))
  }

}
