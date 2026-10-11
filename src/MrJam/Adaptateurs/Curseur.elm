module MrJam.Adaptateurs.Curseur exposing (natif)

{-| Saisie native du curseur, sans aria-live ni présentation.
Input.slider1.1.8 annonce chaque frame sur son parent, sans option publique.
La piste et la poignée sont dessinées en elm-ui ; input reste le contrôle
clavier/tactile invisible comme dans elm-ui. Aucun style/classe libre.
-}

import Element exposing (Element)
import Html
import Html.Attributes as A
import Html.Events as Evenements


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
