module MrJam exposing
    ( ChampIdentifie
    , Interface
    , Niveau(..)
    , actions
    , avis
    , bouton
    , boutonDestructif
    , boutonDevoiler
    , boutonEnCours
    , boutonInactif
    , boutonSecondaire
    , carte
    , caseACocher
    , champ
    , champIdentifie
    , champIdentifieSoumis
    , choix
    , choixRiches
    , emphase
    , identifiant
    , lien
    , lienActif
    , lienExterne
    , litteral
    , mapper
    , motDePasse
    , nouveauMotDePasse
    , page
    , pageAccessible
    , paragraphe
    , pile
    , pour
    , recherche
    , section
    , selecteur
    , separateur
    , soumissionDansChamps
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

import Element exposing (Attribute, Element, centerX, el, fill, height, maximum, minimum, padding, paddingXY, paragraph, px, shrink, spacing, text, width)
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Element.Region as Region
import Html exposing (Html)
import MrJam.Accessibilite as Semantique
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Saisie as Native
import MrJam.Adaptateurs.Selection as Selection
import MrJam.Adaptateurs.Texte as Texte
import MrJam.Controles as Controles exposing (Intention(..))
import MrJam.Identite as Identite
import MrJam.Theme as Theme exposing (Contexte)


{-| Formulaire sans détourner Entrée sur ses commandes de navigation.
-}
soumissionDansChamps : message -> Element message -> Element message
soumissionDansChamps message contenu =
    el [ width fill, Native.soumettreChamps message ] contenu


{-| Les composants d’une vue partagent cette intention de marque. Les variantes
sans contexte utilisent explicitement la marque commune ; pas de cascade implicite.
-}
type alias Interface valeur message =
    { bouton : String -> message -> Element message
    , boutonSecondaire : String -> message -> Element message
    , boutonDestructif : String -> message -> Element message
    , boutonDevoiler : String -> String -> Bool -> message -> Element message
    , boutonInactif : String -> Element message
    , boutonEnCours : String -> Element message
    , selecteur : String -> List ( String, String ) -> String -> (String -> message) -> Element message
    , champ : String -> String -> (String -> message) -> Element message
    , champIdentifie : ChampIdentifie -> String -> (String -> message) -> Element message
    , champIdentifieSoumis : ChampIdentifie -> String -> (String -> message) -> message -> Element message
    , recherche : String -> String -> (String -> message) -> Element message
    , motDePasse : String -> String -> (String -> message) -> Element message
    , identifiant : String -> String -> (String -> message) -> Element message
    , nouveauMotDePasse : String -> String -> (String -> message) -> Element message
    , zoneTexte : String -> String -> (String -> message) -> Element message
    , caseACocher : String -> Bool -> (Bool -> message) -> Element message
    , choix : String -> List ( valeur, String ) -> Maybe valeur -> (valeur -> message) -> Element message
    , choixRiches : String -> List ( valeur, Element message ) -> Maybe valeur -> (valeur -> message) -> Element message
    , lien : String -> String -> Element message
    , lienActif : Bool -> String -> String -> Element message
    , lienExterne : String -> String -> Element message
    , carte : List (Element message) -> Element message
    , section : String -> List (Element message) -> Element message
    , texteSecondaire : String -> Element message
    , separateur : Element message
    , avis : Niveau -> String -> Element message
    , page : String -> List (Element message) -> Html message
    }


pour : Contexte -> Interface valeur message
pour contexte =
    { bouton = boutonPour contexte
    , boutonSecondaire = boutonSecondairePour contexte
    , boutonDestructif = boutonDestructifPour contexte
    , boutonDevoiler = boutonDevoilerPour contexte
    , boutonInactif = boutonInactifPour contexte
    , boutonEnCours = boutonEnCoursPour contexte
    , selecteur = selecteurPour contexte
    , champ = champPour contexte
    , champIdentifie = champIdentifiePour contexte
    , champIdentifieSoumis = champIdentifieSoumisPour contexte
    , recherche = recherchePour contexte
    , motDePasse = motDePassePour contexte
    , identifiant = identifiantPour contexte
    , nouveauMotDePasse = nouveauMotDePassePour contexte
    , zoneTexte = zoneTextePour contexte
    , caseACocher = caseACocherPour contexte
    , choix = choixPour contexte
    , choixRiches = choixRichesPour contexte
    , lien = lienPour contexte
    , lienActif = lienActifPour contexte
    , lienExterne = lienExternePour contexte
    , carte = cartePour contexte
    , section = sectionPour contexte
    , texteSecondaire = texteSecondairePour contexte
    , separateur = separateurPour contexte
    , avis = avisPour contexte
    , page = pagePour contexte
    }


{-| Raccorder un composant applicatif à ses messages parents.
-}
mapper : (a -> b) -> Element a -> Element b
mapper =
    Element.map


bouton : String -> message -> Element message
bouton =
    boutonPour Theme.commune


boutonPour : Contexte -> String -> message -> Element message
boutonPour contexte libelle message =
    Controles.actionPour contexte Principale [] libelle (Just message)


boutonSecondaire : String -> message -> Element message
boutonSecondaire =
    boutonSecondairePour Theme.commune


boutonSecondairePour : Contexte -> String -> message -> Element message
boutonSecondairePour contexte libelle message =
    Controles.actionPour contexte Secondaire [] libelle (Just message)


{-| Action de dévoilement : identifiant du contenu, libellé et état, sans décoration locale.
Le contenu et sa présence dans le DOM restent gérés par l'application.
-}
boutonDevoiler : String -> String -> Bool -> message -> Element message
boutonDevoiler =
    boutonDevoilerPour Theme.commune


boutonDevoilerPour : Contexte -> String -> String -> Bool -> message -> Element message
boutonDevoilerPour contexte cible libelle ouvert message =
    Controles.actionPour contexte
        Secondaire
        [ Accessibilite.controle cible, Accessibilite.depliement ouvert ]
        libelle
        (Just message)


boutonDestructif : String -> message -> Element message
boutonDestructif =
    boutonDestructifPour Theme.commune


boutonDestructifPour : Contexte -> String -> message -> Element message
boutonDestructifPour contexte libelle message =
    Controles.actionPour contexte Destructive [] libelle (Just message)


boutonInactif : String -> Element message
boutonInactif =
    boutonInactifPour Theme.commune


boutonInactifPour : Contexte -> String -> Element message
boutonInactifPour contexte libelle =
    Controles.actionPour contexte
        Secondaire
        [ Accessibilite.inactif
        , Accessibilite.tabulation -1
        ]
        libelle
        Nothing


boutonEnCours : String -> Element message
boutonEnCours =
    boutonEnCoursPour Theme.commune


boutonEnCoursPour : Contexte -> String -> Element message
boutonEnCoursPour contexte libelle =
    Controles.actionPour contexte
        Secondaire
        [ Accessibilite.inactif
        , Accessibilite.occupe
        , Accessibilite.tabulation -1
        ]
        libelle
        Nothing


actions : List (Element message) -> Element message
actions =
    Element.wrappedRow [ width fill, spacing 8 ]


champ : String -> String -> (String -> message) -> Element message
champ =
    champPour Theme.commune


champPour : Contexte -> String -> String -> (String -> message) -> Element message
champPour contexte =
    saisie contexte Saisie.text


{-| Contrats sémantiques d'un champ auquel un pont navigateur doit pouvoir rendre
le focus. `aide` désigne l'identifiant d'une description existante ; `exemple`
est une indication de saisie, jamais un remplacement du libellé accessible.
-}
type alias ChampIdentifie =
    { identifiant : String
    , libelle : String
    , aide : Maybe String
    , exemple : Maybe String
    , limite : Maybe Int
    }


champIdentifie : ChampIdentifie -> String -> (String -> message) -> Element message
champIdentifie =
    champIdentifiePour Theme.commune


champIdentifiePour : Contexte -> ChampIdentifie -> String -> (String -> message) -> Element message
champIdentifiePour contexte =
    champIdentifieAvec contexte []


{-| Variante sémantique pour une réponse courte : Entrée émet le message de
validation sans imposer de formulaire HTML dans l'application.
-}
champIdentifieSoumis : ChampIdentifie -> String -> (String -> message) -> message -> Element message
champIdentifieSoumis =
    champIdentifieSoumisPour Theme.commune


champIdentifieSoumisPour : Contexte -> ChampIdentifie -> String -> (String -> message) -> message -> Element message
champIdentifieSoumisPour contexte contrat valeur modifier soumettre =
    champIdentifieAvec contexte [ Native.soumettre soumettre ] contrat valeur modifier


champIdentifieAvec : Contexte -> List (Attribute message) -> ChampIdentifie -> String -> (String -> message) -> Element message
champIdentifieAvec contexte attributs contrat valeur modifier =
    Saisie.text
        (Theme.champPour contexte
            ++ attributs
            ++ Native.identifie contrat
        )
        { onChange = modifier
        , text = valeur
        , placeholder = Nothing
        , label = etiquette contrat.libelle
        }


recherche : String -> String -> (String -> message) -> Element message
recherche =
    recherchePour Theme.commune


recherchePour : Contexte -> String -> String -> (String -> message) -> Element message
recherchePour contexte =
    saisie contexte Saisie.search


saisie : Contexte -> (List (Attribute message) -> { onChange : String -> message, text : String, placeholder : Maybe (Saisie.Placeholder message), label : Saisie.Label message } -> Element message) -> String -> String -> (String -> message) -> Element message
saisie contexte construire libelle valeur modifier =
    construire (Theme.champPour contexte)
        { onChange = modifier
        , text = valeur
        , placeholder = Nothing
        , label = etiquette libelle
        }


motDePasse : String -> String -> (String -> message) -> Element message
motDePasse =
    motDePassePour Theme.commune


motDePassePour : Contexte -> String -> String -> (String -> message) -> Element message
motDePassePour contexte libelle valeur modifier =
    Saisie.currentPassword (Theme.champPour contexte)
        { onChange = modifier, text = valeur, placeholder = Nothing, label = etiquette libelle, show = False }


{-| L’identifiant de connexion conserve l’autocomplétion adaptée.
-}
identifiant : String -> String -> (String -> message) -> Element message
identifiant =
    identifiantPour Theme.commune


identifiantPour : Contexte -> String -> String -> (String -> message) -> Element message
identifiantPour contexte =
    saisie contexte Saisie.username


{-| Pour la création ou le remplacement du mot de passe, jamais la connexion.
La confirmation et les contraintes de sécurité restent dans l’application.
-}
nouveauMotDePasse : String -> String -> (String -> message) -> Element message
nouveauMotDePasse =
    nouveauMotDePassePour Theme.commune


nouveauMotDePassePour : Contexte -> String -> String -> (String -> message) -> Element message
nouveauMotDePassePour contexte libelle valeur modifier =
    Saisie.newPassword (Theme.champPour contexte)
        { onChange = modifier, text = valeur, placeholder = Nothing, label = etiquette libelle, show = False }


zoneTexte : String -> String -> (String -> message) -> Element message
zoneTexte =
    zoneTextePour Theme.commune


zoneTextePour : Contexte -> String -> String -> (String -> message) -> Element message
zoneTextePour contexte libelle valeur modifier =
    Saisie.multiline (Theme.champPour contexte ++ [ height (minimum 120 shrink), Region.description libelle ])
        { onChange = modifier, text = valeur, placeholder = Nothing, label = etiquette libelle, spellcheck = False }


etiquette : String -> Saisie.Label message
etiquette libelle =
    Saisie.labelAbove [ Police.size 14, Police.semiBold, Element.paddingEach { top = 0, right = 0, bottom = 6, left = 0 } ] (text libelle)


caseACocher : String -> Bool -> (Bool -> message) -> Element message
caseACocher =
    caseACocherPour Theme.commune


caseACocherPour : Contexte -> String -> Bool -> (Bool -> message) -> Element message
caseACocherPour contexte libelle valeur modifier =
    Saisie.checkbox [ width fill, height (minimum 44 shrink), spacing 10 ]
        { onChange = modifier
        , icon = coche contexte
        , checked = valeur
        , label = Saisie.labelRight [ width fill ] (paragraphe libelle)
        }


choix : String -> List ( valeur, String ) -> Maybe valeur -> (valeur -> message) -> Element message
choix =
    choixPour Theme.commune


choixPour : Contexte -> String -> List ( valeur, String ) -> Maybe valeur -> (valeur -> message) -> Element message
choixPour contexte libelle possibilites valeur modifier =
    choixRichesPour contexte libelle (List.map (\( cle, nom ) -> ( cle, paragraphe nom )) possibilites) valeur modifier


{-| Le libellé peut inclure du texte structuré ou un rendu spécialisé tel que
KaTeX. Il ne doit pas contenir d'autre contrôle interactif. La bibliothèque
n'interprète pas le contenu et ne connaît aucune règle de correction.
-}
choixRiches : String -> List ( valeur, Element message ) -> Maybe valeur -> (valeur -> message) -> Element message
choixRiches =
    choixRichesPour Theme.commune


choixRichesPour : Contexte -> String -> List ( valeur, Element message ) -> Maybe valeur -> (valeur -> message) -> Element message
choixRichesPour contexte libelle possibilites valeur modifier =
    Saisie.radio [ spacing 8, width fill, Accessibilite.nomGroupe libelle ]
        { onChange = modifier
        , options = List.map (\( cle, contenu ) -> Saisie.optionWith cle (optionRiche contexte contenu)) possibilites
        , selected = valeur
        , label = etiquette libelle
        }


{-| Sélection compacte : le cadre et le libellé utilisent elm-ui ; le contrôle
natif borné fournit le clavier et la sémantique absents de son API publique.
-}
selecteur : String -> List ( String, String ) -> String -> (String -> message) -> Element message
selecteur =
    selecteurPour Theme.commune


selecteurPour : Contexte -> String -> List ( String, String ) -> String -> (String -> message) -> Element message
selecteurPour contexte libelle possibilites valeur modifier =
    Element.column [ width fill, spacing 6 ]
        [ el [ Police.size 14, Police.semiBold ] (text libelle)
        , el (Theme.champPour contexte) (Selection.native libelle possibilites valeur modifier)
        ]


coche : Contexte -> Bool -> Element message
coche contexte valeur =
    let
        couleurs =
            Theme.palette contexte
    in
    el
        [ width (px 20)
        , height (px 20)
        , Bordure.rounded 4
        , Bordure.width 1
        , Theme.bordure couleurs.accent
        , Theme.fond
            (if valeur then
                couleurs.accent

             else
                couleurs.surface
            )
        , Theme.police couleurs.surface
        , Police.size 16
        , Accessibilite.masque
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
    optionRiche Theme.commune (paragraphe libelle) etat


optionRiche : Contexte -> Element message -> Saisie.OptionState -> Element message
optionRiche contexte contenu etat =
    let
        couleurs =
            Theme.palette contexte
    in
    Element.row [ width fill, height (minimum 44 shrink), spacing 10 ]
        [ el [ width (px 20), height (px 20), Bordure.rounded 10, Bordure.width 1, Theme.bordure couleurs.accent, Accessibilite.masque ]
            (if etat == Saisie.Selected then
                el [ width (px 10), height (px 10), Bordure.rounded 5, Theme.fond couleurs.accent, Element.centerX, Element.centerY ] Element.none

             else
                Element.none
            )
        , contenu
        ]


lien : String -> String -> Element message
lien =
    lienPour Theme.commune


lienPour : Contexte -> String -> String -> Element message
lienPour contexte libelle adresse =
    navigationLien contexte [] libelle adresse


lienActif : Bool -> String -> String -> Element message
lienActif =
    lienActifPour Theme.commune


lienActifPour : Contexte -> Bool -> String -> String -> Element message
lienActifPour contexte actif libelle adresse =
    navigationLien contexte
        (if actif then
            [ Accessibilite.pageCourante, Police.semiBold ]

         else
            []
        )
        libelle
        adresse


lienExterne : String -> String -> Element message
lienExterne =
    lienExternePour Theme.commune


lienExternePour : Contexte -> String -> String -> Element message
lienExternePour contexte libelle adresse =
    let
        couleurs =
            Theme.palette contexte
    in
    Element.newTabLink
        [ Region.description (libelle ++ " — nouvel onglet")
        , Theme.police couleurs.accent
        , Police.underline
        , paddingXY 0 10
        , height (minimum 44 shrink)
        ]
        { url = adresse, label = paragraphe libelle }


navigationLien : Contexte -> List (Attribute message) -> String -> String -> Element message
navigationLien contexte attributs libelle adresse =
    let
        couleurs =
            Theme.palette contexte
    in
    Element.link
        (attributs ++ [ Theme.police couleurs.accent, Police.underline, paddingXY 0 10, height (minimum 44 shrink) ])
        { url = adresse, label = paragraphe libelle }


pile : List (Element message) -> Element message
pile =
    Element.column Theme.disposition


carte : List (Element message) -> Element message
carte =
    cartePour Theme.commune


cartePour : Contexte -> List (Element message) -> Element message
cartePour contexte =
    Element.column (Theme.panneauPour contexte)


sousTitre : String -> Element message
sousTitre libelle =
    paragraph [ Region.heading 2, Police.size 24, Police.bold ] [ text libelle ]


section : String -> List (Element message) -> Element message
section =
    sectionPour Theme.commune


sectionPour : Contexte -> String -> List (Element message) -> Element message
sectionPour contexte libelle contenu =
    cartePour contexte (sousTitre libelle :: contenu)


{-| Emphase sémantique ; la présentation reste Font.italic du socle.
-}
emphase : String -> Element message
emphase contenu =
    el [ Police.italic ] (Texte.emphase contenu)


{-| Texte littéral : espaces/retours conservés, texte long replié, aucune
interprétation HTML. Police et taille héritées de la composition appelante.
-}
litteral : String -> Element message
litteral contenu =
    paragraph ([ width fill ] ++ Texte.litteral) [ Texte.texte contenu ]


paragraphe : String -> Element message
paragraphe contenu =
    paragraph [ width fill, spacing 6 ] [ text contenu ]


texteSecondaire : String -> Element message
texteSecondaire =
    texteSecondairePour Theme.commune


texteSecondairePour : Contexte -> String -> Element message
texteSecondairePour contexte contenu =
    let
        couleurs =
            Theme.palette contexte
    in
    paragraph [ width fill, Police.size 14, Theme.police couleurs.discret, spacing 5 ] [ text contenu ]


separateur : Element message
separateur =
    separateurPour Theme.commune


separateurPour : Contexte -> Element message
separateurPour contexte =
    let
        couleurs =
            Theme.palette contexte
    in
    el [ width fill, height (px 1), Theme.fond couleurs.ligne ] Element.none


type Niveau
    = Information
    | Succes
    | Avertissement
    | Erreur


avis : Niveau -> String -> Element message
avis =
    avisPour Theme.commune


avisPour : Contexte -> Niveau -> String -> Element message
avisPour contexte niveau contenu =
    let
        couleurs =
            Theme.palette contexte

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
        [ width fill, padding 14, spacing 6, Theme.fond couleurs.doux, Theme.police couleur, Bordure.rounded 12, Region.announce ]
        [ el [ Police.bold ] (text (prefixe ++ " : ")), text contenu ]


page : String -> List (Element message) -> Html message
page =
    pagePour Theme.commune


pageAccessible : String -> String -> List (Element message) -> Html message
pageAccessible cible =
    pageAvecPour Theme.commune [ Semantique.evitement cible ]


pagePour : Contexte -> String -> List (Element message) -> Html message
pagePour contexte =
    pageAvecPour contexte []


pageAvecPour : Contexte -> List (Attribute message) -> String -> List (Element message) -> Html message
pageAvecPour contexte attributs titre contenu =
    let
        couleurs =
            Theme.palette contexte
    in
    Element.layoutWith { options = [ Theme.focusPour contexte ] }
        (attributs
            ++ Theme.ecran
            ++ [ width fill
               , Theme.fond couleurs.papier
               , Theme.police couleurs.encre
               , Police.size 16
               , Theme.typographie
               ]
        )
        (Element.column
            [ width (maximum 1120 fill), centerX, spacing 24, padding 16 ]
            [ Element.wrappedRow [ width fill, spacing 16, Accessibilite.banniere ]
                [ Identite.logo, paragraph [ Region.heading 1, Police.size 32, Police.bold ] [ text titre ] ]
            , Element.column [ width fill, spacing 20, Region.mainContent ] contenu
            , Identite.piedDePagePour contexte
            ]
        )
