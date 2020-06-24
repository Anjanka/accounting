module Api.General.DateUtil exposing (..)

import Api.Types.Date exposing (Date)


empty : Date
empty =
    { day = 0
    , month = 0
    , year = 0
    }

updateDay: Date -> Int -> Date
updateDay date day =
        if (1 <= day && day <= 31) then {date | day = day}
        else date

updateMonth : Date -> Int -> Date
updateMonth date month =
    if 1 <= month && month <= 12 then {date | month = month}
    else date

updateYear : Date -> Int -> Date
updateYear date year =
    if 1900 <= year && year <= 2500 then {date | year = year}
    else date

show: Date -> String
show date =
    String.join "." [showDay date.day, showMonth date.month, String.fromInt date.year]

showDay: Int -> String
showDay day =
    if 1 <= day && day <= 9 then "0"++String.fromInt day
    else if 10 <= day && day <= 31 then String.fromInt day
    else "0"

showMonth: Int -> String
showMonth month =
     if 1 <= month && month <= 9 then "0"++String.fromInt month
     else if List.member month [10,11,12] then String.fromInt month
     else "0"


