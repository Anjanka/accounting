port module Ports exposing
    ( doFetchToken
    , fetchToken
    , storeToken
    )


port storeToken : String -> Cmd msg


port doFetchToken : () -> Cmd msg


port fetchToken : (String -> msg) -> Sub msg
