module MrJam.Atelier exposing (accent, badge, button, card, checkbox, divider, format, heading, illustration, ink, label, muted, paragraph, primary, scene, selection, slider, small, suivi, surface, white)

{-| Adaptation de l'atelier aux composants communs de Style MrJam.
Seul le curseur animé possède un rendu technique pour éviter aria-live à chaque frame.
-}

import Element exposing (..)
import Element.Font as Font
import Element.Region as Region
import MrJam
import MrJam.Adaptateurs.Atelier as Reperes
import MrJam.Curseurs as Curseurs
import MrJam.Dessin as Dessin
import MrJam.Disposition as Disposition
import MrJam.Theme as Theme


ink : Color
ink =
    Theme.couleurs.encre


accent : Color
accent =
    Theme.couleurs.accent


muted : Color
muted =
    Theme.couleurs.discret


white : Color
white =
    Theme.couleurs.surface


surface : Color
surface =
    Theme.couleurs.papier


label : String -> Element msg
label text_ =
    el [ Font.size 11, Font.bold, Font.letterSpacing 1.4, Font.color muted ] (text (String.toUpper text_))


small : String -> Element msg
small text_ =
    Element.paragraph [ Font.size 12, Font.color muted, spacing 4 ] [ text text_ ]


paragraph : String -> Element msg
paragraph text_ =
    Element.paragraph [ Font.size 14, Font.color muted, spacing 5 ] [ text text_ ]


heading : Int -> String -> Element msg
heading level text_ =
    Element.paragraph
        [ Region.heading level
        , Font.size
            (if level == 1 then
                40

             else
                20
            )
        , Font.semiBold
        , Font.color ink
        , Font.letterSpacing -0.7
        ]
        [ text text_ ]


card : List (Attribute msg) -> List (Element msg) -> Element msg
card =
    Disposition.panneau


button : Bool -> msg -> String -> Element msg
button selected message caption =
    Disposition.boutonSelection selected caption message


primary : msg -> String -> Element msg
primary message caption =
    MrJam.bouton caption message


checkbox : String -> Bool -> (Bool -> msg) -> Element msg
checkbox =
    MrJam.caseACocher


slider : String -> String -> Float -> Float -> Float -> Float -> (Float -> msg) -> Element msg
slider =
    Curseurs.continu Theme.commune


divider : Element msg
divider =
    MrJam.separateur


badge : String -> Element msg
badge =
    Disposition.etiquette


format : Int -> Float -> String
format =
    Curseurs.format


illustration : Int -> Element message -> Element message
illustration taille dessin =
    el [ width fill, height (px taille) ] dessin


{-| Repères factuels des parcours et dimensions du cadre de scène historique.
Ni classe CSS ni identité métier : progression bornée et état du lecteur.
-}
suivi : Float -> Bool -> List (Attribute message)
suivi =
    Reperes.suivi


selection : String -> Attribute message
selection =
    Reperes.selection


scene : String -> Int -> Element message -> Element message
scene repere largeur dessin =
    let
        marge =
            if largeur < 650 then
                18

            else
                40

        contenu =
            max 0 (min 1260 largeur - 2 * marge)

        disponible =
            if largeur < 950 then
                contenu

            else
                max 0 (contenu - 344)

        rapport =
            if largeur < 650 then
                1.03

            else
                1.26
    in
    el [ width fill, height (px (min 470 (round (toFloat disponible / rapport)))), behindContent (Dessin.quadrillage repere) ] dessin
