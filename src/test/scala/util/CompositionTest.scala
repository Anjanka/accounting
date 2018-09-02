package util

import org.scalacheck.{Prop, Properties}

import util.Composition.comp

object CompositionTest extends Properties("Composition properties") {

  property("translations commute") = Prop.forAll { (t: Long, s: Long) =>
    val fist = t + (_: Long)
    val second = s + (_: Long)


    Prop.forAll((n: Long) => comp(fist, second)(n) == comp(second, fist)(n))
  }

}
