module MrJam.Controles exposing (Intention(..), action, actionAvecContenu, actionAvecContenuPour, actionPour, icone, iconePour)

{-| Moteur interne des actions. Les applications utilisent les noms sémantiques
exposés par MrJam, Documents et Disposition, sans attributs décoratifs.
-}

import Element as UI exposing (Attribute, Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Saisie
import Element.Region as Region
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Saisie as Native
import MrJam.Theme as Theme exposing (Contexte)


type Intention
    = Principale
    | Secondaire
    | Destructive
    | Discrete
    | Selection Bool
    | Icone


action : Intention -> List (Attribute message) -> String -> Maybe message -> Element message
action =
    actionPour Theme.commune


actionPour : Contexte -> Intention -> List (Attribute message) -> String -> Maybe message -> Element message
actionPour contexte intention attributs libelle message =
    actionAvecContenuPour contexte
        intention
        attributs
        (UI.paragraph ([ UI.width UI.shrink, Police.center ] ++ Native.intrinseque) [ UI.text libelle ])
        message


{-| Le même moteur pour un libellé ou un pictogramme. Les noms accessibles sont
fournis par le composant sémantique qui l'appelle.
-}
actionAvecContenu : Intention -> List (Attribute message) -> Element message -> Maybe message -> Element message
actionAvecContenu =
    actionAvecContenuPour Theme.commune


actionAvecContenuPour : Contexte -> Intention -> List (Attribute message) -> Element message -> Maybe message -> Element message
actionAvecContenuPour contexte intention attributs contenu message =
    let
        couleurs =
            Theme.palette contexte

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
                    couleurs.controle

                Selection True ->
                    couleurs.accent

                Selection False ->
                    couleurs.controle

                _ ->
                    fond

        selection =
            case intention of
                Selection actif ->
                    [ Accessibilite.pressee actif ]

                _ ->
                    []
    in
    Saisie.button
        ([ UI.height (UI.minimum 34 UI.shrink)
         , UI.width (UI.minimum 34 UI.shrink)
         , UI.paddingXY 10 6
         , Police.size 14
         , Theme.police encre
         , Theme.fond fond
         , Bordure.rounded 5
         , Bordure.width 1
         , Theme.bordure bord
         , Theme.survol survol
         , Accessibilite.desactive (message == Nothing)
         ]
            ++ (if intention == Icone then
                    []

                else
                    Native.intrinseque
               )
            ++ (if message == Nothing then
                    [ Accessibilite.tabulation -1 ]

                else
                    []
               )
            ++ (case intention of
                    Icone ->
                        [ UI.width (UI.px 34), UI.height (UI.px 34), UI.padding 0, Police.size 20 ]

                    Discrete ->
                        [ Bordure.width 0, UI.paddingXY 6 4 ]

                    _ ->
                        [ Police.semiBold ]
               )
            ++ selection
            ++ attributs
        )
        { onPress = message
        , label = contenu
        }


{-| Une icône visible, un nom accessible et un titre au survol.
-}
icone : String -> String -> message -> Element message
icone =
    iconePour Theme.commune


iconePour : Contexte -> String -> String -> message -> Element message
iconePour contexte libelle symbole message =
    actionPour contexte
        Icone
        [ Region.description libelle
        , Accessibilite.infoBulle libelle
        ]
        symbole
        (Just message)
