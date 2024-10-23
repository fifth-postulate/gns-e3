module Control exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation exposing (Key)
import Control.Gauge as Gauge exposing (Gauge)
import Html exposing (Html)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


type alias Model =
    { gauge : Gauge
    }


type Msg
    = None


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    let
        gauge =
            Gauge.create 30 70
    in
    ( { gauge = gauge }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Gauge Control"
    , body =
        [ Html.div
            []
            [ Gauge.view model.gauge
            ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


onUrlRequest : UrlRequest -> Msg
onUrlRequest _ =
    None


onUrlChange : Url -> Msg
onUrlChange _ =
    None
