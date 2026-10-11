module MrJam.Adaptateurs.Accessibilite exposing (controle, decritPar, depliement, identifiant, tabulation)

{-| Attributs nécessaires absents de l'API publique elm-ui1.1.8.
Les libellés utilisent Element.Region.description, pas un adaptateur HTML.
Aucun nom d'attribut arbitraire, classe ou style ; exceptions centralement
limitées à ces fonctions et aux symboles/littéraux correspondants.
-}

import Element exposing (Attribute)
import Html.Attributes as Attributs


identifiant : String -> Attribute message
identifiant valeur =
    Element.htmlAttribute (Attributs.id valeur)


controle : String -> Attribute message
controle cible =
    Element.htmlAttribute (Attributs.attribute "aria-controls" cible)


decritPar : String -> Attribute message
decritPar cible =
    Element.htmlAttribute (Attributs.attribute "aria-describedby" cible)


depliement : Bool -> Attribute message
depliement ouvert =
    Element.htmlAttribute
        (Attributs.attribute "aria-expanded"
            (if ouvert then
                "true"

             else
                "false"
            )
        )


tabulation : Int -> Attribute message
tabulation index =
    -- Aucun ordre de tabulation positif artificiel.
    Element.htmlAttribute (Attributs.tabindex (clamp -1 0 index))
