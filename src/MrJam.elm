module MrJam exposing
    ( Niveau(..)
    , actions
    , avis
    , bouton
    , boutonDestructif
    , boutonEnCours
    , boutonInactif
    , boutonSecondaire
    , carte
    , caseACocher
    , champ
    , choix
    , lien
    , motDePasse
    , page
    , paragraphe
    , pile
    , recherche
    , section
    , separateur
    , sousTitre
    , texteSecondaire
    , zoneTexte
    )

{-| Composants prêts à l'emploi : le texte, l'état et l'action appartiennent
à l'application ; la présentation appartient à cette bibliothèque.

    bouton "Enregistrer" Enregistrer

    champ "Titre" modele.titre ModifierTitre

La galerie est une application de contrôle, pas un paquet publié sur le registre Elm.

-}

import Element exposing (Attribute, Color, Element, centerX, el, fill, height, htmlAttribute, maximum, minimum, padding, paddingXY, paragraph, px, shrink, spacing, text, width)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Element.Region as Region
import Html exposing (Html)
import Html.Attributes as Attributs
import MrJam.Identite as Identite
import MrJam.Theme as Theme exposing (couleurs)


bouton : String -> message -> Element message
bouton libelle message =
    action couleurs.accent couleurs.surface couleurs.accentSurvol [] libelle (Just message)


boutonSecondaire : String -> message -> Element message
boutonSecondaire libelle message =
    action couleurs.surface couleurs.encre couleurs.doux [] libelle (Just message)


boutonDestructif : String -> message -> Element message
boutonDestructif libelle message =
    action couleurs.danger couleurs.surface couleurs.dangerSurvol [] libelle (Just message)


boutonInactif : String -> Element message
boutonInactif libelle =
    action couleurs.doux
        couleurs.discret
        couleurs.doux
        [ htmlAttribute (Attributs.attribute "aria-disabled" "true")
        , htmlAttribute (Attributs.tabindex -1)
        ]
        libelle
        Nothing


boutonEnCours : String -> Element message
boutonEnCours libelle =
    action couleurs.doux
        couleurs.discret
        couleurs.doux
        [ htmlAttribute (Attributs.attribute "aria-disabled" "true")
        , htmlAttribute (Attributs.attribute "aria-busy" "true")
        , htmlAttribute (Attributs.tabindex -1)
        ]
        libelle
        Nothing


{-| Seule cette fonction interne connaît la décoration commune des actions.
-}
action : Color -> Color -> Color -> List (Attribute message) -> String -> Maybe message -> Element message
action fond encre survol attributs libelle message =
    Saisie.button
        (attributs
            ++ [ height (minimum 44 shrink)
               , width (maximum 360 shrink)
               , paddingXY 16 10
               , Police.size 16
               , Police.semiBold
               , Police.color encre
               , Fond.color fond
               , Bordure.rounded 12
               , Bordure.width 1
               , Bordure.color
                    (if fond == couleurs.surface then
                        couleurs.ligne

                     else
                        fond
                    )
               , Element.mouseOver [ Fond.color survol ]
               ]
        )
        { onPress = message, label = paragraph [ Police.center ] [ text libelle ] }


actions : List (Element message) -> Element message
actions =
    Element.wrappedRow [ width fill, spacing 10 ]


champ : String -> String -> (String -> message) -> Element message
champ =
    saisie Saisie.text


recherche : String -> String -> (String -> message) -> Element message
recherche =
    saisie Saisie.search


saisie : (List (Attribute message) -> { onChange : String -> message, text : String, placeholder : Maybe (Saisie.Placeholder message), label : Saisie.Label message } -> Element message) -> String -> String -> (String -> message) -> Element message
saisie construire libelle valeur modifier =
    construire Theme.champ
        { onChange = modifier
        , text = valeur
        , placeholder = Nothing
        , label = etiquette libelle
        }


motDePasse : String -> String -> (String -> message) -> Element message
motDePasse libelle valeur modifier =
    Saisie.currentPassword Theme.champ
        { onChange = modifier, text = valeur, placeholder = Nothing, label = etiquette libelle, show = False }


zoneTexte : String -> String -> (String -> message) -> Element message
zoneTexte libelle valeur modifier =
    Saisie.multiline (Theme.champ ++ [ height (minimum 120 shrink), htmlAttribute (Attributs.attribute "aria-label" libelle) ])
        { onChange = modifier, text = valeur, placeholder = Nothing, label = etiquette libelle, spellcheck = False }


etiquette : String -> Saisie.Label message
etiquette libelle =
    Saisie.labelAbove [ Police.size 14, Police.semiBold, Element.paddingEach { top = 0, right = 0, bottom = 6, left = 0 } ] (text libelle)


caseACocher : String -> Bool -> (Bool -> message) -> Element message
caseACocher libelle valeur modifier =
    Saisie.checkbox [ width fill, height (minimum 44 shrink), spacing 10 ]
        { onChange = modifier
        , icon = coche
        , checked = valeur
        , label = Saisie.labelRight [ width fill ] (paragraphe libelle)
        }


choix : String -> List ( valeur, String ) -> Maybe valeur -> (valeur -> message) -> Element message
choix libelle possibilites valeur modifier =
    Saisie.radio [ spacing 8, width fill, Region.description libelle ]
        { onChange = modifier
        , options = List.map (\( cle, nom ) -> Saisie.optionWith cle (option nom)) possibilites
        , selected = valeur
        , label = etiquette libelle
        }


coche : Bool -> Element message
coche valeur =
    el
        [ width (px 20)
        , height (px 20)
        , Bordure.rounded 4
        , Bordure.width 1
        , Bordure.color couleurs.accent
        , Fond.color
            (if valeur then
                couleurs.accent

             else
                couleurs.surface
            )
        , Police.color couleurs.surface
        , Police.size 16
        , htmlAttribute (Attributs.attribute "aria-hidden" "true")
        ]
        (el [ Element.centerX, Element.centerY ]
            (text
                (if valeur then
                    "✓"

                 else
                    ""
                )
            )
        )


option : String -> Saisie.OptionState -> Element message
option libelle etat =
    Element.row [ width fill, height (minimum 44 shrink), spacing 10 ]
        [ el [ width (px 20), height (px 20), Bordure.rounded 10, Bordure.width 1, Bordure.color couleurs.accent, htmlAttribute (Attributs.attribute "aria-hidden" "true") ]
            (if etat == Saisie.Selected then
                el [ width (px 10), height (px 10), Bordure.rounded 5, Fond.color couleurs.accent, Element.centerX, Element.centerY ] Element.none

             else
                Element.none
            )
        , paragraphe libelle
        ]


lien : String -> String -> Element message
lien libelle adresse =
    Element.link
        [ Police.color couleurs.accent, Police.underline, paddingXY 0 10, height (minimum 44 shrink) ]
        { url = adresse, label = paragraphe libelle }


pile : List (Element message) -> Element message
pile =
    Element.column Theme.disposition


carte : List (Element message) -> Element message
carte =
    Element.column Theme.panneau


sousTitre : String -> Element message
sousTitre libelle =
    paragraph [ Region.heading 2, Police.size 24, Police.bold ] [ text libelle ]


section : String -> List (Element message) -> Element message
section libelle contenu =
    carte (sousTitre libelle :: contenu)


paragraphe : String -> Element message
paragraphe contenu =
    paragraph [ width fill, spacing 6 ] [ text contenu ]


texteSecondaire : String -> Element message
texteSecondaire contenu =
    paragraph [ width fill, Police.size 14, Police.color couleurs.discret, spacing 5 ] [ text contenu ]


separateur : Element message
separateur =
    el [ width fill, height (px 1), Fond.color couleurs.ligne ] Element.none


type Niveau
    = Information
    | Succes
    | Avertissement
    | Erreur


avis : Niveau -> String -> Element message
avis niveau contenu =
    let
        ( prefixe, couleur ) =
            case niveau of
                Information ->
                    ( "Information", couleurs.encre )

                Succes ->
                    ( "Confirmation", couleurs.accent )

                Avertissement ->
                    ( "Attention", couleurs.danger )

                Erreur ->
                    ( "Erreur", couleurs.danger )
    in
    paragraph
        [ width fill, padding 14, spacing 6, Fond.color couleurs.doux, Police.color couleur, Bordure.rounded 12, Region.announce ]
        [ el [ Police.bold ] (text (prefixe ++ " : ")), text contenu ]


page : String -> List (Element message) -> Html message
page titre contenu =
    Element.layoutWith { options = [ Theme.focus ] }
        [ width fill
        , Fond.color couleurs.papier
        , Police.color couleurs.encre
        , Police.size 16
        , Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]
        ]
        (Element.column
            [ width (maximum 1120 fill), centerX, spacing 24, padding 16 ]
            [ Element.wrappedRow [ width fill, spacing 16, htmlAttribute (Attributs.attribute "role" "banner") ]
                [ Identite.logo, paragraph [ Region.heading 1, Police.size 32, Police.bold ] [ text titre ] ]
            , Element.column [ width fill, spacing 20, Region.mainContent ] contenu
            , Identite.piedDePage
            ]
        )
