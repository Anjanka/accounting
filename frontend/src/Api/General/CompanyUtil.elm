module Api.General.CompanyUtil exposing (..)



import Api.Types.Company exposing (Company)
import Api.Types.CompanyCreationParams exposing (CompanyCreationParams)


empty : Company
empty =
    { id = 0
     , name = ""
     , address = ""
     , postalCode = ""
     , city = ""
     , country = ""
     , taxNumber = ""
     , revenueOffice = ""
    }

updateId: Company -> Int -> Company
updateId company id = { company | id = id }

updateName : Company -> String -> Company
updateName company name = { company | name = name }

updateAddress : Company -> String -> Company
updateAddress company address = { company | address = address }

updatePostalCode : Company -> String -> Company
updatePostalCode company postalCode = { company | postalCode = postalCode }

updateCity : Company -> String -> Company
updateCity company city = { company | city = city }

updateCountry : Company -> String -> Company
updateCountry company country = { company | country = country }

updateTaxNumber : Company -> String -> Company
updateTaxNumber company taxNumber = { company | taxNumber = taxNumber }

updateRevenueOffice : Company -> String -> Company
updateRevenueOffice company revenueOffice = { company | revenueOffice = revenueOffice }

show : Company -> String
show company =
    String.concat [String.fromInt company.id, " - ", company.name, "\n", "Address: ", company.address, "\n", company.postalCode, " ", company.city, "\n", company.country, "\n", "Tax Number: ", company.taxNumber, "\n", "Revenue Office: ", company.revenueOffice]

isValid : Company -> Bool
isValid company =
       not (String.isEmpty company.name)
     --  && not (String.isEmpty company.address)
     --  && not (String.isEmpty company.taxNumber)
     --  && not (String.isEmpty company.revenueOffice)



creationParams : Company -> CompanyCreationParams
creationParams company = { name = company.name, address= company.address, postalCode = company.postalCode, city = company.city, country = company.country, taxNumber = company.taxNumber, revenueOffice = company.revenueOffice }
