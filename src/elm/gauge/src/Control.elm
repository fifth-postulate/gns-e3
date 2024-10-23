module Control exposing (main)

import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation exposing (Key)
import Control.Gauge as Gauge exposing (Gauge)
import Html exposing (Html)
import Html.Events as Event
import Html.Events.Extra.Touch as Touch
import Task
import Time exposing (Posix, every, now, posixToMillis)
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


type Model
    = Playing Data
    | Finished Int


type alias Data =
    { gauge : Gauge
    , force : Float
    , strength : Float
    , grace : Int
    , heat : Int
    , start : Maybe Posix
    }


type Msg
    = None
    | Tick Posix
    | Tock Posix
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
    ( Playing
        { gauge = gauge
        , force = 2
        , strength = toFloat stats.st
        , heat = 0
        , grace = stats.dx
        , start = Nothing
        }
    , Task.perform Tick now
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


type alias Stats =
    { st : Int
    , dx : Int
    , iq : Int
    , ht : Int
    }


defaultStats : Stats
defaultStats =
    { st = 10
    , dx = 10
    , iq = 10
    , ht = 10
    }


view : Model -> Document Msg
view model =
    let
        html =
            case model of
                Playing m ->
                    Html.div
                        [ Event.onMouseDown Pull, Touch.onStart (always Pull) ]
                        [ Gauge.view m.gauge
                        ]

                Finished t ->
                    Html.h1 [] [ Html.text (String.fromInt t) ]
    in
    { title = "Gauge Control"
    , body =
        [ html
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg mdl =
    case mdl of
        Playing model ->
            let
                command : Data -> Cmd Msg
                command data =
                    if Gauge.isCritical data.gauge then
                        Task.perform Tock now

                    else
                        Cmd.none
            in
            case msg of
                None ->
                    ( mdl, Cmd.none )

                Tick t ->
                    ( Playing { model | start = Just t }, Cmd.none )

                Tock t ->
                    let
                        millis =
                            posixToMillis t

                        duration =
                            model.start
                                |> Maybe.map posixToMillis
                                |> Maybe.map (\s -> millis - s)
                                |> Maybe.withDefault 0
                    in
                    ( Finished duration, Cmd.none )

                Push ->
                    let
                        next =
                            { model
                                | gauge = Gauge.update (awayBy model.force) model.gauge
                            }
                    in
                    ( Playing next, command next )

                Pull ->
                    let
                        ( nextHeat, nextForce ) =
                            if model.heat >= model.grace then
                                ( 0, model.force + 1 )

                            else
                                ( model.heat + 1, model.force )

                        next =
                            { model
                                | gauge = Gauge.update (awayBy -model.strength) model.gauge
                                , heat = nextHeat
                                , force = nextForce
                            }

                        cmd =
                            if Gauge.isCritical next.gauge then
                                Task.perform Tock now

                            else
                                Cmd.none
                    in
                    ( Playing next, command next )

        Finished _ ->
            ( mdl, Cmd.none )


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
