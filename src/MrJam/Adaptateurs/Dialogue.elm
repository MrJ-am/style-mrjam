module MrJam.Adaptateurs.Dialogue exposing (assembler, integrer, natif, natifLecture)

{-| Nœud dialog et racines sœurs absents de l'API publique elm-ui1.1.8.
Le cadre, les couleurs, le rayon, les dimensions et la typographie sont rendus
par elm-ui. Trois resets constants retirent uniquement le cadre natif redondant.
Le navigateur possède la couche modale, le fond inerte et l'événement cancel.
-}

import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes as Attributs
import Html.Events as Evenements
import Json.Decode as Decode


natif : String -> String -> message -> Html message -> Html message
natif identifiant titre fermer contenu =
    natifAvec [] identifiant titre fermer contenu


{-| La marge du porteur dialog n'est pas réglable par elm-ui, qui construit son
contenu. Valeur unique bornée ; aucune propriété CSS configurable.
-}
natifLecture : Int -> String -> String -> String -> message -> Html message -> Html message
natifLecture hauteur production identifiant titre fermer contenu =
    natifAvec [ margeLecture hauteur, Attributs.attribute "production-id" production ] identifiant titre fermer contenu


margeLecture : Int -> Html.Attribute message
margeLecture hauteur =
    Attributs.style "margin-top" (String.fromInt (Basics.clamp 12 800 hauteur) ++ "px")


natifAvec : List (Html.Attribute message) -> String -> String -> message -> Html message -> Html message
natifAvec marge identifiant titre fermer contenu =
    Html.node "dialog" (attributsBase identifiant titre fermer ++ marge) [ contenu ]


attributsBase : String -> String -> message -> List (Html.Attribute message)
attributsBase identifiant titre fermer =
    [ Attributs.id identifiant
    , Attributs.attribute "data-mrjam-modale" ""
    , Attributs.attribute "aria-label" titre
    , Attributs.style "border" "0"
    , Attributs.style "padding" "0"
    , Attributs.style "background" "transparent"
    , Evenements.preventDefaultOn "cancel" (Decode.succeed ( fermer, True ))
    ]


assembler : Html message -> Maybe (Html message) -> Html message
assembler contenu dialogue =
    Html.div []
        (contenu :: (Maybe.map List.singleton dialogue |> Maybe.withDefault []))


{-| Insérer le même dialogue natif dans une racine Element ; aucune seconde
implémentation de couche, d'état ou de focus.
-}
integrer : Html message -> Element message
integrer =
    Element.html
