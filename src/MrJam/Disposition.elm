module MrJam.Disposition exposing (Interface, bandeau, boutonIcone, boutonIdentifie, boutonIdentifiePour, boutonMenu, boutonSelection, cadre, date, dialogue, dialoguePour, etiquette, fragment, histogramme, panneau, pour, progression)

{-| Compositions communes. Les identifiants raccordent les interactions et
les tests ; les applications ne règlent pas la décoration des contrôles.
Les dialogues natifs utilisent le raccord commun `fenetres.js` pour leur cycle de vie.
-}

import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html exposing (Html)
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Dialogue as Dialogue
import MrJam.Controles as Controles exposing (Intention(..))
import MrJam.Donnees as Donnees
import MrJam.Fenetres as Fenetres
import MrJam.Identite as Identite
import MrJam.Theme as Theme


type alias Interface message =
    { cadre : List (UI.Attribute message) -> Element message -> Html message
    , fragment : Element message -> Html message
    , panneau : List (UI.Attribute message) -> List (Element message) -> Element message
    , etiquette : String -> Element message
    , progression : String -> Float -> Element message
    , histogramme : String -> List ( String, Float ) -> Element message
    , boutonIdentifie : String -> String -> Maybe message -> Element message
    , boutonSelection : Bool -> String -> message -> Element message
    , boutonIcone : String -> String -> message -> Element message
    , boutonMenu : String -> Bool -> message -> Element message
    }


pour : Theme.Contexte -> Interface message
pour contexte =
    { cadre = cadrePour contexte
    , fragment = fragmentPour contexte
    , panneau = panneauPour contexte
    , etiquette = etiquettePour contexte
    , progression = progressionPour contexte
    , histogramme = histogrammePour contexte
    , boutonIdentifie = boutonIdentifiePour contexte
    , boutonSelection = boutonSelectionPour contexte
    , boutonIcone = boutonIconePour contexte
    , boutonMenu = boutonMenuPour contexte
    }


cadre : List (UI.Attribute message) -> Element message -> Html message
cadre =
    cadrePour Theme.commune


cadrePour : Theme.Contexte -> List (UI.Attribute message) -> Element message -> Html message
cadrePour contexte attributs contenu =
    let
        couleurs =
            Theme.palette contexte
    in
    UI.layoutWith { options = [ Theme.focusPour contexte ] }
        (Theme.ecran ++ [ Theme.fond couleurs.papier, Theme.police couleurs.encre, Police.size 16, Theme.typographie ] ++ attributs)
        contenu


fragment : Element message -> Html message
fragment =
    fragmentPour Theme.commune


fragmentPour : Theme.Contexte -> Element message -> Html message
fragmentPour contexte =
    UI.layoutWith { options = [ UI.noStaticStyleSheet, Theme.focusPour contexte ] }
        [ UI.width UI.fill, UI.height UI.shrink, Police.size 16, Theme.police (Theme.palette contexte).encre, Theme.typographie ]


bandeau : String -> List (Element message) -> Element message
bandeau titre commandes =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 12, UI.paddingXY 0 6 ]
        [ Identite.logo, UI.paragraph [ UI.width (UI.minimum 0 UI.fill), Police.bold, Police.size 24 ] [ UI.text titre ], UI.el [ UI.alignRight ] (MrJam.actions commandes) ]


panneau : List (UI.Attribute message) -> List (Element message) -> Element message
panneau =
    panneauPour Theme.commune


panneauPour : Theme.Contexte -> List (UI.Attribute message) -> List (Element message) -> Element message
panneauPour contexte attributs =
    UI.column (Theme.panneauPour contexte ++ attributs)


etiquette : String -> Element message
etiquette =
    etiquettePour Theme.commune


etiquettePour : Theme.Contexte -> String -> Element message
etiquettePour contexte libelle =
    let
        couleurs =
            Theme.palette contexte
    in
    UI.el [ UI.paddingXY 10 5, Bordure.rounded 8, Theme.fond couleurs.doux, Theme.police couleurs.accent, Police.size 13 ] (UI.text libelle)


boutonIdentifie : String -> String -> Maybe message -> Element message
boutonIdentifie =
    boutonIdentifiePour Theme.commune


boutonIdentifiePour : Theme.Contexte -> String -> String -> Maybe message -> Element message
boutonIdentifiePour contexte identifiant libelle message =
    Controles.actionPour contexte Principale [ Accessibilite.identifiant identifiant ] libelle message


boutonSelection : Bool -> String -> message -> Element message
boutonSelection =
    boutonSelectionPour Theme.commune


boutonSelectionPour : Theme.Contexte -> Bool -> String -> message -> Element message
boutonSelectionPour contexte selectionne libelle message =
    Controles.actionPour contexte (Selection selectionne) [] libelle (Just message)


date : String -> String -> (String -> message) -> Element message
date =
    Donnees.date


progression : String -> Float -> Element message
progression =
    progressionPour Theme.commune


progressionPour : Theme.Contexte -> String -> Float -> Element message
progressionPour contexte libelle valeur =
    let
        pourcentage =
            Basics.clamp 0 100 valeur

        couleurs =
            Theme.palette contexte

        rempli =
            round (pourcentage * 10000)

        segment part couleur =
            if part == 0 then
                []

            else
                [ UI.el [ UI.width (UI.fillPortion part), UI.height UI.fill, Theme.fond couleur ] UI.none ]
    in
    UI.row ([ UI.width UI.fill, UI.height (UI.px 3), Region.description libelle ] ++ Accessibilite.progression pourcentage)
        (segment rempli couleurs.accent ++ segment (1000000 - rempli) couleurs.doux)


histogramme : String -> List ( String, Float ) -> Element message
histogramme =
    histogrammePour Theme.commune


histogrammePour : Theme.Contexte -> String -> List ( String, Float ) -> Element message
histogrammePour contexte libelle donnees =
    let
        maximum =
            Basics.max 1 (List.maximum (List.map Tuple.second donnees) |> Maybe.withDefault 1)

        couleurs =
            Theme.palette contexte
    in
    if not (List.any (\( _, n ) -> n > 0) donnees) then
        (MrJam.pour contexte).texteSecondaire "Aucune évaluation pour cette sélection."

    else
        UI.el [ UI.width UI.fill, UI.scrollbarX, Accessibilite.tabulation 0, Accessibilite.image, Region.description (libelle ++ ". " ++ String.join "; " (List.map (\( x, n ) -> x ++ " : " ++ String.fromFloat n) donnees)) ]
            (UI.row [ UI.spacing 8, UI.alignBottom ] (List.map (\( x, n ) -> UI.column [ UI.width (UI.px 44), UI.alignBottom, UI.spacing 6, Police.size 12 ] [ UI.text (String.fromFloat n), UI.el [ UI.width (UI.px 30), UI.height (UI.px (Basics.max 1 (round (120 * n / maximum)))), Theme.fond couleurs.accent, Bordure.rounded 4 ] UI.none, UI.text x ]) donnees))


dialogue : String -> String -> String -> message -> List (Element message) -> Element message
dialogue =
    dialoguePour Theme.commune


dialoguePour : Theme.Contexte -> String -> String -> String -> message -> List (Element message) -> Element message
dialoguePour contexte repere titre fermeture fermer contenu =
    Dialogue.integrer (Fenetres.confirmationPour contexte repere titre fermeture fermer contenu)


boutonIcone : String -> String -> message -> Element message
boutonIcone =
    boutonIconePour Theme.commune


boutonIconePour : Theme.Contexte -> String -> String -> message -> Element message
boutonIconePour contexte description symbole message =
    Controles.actionPour contexte Icone [ Region.description description ] symbole (Just message)


boutonMenu : String -> Bool -> message -> Element message
boutonMenu =
    boutonMenuPour Theme.commune


boutonMenuPour : Theme.Contexte -> String -> Bool -> message -> Element message
boutonMenuPour contexte cible ouvert message =
    Controles.actionPour contexte
        Icone
        [ Region.description
            (if ouvert then
                "Fermer le menu"

             else
                "Ouvrir le menu"
            )
        , Accessibilite.controle cible
        , Accessibilite.depliement ouvert
        ]
        "☰"
        (Just message)
