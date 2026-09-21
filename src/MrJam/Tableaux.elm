module MrJam.Tableaux exposing (Colonne, colonne, tableau)

{-| Tableaux de lecture, sans tri ni pagination implicites. Les cellules sont
construites avec les composants partagés ; l'application garde ses données.
Le défilement horizontal reste local au tableau, y compris au clavier.
-}

import Element as Interface exposing (Element)
import MrJam
import MrJam.Donnees as Donnees


type Colonne donnee message
    = Colonne String (donnee -> Element message)


colonne : String -> (donnee -> Element message) -> Colonne donnee message
colonne =
    Colonne


tableau : String -> List (Colonne donnee message) -> List donnee -> Element message
tableau libelle colonnes donnees =
    if List.isEmpty colonnes then
        Interface.none

    else
        Interface.column [ Interface.width Interface.fill, Interface.spacing 8 ]
            [ MrJam.texteSecondaire libelle
            , Donnees.tableau libelle (List.map (\(Colonne titre afficher) -> ( titre, afficher )) colonnes) donnees
            , if List.isEmpty donnees then
                MrJam.texteSecondaire "Aucune donnée."

              else
                Interface.none
            ]
