module Api.General.AccountingEntryTemplateUtil exposing (..)


import Api.Types.AccountingEntryTemplate exposing (AccountingEntryTemplate)


empty : AccountingEntryTemplate
empty =
    { description = ""
    , credit = 0
    , debit = 0
    , amountWhole = 0
    , amountChange = 0
    }

updateDescription : AccountingEntryTemplate -> String -> AccountingEntryTemplate
updateDescription aet description = { aet | description = description }

updateCredit : AccountingEntryTemplate -> Int -> AccountingEntryTemplate
updateCredit aet credit = { aet | credit = credit }

updateDebit : AccountingEntryTemplate -> Int -> AccountingEntryTemplate
updateDebit aet debit = { aet | debit = debit }

updateAmountWhole : AccountingEntryTemplate -> Int -> AccountingEntryTemplate
updateAmountWhole aet whole = { aet | amountWhole = whole }

updateAmountChange : AccountingEntryTemplate -> Int -> AccountingEntryTemplate
updateAmountChange aet change = { aet | amountChange = change }

show : AccountingEntryTemplate -> String
show aet =
    String.concat [aet.description, ": ", String.fromInt aet.credit, " - ", String.fromInt aet.debit, ", ", String.fromInt aet.amountWhole, ",", giveDoubleDigitChange aet.amountChange  ]

giveDoubleDigitChange : Int -> String
giveDoubleDigitChange change =
    if change < 10 then
       String.concat ["0", String.fromInt change]
    else String.fromInt change