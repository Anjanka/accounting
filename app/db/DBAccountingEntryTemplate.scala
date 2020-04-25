package db

case class DBAccountingEntryTemplate(description: String,
                                     credit: Int,
                                     debit: Int,
                                     amountWhole: Int,
                                     amountChange: Int
                                    )
