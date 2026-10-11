module Shared.Licorne exposing (illustration)

import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Licorne as Licorne
import Echo.Render as Render
import Element exposing (Element)
import MrJam.Atelier as Atelier
import Palette.Couleurs as Palette


illustration : String -> Int -> Element msg
illustration identifiant taille =
    let
        options =
            Render.defaults identifiant
    in
    Atelier.illustration taille
        (Render.view
            { options | box = "-2 -2 34 34", title = "Licorne rose invisible — dégradé éclairci vers la corne", degrade = Just Licorne.degrade }
            (Animation.static (Palette.css (Palette.couleur Palette.reference Palette.Licorne)) Composition.licorne)
        )
