package base

import scala.Numeric.Implicits._

/**
  * @param id    The unique number associated with this account.
  * @param title The unique name associated with this account.
  */
case class Account(id: Int, title: String) {
  /**
    * Computes the balance of the account after collection of accounting entries.
    *
    * @param entries Collection of '''ALL''' current accounting entries.
    * @return The current (w.r.t. the given entries) balance of this account.
    */
  def balance(entries: List[AccountingEntry]): Balance = Account.balance(this, entries)
}

object Account {

  private def balance(account: Account, entries: List[AccountingEntry]): Balance = {
    /* takes an Account returns a collection of Accounting entries where the
    credit or debit matches the given Account
     */
    def byAccount(cd: AccountingEntry => Account): List[AccountingEntry] =
      entries.filter(entry => cd(entry).id == account.id)

    val credit: List[AccountingEntry] = byAccount(_.credit)
    val debit: List[AccountingEntry] = byAccount(_.debit)

    // takes a collection of Accounting Entries and returns the sum of the amounts
    def makeSum(es: List[AccountingEntry]): MonetaryValue = es.map(_.amount).sum

    val creditSum = makeSum(credit)
    val debitSum = makeSum(debit)

    creditSum - debitSum
  }

}
