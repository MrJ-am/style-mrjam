module MrJam.Fenetres exposing (avecModale, modale)

{-| Dialogue natif : le navigateur rend le fond inerte et retient le focus.
Le compagnon fenetres.js ouvre le dialogue et restitue le focus à sa fermeture.
-}

import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import MrJam
import MrJam.Theme as Theme


modale : String -> String -> message -> List (Element message) -> Html message
modale identifiant titre fermer contenu =
    Html.node "dialog"
        [ A.id identifiant
        , A.attribute "data-mrjam-modale" ""
        , A.attribute "aria-label" titre
        , A.style "border" "0"
        , A.style "padding" "0"
        , A.style "border-radius" "6px"
        , A.style "max-width" "min(680px, calc(100vw - 24px))"
        , A.style "width" "680px"
        , A.style "max-height" "calc(100dvh - 24px)"
        , E.preventDefaultOn "cancel" (D.succeed ( fermer, True ))
        , E.custom "keydown"
            (D.field "key" D.string
                |> D.andThen
                    (\touche ->
                        if touche == "Escape" then
                            D.succeed { message = fermer, stopPropagation = True, preventDefault = True }

                        else
                            D.fail "Autre touche"
                    )
            )
        ]
        [ Element.layoutWith { options = [ Element.noStaticStyleSheet, Theme.focus ] }
            [ Element.htmlAttribute (A.style "min-height" "0") ]
            (MrJam.section titre contenu)
        ]


{-| Deux racines ElmUI sœurs : imbriquer deux layout dans une même racine
peut remplacer les règles dynamiques du premier lors de l'ouverture du dialogue.
Le div ne porte aucune présentation de contrôle.
-}
avecModale : Maybe (Html message) -> Html message -> Html message
avecModale dialogue contenu =
    Html.div [ A.style "font-family" "Inter, Aptos, Segoe UI, sans-serif" ]
        [ contenu, Maybe.withDefault (Html.text "") dialogue ]
