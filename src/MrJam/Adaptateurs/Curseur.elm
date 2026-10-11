module MrJam.Adaptateurs.Curseur exposing (natif, note, noteRelative)

{-| Saisie native du curseur, sans aria-live ni présentation.
Input.slider1.1.8 annonce chaque frame sur son parent, sans option publique.
La piste et la poignée sont dessinées en elm-ui ; input reste le contrôle
clavier/tactile invisible comme dans elm-ui. Aucun style/classe libre.
-}

import Element exposing (Element)
import Html
import Html.Attributes as A
import Html.Events as Evenements
import Json.Decode as D


natif : String -> String -> String -> Float -> Float -> Float -> Float -> (Float -> message) -> Element message
natif identifiant libelle lecture minimum maximum pas valeur changer =
    Element.html <|
        Html.input
            [ A.type_ "range"
            , A.id identifiant
            , A.attribute "aria-label" libelle
            , A.attribute "aria-valuetext" lecture
            , A.min (String.fromFloat minimum)
            , A.max (String.fromFloat maximum)
            , A.step (String.fromFloat pas)
            , A.value (String.fromFloat valeur)
            , Evenements.onInput (String.toFloat >> Maybe.withDefault valeur >> changer)
            ]
            []


{-| Proxy natif de notation : seule la valeur de saisie est modifiée par le
pont de pointeurs. Aucun nœud/attribut de présentation n'est créé par JavaScript.
Les trois dimensions fixes rendent le proxy superposable à la piste elm-ui.
-}
note : Float -> String -> (Float -> message) -> (Maybe Float -> message) -> Element message
note valeur lecture changer apercu =
    Element.html <|
        Html.input
            [ A.type_ "range"
            , A.id "grade"
            , A.min "0"
            , A.max "3"
            , A.step "0.25"
            , A.value (String.fromFloat valeur)
            , A.attribute "aria-label" "Note sur 3"
            , A.attribute "aria-describedby" "grade-help"
            , A.attribute "aria-valuetext" lecture
            , A.style "width" "100%"
            , A.style "height" "44px"
            , A.style "opacity" "0"
            , Evenements.onInput (String.toFloat >> Maybe.withDefault valeur >> changer)
            , Evenements.on "change" (D.map changer (D.at [ "target", "value" ] D.string |> D.andThen flottant))
            , Evenements.on "mrjam-note-apercu" (D.map apercu (D.field "detail" (D.nullable D.float)))
            ]
            []


flottant : String -> D.Decoder Float
flottant texte =
    case String.toFloat texte of
        Just nombre ->
            D.succeed nombre

        Nothing ->
            D.fail "Valeur de note non numérique"


noteRelative : Element.Attribute message
noteRelative =
    Element.htmlAttribute (A.attribute "data-mrjam-note-relative" "")
