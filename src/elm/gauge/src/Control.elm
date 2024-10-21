module Control exposing (main)

import Control.Gauge as Gauge exposing (Gauge)
import Html exposing (Html)


main : Html msg
main =
    let
        gauge =
            Gauge.create 30 70
    in
    Html.div []
        [ Gauge.view gauge
        ]
