module MrJam.Adaptateurs.Pictogramme exposing (traits)

{-| Dessin vectoriel décoratif absent de l'API elm-ui. Un viewport fixe et des
tracés, sans HTML, CSS, événements ou contenu distant. La couleur courante et
les dimensions de la boîte sont fournies par elm-ui au composant appelant.
-}

import Element exposing (Element)
import Html.Attributes as Attributs
import Svg
import Svg.Attributes as Geometrie


traits : List String -> Element message
traits chemins =
    Element.html <|
        Svg.svg
            [ Geometrie.viewBox "0 0 24 24"
            , Geometrie.width "22"
            , Geometrie.height "22"
            , Geometrie.fill "none"
            , Geometrie.stroke "currentColor"
            , Geometrie.strokeWidth "1.7"
            , Geometrie.strokeLinecap "round"
            , Geometrie.strokeLinejoin "round"
            , Attributs.attribute "aria-hidden" "true"
            , Attributs.attribute "focusable" "false"
            ]
            (List.map (\chemin -> Svg.path [ Geometrie.d chemin ] []) chemins)
