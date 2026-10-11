module MrJam.Curseurs exposing (continu, format)

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
