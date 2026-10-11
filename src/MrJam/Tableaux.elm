module MrJam.Tableaux exposing (Colonne, Interface, celluleEditable, colonne, commandes, mesure, outil, pour, principale, tableau, tableauAvecOutils)

{-| Un seul moteur de tableau. Le type opaque garantit les mêmes largeurs pour
les en-têtes et cellules. Les variantes expriment l'intention de la colonne.
-}

import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Element.Region as Region
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Tableau as Native
import MrJam.Controles as Controles
import MrJam.Theme as Theme


type alias Interface donnee message =
    { tableau : String -> List (Colonne donnee message) -> List donnee -> Element message
    , tableauAvecOutils : String -> List (Element message) -> List (Colonne donnee message) -> List donnee -> Element message
    , outil : String -> String -> message -> Element message
    , celluleEditable : String -> String -> (String -> message) -> Element message
    }


pour : Theme.Contexte -> Interface donnee message
pour contexte =
    { tableau = tableauPour contexte
    , tableauAvecOutils = tableauAvecOutilsPour contexte
    , outil = Controles.iconePour contexte
    , celluleEditable = celluleEditablePour contexte
    }


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


tableau : String -> List (Colonne donnee message) -> List donnee -> Element message
tableau =
    tableauPour Theme.commune


tableauPour : Theme.Contexte -> String -> List (Colonne donnee message) -> List donnee -> Element message
tableauPour contexte libelle colonnes donnees =
    let
        couleurs =
            Theme.palette contexte

        largeur (Colonne taille _ _) =
            dimensions taille |> Tuple.first

        cellule nature contenu (Colonne taille _ _) =
            let
                ( minimum, longueur ) =
                    dimensions taille
            in
            UI.el
                [ nature
                , UI.width (UI.minimum minimum longueur)
                , UI.paddingXY 10 4
                , UI.height (UI.minimum 38 UI.shrink)
                , UI.alignTop
                ]
                (UI.el [ UI.width UI.fill, UI.centerY ] contenu)

        rangee attributs cellules =
            UI.row
                ([ Accessibilite.rangee, UI.width UI.fill, Bordure.widthEach { bottom = 1, top = 0, left = 0, right = 0 }, Theme.bordure couleurs.ligne ] ++ attributs)
                cellules
    in
    if List.isEmpty colonnes then
        UI.none

    else
        UI.column [ UI.width UI.fill, UI.spacing 10 ]
            [ UI.el
                [ UI.width UI.fill
                , UI.scrollbarX
                , Native.defilement
                , Accessibilite.region
                , Region.description (libelle ++ " — défilement horizontal")
                , Accessibilite.tabulation 0
                ]
                (UI.column
                    [ UI.width (UI.minimum (List.sum (List.map largeur colonnes)) UI.fill)
                    , Accessibilite.tableau
                    , Region.description libelle
                    , Police.size 14
                    ]
                    (rangee [ Theme.police couleurs.discret, Police.size 13 ]
                        (List.map (\((Colonne _ nom _) as col) -> cellule Accessibilite.enteteColonne (UI.paragraph [ UI.width UI.fill ] [ UI.text nom ]) col) colonnes)
                        :: List.map
                            (\donnee ->
                                rangee [ Theme.survol couleurs.papier ]
                                    (List.map (\((Colonne _ _ afficher) as col) -> cellule Accessibilite.cellule (afficher donnee) col) colonnes)
                            )
                            donnees
                    )
                )
            , if List.isEmpty donnees then
                (MrJam.pour contexte).texteSecondaire "Aucune donnée."

              else
                UI.none
            ]


tableauAvecOutils : String -> List (Element message) -> List (Colonne donnee message) -> List donnee -> Element message
tableauAvecOutils =
    tableauAvecOutilsPour Theme.commune


tableauAvecOutilsPour : Theme.Contexte -> String -> List (Element message) -> List (Colonne donnee message) -> List donnee -> Element message
tableauAvecOutilsPour contexte libelle commandesTable colonnes donnees =
    UI.column [ UI.width UI.fill, UI.spacing 6 ]
        [ UI.el
            [ Accessibilite.region
            , Region.description ("Outils du tableau " ++ libelle)
            , UI.width UI.fill
            ]
            (UI.wrappedRow [ UI.spacing 4, UI.alignRight ] commandesTable)
        , tableauPour contexte libelle colonnes donnees
        ]


outil : String -> String -> message -> Element message
outil =
    Controles.icone


celluleEditable : String -> String -> (String -> message) -> Element message
celluleEditable =
    celluleEditablePour Theme.commune


celluleEditablePour : Theme.Contexte -> String -> String -> (String -> message) -> Element message
celluleEditablePour contexte libelle valeur modifier =
    Saisie.text
        (Theme.champPour contexte ++ [ UI.width UI.fill, Region.description libelle ])
        { onChange = modifier
        , text = valeur
        , placeholder = Nothing
        , label = Saisie.labelHidden libelle
        }
