module MrJam.Adaptateurs.Constructions exposing (Repere(..), encocheEntete, encochePied, incorrect, neutre, objet, repere, selectionne)

{-| Trois contours non rectangulaires et leurs ombres, absents de l'API elm-ui.
Géométrie et ombres littérales originales ; aucun style ou classe configurable.
Les tailles, couleurs, espaces, bordures et contrôles appartiennent à Blocs/elm-ui.
Les marqueurs nomment les pièces pour les ponts de gestes et les contrôles DOM.
-}

import Element exposing (Attribute, htmlAttribute)
import Html.Attributes as Attributs


type Repere
    = Entete
    | Pied
    | Traverse
    | Epine
    | Cavite
    | Emplacement
    | Objet
    | Logement
    | Palette
    | Atelier
    | Bloc


repere : Repere -> Attribute message
repere partie =
    htmlAttribute
        (Attributs.attribute "data-mrjam-construction"
            (case partie of
                Entete ->
                    "entete"

                Pied ->
                    "pied"

                Traverse ->
                    "traverse"

                Epine ->
                    "epine"

                Cavite ->
                    "cavite"

                Emplacement ->
                    "emplacement"

                Objet ->
                    "objet"

                Logement ->
                    "logement"

                Palette ->
                    "palette"

                Atelier ->
                    "atelier"

                Bloc ->
                    "bloc"
            )
        )


encocheEntete : List (Attribute message)
encocheEntete =
    [ htmlAttribute (Attributs.style "clip-path" "polygon(0 0,15px 0,21px 5px,38px 5px,44px 0,100% 0,100% 100%,0 100%)") ]


encochePied : List (Attribute message)
encochePied =
    [ htmlAttribute (Attributs.style "clip-path" "polygon(0 0,100% 0,100% calc(100% - 5px),44px calc(100% - 5px),38px 100%,21px 100%,15px calc(100% - 5px),0 calc(100% - 5px))") ]


objet : List (Attribute message)
objet =
    [ htmlAttribute (Attributs.style "clip-path" "polygon(10px 0,calc(100% - 10px) 0,100% 50%,calc(100% - 10px) 100%,10px 100%,0 50%)")
    , htmlAttribute (Attributs.style "filter" "drop-shadow(0 1px 0 oklch(0.55163012 0.13717295 144.68276832))")
    ]


neutre : Attribute message
neutre =
    htmlAttribute (Attributs.style "filter" "drop-shadow(0 1px 0 oklch(0.69802785 0.14003027 82.64614801))")


selectionne : Attribute message
selectionne =
    htmlAttribute (Attributs.style "filter" "drop-shadow(0 0 2px oklch(0.52094715 0.13971434 251.30770236)) drop-shadow(0 0 2px oklch(0.52094715 0.13971434 251.30770236))")


incorrect : Attribute message
incorrect =
    htmlAttribute (Attributs.style "filter" "drop-shadow(0 0 2px oklch(0.50049969 0.17361526 28.26574628))")
