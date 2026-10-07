module Shared.Ui exposing (accent, badge, button, card, checkbox, divider, format, heading, ink, label, muted, paragraph, primary, slider, small, surface, white)

{-| Adaptation de l'atelier aux composants communs de Style MrJam.
Seul le curseur animé possède un rendu technique pour éviter aria-live à chaque frame.
-}

import Char
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes as H
import Html.Events as Events
import MrJam
import MrJam.Disposition as Disposition
import MrJam.Theme as Theme


ink : Color
ink =
    Theme.couleurs.encre


accent : Color
accent =
    Theme.couleurs.accent


muted : Color
muted =
    Theme.couleurs.discret


white : Color
white =
    Theme.couleurs.surface


surface : Color
surface =
    Theme.couleurs.papier


label : String -> Element msg
label text_ =
    el [ Font.size 11, Font.bold, Font.letterSpacing 1.4, Font.color muted ] (text (String.toUpper text_))


small : String -> Element msg
small text_ =
    Element.paragraph [ Font.size 12, Font.color muted, spacing 4 ] [ text text_ ]


paragraph : String -> Element msg
paragraph text_ =
    Element.paragraph [ Font.size 14, Font.color muted, spacing 5 ] [ text text_ ]


heading : Int -> String -> Element msg
heading level text_ =
    Element.paragraph
        [ Region.heading level
        , Font.size
            (if level == 1 then
                40

             else
                20
            )
        , Font.semiBold
        , Font.color ink
        , Font.letterSpacing -0.7
        ]
        [ text text_ ]


card : List (Attribute msg) -> List (Element msg) -> Element msg
card =
    Disposition.panneau


button : Bool -> msg -> String -> Element msg
button selected message caption =
    Disposition.boutonSelection selected caption message


primary : msg -> String -> Element msg
primary message caption =
    MrJam.bouton caption message


checkbox : String -> Bool -> (Bool -> msg) -> Element msg
checkbox =
    MrJam.caseACocher


slider : String -> String -> Float -> Float -> Float -> Float -> (Float -> msg) -> Element msg
slider caption unit minimum maximum step value onChange =
    column [ width fill, spacing 11 ]
        [ row [ width fill, Font.size 12 ]
            [ html (Html.label [ H.for (controlId caption) ] [ Html.text caption ])
            , el [ alignRight, Font.color accent, Font.bold, Font.family [ Font.monospace ], htmlAttribute (H.attribute "aria-hidden" "true") ] (text (format 2 value ++ unit))
            ]

        -- Elm UI 1.1.8 ajoute aria-live à Input.slider. Ce contrôle natif partagé
        -- conserve le clavier et le toucher sans annoncer chaque frame.
        , el [ width fill, height (px 24) ]
            (html
                (Html.input
                    [ H.type_ "range"
                    , H.class "echo-slider"
                    , H.id (controlId caption)
                    , H.attribute "aria-label" caption
                    , H.attribute "aria-valuetext" (format 2 value ++ unit)
                    , H.min (String.fromFloat minimum)
                    , H.max (String.fromFloat maximum)
                    , H.step (String.fromFloat step)
                    , H.value (String.fromFloat value)
                    , Events.onInput (String.toFloat >> Maybe.withDefault value >> onChange)
                    ]
                    []
                )
            )
        ]


controlId : String -> String
controlId caption =
    "slider-" ++ String.filter Char.isAlphaNum (String.toLower caption)


divider : Element msg
divider =
    MrJam.separateur


badge : String -> Element msg
badge =
    Disposition.etiquette


format : Int -> Float -> String
format digits value =
    let
        factor =
            toFloat (10 ^ digits)
    in
    String.fromFloat (toFloat (round (value * factor)) / factor) |> String.replace "." ","
