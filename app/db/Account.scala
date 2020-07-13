package db

import base.Id.AccountKey
import io.circe.generic.JsonCodec

@JsonCodec
case class Account(id: Int, title: String, companyId: Int)

object Account {

  def keyOf(account: Account): AccountKey =
    AccountKey(companyId = account.companyId, id = account.id)

}
