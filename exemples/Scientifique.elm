module Scientifique exposing (main)

{-| Fixture du document scientifique et de la soumission, sans données métier.
-}

import Browser
import Element as UI
import Html
import MrJam as M
import MrJam.Accessibilite as A
import MrJam.Contexte as Contexte
import MrJam.Curseurs as Curseurs
import MrJam.Mathematiques as Math


type alias Modele =
    { source : String, valeur : String, validations : Int, actions : Int, note : Maybe Float, apercu : Maybe Float, notes : Int }


type Message
    = Saisir String
    | Valider
    | Action
    | Noter Float
    | Apercu (Maybe Float)


main : Program String Modele Message
main =
    Browser.element
        { init = \source -> ( { source = source, valeur = "", validations = 0, actions = 0, note = Nothing, apercu = Nothing, notes = 0 }, Cmd.none )
        , view = vue
        , update = actualiser
        , subscriptions = \_ -> Sub.none
        }


actualiser : Message -> Modele -> ( Modele, Cmd Message )
actualiser message modele =
    ( case message of
        Saisir valeur ->
            { modele | valeur = valeur }

        Valider ->
            { modele | validations = modele.validations + 1 }

        Action ->
            { modele | actions = modele.actions + 1 }

        Noter valeur ->
            if modele.note == Just valeur then
                modele

            else
                { modele | note = Just valeur, notes = modele.notes + 1 }

        Apercu valeur ->
            { modele | apercu = valeur }
    , Cmd.none
    )


vue : Modele -> Html.Html Message
vue modele =
    M.page "Document scientifique"
        [ Math.document modele.source
        , Curseurs.note (Contexte.pour "Matheval") modele.note modele.apercu Noter Apercu
        , UI.el [ A.identifiant "grade-help" ] (UI.text "Note facultative")
        , UI.el [ A.identifiant "note-reponse" ] (UI.text (Maybe.map String.fromFloat modele.note |> Maybe.withDefault "absente"))
        , UI.el [ A.identifiant "note-evenements" ] (UI.text (String.fromInt modele.notes))
        , M.soumissionDansChamps Valider
            (M.pile
                [ M.champ "Saisie" modele.valeur Saisir
                , M.bouton "Action indépendante" Action
                , UI.el [ A.identifiant "validations" ] (UI.text (String.fromInt modele.validations))
                , UI.el [ A.identifiant "actions" ] (UI.text (String.fromInt modele.actions))
                ]
            )
        ]
