module Scientifique exposing (main)

{-| Fixture du document scientifique et de la soumission, sans données métier.
-}

import Browser
import Element as UI
import Html
import MrJam as M
import MrJam.Accessibilite as A
import MrJam.Mathematiques as Math


type alias Modele =
    { source : String, valeur : String, validations : Int, actions : Int }


type Message
    = Saisir String
    | Valider
    | Action


main : Program String Modele Message
main =
    Browser.element
        { init = \source -> ( { source = source, valeur = "", validations = 0, actions = 0 }, Cmd.none )
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
    , Cmd.none
    )


vue : Modele -> Html.Html Message
vue modele =
    M.page "Document scientifique"
        [ Math.document modele.source
        , M.soumissionDansChamps Valider
            (M.pile
                [ M.champ "Saisie" modele.valeur Saisir
                , M.bouton "Action indépendante" Action
                , UI.el [ A.identifiant "validations" ] (UI.text (String.fromInt modele.validations))
                , UI.el [ A.identifiant "actions" ] (UI.text (String.fromInt modele.actions))
                ]
            )
        ]
