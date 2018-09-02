package util

import org.scalacheck.{Prop, Properties}

import util.Composition.comp

object CompositionTest extends Properties("Composition properties") {

  property("translations commute") = Prop.forAll { (t: Long, s: Long) =>
    val first = t + (_: Long)
    val second = s + (_: Long)


    Prop.forAll((n: Long) => comp(first, second)(n) == comp(second, first)(n))
  }

}
