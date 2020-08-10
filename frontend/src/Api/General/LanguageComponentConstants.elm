module Api.General.LanguageComponentConstants exposing (..)

import Api.General.AccountCategoryConstants exposing (englishAccountCategories, germanAccountCategories)
import Api.General.ReportLanguageComponentConstants exposing (englishReportLanguageComponents, germanReportLanguageComponents)
import Api.General.AccountTypeConstants exposing (englishAccountTypes, germanAccountTypes)
import Api.Types.LanguageComponents exposing (LanguageComponents)


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
    , accountCategories = englishAccountCategories
    , accountTypes = englishAccountTypes
    , reportLanguageComponents = englishReportLanguageComponents
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
    , pleaseSelectCompany = "[Bitte Firma auswählen]"
    , pleaseSelectYear = "[Bitte Buchungsjahr auswählen]"
    , selectTemplate = "[Vorlage auswählen]"
    , pleaseSelectCategory = "[Bitte Kategorie auswählen]"
    , pleaseSelectAccountType = "[Bitte Kontotyp auswählen]"
    , manageAccounts = "Konten bearbeiten"
    , manageTemplates = "Vorlagen bearbeiten"
    , manageCompanies = "Firmen bearbeiten"
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
    , commitNewEntry = "Neuen Eintrag buchen"
    , amount = "Betrag"
    , accountId = "Konto-ID"
    , hideTemplateList = "Vorlagenliste verbergen"
    , hideAccountList = "Kontenliste verbergen"
    , showAccountList = "Kontenliste anzeigen"
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
    , accountCategories = germanAccountCategories
    , accountTypes = germanAccountTypes
    , reportLanguageComponents = germanReportLanguageComponents
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