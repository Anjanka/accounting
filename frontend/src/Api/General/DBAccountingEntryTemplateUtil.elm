module Api.General.DBAccountingEntryTemplateUtil exposing (..)


import Api.Types.DBAccountingEntryTemplate exposing (DBAccountingEntryTemplate)


empty : DBAccountingEntryTemplate
empty =
    { description = ""
    , credit = 0
    , debit = 0
    , amountWhole = 0
    , amountChange = 0
    }

updateDescription : DBAccountingEntryTemplate -> String -> DBAccountingEntryTemplate
updateDescription aet description = { aet | description = description }

updateCredit : DBAccountingEntryTemplate -> Int -> DBAccountingEntryTemplate
updateCredit aet credit = { aet | credit = credit }

updateDebit : DBAccountingEntryTemplate -> Int -> DBAccountingEntryTemplate
updateDebit aet debit = { aet | debit = debit }

updateAmountWhole : DBAccountingEntryTemplate -> Int -> DBAccountingEntryTemplate
updateAmountWhole aet whole = { aet | amountWhole = whole }

updateAmountChange : DBAccountingEntryTemplate -> Int -> DBAccountingEntryTemplate
updateAmountChange aet change = { aet | amountChange = change }

show: DBAccountingEntryTemplate -> String
show aet =
    String.concat [aet.description, ": ", String.fromInt aet.credit, " - ", String.fromInt aet.debit, ", ", String.fromInt aet.amountWhole, ",", String.fromInt aet.amountChange  ]