module MrJam.Adaptateurs.Selection exposing (native)

{-| elm-ui1.1.8 n'expose ni select ni son renderer interne (non exposé dans
elm.json). La présentation du cadre et du libellé appartient aux composants
elm-ui ; ce raccord conserve exclusivement la sémantique native et son clavier.
Les resets constants font hériter à ce seul contrôle la présentation de son
cadre : aucun choix de couleur, fonte, taille, position ou animation CSS.
-}

import Element exposing (Element)
import Html
import Html.Attributes as Attributs
import Html.Events as Evenements


native : String -> List ( String, String ) -> String -> (String -> message) -> Element message
native libelle possibilites valeur modifier =
    Element.html <|
        Html.select
            [ Attributs.value valeur
            , Attributs.attribute "aria-label" libelle
            , Evenements.onInput modifier
            , Attributs.style "font" "inherit"
            , Attributs.style "color" "inherit"
            , Attributs.style "background" "transparent"
            , Attributs.style "border" "0"
            , Attributs.style "padding" "0"
            , Attributs.style "width" "100%"
            , Attributs.style "box-sizing" "border-box"
            ]
            (List.map (\( cle, nom ) -> Html.option [ Attributs.value cle, Attributs.selected (cle == valeur) ] [ Html.text nom ]) possibilites)
