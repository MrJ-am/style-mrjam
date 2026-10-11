module MrJam.Adaptateurs.Tableau exposing (defilement)

{-| elm-ui1.1.8 impose flex-basis:0px aux enfants d'une colonne. Le minimum
intrinsèque du conteneur défilant peut devenir nul dans Firefox, même quand ses
lignes ont une hauteur. L'API publique ne permet pas de changer flex-basis.
Le raccord fixe auto conserve leur hauteur intrinsèque, sans dimension libre.
-}

import Element
import Html.Attributes as A


defilement : Element.Attribute message
defilement =
    Element.htmlAttribute (A.style "flex-basis" "auto")
