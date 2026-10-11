module MrJam.Adaptateurs.Dessin exposing (quadrillage, vue)

{-| SVG spécialisé absent d'elm-ui : tracés, matrices, masques et référence.
Raccord transféré du rendu historique, sans import d'application ni animation.
Aucun foreignObject, HTML, classe, événement ou style fourni par le consommateur.
Deux styles littéraux sont nécessaires à la comparaison avec la référence.
-}

import Element exposing (Element)
import Html.Attributes as H
import MrJam.Dessin.Types exposing (Definition, Forme(..), Options, Piece, Scene, Trou)
import Svg exposing (Svg)
import Svg.Attributes as A


{-| Repère graphique de la scène historique, exprimé en pixels SVG.
Le motif ne reçoit aucun style ou nœud applicatif et reste décoratif.
-}
quadrillage : String -> Element message
quadrillage repere =
    Element.html <|
        Svg.svg [ A.width "100%", A.height "100%", H.attribute "aria-hidden" "true", H.attribute "focusable" "false" ]
            [ Svg.defs []
                [ Svg.pattern [ A.id repere, A.patternUnits "userSpaceOnUse", A.width "22", A.height "22" ]
                    [ Svg.circle [ A.cx "11", A.cy "11", A.r "0.7", A.fill "#abc9bf", A.opacity "0.09411764705882353" ] [] ]
                ]
            , Svg.rect [ A.width "100%", A.height "100%", A.fill ("url(#" ++ repere ++ ")") ] []
            ]


definitions : String -> List Definition -> Svg msg
definitions prefix formes =
    Svg.defs [] (List.map (definition prefix) formes)


definition : String -> Definition -> Svg msg
definition prefix brick =
    let
        id =
            A.id (prefix ++ "-" ++ brick.cle)
    in
    case brick.forme of
        Disque radius ->
            Svg.circle [ id, A.cx "0", A.cy "0", A.r (String.fromFloat radius) ] []

        Contour path ->
            Svg.g [ id, A.transform "translate(-13.8 -9)" ] [ Svg.path [ A.d path ] [] ]


{-| Le rectangle blanc du masque est un support technique : seules les copies
noires du disque canonique évident la silhouette ; le fond reste indépendant.
-}
masque : String -> List Trou -> Svg msg
masque prefix trous =
    Svg.defs []
        [ Svg.mask [ A.id (prefix ++ "-trous"), A.maskUnits "userSpaceOnUse", A.x "-20", A.y "-20", A.width "70", A.height "70" ]
            (Svg.rect [ A.x "-20", A.y "-20", A.width "70", A.height "70", A.fill "white" ] []
                :: List.map (\trou -> Svg.use [ H.attribute "href" ("#" ++ prefix ++ "-" ++ trou.cle), A.transform trou.matrice, A.fill "black", H.attribute "data-trou" trou.id ] []) trous
            )
        ]


vue : Options -> Scene -> Element msg
vue options scene =
    let
        visible piece =
            not (List.member piece.id options.hidden)
                && (options.isolated == Nothing || options.isolated == Just piece.id)

        reference =
            case options.reference of
                Nothing ->
                    []

                Just url ->
                    [ Svg.image
                        [ H.attribute "href" url
                        , A.x "0"
                        , A.y "0"
                        , A.width "30"
                        , A.height "30"
                        , A.opacity
                            (if options.difference then
                                "1"

                             else
                                "0.5"
                            )
                        , H.style "pointer-events" "none"
                        , if options.difference then
                            H.style "mix-blend-mode" "difference"

                          else
                            A.opacity "0.5"
                        ]
                        []
                    ]

        axes =
            if options.axes then
                [ Svg.g [ A.stroke "#b6d5d0", A.strokeWidth "0.065", A.strokeDasharray "0.25 0.3", A.opacity "0.8" ]
                    [ Svg.line [ A.x1 "13.8", A.x2 "13.8", A.y1 "-10", A.y2 "32" ] []
                    , Svg.line [ A.x1 "-6", A.x2 "35", A.y1 "9", A.y2 "9" ] []
                    , Svg.circle [ A.cx "13.8", A.cy "9", A.r "0.3", A.fill "none" ] []
                    ]
                ]

            else
                []

        pieces =
            List.map (renderPiece options) (List.filter visible scene.pieces)

        silhouette =
            if List.isEmpty options.trous then
                pieces

            else
                [ masque options.prefix options.trous
                , Svg.g [ A.mask ("url(#" ++ options.prefix ++ "-trous)") ] pieces
                ]

        coloree =
            case options.degrade of
                Just d ->
                    if options.diagnostic then
                        silhouette

                    else
                        [ Svg.defs []
                            [ Svg.linearGradient
                                [ A.id (options.prefix ++ "-degrade"), A.gradientUnits "userSpaceOnUse", A.x1 (String.fromFloat d.x1), A.y1 (String.fromFloat d.y1), A.x2 (String.fromFloat d.x2), A.y2 (String.fromFloat d.y2), A.colorInterpolation "sRGB" ]
                                [ Svg.stop [ A.offset "0", A.stopColor "#ffffff" ] []
                                , Svg.stop [ A.offset "1", A.stopColor scene.fond ] []
                                ]
                            , Svg.mask [ A.id (options.prefix ++ "-silhouette"), A.maskUnits "userSpaceOnUse", A.maskContentUnits "userSpaceOnUse", A.x "0", A.y "0", A.width "30", A.height "30" ] silhouette
                            ]
                        , Svg.rect [ A.x "0", A.y "0", A.width "30", A.height "30", A.fill ("url(#" ++ options.prefix ++ "-degrade)"), A.mask ("url(#" ++ options.prefix ++ "-silhouette)"), H.attribute "data-degrade-global" "true" ] []
                        ]

                Nothing ->
                    silhouette
    in
    Element.html <|
        Svg.svg
            [ A.viewBox options.box
            , A.width "100%"
            , A.height "100%"
            , H.attribute "role" "img"
            , H.attribute "aria-labelledby" (options.prefix ++ "-title " ++ options.prefix ++ "-description")
            , H.attribute "data-svg" options.prefix
            ]
            ([ Svg.title [ A.id (options.prefix ++ "-title") ] [ Svg.text options.title ]
             , Svg.desc [ A.id (options.prefix ++ "-description") ] [ Svg.text "Assemblage vectoriel des formes du logo. Audio, visio et kino associent chacun leur contour au disque de connaissance." ]
             , definitions options.prefix scene.definitions
             , Svg.circle [ A.cx "15", A.cy "15", A.r "15", A.fill scene.fond, H.attribute "data-background" "true" ] []
             ]
                ++ coloree
                ++ reference
                ++ axes
            )


renderPiece : Options -> Piece -> Svg msg
renderPiece options visual =
    Svg.g
        [ A.id (options.prefix ++ "-instance-" ++ visual.id)
        , H.attribute "data-instance" visual.id
        , H.attribute "data-opacity" (String.fromFloat visual.opacite)
        , H.attribute "data-mirror" (String.fromFloat visual.miroir)
        ]
        (visual.faces
            |> List.indexedMap
                (\index face ->
                    Svg.use
                        [ A.id (options.prefix ++ "-" ++ visual.id ++ "-face-" ++ String.fromInt index)
                        , H.attribute "href" ("#" ++ options.prefix ++ "-" ++ visual.cle)
                        , A.transform face.matrice
                        , A.opacity (String.fromFloat face.opacite)
                        , A.fill
                            (if options.diagnostic then
                                visual.couleur

                             else
                                "#ffffff"
                            )
                        , A.stroke "none"
                        ]
                        []
                )
        )
