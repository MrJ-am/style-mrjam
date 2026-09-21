module Galerie exposing (main)

import Browser
import Html exposing (Html)
import MrJam exposing (..)
import MrJam.Tableaux exposing (colonne, tableau)


type alias Modele =
    { titre : String, contenu : String, recherche : String, motDePasse : String, accord : Bool, choix : Maybe String, compteur : Int, notification : String }


type Message
    = ModifierTitre String
    | ModifierContenu String
    | Rechercher String
    | ModifierMotDePasse String
    | Accepter Bool
    | Choisir String
    | Enregistrer
    | Annuler
    | Archiver


initial : Modele
initial =
    { titre = "Une fiche", contenu = "  Une indentation à préserver.\nUne seconde ligne.", recherche = "", motDePasse = "", accord = False, choix = Just "toutes", compteur = 0, notification = "Aucune action effectuée." }


actualiser : Message -> Modele -> Modele
actualiser message modele =
    case message of
        ModifierTitre valeur ->
            { modele | titre = valeur }

        ModifierContenu valeur ->
            { modele | contenu = valeur }

        Rechercher valeur ->
            { modele | recherche = valeur }

        ModifierMotDePasse valeur ->
            { modele | motDePasse = valeur }

        Accepter valeur ->
            { modele | accord = valeur }

        Choisir valeur ->
            { modele | choix = Just valeur }

        Enregistrer ->
            { modele | compteur = modele.compteur + 1, notification = "Enregistrement demandé." }

        Annuler ->
            { modele | notification = "Annulation demandée." }

        Archiver ->
            { modele | notification = "Archivage demandé, aucune donnée réelle n’est modifiée." }


vue : Modele -> Html Message
vue modele =
    page "Style MrJ.am"
        [ avis Information "Galerie de contrôle. Les interfaces existantes ne sont pas encore migrées."
        , section "Actions"
            [ actions [ bouton "Enregistrer" Enregistrer, boutonSecondaire "Annuler" Annuler, boutonDestructif "Archiver" Archiver ]
            , actions [ boutonInactif "Indisponible", boutonEnCours "Enregistrement en cours…" ]
            , paragraphe ("Nombre d’enregistrements : " ++ String.fromInt modele.compteur)
            , avis Succes modele.notification
            ]
        , section "Saisie"
            [ champ "Titre" modele.titre ModifierTitre
            , zoneTexte "Contenu" modele.contenu ModifierContenu
            , recherche "Rechercher une fiche" modele.recherche Rechercher
            , motDePasse "Mot de passe" modele.motDePasse ModifierMotDePasse
            , caseACocher "Inclure les fiches archivées" modele.accord Accepter
            , choix "Correspondance des étiquettes" [ ( "toutes", "Toutes les étiquettes" ), ( "une", "Au moins une étiquette" ) ] modele.choix Choisir
            ]
        , section "Composants administratifs"
            [ identifiant "Identifiant de connexion" modele.titre ModifierTitre
            , nouveauMotDePasse "Nouveau mot de passe" modele.motDePasse ModifierMotDePasse
            , tableau "Valeurs de démonstration"
                [ colonne "Intitulé" (\valeur -> paragraphe valeur)
                , colonne "Action" (\_ -> boutonSecondaire "Consulter" Annuler)
                , colonne "Note" (\_ -> paragraphe "0")
                ]
                [ "Une ligne avec des accents : éèàœ", "Deuxième ligne" ]
            , tableau "Résultats vides" [ colonne "Valeur" paragraphe ] []
            ]
        , section "Informations"
            [ avis Avertissement "Une action destructive doit expliquer ses conséquences et être confirmée par l’application."
            , avis Erreur "La sauvegarde n’a pas abouti. Le texte saisi reste disponible."
            , texteSecondaire "Le logo et la signature sont réservés. Cette galerie n’accorde aucun droit d’utilisation."
            , separateur
            , lien "Revenir aux actions" "#"
            ]
        ]


main : Program () Modele Message
main =
    Browser.sandbox { init = initial, update = actualiser, view = vue }
