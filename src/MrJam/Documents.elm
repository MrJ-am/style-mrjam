module MrJam.Documents exposing (Interface, action, actionSur, actions, document, entete, espace, espaceMarque, filtres, lien, menu, navigation, onglet, pagination, pour, repere, repereFocusable, restituerFocusMenu, section)

{-| Présentation documentaire : données denses, actions discrètes, document sans
carte imbriquée. Aucun état ni règle métier ne réside dans ces composants.
-}

import Browser.Dom
import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html exposing (Html)
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Saisie as Native
import MrJam.Controles as Controles exposing (Intention(..))
import MrJam.Fenetres as Fenetres
import MrJam.Identite as Identite
import MrJam.Theme as Theme


type alias Interface message =
    { action : String -> message -> Element message
    , actionSur : String -> String -> message -> Element message
    , onglet : Bool -> String -> message -> Element message
    , lien : String -> String -> Element message
    , menu : Bool -> message -> List (Element message) -> Element message
    , pagination : { debut : Int, total : Int, taille : Int, precedent : message, suivant : message } -> Element message
    }


pour : Theme.Contexte -> Interface message
pour contexte =
    { action = actionPour contexte
    , actionSur = actionSurPour contexte
    , onglet = ongletPour contexte
    , lien = lienPour contexte
    , menu = menuPour contexte
    , pagination = paginationPour contexte
    }


action : String -> message -> Element message
action =
    actionPour Theme.commune


actionPour : Theme.Contexte -> String -> message -> Element message
actionPour contexte libelle message =
    Controles.actionPour contexte Discrete [] libelle (Just message)


{-| Une action courte dont le nom accessible précise l’objet concerné.
-}
actionSur : String -> String -> message -> Element message
actionSur =
    actionSurPour Theme.commune


actionSurPour : Theme.Contexte -> String -> String -> message -> Element message
actionSurPour contexte libelle cible message =
    Controles.actionPour contexte Discrete [ Region.description (libelle ++ " : " ++ cible) ] libelle (Just message)


actions : List (Element message) -> Element message
actions =
    MrJam.actions


onglet : Bool -> String -> message -> Element message
onglet =
    ongletPour Theme.commune


ongletPour : Theme.Contexte -> Bool -> String -> message -> Element message
ongletPour contexte actif libelle message =
    let
        couleurs =
            Theme.palette contexte
    in
    UI.el
        ([ Bordure.widthEach { bottom = 2, top = 0, right = 0, left = 0 }
         , Theme.bordure
            (if actif then
                couleurs.accent

             else
                couleurs.surface
            )
         ]
            ++ (if actif then
                    [ Accessibilite.pageCourante ]

                else
                    []
               )
        )
        (actionPour contexte libelle message)


lien : String -> String -> Element message
lien =
    lienPour Theme.commune


lienPour : Theme.Contexte -> String -> String -> Element message
lienPour contexte titre url =
    let
        couleurs =
            Theme.palette contexte
    in
    UI.link
        [ UI.width UI.fill
        , UI.height (UI.minimum 30 UI.shrink)
        , UI.paddingXY 0 4
        , Police.semiBold
        , Theme.police couleurs.encre
        , Theme.survolPolice couleurs.accent
        ]
        { url = url, label = UI.paragraph [ UI.width UI.fill ] [ UI.text titre ] }


document : String -> List (Element message) -> Element message
document titre contenu =
    UI.column [ UI.width UI.fill, UI.spacing 18 ]
        (UI.paragraph [ UI.width UI.fill, Region.heading 2, Accessibilite.tabulation -1, Police.size 26, Police.bold ] [ UI.text titre ] :: contenu)


filtres : List (Element message) -> Element message
filtres controles =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 12, UI.alignBottom ]
        (List.map (UI.el [ UI.width (UI.minimum 180 (UI.maximum 360 UI.fill)), UI.alignBottom ]) controles)


repere : String -> Element message -> Element message
repere identifiant =
    UI.el [ UI.width UI.fill, Accessibilite.identifiant identifiant ]


repereFocusable : String -> Element message -> Element message
repereFocusable identifiant =
    UI.el [ UI.width UI.fill, Accessibilite.identifiant identifiant, Accessibilite.tabulation -1 ]


navigation : String -> List (Element message) -> Element message
navigation libelle contenu =
    UI.el [ UI.width UI.fill, Region.navigation, Region.description libelle ] (actions contenu)


pagination : { debut : Int, total : Int, taille : Int, precedent : message, suivant : message } -> Element message
pagination =
    paginationPour Theme.commune


paginationPour : Theme.Contexte -> { debut : Int, total : Int, taille : Int, precedent : message, suivant : message } -> Element message
paginationPour contexte p =
    actions
        [ (MrJam.pour contexte).texteSecondaire (String.fromInt p.total ++ " résultats")
        , if p.debut > 0 then
            actionPour contexte "Précédent" p.precedent

          else
            Controles.actionPour contexte Discrete [] "Précédent" Nothing
        , if p.debut + p.taille < p.total then
            actionPour contexte "Suivant" p.suivant

          else
            Controles.actionPour contexte Discrete [] "Suivant" Nothing
        ]


menu : Bool -> message -> List (Element message) -> Element message
menu =
    menuPour Theme.commune


menuPour : Theme.Contexte -> Bool -> message -> List (Element message) -> Element message
menuPour contexte ouvert basculer contenu =
    UI.column
        [ UI.width (UI.maximum 280 UI.shrink)
        , UI.spacing 8
        , Native.echap ouvert basculer
        ]
        [ Controles.actionPour contexte
            Icone
            [ Region.description "Ouvrir le menu"
            , Accessibilite.identifiant "commande-menu-application"
            , Accessibilite.controle "menu-application"
            , Accessibilite.depliement ouvert
            ]
            "☰"
            (Just basculer)
        , if ouvert then
            repere "menu-application" (actions contenu)

          else
            UI.none
        ]


{-| À commander par update après une fermeture clavier du menu, lorsque ses
actions disparaissent. Aucun délai d'animation ne conditionne la restitution.
-}
restituerFocusMenu : (Result Browser.Dom.Error () -> message) -> Cmd message
restituerFocusMenu =
    Accessibilite.restituerFocus "commande-menu-application"


espace : String -> List (Element message) -> Maybe (Html message) -> List (Element message) -> Html message
espace titre liensNavigation dialogue contenu =
    cadre False titre liensNavigation dialogue contenu


{-| Cadre avec une marque liée à l'accueil et sans signature de bas de page.
Cette variante est explicite : les consommateurs de `espace` gardent leur cadre.
-}
espaceMarque : String -> List (Element message) -> Maybe (Html message) -> List (Element message) -> Html message
espaceMarque titre liensNavigation dialogue contenu =
    cadre True titre liensNavigation dialogue contenu


cadre : Bool -> String -> List (Element message) -> Maybe (Html message) -> List (Element message) -> Html message
cadre marque titre liensNavigation dialogue contenu =
    let
        contexte =
            Theme.pour titre

        couleurs =
            Theme.palette contexte
    in
    Fenetres.avecModalePour titre dialogue <|
        UI.layoutWith { options = [ Theme.focusPour contexte ] }
            (Theme.ecran
                ++ [ Theme.fond couleurs.surface
                   , Theme.police couleurs.encre
                   , Police.size 15
                   , Theme.typographie
                   ]
            )
            (UI.column [ UI.width UI.fill, UI.spacing 0 ]
                [ UI.wrappedRow
                    [ UI.width UI.fill
                    , UI.paddingXY 20 12
                    , UI.spacing 18
                    , Theme.fond couleurs.papier
                    , Bordure.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
                    , Theme.bordure couleurs.ligne
                    , Accessibilite.banniere
                    ]
                    ((if marque then
                        [ Identite.logoPour titre
                        , UI.link [ Region.description (titre ++ ".MrJ.am — accueil") ]
                            { url = "./", label = Identite.marque titre }
                        ]

                      else
                        [ Identite.logo
                        , UI.paragraph [ Region.heading 1, Police.size 20, Police.bold ] [ UI.text titre ]
                        ]
                     )
                        ++ [ if marque then
                                UI.el [ UI.width (UI.minimum 200 UI.fill) ]
                                    (UI.wrappedRow [ UI.spacing 12, UI.alignRight, Region.navigation ] liensNavigation)

                             else
                                UI.wrappedRow [ UI.spacing 12, UI.width (UI.minimum 200 UI.fill), Region.navigation ] liensNavigation
                           ]
                    )
                , UI.column [ UI.width (UI.maximum 1280 UI.fill), UI.centerX, UI.padding 24, UI.spacing 20, Region.mainContent, Accessibilite.identifiant "contenu-principal" ] contenu
                , if marque then
                    UI.none

                  else
                    UI.el [ UI.width UI.fill, UI.paddingXY 24 0 ] (Identite.piedDePagePour contexte)
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
