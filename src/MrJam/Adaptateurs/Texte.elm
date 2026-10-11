module MrJam.Adaptateurs.Texte exposing (document, emphase, litteral, portee, texte)

{-| Conservation littérale des espaces/retours et repli d'un mot sans espace.
Ces deux capacités ne sont pas exposées par Font/paragraph dans elm-ui1.1.8.
Attributs fixes uniquement : aucun texte transformé, HTML injecté ou CSS libre.
-}

import Element exposing (Attribute, Element, htmlAttribute)
import Html
import Html.Attributes as Attributs


litteral : List (Attribute message)
litteral =
    [ htmlAttribute (Attributs.style "white-space" "pre-wrap")
    , htmlAttribute (Attributs.style "overflow-wrap" "anywhere")
    ]


{-| Element.text crée un élément .t qui force white-space:normal dans paragraph.
Le nœud texte natif échappé hérite du réglage littéral sans construire une vue
HTML, interpréter la chaîne ou ajouter un élément de présentation.
-}
texte : String -> Element message
texte =
    Element.html << Html.text


{-| Sémantique d'emphase absente de Element.Region. Le texte est échappé,
sans attribut HTML ni autre construction ; Font.italic porte la présentation.
-}
emphase : String -> Element message
emphase contenu =
    Element.html (Html.em [] [ Html.text contenu ])


{-| Les espaces initiaux d'une preuve expriment une portée scientifique.
elm-ui ne propose pas l'unité ch : seul ce retrait numérique, positif et
hérité de la police du document passe par le raccord. Aucun CSS appelant.
-}
portee : Int -> List (Attribute message)
portee espaces =
    [ htmlAttribute (Attributs.style "padding-left" (String.fromInt (Basics.max 0 espaces) ++ "ch"))
    , htmlAttribute (Attributs.attribute "data-mrjam-portee" (String.fromInt espaces))
    ]


{-| Source exacte pour les contrôles scientifiques, sans interprétation HTML.
-}
document : String -> Attribute message
document source =
    htmlAttribute (Attributs.attribute "data-mrjam-document" source)
