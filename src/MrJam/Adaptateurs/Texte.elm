module MrJam.Adaptateurs.Texte exposing (emphase, litteral, texte)

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
