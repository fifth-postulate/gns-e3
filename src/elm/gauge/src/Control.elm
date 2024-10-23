module Control exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation exposing (Key)
import Control.Gauge as Gauge exposing (Gauge)
import Html exposing (Html)
import Html.Events as Event
import Html.Events.Extra.Touch as Touch
import Time exposing (every)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)
import Url.Parser.Query as Query


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
    , strength : Float
    }


type Msg
    = None
    | Push
    | Pull


init : flags -> Url -> Key -> ( Model, Cmd Msg )
init _ uri _ =
    let
        stats =
            uri
                |> Parser.parse statsParser
                |> Maybe.withDefault defaultStats

        gauge =
            Gauge.create (2 * stats.ht) (3 * stats.iq)
    in
    ( { gauge = gauge
      , force = 2
      , strength = toFloat stats.st
      }
    , Cmd.none
    )


statsParser : Parser (Stats -> a) a
statsParser =
    let
        stat : String -> Query.Parser Int
        stat attribute =
            attribute
                |> Query.int
                |> Query.map (Maybe.withDefault 10)
    in
    Query.map4 Stats (stat "ST") (stat "DX") (stat "IQ") (stat "HT")
        |> Parser.query


defaultStats : Stats
defaultStats =
    { st = 10
    , dx = 10
    , iq = 10
    , ht = 10
    }


type alias Stats =
    { st : Int
    , dx : Int
    , iq : Int
    , ht : Int
    }


view : Model -> Document Msg
view model =
    { title = "Gauge Control"
    , body =
        [ Html.div
            [ Event.onMouseDown Pull, Touch.onStart (always Pull) ]
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

        Pull ->
            ( { model
                | gauge = Gauge.update (awayBy -model.strength) model.gauge
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
