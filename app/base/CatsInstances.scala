package base

import cats.{Applicative, Eval, Monad, StackSafeMonad, Traverse}
import cats.instances.list._
import cats.syntax.functor._

import scala.language.higherKinds

object CatsInstances {

  object seq {
    implicit val seqMonad: Monad[Seq] = new Monad[Seq] with StackSafeMonad[Seq] {
      override def flatMap[A, B](fa: Seq[A])(f: A => Seq[B]): Seq[B] = fa.flatMap(f)
      override def pure[A](x: A): Seq[A] = Seq(x)
    }

    implicit val seqTraverse: Traverse[Seq] = new Traverse[Seq] {
      override def traverse[G[_], A, B](fa: Seq[A])(f: A => G[B])(implicit evidence$1: Applicative[G]): G[Seq[B]] =
        Traverse[List].traverse(fa.toList)(f).map(_.toSeq)

      override def foldLeft[A, B](fa: Seq[A], b: B)(f: (B, A) => B): B = fa.foldLeft(b)(f)

      override def foldRight[A, B](fa: Seq[A], lb: Eval[B])(f: (A, Eval[B]) => Eval[B]): Eval[B] = fa.foldRight(lb)(f)
    }
  }

}
