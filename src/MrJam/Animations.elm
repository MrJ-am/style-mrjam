module MrJam.Animations exposing (deploiement)

{-| Présentation continue sur les valeurs du socle elm-animator. Le contenu
informatif reste au même emplacement pendant ouverture/inversion/fermeture.
Les commandes et le focus restent hors de ce conteneur décoratif ; aucune
action métier n'attend sa hauteur ou la fin de sa chronologie.
-}

import Element exposing (Element)
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Transitions as Transitions


deploiement : Int -> Transitions.Transition Bool -> Element message -> Element message
deploiement hauteur transition contenu =
    let
        progression =
            Transitions.nombre
                (\ouvert ->
                    if ouvert then
                        1

                    else
                        0
                )
                transition
    in
    Element.el
        ([ Element.width Element.fill
         , Element.height (Element.minimum 0 (Element.px (round (toFloat (max 0 hauteur) * progression))))
         , Element.clipY
         , Element.alpha progression
         ]
            ++ (if Transitions.courant transition then
                    []

                else
                    [ Accessibilite.masque ]
               )
        )
        contenu
