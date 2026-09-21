module Galerie exposing (main)

import Browser
import Element as UI
import Html exposing (Html)
import Html.Attributes as Attributs
import MrJam exposing (..)


type alias Modele =
    { titre : String, contenu : String, recherche : String, motDePasse : String, accord : Bool, choix : Maybe String, compteur : Int, notification : String, reponse : String, choixRiche : Maybe String, aideOuverte : Bool }


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
    | ModifierReponse String
    | ChoisirRiche String
    | DevoilerAide


initial : Modele
initial =
    { titre = "Une fiche", contenu = "  Une indentation à préserver.\nUne seconde ligne.", recherche = "", motDePasse = "", accord = False, choix = Just "toutes", compteur = 0, notification = "Aucune action effectuée.", reponse = "", choixRiche = Nothing, aideOuverte = False }


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

        ModifierReponse valeur ->
            { modele | reponse = valeur }

        ChoisirRiche valeur ->
            { modele | choixRiche = Just valeur }

        DevoilerAide ->
            { modele | aideOuverte = not modele.aideOuverte }


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
        , section "Contrôles identifiés et contenu riche"
            [ champIdentifie
                { identifiant = "reponse-controle", libelle = "Réponse de contrôle", aide = Just "description-reponse", exemple = Just "Deux témoins distincts", limite = Just 500 }
                modele.reponse
                ModifierReponse
            , UI.el [ UI.htmlAttribute (Attributs.id "description-reponse") ] (texteSecondaire "Au plus 500 caractères ; les espaces sont conservés.")
            , choixRiches "Choix à contenu riche"
                [ ( "distincts", UI.paragraph [ UI.width UI.fill ] [ UI.text "Choisir ", UI.html (Html.em [] [ Html.text "deux témoins distincts" ]) ] )
                , ( "identiques", paragraphe "Choisir un même témoin pour les deux valeurs, avec un libellé suffisamment long pour tester les petits écrans." )
                ]
                modele.choixRiche
                ChoisirRiche
            , boutonDevoiler "aide-controle" "Afficher l’aide" modele.aideOuverte DevoilerAide
            , if modele.aideOuverte then
                UI.el [ UI.htmlAttribute (Attributs.id "aide-controle") ] (paragraphe "Chaque témoin possède son nom.")

              else
                UI.none
            , actions [ lienActif True "Étape courante" "#courante", lienActif False "Étape suivante" "#suivante", lienExterne "Source de contrôle" "https://example.org/" ]
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
