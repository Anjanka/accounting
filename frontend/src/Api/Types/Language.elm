module Api.Types.Language exposing (..)

type Language =
       En
     | De


type alias LanguageComponents = {
    language : Language
  , name : String
  , nameAsPart : String
  , description: String
  , save : String
  , delete : String
  , back : String
  , cancel : String
  , edit : String
  , account : String
  , debit : String
  , credit : String
  , accountingEntryTemplate : String
  , template : String
  , accountingEntry : String
  , company : String
  , select : String
  , please: String
  , manage: String
  , accounts : String
  , templates: String
  , companies : String
  , create :String
  , accountingYear : String
  , bookingDate : String
  , receiptNumber : String
  , address : String
  , city : String
  , postalCode : String
  , country : String
  , taxNumber : String
  , revenueOffice : String
  , commit : String
  , amount : String
  , id : String
  , changes : String
  , hide : String
  , show : String
  , number : String
  , noValidAccount : String
  , list : String
  , accountValidationMessageOk : String
  , accountValidationMessageErr : String
  , accountValidationMessageExisting : String
  , balance : String
  , equalAccountsWarning : String
  , day : String
  , month : String
 }


