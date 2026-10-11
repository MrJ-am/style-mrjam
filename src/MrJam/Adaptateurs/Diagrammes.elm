module MrJam.Adaptateurs.Diagrammes exposing (carte, geometrie, legende, limite, plan)

{-| Graphiques scientifiques vectoriels absents d'elm-ui ; coordonnées et courbes
neutres, aucun calcul scientifique déplacé ici. Événement clavier borné aux
flèches/Maj, styles techniques fixes pour pointer/tactile/chevauchement.
-}

import Element exposing (Attribute, Element)
import Html.Attributes as H
import Html.Events as Events
import Json.Decode as D
import MrJam.Diagrammes.Types exposing (Courbe, Plan, Tetrades)
import Svg
import Svg.Attributes as A


clavier : (Float -> Float -> message) -> D.Decoder ( message, Bool )
clavier changer =
    D.map2 Tuple.pair (D.field "key" D.string) (D.field "shiftKey" D.bool)
        |> D.andThen
            (\( touche, rapide ) ->
                let
                    pas =
                        if rapide then
                            0.01

                        else
                            0.001
                in
                case touche of
                    "ArrowUp" ->
                        D.succeed ( changer pas 0, True )

                    "ArrowDown" ->
                        D.succeed ( changer -pas 0, True )

                    "ArrowRight" ->
                        D.succeed ( changer 0 pas, True )

                    "ArrowLeft" ->
                        D.succeed ( changer 0 -pas, True )

                    _ ->
                        D.fail "Touche laissée au navigateur"
            )


courbe : Maybe String -> Courbe -> Svg.Svg message
courbe selection trace =
    Svg.path
        [ A.d trace.chemin
        , A.fill "none"
        , A.stroke trace.couleur
        , A.strokeWidth
            (if selection == Just trace.cle then
                "4"

             else
                "2"
            )
        , A.strokeDasharray trace.tirets
        , A.opacity
            (if selection == Nothing || selection == Just trace.cle then
                "1"

             else
                "0.25"
            )
        , H.attribute "vector-effect" "non-scaling-stroke"
        , H.attribute "data-frontiere-role" trace.cle
        , H.attribute "data-h" (String.fromFloat trace.teinte)
        ]
        [ Svg.title [] [ Svg.text ("Limite sRGB · " ++ trace.nom) ] ]


legende : Courbe -> Element message
legende trace =
    Element.html <|
        Svg.svg [ A.viewBox "0 0 100 6", A.width "100%", A.height "6", H.attribute "aria-hidden" "true" ]
            [ Svg.line [ A.x1 "0", A.x2 "100", A.y1 "3", A.y2 "3", A.stroke trace.couleur, A.strokeWidth "2", A.strokeDasharray trace.tirets ] [] ]


plan : Plan -> (Float -> Float -> message) -> Element message
plan donnees changer =
    Element.html <|
        Svg.svg
            [ A.viewBox "0 0 400 300"
            , A.preserveAspectRatio "none"
            , A.width "100%"
            , A.height "100%"
            , H.attribute "data-palette-plan" "true"
            , H.attribute "role" "group"
            , H.attribute "tabindex" "0"
            , H.attribute "aria-label" "Plan L × C"
            , H.attribute "aria-describedby" "aide-plan valeurs-palette"
            , H.attribute "aria-roledescription" "sélecteur à deux axes"
            , H.style "touch-action" "none"
            , H.style "cursor" "crosshair"
            , H.style "overflow" "visible"
            , Events.preventDefaultOn "keydown" (clavier changer)
            ]
            ([ Svg.title [] [ Svg.text "Huit frontières sRGB et leur enveloppe commune" ]
             , Svg.rect [ A.width "400", A.height "300", A.fill "#f1eeeb", A.stroke "#b9c8c3", A.strokeWidth "1" ] []
             , Svg.path [ A.d donnees.zone, A.fill "#d6e9df", H.attribute "data-gamut-region" "true" ] []
             , Svg.g [ A.stroke "#193d38", A.strokeOpacity "0.18", A.strokeWidth "1", H.style "pointer-events" "none" ]
                (List.range 1 3 |> List.map (\i -> Svg.line [ A.x1 "0", A.x2 "400", A.y1 (String.fromInt (i * 75)), A.y2 (String.fromInt (i * 75)) ] []))
             ]
                ++ List.map (courbe donnees.selection)
                    (List.sortBy
                        (\trace ->
                            if donnees.selection == Just trace.cle then
                                1

                            else
                                0
                        )
                        donnees.courbes
                    )
                ++ [ Svg.path [ A.d donnees.limite, A.fill "none", A.stroke "white", A.strokeWidth "5", H.attribute "vector-effect" "non-scaling-stroke", H.attribute "aria-hidden" "true" ] []
                   , Svg.path [ A.d donnees.limite, A.fill "none", A.stroke "#193d38", A.strokeWidth "2.5", A.strokeDasharray "3 2", H.attribute "vector-effect" "non-scaling-stroke", H.attribute "data-gamut-frontiere" "true" ] []
                   , Svg.line [ A.x1 "0", A.x2 "400", A.y1 (String.fromFloat donnees.y), A.y2 (String.fromFloat donnees.y), A.stroke "#193d38", A.strokeOpacity "0.35", A.strokeDasharray "3 4" ] []
                   , Svg.circle [ A.cx (String.fromFloat donnees.x), A.cy (String.fromFloat donnees.y), A.r "7", A.fill "#193d38", A.stroke "white", A.strokeWidth "3", H.attribute "data-palette-curseur" "true" ] []
                   ]
            )


geometrie : Tetrades -> Element message
geometrie donnees =
    let
        carre numero =
            Svg.polygon
                [ A.points
                    (if numero == 1 then
                        donnees.premier

                     else
                        donnees.second
                    )
                , A.fill "none"
                , A.stroke
                    (if numero == 1 then
                        "#193d38"

                     else
                        "#8a5277"
                    )
                , A.strokeWidth "2"
                , A.strokeDasharray
                    (if numero == 1 then
                        "none"

                     else
                        "5 4"
                    )
                , H.attribute "data-tetrade" (String.fromInt numero)
                ]
                []

        sommet index point =
            let
                x =
                    point.x

                y =
                    point.y

                lx =
                    point.lx

                ly =
                    point.ly
            in
            Svg.g []
                [ Svg.circle
                    [ A.cx (String.fromFloat x)
                    , A.cy (String.fromFloat y)
                    , A.r "5"
                    , A.fill point.couleur
                    , A.stroke "#193d38"
                    , A.strokeDasharray
                        (if point.pointille then
                            "2 2"

                         else
                            "none"
                        )
                    , H.attribute "data-sommet" point.cle
                    ]
                    []
                , Svg.text_ [ A.x (String.fromFloat lx), A.y (String.fromFloat ly), A.textAnchor "middle", A.dominantBaseline "middle", A.fontSize "12", A.fill "#193d38" ] [ Svg.text (String.fromInt (index + 1)) ]
                ]
    in
    Element.html <|
        Svg.svg [ A.viewBox "0 0 320 320", A.width "100%", A.height "100%", H.attribute "role" "img", H.attribute "aria-label" "Plan OKLab a,b : deux carrés décalés de 45 degrés" ]
            ([ Svg.line [ A.x1 "12", A.y1 "160", A.x2 "308", A.y2 "160", A.stroke "#b9c8c3" ] []
             , Svg.line [ A.x1 "160", A.y1 "12", A.x2 "160", A.y2 "308", A.stroke "#b9c8c3" ] []
             , Svg.text_ [ A.x "304", A.y "180", A.fontSize "12" ] [ Svg.text "a" ]
             , Svg.text_ [ A.x "169", A.y "15", A.fontSize "12" ] [ Svg.text "b" ]
             , Svg.circle [ A.cx "160", A.cy "160", A.r "2", A.fill "#193d38" ] []
             , carre 1
             , carre 2
             ]
                ++ List.indexedMap sommet donnees.sommets
            )


limite : Float -> List String -> List (Attribute message)
limite chroma roles =
    [ Element.htmlAttribute (H.attribute "data-limite-commune" (String.fromFloat chroma)), Element.htmlAttribute (H.attribute "data-limitantes" (String.join " " roles)) ]


carte : String -> Float -> Float -> Float -> List (Attribute message)
carte role clarte chroma teinte =
    [ Element.htmlAttribute (H.attribute "data-role-palette" role), Element.htmlAttribute (H.attribute "data-l" (String.fromFloat clarte)), Element.htmlAttribute (H.attribute "data-c" (String.fromFloat chroma)), Element.htmlAttribute (H.attribute "data-h" (String.fromFloat teinte)) ]
