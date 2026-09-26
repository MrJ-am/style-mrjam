module Bibliotheque exposing (main)

import Browser
import Element
import Html exposing (Html)
import MrJam
import MrJam.Documents as Documents
import MrJam.Fenetres as Fenetres
import MrJam.Tableaux as Tableaux


type alias Modele =
    { menu : Bool, confirmation : Bool, recherche : String }


type Message
    = Menu
    | Confirmer
    | Fermer
    | Recherche String


actualiser : Message -> Modele -> Modele
actualiser message m =
    case message of
        Menu ->
            { m | menu = not m.menu }

        Confirmer ->
            { m | confirmation = True }

        Fermer ->
            { m | confirmation = False }

        Recherche texte ->
            { m | recherche = texte }


vue : Modele -> Html Message
vue m =
    Documents.espace "Bibliothèque"
        [ Documents.onglet True "Documents" Fermer
        , Documents.menu m.menu Menu [ MrJam.lien "Aide" "#aide" ]
        ]
        (if m.confirmation then
            Just (Fenetres.modale "confirmation" "Confirmer" Fermer [ MrJam.paragraphe "Les informations restent conservées.", MrJam.bouton "Continuer" Fermer ])

         else
            Nothing
        )
        [ Documents.entete "Documents" [ MrJam.bouton "Nouveau document" Confirmer ]
        , Documents.filtres [ MrJam.recherche "Recherche" m.recherche Recherche, Documents.action "Importer" Confirmer ]
        , Tableaux.tableau "Documents"
            [ Tableaux.principale "Titre" (\( titre, _ ) -> Documents.lien titre "#document")
            , Tableaux.mesure "Pages" (Tuple.second >> String.fromInt >> Element.text)
            , Tableaux.commandes (\( titre, _ ) -> Documents.actionSur "Archiver" titre Confirmer)
            ]
            [ ( "Guide de travail", 12 ), ( "Notes de lecture", 8 ), ( "Un titre très long qui reste lisible sur un petit écran sans déborder du tableau", 140 ) ]
        , Tableaux.tableau "Vide" [ Tableaux.colonne "Titre" Element.text ] []
        , MrJam.boutonSecondaire "Une action dont le libellé très long doit rester lisible même sur un écran étroit" Confirmer
        ]


main : Program () Modele Message
main =
    Browser.sandbox { init = { menu = False, confirmation = False, recherche = "" }, update = actualiser, view = vue }
