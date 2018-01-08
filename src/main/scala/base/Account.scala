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

  private def balance(account: Account, entries: List[AEntry]): Balance = ???

}
