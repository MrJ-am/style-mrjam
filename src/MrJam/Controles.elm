module MrJam.Controles exposing (Intention(..), action)

{-| Moteur interne des actions. Les applications utilisent les noms sémantiques
exposés par MrJam, Documents et Disposition, sans attributs décoratifs.
-}

import Element as UI exposing (Attribute, Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Html.Attributes as A
import MrJam.Theme exposing (couleurs)


type Intention
    = Principale
    | Secondaire
    | Destructive
    | Discrete
    | Selection Bool
    | Icone


action : Intention -> List (Attribute message) -> String -> Maybe message -> Element message
action intention attributs libelle message =
    let
        ( fond, encre, survol ) =
            if message == Nothing then
                ( if intention == Discrete then
                    couleurs.surface

                  else
                    couleurs.doux
                , couleurs.discret
                , couleurs.doux
                )

            else
                case intention of
                    Principale ->
                        ( couleurs.accent, couleurs.surface, couleurs.accentSurvol )

                    Destructive ->
                        ( couleurs.danger, couleurs.surface, couleurs.dangerSurvol )

                    Discrete ->
                        ( couleurs.surface, couleurs.discret, couleurs.doux )

                    _ ->
                        ( couleurs.surface, couleurs.encre, couleurs.doux )

        bord =
            case intention of
                Secondaire ->
                    couleurs.ligne

                Selection True ->
                    couleurs.accent

                Selection False ->
                    couleurs.ligne

                _ ->
                    fond

        selection =
            case intention of
                Selection actif ->
                    [ UI.htmlAttribute
                        (A.attribute "aria-pressed"
                            (if actif then
                                "true"

                             else
                                "false"
                            )
                        )
                    ]

                _ ->
                    []
    in
    Saisie.button
        ([ UI.height (UI.minimum 34 UI.shrink)
         , UI.width (UI.minimum 34 UI.shrink)
         , UI.paddingXY 10 6
         , UI.htmlAttribute (A.style "width" "max-content")
         , UI.htmlAttribute (A.style "max-width" "100%")
         , UI.htmlAttribute (A.style "flex-basis" "auto")
         , Police.size 14
         , Police.color encre
         , Fond.color fond
         , Bordure.rounded 5
         , Bordure.width 1
         , Bordure.color bord
         , UI.mouseOver [ Fond.color survol ]
         , UI.htmlAttribute
            (A.attribute "aria-disabled"
                (if message == Nothing then
                    "true"

                 else
                    "false"
                )
            )
         ]
            ++ (if message == Nothing then
                    [ UI.htmlAttribute (A.tabindex -1) ]

                else
                    []
               )
            ++ (case intention of
                    Icone ->
                        [ UI.width (UI.px 34), UI.height (UI.px 34), UI.htmlAttribute (A.style "width" "34px"), UI.padding 0, Police.size 20 ]

                    Discrete ->
                        [ Bordure.width 0, UI.paddingXY 6 4 ]

                    _ ->
                        [ Police.semiBold ]
               )
            ++ selection
            ++ attributs
        )
        { onPress = message
        , label = UI.paragraph [ UI.htmlAttribute (A.style "width" "max-content"), UI.htmlAttribute (A.style "max-width" "100%"), Police.center ] [ UI.text libelle ]
        }
