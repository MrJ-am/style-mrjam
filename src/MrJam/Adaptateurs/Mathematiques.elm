module MrJam.Adaptateurs.Mathematiques exposing (expression)

{-| Raccord à KaTeX déjà employé par les applications. elm-ui n'offre pas de
rendu TeX natif. Le custom element reçoit une formule échappée en attribut,
sans HTML fourni par l'appelant ; son pont appelle KaTeX avec trust=false.
Aucune présentation ordinaire, classe ou feuille applicative dans ce raccord.
-}

import Element exposing (Element)
import Html
import Html.Attributes as Attributs


expression : Bool -> String -> Element message
expression bloc source =
    Element.html
        (Html.node "math-tex"
            ([ Attributs.attribute "formula" source ]
                ++ (if bloc then
                        [ Attributs.attribute "display-mode" "true" ]

                    else
                        []
                   )
            )
            []
        )
