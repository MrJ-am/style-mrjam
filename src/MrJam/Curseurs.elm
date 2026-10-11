module MrJam.Curseurs exposing (continu, format, note)

{-| Curseur animé sans annonces à chaque frame. Commande native immédiate,
piste et poignée elm-ui ; aucune seconde horloge ni lecture automatique.
-}

import Char
import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Curseur as Native
import MrJam.Contexte exposing (Contexte)
import MrJam.Manipulation as Manipulation
import MrJam.Theme as Theme


continu : Contexte -> String -> String -> Float -> Float -> Float -> Float -> (Float -> message) -> Element message
continu contexte libelle unite minimum maximum pas valeur changer =
    let
        couleurs =
            Theme.palette contexte

        lecture =
            format 2 valeur ++ unite

        facteur =
            if maximum == minimum then
                0

            else
                clamp 0 1 ((valeur - minimum) / (maximum - minimum))

        avant =
            round (facteur * 10000)

        apres =
            10000 - avant

        vide proportion =
            UI.el [ UI.width (UI.fillPortion proportion) ] UI.none
    in
    UI.column [ UI.width UI.fill, UI.spacing 11 ]
        [ UI.row [ UI.width UI.fill, Police.size 12 ]
            [ UI.text libelle
            , UI.el [ UI.alignRight, Police.color couleurs.accent, Police.bold, Police.family [ Police.monospace ], Accessibilite.masque ] (UI.text lecture)
            ]
        , UI.el
            [ UI.width UI.fill
            , UI.height (UI.px 24)
            , UI.focused [ Bordure.shadow { offset = ( 0, 0 ), size = 3, blur = 0, color = couleurs.accent } ]
            , Bordure.rounded 4
            , UI.inFront
                (UI.el [ UI.width UI.fill, UI.height (UI.px 24) ]
                    (Native.natif ("slider-" ++ String.filter Char.isAlphaNum (String.toLower libelle)) libelle lecture minimum maximum pas valeur changer)
                )
            ]
            (UI.el
                [ UI.width UI.fill
                , UI.height (UI.px 4)
                , UI.centerY
                , Bordure.rounded 4
                , Theme.fond couleurs.ligne
                , UI.inFront
                    (UI.row [ UI.width UI.fill, UI.height (UI.px 24), UI.centerY ]
                        [ vide avant
                        , UI.el
                            [ UI.width (UI.px 17)
                            , UI.height (UI.px 17)
                            , UI.centerY
                            , Bordure.rounded 17
                            , Bordure.width 3
                            , Bordure.color couleurs.surface
                            , Theme.fond couleurs.accent
                            , Bordure.shadow { offset = ( 0, 1 ), size = 0, blur = 3, color = UI.rgba255 20 45 30 0.25 }
                            ]
                            UI.none
                        , vide apres
                        ]
                    )
                ]
                UI.none
            )
        ]


format : Int -> Float -> String
format chiffres valeur =
    let
        facteur =
            toFloat (10 ^ chiffres)
    in
    String.fromFloat (toFloat (round (valeur * facteur)) / facteur) |> String.replace "." ","


{-| Note facultative sur trois. L'aperçu de geste est distinct de la réponse :
un déplacement annulé ou vertical ne crée ni note ni interaction scientifique.
Le clavier natif et la validation de geste écrivent immédiatement la réponse.
-}
note : Contexte -> Maybe Float -> Maybe Float -> (Float -> message) -> (Maybe Float -> message) -> Element message
note contexte reponse apercu changer previsualiser =
    let
        couleurs =
            Theme.palette contexte

        valeur =
            clamp 0 3 (Maybe.withDefault (Maybe.withDefault 1.5 reponse) apercu)

        lecture =
            case reponse of
                Nothing ->
                    "Non noté"

                Just n ->
                    format 2 n ++ " sur 3"

        curseur =
            round (valeur / 3 * 10000)

        vide n =
            UI.el [ UI.width (UI.fillPortion (max 1 n)) ] UI.none

        sphere =
            UI.el
                [ UI.width (UI.px 32)
                , UI.height (UI.px 32)
                , UI.centerY
                , Bordure.rounded 32
                , Bordure.width 2
                , Bordure.color couleurs.accent
                , Theme.fond couleurs.surface
                , Manipulation.test "grade-knob"
                ]
                (UI.el [ UI.centerX, UI.centerY, Police.size 12, Police.bold ]
                    (UI.text
                        (if reponse == Nothing && apercu == Nothing then
                            "?"

                         else
                            format 2 valeur
                        )
                    )
                )
    in
    UI.row [ UI.width UI.fill, UI.spacing 8 ]
        [ UI.text "0"
        , UI.el
            ([ UI.width UI.fill
             , UI.height (UI.px 44)
             , Manipulation.test "grade-slider"
             , UI.focused [ Bordure.glow couleurs.accent 3 ]
             , UI.inFront
                (UI.el [ UI.width UI.fill, UI.height (UI.px 44) ]
                    (Native.note valeur lecture changer previsualiser)
                )
             ]
                ++ Native.noteRelative
            )
            (UI.el
                [ UI.width UI.fill
                , UI.height (UI.px 4)
                , UI.centerY
                , Theme.fond couleurs.ligne
                , Bordure.rounded 4
                , Manipulation.test "grade-rail"
                , UI.inFront
                    (UI.row [ UI.width UI.fill, UI.height (UI.px 44), UI.centerY ]
                        [ vide curseur, sphere, vide (10000 - curseur) ]
                    )
                ]
                UI.none
            )
        , UI.text "3"
        ]
