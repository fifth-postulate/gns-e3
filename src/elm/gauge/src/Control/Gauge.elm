module Control.Gauge exposing (Gauge, create, view)

import Svg exposing (Svg)
import Svg.Attributes as Attribute


type Gauge
    = Gauge
        { current : Float
        , safe : Float
        , maximum : Float
        }


create : Int -> Int -> Gauge
create safe maximum =
    Gauge
        { current = 20
        , safe = toFloat safe
        , maximum = toFloat maximum
        }


radius : Float
radius =
    100


view : Gauge -> Svg msg
view gauge =
    case gauge of
        Gauge { current, safe, maximum } ->
            let
                rotate : Float -> String
                rotate a =
                    "rotate(" ++ String.fromFloat a ++ ")"
            in
            Svg.svg
                [ Attribute.width "200"
                , Attribute.height "200"
                , Attribute.viewBox viewBox
                ]
                [ Svg.g []
                    [ Svg.circle
                        [ Attribute.cx "0"
                        , Attribute.cy "0"
                        , Attribute.r (String.fromFloat radius)
                        , Attribute.fill "white"
                        , Attribute.stroke "black"
                        ]
                        []
                    , Svg.g []
                        [ gaugeSegment 0 "red"
                        , gaugeSegment (90 - maximum) "orange"
                        , gaugeSegment (90 - safe) "green"
                        ]
                    , Svg.g [ Attribute.transform (rotate current) ]
                        [ Svg.path
                            [ Attribute.d "M -4,0 L 0,-100 L 4,0 A 2 2 1 1 1 -4 0 Z"
                            , Attribute.stroke "black"
                            , Attribute.fill "black"
                            ]
                            []
                        , Svg.circle
                            [ Attribute.cx "0"
                            , Attribute.cy "0"
                            , Attribute.r "2"
                            , Attribute.fill "white"
                            ]
                            []
                        ]
                    ]
                ]


viewBox : String
viewBox =
    [ -radius, -radius, 2 * radius, 2 * radius ]
        |> List.map String.fromFloat
        |> String.join " "


gaugeSegment : Float -> String -> Svg msg
gaugeSegment deg color =
    let
        r =
            20

        angle =
            degrees -deg

        xOuter =
            radius * cos angle

        yOuter =
            radius * sin angle

        xInner =
            (radius - r) * cos angle

        yInner =
            (radius - r) * sin angle
    in
    Svg.path
        [ Attribute.d
            (toString
                [ MoveTo -xOuter yOuter
                , Arc radius radius 0 False True xOuter yOuter
                , LineTo xInner yInner
                , Arc (radius - r) (radius - r) 0 False False -xInner yInner
                , Close
                ]
            )
        , Attribute.fill color
        ]
        []


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
