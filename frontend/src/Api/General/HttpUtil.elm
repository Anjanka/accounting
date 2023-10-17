module Api.General.HttpUtil exposing (..)

import Api.Auxiliary exposing (JWT)
import Http exposing (Body, Error(..), Expect, expectStringResponse)
import Json.Decode as D


expectJson : (Result Http.Error a -> msg) -> D.Decoder a -> Expect msg
expectJson toMsg decoder =
    expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ _ body ->
                    Err (BadBody body)

                Http.GoodStatus_ _ body ->
                    case D.decodeString decoder body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Err (BadBody (D.errorToString err))


expectWhatever : (Result Http.Error () -> msg) -> Expect msg
expectWhatever toMsg =
    expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Err (Http.BadUrl url)

                Http.Timeout_ ->
                    Err Http.Timeout

                Http.NetworkError_ ->
                    Err Http.NetworkError

                Http.BadStatus_ _ body ->
                    Err (BadBody body)

                Http.GoodStatus_ _ _ ->
                    Ok ()


errorToString : Error -> String
errorToString error =
    case error of
        BadUrl string ->
            "BadUrl: " ++ string

        Timeout ->
            "Timeout"

        NetworkError ->
            "NetworkError"

        BadStatus int ->
            "BadStatus: " ++ String.fromInt int

        BadBody string ->
            string


type Verb
    = GET
    | POST
    | PUT
    | PATCH
    | DELETE


verbToString : Verb -> String
verbToString verb =
    case verb of
        GET ->
            "GET"

        POST ->
            "POST"

        PUT ->
            "PUT"

        PATCH ->
            "PATCH"

        DELETE ->
            "DELETE"


type alias RequestParameters msg =
    { url : String
    , jwt : JWT
    , body : Http.Body
    , expect : Expect msg
    }


userTokenHeader : String
userTokenHeader =
    "User-Token"


jwtHeader : JWT -> Http.Header
jwtHeader =
    Http.header userTokenHeader


byVerb :
    Verb
    -> RequestParameters msg
    -> Cmd msg
byVerb verb ps =
    Http.request
        { method = verb |> verbToString
        , headers = [ jwtHeader ps.jwt ]
        , url = ps.url
        , body = ps.body
        , expect = ps.expect
        , timeout = Nothing
        , tracker = Nothing
        }


get :
    { url : String
    , jwt : JWT
    , expect : Expect msg
    }
    -> Cmd msg
get ps =
    byVerb GET
        { url = ps.url
        , jwt = ps.jwt
        , body = Http.emptyBody
        , expect = ps.expect
        }


post :
    { url : String
    , body : Http.Body
    , jwt : JWT
    , expect : Expect msg
    }
    -> Cmd msg
post ps =
    byVerb POST
        { url = ps.url
        , jwt = ps.jwt
        , body = ps.body
        , expect = ps.expect
        }
