module MrJam.Disposition exposing (bandeau, boutonIcone, boutonIdentifie, boutonMenu, boutonSelection, cadre, date, dialogue, etiquette, fragment, histogramme, panneau, progression)

{-| Compositions communes. Les identifiants raccordent les interactions et
les tests ; les applications ne règlent pas la décoration des contrôles.
Les dialogues utilisent le pont local `dialogues.js` pour le focus et inert.
-}

import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Html exposing (Html)
import Html.Attributes as A
import MrJam
import MrJam.Donnees as Donnees
import MrJam.Identite as Identite
import MrJam.Theme as Theme exposing (couleurs)


cadre : List (UI.Attribute message) -> Element message -> Html message
cadre attributs contenu =
    UI.layoutWith { options = [ Theme.focus ] }
        ([ UI.width UI.fill, Fond.color couleurs.papier, Police.color couleurs.encre, Police.size 16, Police.family [ Police.typeface "Inter", Police.typeface "Segoe UI", Police.sansSerif ] ] ++ attributs)
        contenu


fragment : Element message -> Html message
fragment =
    UI.layoutWith { options = [ UI.noStaticStyleSheet, Theme.focus ] }
        [ UI.width UI.fill, UI.height UI.shrink, UI.htmlAttribute (A.style "min-height" "0"), UI.htmlAttribute (A.style "font" "inherit"), UI.htmlAttribute (A.style "color" "inherit") ]


bandeau : String -> List (Element message) -> Element message
bandeau titre commandes =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 12, UI.paddingXY 0 12 ]
        [ Identite.logo, UI.paragraph [ UI.width (UI.minimum 0 UI.fill), Police.bold, Police.size 24 ] [ UI.text titre ], UI.el [ UI.alignRight ] (MrJam.actions commandes) ]


panneau : List (UI.Attribute message) -> List (Element message) -> Element message
panneau attributs =
    UI.column (Theme.panneau ++ attributs)


etiquette : String -> Element message
etiquette libelle =
    UI.el [ UI.paddingXY 10 5, Bordure.rounded 8, Fond.color couleurs.doux, Police.color couleurs.accent, Police.size 13 ] (UI.text libelle)


boutonIdentifie : String -> String -> Maybe message -> Element message
boutonIdentifie identifiant libelle message =
    Saisie.button
        [ UI.htmlAttribute (A.id identifiant)
        , UI.htmlAttribute (A.style "flex-basis" "auto")
        , UI.height (UI.minimum 44 UI.shrink)
        , UI.paddingXY 16 10
        , Bordure.rounded 12
        , Police.semiBold
        , Fond.color
            (if message == Nothing then
                couleurs.doux

             else
                couleurs.accent
            )
        , Police.color
            (if message == Nothing then
                couleurs.discret

             else
                couleurs.surface
            )
        , UI.htmlAttribute
            (A.attribute "aria-disabled"
                (if message == Nothing then
                    "true"

                 else
                    "false"
                )
            )
        ]
        { onPress = message, label = UI.paragraph [] [ UI.text libelle ] }


boutonSelection : Bool -> String -> message -> Element message
boutonSelection selectionne libelle message =
    Saisie.button
        [ UI.height (UI.minimum 44 UI.shrink)
        , UI.htmlAttribute (A.style "flex-basis" "auto")
        , UI.paddingXY 12 8
        , Bordure.rounded 12
        , Bordure.width 1
        , Bordure.color
            (if selectionne then
                couleurs.accent

             else
                couleurs.ligne
            )
        , Fond.color couleurs.surface
        , Police.color couleurs.encre
        , UI.htmlAttribute
            (A.attribute "aria-pressed"
                (if selectionne then
                    "true"

                 else
                    "false"
                )
            )
        ]
        { onPress = Just message, label = UI.paragraph [] [ UI.text libelle ] }


date : String -> String -> (String -> message) -> Element message
date =
    Donnees.date


progression : String -> Float -> Element message
progression libelle valeur =
    let
        pourcentage =
            Basics.clamp 0 100 valeur
    in
    UI.el [ UI.width UI.fill, UI.height (UI.px 3), Fond.color couleurs.doux, UI.htmlAttribute (A.attribute "role" "progressbar"), UI.htmlAttribute (A.attribute "aria-label" libelle), UI.htmlAttribute (A.attribute "aria-valuenow" (String.fromFloat pourcentage)), UI.htmlAttribute (A.attribute "aria-valuemin" "0"), UI.htmlAttribute (A.attribute "aria-valuemax" "100") ]
        (UI.el [ UI.height UI.fill, UI.htmlAttribute (A.style "width" (String.fromFloat pourcentage ++ "%")), Fond.color couleurs.accent ] UI.none)


histogramme : String -> List ( String, Float ) -> Element message
histogramme libelle donnees =
    let
        maximum =
            Basics.max 1 (List.maximum (List.map Tuple.second donnees) |> Maybe.withDefault 1)
    in
    if not (List.any (\( _, n ) -> n > 0) donnees) then
        MrJam.texteSecondaire "Aucune évaluation pour cette sélection."

    else
        UI.el [ UI.width UI.fill, UI.scrollbarX, UI.htmlAttribute (A.style "flex-basis" "auto"), UI.htmlAttribute (A.tabindex 0), UI.htmlAttribute (A.attribute "role" "img"), UI.htmlAttribute (A.attribute "aria-label" (libelle ++ ". " ++ String.join "; " (List.map (\( x, n ) -> x ++ " : " ++ String.fromFloat n) donnees))) ]
            (UI.row [ UI.spacing 8, UI.alignBottom ] (List.map (\( x, n ) -> UI.column [ UI.width (UI.px 44), UI.alignBottom, UI.spacing 6, Police.size 12 ] [ UI.text (String.fromFloat n), UI.el [ UI.width (UI.px 30), UI.height (UI.px (Basics.max 1 (round (120 * n / maximum)))), Fond.color couleurs.accent, Bordure.rounded 4 ] UI.none, UI.text x ]) donnees))


dialogue : String -> String -> String -> message -> List (Element message) -> Element message
dialogue repere titre fermeture fermer contenu =
    UI.el
        [ UI.htmlAttribute (A.class (repere ++ "-layer"))
        , UI.htmlAttribute (A.style "position" "fixed")
        , UI.htmlAttribute (A.style "inset" "0")
        , UI.htmlAttribute (A.style "z-index" "230")
        , UI.width UI.fill
        , UI.height UI.fill
        , UI.padding 16
        , Fond.color (UI.rgba255 23 59 53 0.3)
        ]
        (panneau
            [ UI.width
                (UI.maximum
                    (if repere == "comparison" then
                        1160

                     else
                        560
                    )
                    UI.fill
                )
            , UI.height (UI.maximum 760 UI.shrink)
            , UI.centerX
            , UI.centerY
            , UI.scrollbarY
            , UI.htmlAttribute (A.style "max-height" "100%")
            , UI.htmlAttribute (A.id repere)
            , UI.htmlAttribute (A.class repere)
            , UI.htmlAttribute (A.attribute "role" "dialog")
            , UI.htmlAttribute (A.attribute "aria-modal" "true")
            , UI.htmlAttribute (A.attribute "aria-label" titre)
            , UI.htmlAttribute (A.attribute "data-mrjam-dialogue" "")
            , UI.htmlAttribute (A.tabindex -1)
            ]
            (UI.wrappedRow [ UI.width UI.fill, UI.spacing 12 ] [ MrJam.sousTitre titre, UI.el [ UI.alignRight, UI.htmlAttribute (A.attribute "data-mrjam-fermer" "") ] (MrJam.boutonSecondaire fermeture fermer) ] :: contenu)
        )


boutonIcone : String -> String -> message -> Element message
boutonIcone description symbole message =
    Saisie.button [ UI.width (UI.px 44), UI.height (UI.px 44), Bordure.rounded 22, Fond.color couleurs.doux, Police.color couleurs.accent, UI.htmlAttribute (A.attribute "aria-label" description) ]
        { onPress = Just message, label = UI.el [ UI.centerX, UI.centerY ] (UI.text symbole) }


boutonMenu : String -> Bool -> message -> Element message
boutonMenu cible ouvert message =
    Saisie.button
        [ UI.width (UI.px 44)
        , UI.height (UI.px 44)
        , Bordure.rounded 22
        , Fond.color couleurs.doux
        , Police.color couleurs.accent
        , UI.htmlAttribute
            (A.attribute "aria-label"
                (if ouvert then
                    "Fermer le menu"

                 else
                    "Ouvrir le menu"
                )
            )
        , UI.htmlAttribute (A.attribute "aria-controls" cible)
        , UI.htmlAttribute
            (A.attribute "aria-expanded"
                (if ouvert then
                    "true"

                 else
                    "false"
                )
            )
        ]
        { onPress = Just message, label = UI.el [ UI.centerX, UI.centerY ] (UI.text "☰") }
