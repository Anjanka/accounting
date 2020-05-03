package base

import cats.{Monad, StackSafeMonad}

object CatsInstances {

  object seq {
    implicit val seqMonad: Monad[Seq] = new Monad[Seq] with StackSafeMonad[Seq] {
      override def flatMap[A, B](fa: Seq[A])(f: A => Seq[B]): Seq[B] = fa.flatMap(f)
      override def pure[A](x: A): Seq[A] = Seq(x)
    }
  }

}
