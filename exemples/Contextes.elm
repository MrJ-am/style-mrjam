port module Contextes exposing (main)

import Browser
import Browser.Dom
import Element
import Element.Keyed as Keyed
import Html exposing (Html)
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Animations as Animations
import MrJam.Contexte as Contexte
import MrJam.Disposition as Disposition
import MrJam.Documents as Documents
import MrJam.Donnees as Donnees
import MrJam.Ecran as Ecran
import MrJam.Fenetres as Fenetres
import MrJam.Identite as Identite
import MrJam.Pictogrammes as Pictogrammes
import MrJam.Tableaux as Tableaux
import MrJam.Transitions as Transitions
import MrJam.Vitrine as Vitrine
import Time


port reductionAnimations : (Bool -> message) -> Sub message


type alias Modele =
    { largeur : Int, inverse : Bool, selection : String, valeur : String, chaine : Maybe String, entier : Maybe Int, confirmation : Maybe Bool, modale : Bool, fermetures : Int, courte : String, validations : Int, nombre : String, date : String, dateHeure : String, menu : Bool, aide : Transitions.Transition Bool, frames : Int }


type Message
    = Redimensionner Int
    | Inverser String
    | Selection String
    | Chaine String
    | Entier Int
    | Champ String
    | FocusRestitue (Result Browser.Dom.Error ())
    | Ouvrir
    | Confirmer Bool
    | FermerConfirmation
    | Fermer
    | Courte String
    | Valider
    | Nombre String
    | Date String
    | DateHeure String
    | Menu
    | Aide
    | Frame Time.Posix
    | ReductionAnimations Bool


actualiser : Message -> Modele -> ( Modele, Cmd Message )
actualiser message modele =
    case message of
        Redimensionner largeur ->
            ( { modele | largeur = largeur }, Cmd.none )

        Inverser nom ->
            ( { modele | inverse = not modele.inverse }, Accessibilite.restituerFocus ("action-" ++ nom) FocusRestitue )

        Selection valeur ->
            ( { modele | selection = valeur }, Cmd.none )

        Chaine valeur ->
            ( { modele | chaine = Just valeur }, Cmd.none )

        Entier valeur ->
            ( { modele | entier = Just valeur }, Cmd.none )

        Champ valeur ->
            ( { modele | valeur = valeur }, Cmd.none )

        FocusRestitue _ ->
            ( modele, Cmd.none )

        Confirmer comparaison ->
            ( { modele | confirmation = Just comparaison }, Cmd.none )

        FermerConfirmation ->
            ( { modele | confirmation = Nothing }, Cmd.none )

        Ouvrir ->
            ( { modele | modale = True }, Cmd.none )

        Fermer ->
            ( { modele | modale = False, fermetures = modele.fermetures + 1 }, Cmd.none )

        Courte valeur ->
            ( { modele | courte = valeur }, Cmd.none )

        Valider ->
            ( { modele | validations = modele.validations + 1 }, Cmd.none )

        Nombre valeur ->
            ( { modele | nombre = valeur }, Cmd.none )

        Date valeur ->
            ( { modele | date = valeur }, Cmd.none )

        DateHeure valeur ->
            ( { modele | dateHeure = valeur }, Cmd.none )

        Menu ->
            ( { modele | menu = not modele.menu }
            , if modele.menu then
                Documents.restituerFocusMenu FocusRestitue

              else
                Cmd.none
            )

        Aide ->
            ( { modele | aide = Transitions.aller 400 (not (Transitions.courant modele.aide)) modele.aide }, Cmd.none )

        Frame maintenant ->
            ( { modele | aide = Transitions.mettreAJour maintenant modele.aide, frames = modele.frames + 1 }, Cmd.none )

        ReductionAnimations preference ->
            ( { modele | aide = Transitions.reduire preference modele.aide }, Cmd.none )


vue : Modele -> Html Message
vue modele =
    let
        ui =
            MrJam.pour Contexte.commune

        vision =
            MrJam.pour (Contexte.pour "Vision")

        tableaux =
            Tableaux.pour (Contexte.pour "Vision")

        donnees =
            Donnees.pour (Contexte.pour "Vision")

        documents =
            Documents.pour (Contexte.pour "Vision")

        disposition =
            Disposition.pour (Contexte.pour "Vision")

        vitrine =
            Vitrine.pour (Contexte.pour "Vision") modele.largeur

        pictogrammes =
            Pictogrammes.pour (Contexte.pour "Vision")

        marque nom =
            let
                composants =
                    MrJam.pour (Contexte.pour nom)
            in
            composants.carte
                [ Disposition.boutonIdentifiePour (Contexte.pour nom) ("action-" ++ nom) nom (Just (Inverser nom))
                , composants.champ ("Champ " ++ nom) modele.valeur Champ
                ]
    in
    Fenetres.avecModale
        (if modele.modale then
            Just
                (Fenetres.modalePour (Contexte.pour "Vision")
                    "dialogue-contextes"
                    "Dialogue Vision"
                    Fermer
                    [ vision.champ "Champ du dialogue" modele.valeur Champ
                    , vision.bouton "Fermer" Fermer
                    ]
                )

         else
            Nothing
        )
    <|
        ui.page "Contextes explicites"
            [ Keyed.column [ Element.width Element.fill, Element.spacing 16 ]
                (List.map (\nom -> ( nom, marque nom ))
                    (if modele.inverse then
                        [ "Zoé", "Vision", "MrJ.am" ]

                     else
                        [ "MrJ.am", "Vision", "Zoé" ]
                    )
                )
            , Identite.marque "Vision"
            , ui.selecteur "Leçon" [ ( "une", "Première leçon" ), ( "deux", "Deuxième leçon" ) ] modele.selection Selection
            , ui.choix "Chaînes" [ ( "a", "Alpha" ), ( "b", "Bêta" ) ] modele.chaine Chaine
            , ui.choix "Entiers" [ ( 0, "Zéro" ), ( 1, "Un" ) ] modele.entier Entier
            , tableaux.tableau "Tableau Vision"
                [ Tableaux.colonne "Réponse" (\valeur -> tableaux.celluleEditable "Réponse dans le tableau" valeur Champ) ]
                [ modele.valeur ]
            , vision.champIdentifieSoumis
                { identifiant = "reponse-courte", libelle = "Réponse courte", aide = Just "aide-reponse", exemple = Just "Exemple", limite = Just 5 }
                modele.courte
                Courte
                Valider
            , Documents.repere "aide-reponse" (MrJam.paragraphe "Cinq caractères au maximum.")
            , MrJam.paragraphe ("Validations : " ++ String.fromInt modele.validations)
            , donnees.nombre "Nombre natif" modele.nombre Nombre
            , MrJam.paragraphe ("Valeur native : «" ++ modele.nombre ++ "»")
            , donnees.date "Date native" modele.date Date
            , donnees.dateHeure "Date et heure natives" modele.dateHeure DateHeure
            , documents.menu modele.menu Menu [ documents.action "Action du menu" Valider ]
            , pictogrammes.action Pictogrammes.Loupe "Loupe vectorielle" Valider
            , MrJam.pile (List.map (\valeur -> disposition.progression ("Avancement " ++ String.fromFloat valeur) valeur) [ -4, 0, 32.125, 100, 124 ])
            , vision.boutonSecondaire "Basculer l’aide" Aide
            , Documents.repere "etat-aide"
                (MrJam.paragraphe
                    (if Transitions.courant modele.aide then
                        "Aide ouverte"

                     else
                        "Aide fermée"
                    )
                )
            , Documents.repere "compteur-frames" (MrJam.paragraphe (String.fromInt modele.frames))
            , Documents.repere "preference-animation"
                (MrJam.paragraphe
                    (if modele.aide.reduite then
                        "Animations réduites"

                     else
                        "Animations ordinaires"
                    )
                )
            , Documents.repere "aide-animee"
                (Animations.deploiement 96 modele.aide (vision.carte [ MrJam.paragraphe "L’aide se déploie en conservant sa place. Les réponses et actions restent disponibles pendant la transition." ]))
            , Documents.repere "texte-litteral" (Donnees.lecture ("Deux  espaces\nUne autre ligne\n" ++ String.repeat 100 "sans-espace"))
            , vitrine.introduction "REPÈRE" "Titre de découverte" "Une introduction conserve sa marque et s’adapte à la largeur réelle."
            , vitrine.partie "COMPLÉMENT" "Un titre de section" [ vitrine.details "Complément natif" [ vision.champ "Réponse du complément" modele.valeur Champ ] ]
            , Disposition.boutonIdentifie "ouvrir-dialogue" "Ouvrir le dialogue" (Just Ouvrir)
            , vision.boutonSecondaire "Ouvrir une confirmation" (Confirmer False)
            , vision.boutonSecondaire "Comparer" (Confirmer True)
            , case modele.confirmation of
                Just comparaison ->
                    Disposition.dialoguePour (Contexte.pour "Vision")
                        (if comparaison then
                            "comparison"

                         else
                            "confirmation-contextes"
                        )
                        "Confirmation explicite"
                        "Rester ici"
                        FermerConfirmation
                        [ vision.champ "Valeur conservée" modele.valeur Champ ]

                Nothing ->
                    Element.none
            , MrJam.paragraphe ("Fermetures : " ++ String.fromInt modele.fermetures)
            ]


main : Program () Modele Message
main =
    Browser.element
        { init = \() -> ( { largeur = 0, inverse = False, selection = "une", valeur = "valeur", chaine = Nothing, entier = Just 0, confirmation = Nothing, modale = False, fermetures = 0, courte = "", validations = 0, nombre = "0", date = "2026-10-11", dateHeure = "2026-10-11T14:30", menu = False, aide = Transitions.initialiser False, frames = 0 }, Ecran.largeurInitiale Redimensionner )
        , update = actualiser
        , subscriptions = \modele -> Sub.batch [ Ecran.redimensionnements Redimensionner, Transitions.abonnement Frame modele.aide, reductionAnimations ReductionAnimations ]
        , view = vue
        }
