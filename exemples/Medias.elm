module Medias exposing (main)

{-| Fixture des raccords réels, isolée du cours et de toute donnée pédagogique.
-}

import Browser
import Element as UI
import Html
import MrJam
import MrJam.Accessibilite as A
import MrJam.Mathematiques as Math
import MrJam.Videos as Video


type alias Modele =
    { source : Video.Source, video : Video.Modele }


type Message
    = Lecteur Video.Message
    | Changer String


source : Video.Source
source =
    { titre = "Démonstration", url = "https://player.vimeo.com/video/123?h=test", affiche = "./affiche.svg", debut = 37, externe = "https://vimeo.com/123" }


main : Program () Modele Message
main =
    Browser.element
        { init = \_ -> ( { source = source, video = Video.initial }, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }


update : Message -> Modele -> ( Modele, Cmd Message )
update message modele =
    case message of
        Lecteur evenement ->
            let
                ( video, commande ) =
                    Video.mettreAJour evenement modele.video
            in
            ( { modele | video = video }, Cmd.map Lecteur commande )

        Changer url ->
            ( { modele | source = { source | url = url }, video = Video.quitter modele.video }, Cmd.none )


view : Modele -> Html.Html Message
view modele =
    MrJam.pageAccessible "repere-medias"
        "Médias communs"
        [ UI.el [ A.identifiant "repere-medias", A.tabulation -1 ] (UI.map Lecteur (Video.vue modele.source modele.video))
        , MrJam.actions
            [ MrJam.boutonSecondaire "YouTube" (Changer "https://www.youtube-nocookie.com/embed/test")
            , MrJam.boutonSecondaire "Vimeo" (Changer source.url)
            , MrJam.boutonSecondaire "Source invalide" (Changer "https://exemple.invalid/video")
            ]
        , UI.el [ A.identifiant "texte-mathematique" ] (Math.texte "Un $x^2$ et du texte <b>échappé</b>.")
        , UI.el [ A.identifiant "formule-mathematique" ] (Math.formule "\\frac{1}{2}+\\sqrt{x}")
        , UI.el [ A.identifiant "formule-hostile" ] (Math.formule "\\href{javascript:alert(1)}{interdit}")
        ]
