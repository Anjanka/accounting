package util

object Composition {

  def comp[A, B, C](f: A => B, g: B => C): A => C = f.andThen(g)

}
