package base

trait Account {
  /**
    * @return The unique number associated with this account.
    */
  def id: Int

  /**
    * @return The unique name associated with this account.
    */
  def title: String

  /**
    * Compute the balance of the account after collection of accounting entries.
    *
    * @param entries Collection of '''ALL''' current accounting entries.
    * @return The current (w.r.t. the given entries) balance of this account.
    */
  def balance(entries: List[AEntry]): Balance = Account.balance(this, entries)
}

object Account {


  private def balance(account: Account, entries: List[AEntry]): Balance = {
    /* takes an Account returns a collection of Accounting entries where the
    credit or debit matches the given Account
     */
    def byAccount(cd: AEntry => Account): List[AEntry] =
      entries.filter(entry => cd(entry).id == account.id)
    val credit: List[AEntry] = byAccount(_.credit)
    val debit: List[AEntry] = byAccount(_.debit)

    // takes a collection of Accounting Entries and returns the sum of the amounts
    def makeSum (es: List[AEntry]): MonetaryValue = es.map(_.amount).sum
    val creditSum = makeSum(credit)
    val debitSum = makeSum(debit)

    creditSum - debitSum
  }

}
