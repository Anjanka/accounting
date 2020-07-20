module Api.General.LanguageUtil exposing (..)

import Api.Types.Language exposing (LanguageComponents)


getLanguage : String -> LanguageComponents
getLanguage lang =
    if lang == "en" then
        english
    else if lang == "de" then
        german
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
    , accountingEntryTemplate = "Accounting Entry Template"
    , template = "Template"
    , accountingEntry = "Accounting Entry"
    , company = "Company"
    , pleaseSelectCompany = "[Please Select Company]"
    , pleaseSelectYear = "[Please Select Accounting Year]"
    , selectTemplate = "[Select Template]"
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
    , accountingEntryTemplate = "Vorlage"
    , template = "Vorlage"
    , accountingEntry = "Buchungseintrag"
    , company = "Firma"
    , pleaseSelectCompany = "[Bitte Firma Auswählen]"
    , pleaseSelectYear = "[Bitte Buchungsjahr Auswählen]"
    , selectTemplate = "[Vorlage Auswählen]"
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
    , accountId = "Konto ID"
    , hideTemplateList = "Vorlagenliste Verbergen"
    , hideAccountList = "Kontenliste Verbergen"
    , showAccountList = "Kontenliste Anzeigen"
    , number = "Nr."
    , noValidAccount = "[Kein gültiges Konto ausgewählt.]"
    , accountValidationMessageOk = "Konto ID ist gültig."
    , accountValidationMessageErr = "Die Konto ID muss eine positive Zahl mit 3 bis 5 Stellen sein. Führende Nullen werden ignoriert."
    , accountValidationMessageExisting = "Ein Konto mit dieser ID existiert bereits. Benutzen Sie 'Bearbeiten' um Änderungen an bestehenden Konten zu machen."
    , balance = "Bilanz"
    , equalAccountsWarning = "Soll und Haben dürfen nicht gleich sein."
    , day = "tt"
    , month = "mm"
    }
