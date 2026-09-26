module MrJam.Tableaux exposing (Colonne, colonne, commandes, mesure, principale, tableau)

{-| Un seul moteur de tableau. Le type opaque garantit les mêmes largeurs pour
les en-têtes et cellules. Les variantes expriment l'intention de la colonne.
-}

import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Html.Attributes as A
import MrJam
import MrJam.Theme exposing (couleurs)


type Colonne donnee message
    = Colonne Largeur String (donnee -> Element message)


type Largeur
    = Souple
    | Titre
    | Courte
    | Actions


colonne : String -> (donnee -> Element message) -> Colonne donnee message
colonne =
    Colonne Souple


principale : String -> (donnee -> Element message) -> Colonne donnee message
principale =
    Colonne Titre


mesure : String -> (donnee -> Element message) -> Colonne donnee message
mesure =
    Colonne Courte


commandes : (donnee -> Element message) -> Colonne donnee message
commandes =
    Colonne Actions "Actions"


dimensions : Largeur -> ( Int, UI.Length )
dimensions taille =
    case taille of
        Souple ->
            ( 160, UI.fill )

        Titre ->
            ( 240, UI.fillPortion 3 )

        Courte ->
            ( 128, UI.px 128 )

        Actions ->
            ( 120, UI.px 120 )


role : String -> UI.Attribute message
role nom =
    UI.htmlAttribute (A.attribute "role" nom)


tableau : String -> List (Colonne donnee message) -> List donnee -> Element message
tableau libelle colonnes donnees =
    let
        largeur (Colonne taille _ _) =
            dimensions taille |> Tuple.first

        cellule nature contenu (Colonne taille _ _) =
            let
                ( minimum, longueur ) =
                    dimensions taille
            in
            UI.el
                [ role nature
                , UI.width (UI.minimum minimum longueur)
                , UI.paddingXY 10 4
                , UI.height (UI.minimum 38 UI.shrink)
                , UI.alignTop
                ]
                (UI.el [ UI.width UI.fill, UI.centerY ] contenu)

        rangee attributs cellules =
            UI.row
                ([ role "row", UI.width UI.fill, Bordure.widthEach { bottom = 1, top = 0, left = 0, right = 0 }, Bordure.color couleurs.ligne ] ++ attributs)
                cellules
    in
    if List.isEmpty colonnes then
        UI.none

    else
        UI.column [ UI.width UI.fill, UI.spacing 10 ]
            [ UI.el
                [ UI.width UI.fill
                , UI.scrollbarX
                , UI.htmlAttribute (A.style "flex-basis" "auto")
                , role "region"
                , UI.htmlAttribute (A.attribute "aria-label" (libelle ++ " — défilement horizontal"))
                , UI.htmlAttribute (A.tabindex 0)
                ]
                (UI.column
                    [ UI.width (UI.minimum (List.sum (List.map largeur colonnes)) UI.fill)
                    , role "table"
                    , UI.htmlAttribute (A.attribute "aria-label" libelle)
                    , Police.size 14
                    ]
                    (rangee [ Police.color couleurs.discret, Police.size 13 ]
                        (List.map (\((Colonne _ nom _) as col) -> cellule "columnheader" (UI.text nom) col) colonnes)
                        :: List.map
                            (\donnee ->
                                rangee [ UI.mouseOver [ Fond.color couleurs.papier ] ]
                                    (List.map (\((Colonne _ _ afficher) as col) -> cellule "cell" (afficher donnee) col) colonnes)
                            )
                            donnees
                    )
                )
            , if List.isEmpty donnees then
                MrJam.texteSecondaire "Aucune donnée."

              else
                UI.none
            ]
