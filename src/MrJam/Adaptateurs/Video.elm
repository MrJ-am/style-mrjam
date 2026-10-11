module MrJam.Adaptateurs.Video exposing (format, lecteur)

{-| Iframe et cycle de vie du SDK déjà présent. Aucune commande, affiche,
message ou présentation ordinaire ne réside dans le custom element.
Les quatre styles constants bornent uniquement la surface 16/9 de l'iframe,
capacité absente d'elm-ui ; le pont n'écrit aucun style.
-}

import Element exposing (Element)
import Html
import Html.Attributes as A
import Html.Events
import Json.Decode as D


lecteur : { url : String, titre : String, generation : Int } -> (D.Value -> message) -> Element message
lecteur configuration evenement =
    Element.html
        (Html.node "course-video"
            [ A.attribute "generation" (String.fromInt configuration.generation)
            , Html.Events.on "video-etat" (D.map evenement (D.field "detail" D.value))
            ]
            [ Html.iframe
                [ A.src configuration.url
                , A.title configuration.titre
                , A.attribute "allow" "autoplay; encrypted-media; picture-in-picture; fullscreen"
                , A.attribute "allowfullscreen" ""
                , A.attribute "referrerpolicy" "strict-origin-when-cross-origin"
                , A.style "display" "block"
                , A.style "width" "100%"
                , A.style "aspect-ratio" "16/9"
                , A.style "border" "0"
                ]
                []
            ]
        )


format : Element.Attribute message
format =
    Element.htmlAttribute (A.style "aspect-ratio" "16/9")
