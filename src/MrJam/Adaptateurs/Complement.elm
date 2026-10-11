module MrJam.Adaptateurs.Complement exposing (natif)

{-| Ouverture native, clavier, état open et recherche dans les compléments.
elm-ui1.1.8 ne possède pas de details/summary natifs. Ce raccord ne porte aucun
attribut de présentation, événement, état mutable ou interprétation HTML.
Le résumé et le corps sont construits en elm-ui par le composant commun.
-}

import Element
import Html exposing (Html)


natif : Html message -> Html message -> Element.Element message
natif resume contenu =
    Element.html (Html.details [] [ Html.summary [] [ resume ], contenu ])
