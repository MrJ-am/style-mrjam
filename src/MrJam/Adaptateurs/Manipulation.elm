module MrJam.Adaptateurs.Manipulation exposing (bloc, chemin, cible, defilement, depot, fantome, fond, formule, piece, prise, source, sousFormule, test, zoom)

{-| Métadonnées fixes du pont de gestes. Touch action, inert et zoom n'ont
pas d'équivalent dans elm-ui ; aucune classe ni propriété CSS libre.
-}

import Element exposing (Attribute, htmlAttribute)
import Html.Attributes as A


source valeur =
    htmlAttribute (A.attribute "data-atelier-source" valeur)


cible valeur =
    htmlAttribute (A.attribute "data-atelier-cible" valeur)


piece valeur =
    htmlAttribute (A.attribute "data-atelier-piece" valeur)


bloc valeur =
    htmlAttribute (A.attribute "data-bloc" valeur)


test valeur =
    htmlAttribute (A.attribute "data-testid" valeur)


sousFormule valeur =
    htmlAttribute (A.attribute "data-sous-formule" valeur)


formule valeur =
    htmlAttribute (A.attribute "data-formule" valeur)


chemin valeur =
    htmlAttribute (A.attribute "data-chemin" valeur)


defilement =
    htmlAttribute (A.attribute "data-atelier-defile" "canevas")


fond valeur =
    htmlAttribute (A.attribute "data-atelier-fond" valeur)


depot =
    htmlAttribute (A.attribute "data-depot-actif" "true")


fantome =
    [ htmlAttribute (A.attribute "data-mrjam-fantome" "")
    , htmlAttribute (A.attribute "inert" "")
    , htmlAttribute (A.style "pointer-events" "none")
    ]


prise =
    [ htmlAttribute (A.style "touch-action" "none")
    , htmlAttribute (A.style "cursor" "grab")
    , htmlAttribute (A.style "user-select" "none")
    , htmlAttribute (A.style "-webkit-user-select" "none")
    , htmlAttribute (A.style "-webkit-touch-callout" "none")
    ]


zoom : Int -> Attribute message
zoom pourcentage =
    htmlAttribute (A.style "zoom" (String.fromFloat (toFloat (clamp 50 150 pourcentage) / 100)))
