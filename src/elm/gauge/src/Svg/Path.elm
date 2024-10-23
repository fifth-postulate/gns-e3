module Svg.Path exposing (PathElement(..), toString)


type PathElement
    = MoveTo Float Float
    | LineTo Float Float
    | Arc Float Float Float Bool Bool Float Float
    | Close


toString : List PathElement -> String
toString path =
    let
        toS : PathElement -> String
        toS element =
            case element of
                MoveTo x y ->
                    "M " ++ String.fromFloat x ++ " " ++ String.fromFloat y

                LineTo x y ->
                    "L " ++ String.fromFloat x ++ " " ++ String.fromFloat y

                Arc xRadius yRadius angle arcFlag sweepFlag x y ->
                    let
                        toF guard =
                            if guard then
                                1.0

                            else
                                0.0

                        data =
                            [ xRadius
                            , yRadius
                            , angle
                            , toF arcFlag
                            , toF sweepFlag
                            , x
                            , y
                            ]
                                |> List.map String.fromFloat
                                |> String.join " "
                    in
                    "A " ++ data

                Close ->
                    "Z"
    in
    path
        |> List.map toS
        |> String.join " "
