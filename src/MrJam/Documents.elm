module MrJam.Documents exposing (action, actionSur, actions, document, entete, espace, filtres, lien, menu, onglet, pagination, repere, section)

{-| Présentation documentaire : données denses, actions discrètes, document sans
carte imbriquée. Aucun état ni règle métier ne réside dans ces composants.
-}

import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as Evenements
import Json.Decode as D
import MrJam
import MrJam.Controles as Controles exposing (Intention(..))
import MrJam.Fenetres as Fenetres
import MrJam.Identite as Identite
import MrJam.Theme as Theme exposing (couleurs)


action : String -> message -> Element message
action libelle message =
    Controles.action Discrete [] libelle (Just message)


{-| Une action courte dont le nom accessible précise l’objet concerné.
-}
actionSur : String -> String -> message -> Element message
actionSur libelle cible message =
    Controles.action Discrete [ UI.htmlAttribute (A.attribute "aria-label" (libelle ++ " : " ++ cible)) ] libelle (Just message)


actions : List (Element message) -> Element message
actions =
    MrJam.actions


onglet : Bool -> String -> message -> Element message
onglet actif libelle message =
    UI.el
        [ Bordure.widthEach { bottom = 2, top = 0, right = 0, left = 0 }
        , Bordure.color
            (if actif then
                couleurs.accent

             else
                couleurs.surface
            )
        , UI.htmlAttribute
            (A.attribute "aria-current"
                (if actif then
                    "page"

                 else
                    "false"
                )
            )
        ]
        (action libelle message)


lien : String -> String -> Element message
lien titre url =
    UI.link
        [ UI.width UI.fill
        , UI.height (UI.minimum 30 UI.shrink)
        , UI.paddingXY 0 4
        , Police.semiBold
        , Police.color couleurs.encre
        , UI.mouseOver [ Police.color couleurs.accent ]
        ]
        { url = url, label = UI.paragraph [ UI.width UI.fill ] [ UI.text titre ] }


document : String -> List (Element message) -> Element message
document titre contenu =
    UI.column [ UI.width UI.fill, UI.spacing 18 ]
        (UI.paragraph [ UI.width UI.fill, Region.heading 2, UI.htmlAttribute (A.tabindex -1), Police.size 26, Police.bold ] [ UI.text titre ] :: contenu)


filtres : List (Element message) -> Element message
filtres controles =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 12, UI.alignBottom ]
        (List.map (UI.el [ UI.width (UI.minimum 180 (UI.maximum 360 UI.fill)), UI.alignBottom ]) controles)


repere : String -> Element message -> Element message
repere identifiant =
    UI.el [ UI.width UI.fill, UI.htmlAttribute (A.id identifiant) ]


pagination : { debut : Int, total : Int, taille : Int, precedent : message, suivant : message } -> Element message
pagination p =
    actions
        [ MrJam.texteSecondaire (String.fromInt p.total ++ " résultats")
        , if p.debut > 0 then
            action "Précédent" p.precedent

          else
            Controles.action Discrete [] "Précédent" Nothing
        , if p.debut + p.taille < p.total then
            action "Suivant" p.suivant

          else
            Controles.action Discrete [] "Suivant" Nothing
        ]


menu : Bool -> message -> List (Element message) -> Element message
menu ouvert basculer contenu =
    UI.column
        [ UI.width (UI.maximum 280 UI.shrink)
        , UI.spacing 8
        , UI.htmlAttribute
            (Evenements.on "keydown"
                (D.field "key" D.string
                    |> D.andThen
                        (\touche ->
                            if touche == "Escape" && ouvert then
                                D.succeed basculer

                            else
                                D.fail "Autre touche"
                        )
                )
            )
        ]
        [ Controles.action Icone
            [ UI.htmlAttribute (A.attribute "aria-label" "Ouvrir le menu")
            , UI.htmlAttribute (A.attribute "aria-controls" "menu-application")
            , UI.htmlAttribute
                (A.attribute "aria-expanded"
                    (if ouvert then
                        "true"

                     else
                        "false"
                    )
                )
            ]
            "☰"
            (Just basculer)
        , if ouvert then
            repere "menu-application" (actions contenu)

          else
            UI.none
        ]


espace : String -> List (Element message) -> Maybe (Html message) -> List (Element message) -> Html message
espace titre navigation dialogue contenu =
    Fenetres.avecModale dialogue <|
        UI.layoutWith { options = [ Theme.focus ] }
            (Theme.ecran
                ++ [ Fond.color couleurs.surface
                   , Police.color couleurs.encre
                   , Police.size 15
                   , Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]
                   ]
            )
            (UI.column [ UI.width UI.fill, UI.spacing 0 ]
                [ UI.wrappedRow
                    [ UI.width UI.fill
                    , UI.paddingXY 20 12
                    , UI.spacing 18
                    , Fond.color couleurs.papier
                    , Bordure.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                    , Bordure.color couleurs.ligne
                    , UI.htmlAttribute (A.attribute "role" "banner")
                    ]
                    [ Identite.logo
                    , UI.paragraph [ Region.heading 1, Police.size 20, Police.bold ] [ UI.text titre ]
                    , UI.wrappedRow [ UI.spacing 12, UI.width (UI.minimum 200 UI.fill), Region.navigation ] navigation
                    ]
                , UI.column [ UI.width (UI.maximum 1280 UI.fill), UI.centerX, UI.padding 24, UI.spacing 20, Region.mainContent ] contenu
                , UI.el [ UI.width UI.fill, UI.paddingXY 24 0 ] Identite.piedDePage
                ]
            )


entete : String -> List (Element message) -> Element message
entete titre commandes =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 12 ]
        [ UI.paragraph [ Region.heading 2, Police.size 26, Police.bold, UI.width UI.shrink ] [ UI.text titre ]
        , UI.row [ UI.spacing 8 ] commandes
        ]


section : String -> List (Element message) -> Element message
section titre contenu =
    UI.column [ UI.width UI.fill, UI.spacing 12 ]
        (UI.paragraph [ UI.width UI.fill, Region.heading 3, Police.size 18, Police.semiBold ] [ UI.text titre ] :: contenu)
