module MrJam.Adaptateurs.Atelier exposing (selection, suivi)

{-| Repères de lecture et sélection ; noms fixes, aucune décoration.
-}

import Element exposing (Attribute)
import Html.Attributes as A


suivi : Float -> Bool -> List (Attribute message)
suivi progression lecture =
    [ Element.htmlAttribute (A.attribute "data-progress" (String.fromFloat (clamp 0 1 progression)))
    , Element.htmlAttribute
        (A.attribute "data-running"
            (if lecture then
                "true"

             else
                "false"
            )
        )
    ]


selection : String -> Attribute message
selection identifiant =
    Element.htmlAttribute (A.attribute "data-selected" identifiant)
