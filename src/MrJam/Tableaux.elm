module MrJam.Tableaux exposing (Colonne, colonne, tableau)

{-| Tableaux de lecture, sans tri ni pagination implicites. Les cellules sont
construites avec les composants partagés ; l'application garde ses données.
Le défilement horizontal reste local au tableau, y compris au clavier.
-}

import Element as Interface exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Html.Attributes as Attributs
import MrJam
import MrJam.Theme exposing (couleurs)


type Colonne donnee message
    = Colonne String (donnee -> Element message)


colonne : String -> (donnee -> Element message) -> Colonne donnee message
colonne =
    Colonne


tableau : String -> List (Colonne donnee message) -> List donnee -> Element message
tableau libelle colonnes donnees =
    let
        role nom =
            Interface.htmlAttribute (Attributs.attribute "role" nom)

        cellule nom contenu =
            Interface.el
                [ Interface.width (Interface.px 180)
                , Interface.height Interface.shrink
                , Interface.padding 12
                , role nom
                ]
                contenu

        ligne contenu =
            Interface.row
                [ Interface.width Interface.fill
                , Interface.height Interface.shrink
                , Bordure.widthEach { top = 0, right = 0, bottom = 1, left = 0 }
                , Bordure.color couleurs.ligne
                , role "row"
                ]
                contenu

        entete (Colonne titre _) =
            cellule "columnheader" (Interface.el [ Police.semiBold ] (MrJam.paragraphe titre))

        valeur donnee (Colonne _ afficher) =
            cellule "cell" (afficher donnee)
    in
    if List.isEmpty colonnes then
        Interface.none

    else
        Interface.column [ Interface.width Interface.fill, Interface.spacing 8 ]
            [ MrJam.texteSecondaire libelle
            , Interface.el
                [ Interface.width (Interface.minimum 0 Interface.fill)
                , Interface.scrollbarX
                , Interface.focused [ Bordure.innerShadow { offset = ( 0, 0 ), size = 3, blur = 0, color = couleurs.accent } ]
                , Interface.htmlAttribute (Attributs.tabindex 0)
                , role "region"
                , Interface.htmlAttribute (Attributs.attribute "aria-label" (libelle ++ " — défilement horizontal"))
                ]
                (Interface.column
                    [ Interface.width (Interface.px (180 * List.length colonnes))
                    , Fond.color couleurs.surface
                    , role "table"
                    , Interface.htmlAttribute (Attributs.attribute "aria-label" libelle)
                    ]
                    [ Interface.el [ Interface.width Interface.fill, role "rowgroup", Fond.color couleurs.doux ]
                        (ligne (List.map entete colonnes))
                    , Interface.column [ Interface.width Interface.fill, role "rowgroup" ]
                        (List.map (\donnee -> ligne (List.map (valeur donnee) colonnes)) donnees)
                    ]
                )
            , if List.isEmpty donnees then
                MrJam.texteSecondaire "Aucune donnée."

              else
                Interface.none
            ]
