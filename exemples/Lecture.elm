module Lecture exposing (main)

import Browser
import Element as UI
import Html
import MrJam
import MrJam.Accessibilite as A
import MrJam.Contexte as Contexte
import MrJam.Curseurs as Notes
import MrJam.Ecran as Ecran
import MrJam.Lectures as Lectures
import MrJam.Mathematiques as Math
import MrJam.Transitions as T
import Time


type alias Modele =
    { ecran : Ecran.Dimensions, ouvert : Bool, transition : T.Transition Bool, note : Maybe Float, apercu : Maybe Float, texte : Int }


type Message
    = Ouvrir
    | Fermer
    | Ecran Ecran.Dimensions
    | Frame Time.Posix
    | Noter Float
    | Apercu (Maybe Float)
    | AutreTexte
    | SansEffet


main : Program Bool Modele Message
main =
    Browser.element
        { init = \reduite -> ( { ecran = { largeur = 390, hauteur = 844 }, ouvert = False, transition = T.initialiser False |> T.reduire reduite, note = Nothing, apercu = Nothing, texte = 0 }, Ecran.initiale Ecran )
        , update = actualiser
        , view = vue
        , subscriptions = \m -> Sub.batch [ Ecran.changements Ecran, T.abonnement Frame m.transition ]
        }


actualiser : Message -> Modele -> ( Modele, Cmd Message )
actualiser message m =
    if message == AutreTexte then
        ( { m | texte = m.texte + 1 }, Lectures.reinitialiser (\_ -> SansEffet) )

    else
        ( case message of
            Ouvrir ->
                { m | ouvert = True, transition = T.aller 220 True m.transition }

            Fermer ->
                { m | ouvert = False, transition = T.aller 0 False m.transition, apercu = Nothing }

            Ecran ecran ->
                { m | ecran = ecran }

            Frame maintenant ->
                { m | transition = T.mettreAJour maintenant m.transition }

            Noter n ->
                { m | note = Just n }

            Apercu n ->
                { m | apercu = n }

            AutreTexte ->
                m

            SansEffet ->
                m
        , Cmd.none
        )


vue : Modele -> Html.Html Message
vue m =
    let
        marque =
            Contexte.pour "Matheval"

        composants =
            MrJam.pour marque
    in
    MrJam.page "Lecture"
        [ UI.el [ A.identifiant "ouvrir-lecture" ] (composants.bouton "Lire" Ouvrir)
        , if m.ouvert then
            Lectures.vue marque
                m.ecran
                100
                m.transition
                { identifiant = "lecture-" ++ String.fromInt m.texte
                , titre = "Rédaction de contrôle"
                , fermer = Fermer
                , actions = [ composants.boutonSecondaire "Autre texte" AutreTexte, composants.boutonSecondaire "Fermer la rédaction" Fermer ]
                , contenu = Math.document (String.join "\n" (List.repeat 60 ("  Étape " ++ String.fromInt m.texte ++ " avec $x^2$ et sa conséquence.")))
                , commandes =
                    [ Notes.note marque m.note m.apercu Noter Apercu
                    , UI.el [ A.identifiant "grade-help" ] (UI.text "Note facultative")
                    , UI.el [ A.identifiant "lecture-note" ] (UI.text (Maybe.map String.fromFloat m.note |> Maybe.withDefault "absente"))
                    , composants.boutonSecondaire "Fermer" Fermer
                    ]
                }

          else
            UI.none
        ]
