module Api.General.LanguageUtil exposing (..)

import Api.Types.Language exposing (LanguageComponents)


getLanguage : String -> LanguageComponents
getLanguage lang =
    if lang == "en" then
        english
    else if lang == "de" then
        german
--    else if lang == "fr" then
--        french
    else default


default : LanguageComponents
default = english


english : LanguageComponents
english =
    { short = "en"
    , name = "Name"
    , id = "ID"
    , accountName = "Account Name"
    , companyName = "Company Name"
    , description = "Description"
    , saveChanges = "Save Changes"
    , delete = "Delete"
    , back = "Back"
    , cancel = "Cancel"
    , edit = "Edit"
    , account = "Account"
    , debit = "Debit"
    , credit = "Credit"
    , template = "Template"
    , accountingEntry = "Accounting Entry"
    , company = "Company"
    , pleaseSelectCompany = "[Please Select Company]"
    , pleaseSelectYear = "[Please Select Accounting Year]"
    , selectTemplate = "[Select Template]"
    , pleaseSelectCategory ="[Please Select Category]"
    , pleaseSelectAccountType = "[Please Select Account Type]"
    , manageAccounts = "Manage Accounts"
    , manageTemplates = "Manage Templates"
    , manageCompanies = "Manage Companies"
    , create = "Create"
    , accountingYear = "Accounting Year"
    , bookingDate = "Booking Date"
    , receiptNumber = "Receipt No."
    , address = "Address"
    , city = "City"
    , postalCode = "Postal Code"
    , country = "Country"
    , taxNumber = "Tax Number"
    , revenueOffice = "Revenue Office"
    , commitNewEntry = "Commit New Entry"
    , amount = "Amount"
    , accountId = "Account ID"
    , hideTemplateList = "Hide Template List"
    , hideAccountList = "Hide Account List"
    , showAccountList = "Show Account List"
    , number = "No."
    , noValidAccount = "[No valid account selected.]"
    , accountValidationMessageOk = "Account ID is valid."
    , accountValidationMessageErr = "Account ID must be positive number with 3 to 5 digits. Leading 0s will be ignored"
    , accountValidationMessageExisting = "An account with this Id already exists. Use edit to make changes to existing accounts."
    , balance = "Balance"
    , equalAccountsWarning = "Credit and Debit must not be equal."
    , day = "dd"
    , month = "mm"
    , printJournal = "Print Journal"
    , printNominalAccounts = "Print Nominal Accounts"
    , accountCategories = [ {id = 0, name ="financial account"}
                              , {id = 1 , name = "fixed assets"}
                              , {id = 2, name = "resources"}
                              , {id = 3, name = "business expenses"}
                              , {id = 4, name = "borrowed capital"}
                              , {id = 5, name = "tax account"}
                              , {id = 8, name = "revenues"}
                              , {id = 9, name ="balance carried forward"}]
        , accountTypes = [ {id = 11, categoryIds = [1], name = "inferior assets"}
                          , {id = 1, categoryIds = [0], name = "cash account"}
                          , {id = 31, categoryIds = [3], name = "purchased goods"}
                          , {id = 32, categoryIds = [3], name = "telephone costs"}
                          , {id = 33, categoryIds = [3], name = "travel expenses"}
                          , {id = 0, categoryIds = [7,1,2,3,4,5,6,7,8,9,0], name = "other"}
                          , {id = 81, categoryIds = [8], name ="interest income"}
                          , {id = 91, categoryIds = [9], name = "opening balance"}
                          , {id = 82, categoryIds = [8], name = "sales revenue"}
                          , {id = 34, categoryIds = [3], name = "personnel costs"}
                          , {id = 35, categoryIds = [3], name = "postal charges"}
                          , {id = 36, categoryIds = [3], name = "lease expenses"}
                          , {id = 41, categoryIds = [4], name = "loans"}
                          , {id = 42, categoryIds = [4], name = "debts"}
                          , {id = 51, categoryIds = [5], name = "prepaid tax"}
                          , {id = 52, categoryIds = [5], name = "sales taxes"}]
    , reportLanguageComponents = { journal = "Journal"
                                     , nominalAccounts = "Nominal Accounts"
                                     , bookingDate = "Date"
                                     , number = "No."
                                     , receiptNumber = "Receipt. No."
                                     , description = "Posting Text"
                                     , debit = "DEBIT"
                                     , credit = "CREDIT"
                                     , amount = "Amount"
                                     , sum = "Sum"
                                     , revenue = "Revenue"
                                     , openingBalance = "OB value:"
                                     , balance = "Balance:"
                                     , offsetAccount = "Offset Account"
                                     , bookedUntil = "booked until"}
    }


german : LanguageComponents
german =
    { short = "de"
    , name = "Name"
    , id = "ID"
    , accountName = "Kontoname"
    , companyName = "Firmenname"
    , description = "Bezeichnung"
    , saveChanges = "Änderungen speichern"
    , delete = "Löschen"
    , back = "Zurück"
    , cancel = "Abbrechen"
    , edit = "Bearbeiten"
    , account = "Konto"
    , debit = "Soll"
    , credit = "Haben"
    , template = "Vorlage"
    , accountingEntry = "Buchungseintrag"
    , company = "Firma"
    , pleaseSelectCompany = "[Bitte Firma Auswählen]"
    , pleaseSelectYear = "[Bitte Buchungsjahr Auswählen]"
    , selectTemplate = "[Vorlage Auswählen]"
    , pleaseSelectCategory = "[Bitte Kategorie Auswählen]"
    , pleaseSelectAccountType = "[Bitte Kontotyp Auswählen]"
    , manageAccounts = "Konten Bearbeiten"
    , manageTemplates = "Vorlagen Bearbeiten"
    , manageCompanies = "Firmen Bearbeiten"
    , create = "Anlegen"
    , accountingYear = "Buchungsjahr"
    , bookingDate = "Buchungsdatum"
    , receiptNumber = "Belegnr."
    , address = "Adresse"
    , city = "Stadt"
    , postalCode = "PLZ"
    , country = "Land"
    , taxNumber = "Steuernummer"
    , revenueOffice = "Finanzamt"
    , commitNewEntry = "Neuen Eintrag Buchen"
    , amount = "Betrag"
    , accountId = "Konto-ID"
    , hideTemplateList = "Vorlagenliste Verbergen"
    , hideAccountList = "Kontenliste Verbergen"
    , showAccountList = "Kontenliste Anzeigen"
    , number = "Nr."
    , noValidAccount = "[Kein gültiges Konto ausgewählt.]"
    , accountValidationMessageOk = "Konto-ID ist gültig."
    , accountValidationMessageErr = "Die Konto-ID muss eine positive Zahl mit 3 bis 5 Stellen sein. Führende Nullen werden ignoriert."
    , accountValidationMessageExisting = "Ein Konto mit dieser ID existiert bereits. Benutzen Sie 'Bearbeiten' um Änderungen an bestehenden Konten zu machen."
    , balance = "Bilanz"
    , equalAccountsWarning = "Soll und Haben dürfen nicht gleich sein."
    , day = "tt"
    , month = "mm"
    , printJournal = "Journal drucken"
    , printNominalAccounts = "Sachkonten drucken"
    , accountCategories = [ {id = 0, name ="Finanzkonto"}
                          , {id = 1 , name = "Anlagevermögen"}
                          , {id = 2, name = "Eigenkapital"}
                          , {id = 3, name = "Betriebsausgaben"}
                          , {id = 4, name = "Fremdkapital"}
                          , {id = 5, name = "Steuerkonto"}
                          , {id = 8, name = "Einnahmen"}
                          , {id = 9, name ="Saldovortrag"}]
    , accountTypes = [ {id = 11, categoryIds = [1], name = "Geringwertige WG"}
                      , {id = 1, categoryIds = [0], name = "Kassenkonto"}
                      , {id = 31, categoryIds = [3], name = "Wareneinkauf"}
                      , {id = 32, categoryIds = [3], name = "Telefonkosten"}
                      , {id = 33, categoryIds = [3], name = "Reisekosten"}
                      , {id = 0, categoryIds = [7,1,2,3,4,5,6,7,8,9,0], name = "Sonstige"}
                      , {id = 81, categoryIds = [8], name ="Zinserträge"}
                      , {id = 91, categoryIds = [9], name = "Eröffungsbilanz"}
                      , {id = 82, categoryIds = [8], name = "Umsatzerlöse"}
                      , {id = 34, categoryIds = [3], name = "Personalkosten"}
                      , {id = 35, categoryIds = [3], name = "Portokosten"}
                      , {id = 36, categoryIds = [3], name = "Miete"}
                      , {id = 41, categoryIds = [4], name = "Darlehen"}
                      , {id = 42, categoryIds = [4], name = "Verbindlichkeiten"}
                      , {id = 51, categoryIds = [5], name = "Vorsteuer"}
                      , {id = 52, categoryIds = [5], name = "Umsatzsteuer"}]
    , reportLanguageComponents = { journal = "Journal"
                                 , nominalAccounts = "Sachkonten"
                                 , bookingDate = "Beleg- datum"
                                 , number = "Nr."
                                 , receiptNumber = "Beleg- nr."
                                 , description = "Buchungstext"
                                 , debit = "SOLL"
                                 , credit = "HABEN"
                                 , amount = "Betrag"
                                 , sum = "Summe"
                                 , revenue = "Einnahmen"
                                 , openingBalance = "EB-Wert:"
                                 , balance = "Saldo:"
                                 , offsetAccount = "Gegenkonto"
                                 , bookedUntil = "gebucht bis"}
    }


--french : LanguageComponents
--french =
--   { short = "fr"
--   , name = "nom"
--   , id = "ID"
--   , accountName = "nom du compte"
--   , companyName = "raison sociale"
--   , description = "désignation"
--   , saveChanges = "enregistrer les modifications"
--   , delete = "supprimer"
--   , back = "retour"
--   , cancel = "annuler"
--   , edit = "corriger"
--   , account = "compte"
--   , debit = "débit"
--   , credit = "crédit"
--   , template = "modèle"
--   , accountingEntry = "enregistrement comptable"
--   , company = "entreprise"
--   , pleaseSelectCompany = "[Veuillez sélectionner une entreprise]"
--   , pleaseSelectYear = "[Veuillez sélectionner l'année comptable]"
--   , selectTemplate = "[Sélectionnez un modèle]"
--   , pleaseSelectCategory = ""
--   , pleaseSelectAccountType = ""
--   , manageAccounts = "gérer les comptes"
--   , manageTemplates = "gérer les modèles"
--   , manageCompanies = "gérer les entreprises"
--   , create = "créer"
--   , accountingYear = "exercice comptable"
--   , bookingDate = "date comptable"
--   , receiptNumber = "n° de reçu"
--   , address = "adresse"
--   , city = "ville"
--   , postalCode = "code postal"
--   , country = "pays"
--   , taxNumber = "numéro fiscal"
--   , revenueOffice = "fisc"
--   , commitNewEntry = "valider une nouvelle entrée"
--   , amount = "montant"
--   , accountId = "ID de compte"
--   , hideTemplateList = "masquer la liste des modèles"
--   , hideAccountList = "masquer la list des comptes"
--   , showAccountList = "afficher la list des comptes"
--   , number = "N°"
--   , noValidAccount = "[Aucun compte valide n'a été sélectionné.]"
--   , accountValidationMessageOk = "L'ID de compte est valide."
--   , accountValidationMessageErr = "L'ID de compte doit être un nombre positif de 3 à 5 chiffres. Les 0 en tête seront ignorés."
--   , accountValidationMessageExisting = "Un compte avec cet identifiant existe déjà. Utilisez la fonction d'édition pour apporter des modifications aux comptes existants."
--   , balance = "bilan"
--   , equalAccountsWarning = "Le crédit et le débit ne doivent pas être égaux."
--   , day = "jj"
--   , month = "mm"
--   , printJournal = "Imprimer le journal"
--   , printNominalAccounts = "Imprimer les comptes du grand livre"
--   , accountCategories  = []
--   , accountTypes = []
--   }