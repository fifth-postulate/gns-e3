module Control exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation exposing (Key)
import Control.Gauge as Gauge exposing (Gauge)
import Html exposing (Html)
import Time exposing (every)
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
    , force : Float
    }


type Msg
    = None
    | Push


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    let
        gauge =
            Gauge.create 30 70
    in
    ( { gauge = gauge
      , force = 2
      }
    , Cmd.none
    )


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
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )

        Push ->
            ( { model
                | gauge = Gauge.update (awayBy model.force) model.gauge
              }
            , Cmd.none
            )


awayBy : Float -> Float -> Float
awayBy force current =
    if current >= 0 then
        current + force

    else
        current - force


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ every 250 (always Push)
        ]


onUrlRequest : UrlRequest -> Msg
onUrlRequest _ =
    None


onUrlChange : Url -> Msg
onUrlChange _ =
    None
