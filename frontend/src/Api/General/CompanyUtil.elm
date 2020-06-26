module Api.General.CompanyUtil exposing (..)



import Api.Types.Company exposing (Company)


empty : Company
empty =
    { id = 0
     , name = ""
     , address = ""
     , taxNumber = ""
     , revenueOffice = ""
    }

updateId: Company -> Int -> Company
updateId company id = { company | id = id }

updateName : Company -> String -> Company
updateName company name = { company | name = name }

updateAddress : Company -> String -> Company
updateAddress company address = { company | address = address }

updateTaxNumber : Company -> String -> Company
updateTaxNumber company taxNumber = { company | taxNumber = taxNumber }

updateRevenueOffice : Company -> String -> Company
updateRevenueOffice company revenueOffice = { company | revenueOffice = revenueOffice }

show : Company -> String
show company =
    String.concat [String.fromInt company.id, " - ", company.name, "\n", "Address: ", company.address, "\n", "Tax Number: ", company.taxNumber, "\n", "Revenue Office: ", company.revenueOffice]

isValid : Company -> Bool
isValid company =
    if company.id /= 0
       && not (String.isEmpty company.name)
       && not (String.isEmpty company.address)
       && not (String.isEmpty company.taxNumber)
       && not (String.isEmpty company.revenueOffice)
       then True
    else False
