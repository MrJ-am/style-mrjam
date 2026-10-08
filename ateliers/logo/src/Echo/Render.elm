module Echo.Render exposing (Options, defaults, svgString, svgStringAvecTrous, view)

import Echo.Animation as Animation exposing (Scene, Visual)
import Echo.Composition exposing (Instance)
import Echo.Primitives as Primitives exposing (Brick, Shape(..))
import Echo.Transform as Transform
import Html exposing (Html)
import Html.Attributes as H
import Svg exposing (Svg)
import Svg.Attributes as A


type alias Options =
    { prefix : String
    , box : String
    , title : String
    , diagnostic : Bool
    , axes : Bool
    , hidden : List String
    , isolated : Maybe String
    , reference : Maybe String
    , difference : Bool
    , trous : List Instance
    }


defaults : String -> Options
defaults prefix =
    { prefix = prefix, box = "-9 -12 48 48", title = "Composition vectorielle du logo", diagnostic = False, axes = False, hidden = [], isolated = Nothing, reference = Nothing, difference = False, trous = [] }


definitions : String -> Svg msg
definitions prefix =
    Svg.defs [] (List.map (definition prefix) Primitives.all)


definition : String -> Brick -> Svg msg
definition prefix brick =
    let
        id =
            A.id (prefix ++ "-" ++ Primitives.key brick)
    in
    case Primitives.shape brick of
        Disc radius ->
            Svg.circle [ id, A.cx "0", A.cy "0", A.r (String.fromFloat radius) ] []

        Contour path ->
            Svg.g [ id, A.transform "translate(-13.8 -9)" ] [ Svg.path [ A.d path ] [] ]


{-| Le rectangle blanc du masque est un support technique : seules les copies
noires du disque canonique évident la silhouette ; le fond reste indépendant.
-}
masque : String -> List Instance -> Svg msg
masque prefix trous =
    Svg.defs []
        [ Svg.mask [ A.id (prefix ++ "-trous"), A.maskUnits "userSpaceOnUse", A.x "-20", A.y "-20", A.width "70", A.height "70" ]
            (Svg.rect [ A.x "-20", A.y "-20", A.width "70", A.height "70", A.fill "white" ] []
                :: List.map (\trou -> Svg.use [ H.attribute "href" ("#" ++ prefix ++ "-" ++ Primitives.key trou.brick), A.transform (Transform.serialize (Transform.terminal trou.pose)), A.fill "black", H.attribute "data-trou" trou.id ] []) trous
            )
        ]


view : Options -> Scene -> Html msg
view options scene =
    let
        visible piece =
            not (List.member piece.source.id options.hidden)
                && (options.isolated == Nothing || options.isolated == Just piece.source.id)

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
                        , H.attribute "style"
                            (if options.difference then
                                "mix-blend-mode:difference;pointer-events:none"

                             else
                                "pointer-events:none"
                            )
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
            List.map (renderPiece options scene) (List.filter visible scene.pieces)

        silhouette =
            if List.isEmpty options.trous then
                pieces

            else
                [ masque options.prefix options.trous
                , Svg.g [ A.mask ("url(#" ++ options.prefix ++ "-trous)") ] pieces
                ]
    in
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
         , definitions options.prefix
         , Svg.circle [ A.cx "15", A.cy "15", A.r "15", A.fill scene.background, H.attribute "data-background" "true" ] []
         ]
            ++ silhouette
            ++ reference
            ++ axes
        )


renderPiece : Options -> Scene -> Visual -> Svg msg
renderPiece options scene visual =
    Svg.g
        [ A.id (options.prefix ++ "-instance-" ++ visual.source.id)
        , H.attribute "data-instance" visual.source.id
        , H.attribute "data-opacity" (String.fromFloat visual.opacity)
        , H.attribute "data-mirror" (String.fromFloat visual.mirror)
        ]
        (Animation.faces scene.strategy visual
            |> List.indexedMap
                (\index ( matrix, opacity ) ->
                    Svg.use
                        [ A.id (options.prefix ++ "-" ++ visual.source.id ++ "-face-" ++ String.fromInt index)
                        , H.attribute "href" ("#" ++ options.prefix ++ "-" ++ Primitives.key visual.source.brick)
                        , A.transform (Transform.serialize matrix)
                        , A.opacity (String.fromFloat opacity)
                        , A.fill
                            (if options.diagnostic then
                                Primitives.color visual.source.brick

                             else
                                "#ffffff"
                            )
                        , A.stroke "none"
                        ]
                        []
                )
        )


{-| Export autonome lisible. Même définition de contour et mêmes matrices que le rendu.
Le cadrage 0 0 30 30 convient aux deux compositions statiques.
-}
svgString : String -> String -> Scene -> String
svgString prefix box scene =
    svgStringAvecTrous prefix box [] scene


svgStringAvecTrous : String -> String -> List Instance -> Scene -> String
svgStringAvecTrous prefix box trous scene =
    let
        def brick =
            let
                id =
                    prefix ++ "-" ++ Primitives.key brick
            in
            case Primitives.shape brick of
                Disc radius ->
                    "    <circle id=\"" ++ id ++ "\" cx=\"0\" cy=\"0\" r=\"" ++ String.fromFloat radius ++ "\"/>"

                Contour path ->
                    "    <g id=\"" ++ id ++ "\" transform=\"translate(-13.8 -9)\"><path d=\"" ++ path ++ "\"/></g>"

        masqueTexte =
            if List.isEmpty trous then
                ""

            else
                "\n    <mask id=\""
                    ++ prefix
                    ++ "-trous\" maskUnits=\"userSpaceOnUse\" x=\"-20\" y=\"-20\" width=\"70\" height=\"70\"><rect x=\"-20\" y=\"-20\" width=\"70\" height=\"70\" fill=\"white\"/>"
                    ++ String.join "" (List.map (\trou -> "<use data-trou=\"" ++ trou.id ++ "\" href=\"#" ++ prefix ++ "-" ++ Primitives.key trou.brick ++ "\" transform=\"" ++ Transform.serialize (Transform.terminal trou.pose) ++ "\" fill=\"black\"/>") trous)
                    ++ "</mask>"

        piece visual =
            Animation.faces scene.strategy visual
                |> List.filter (\( _, opacity ) -> opacity > 0)
                |> List.map
                    (\( matrix, opacity ) ->
                        "  <use data-instance=\""
                            ++ visual.source.id
                            ++ "\" href=\"#"
                            ++ prefix
                            ++ "-"
                            ++ Primitives.key visual.source.brick
                            ++ "\" transform=\""
                            ++ Transform.serialize matrix
                            ++ "\" opacity=\""
                            ++ String.fromFloat opacity
                            ++ "\" fill=\"#ffffff\" stroke=\"none\"/>"
                    )
                |> String.join "\n"
    in
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\""
        ++ box
        ++ "\">\n  <defs>\n"
        ++ String.join "\n" (List.map def Primitives.all)
        ++ masqueTexte
        ++ "\n  </defs>\n  <circle cx=\"15\" cy=\"15\" r=\"15\" fill=\""
        ++ scene.background
        ++ "\"/>\n"
        ++ (if List.isEmpty trous then
                ""

            else
                "  <g mask=\"url(#" ++ prefix ++ "-trous)\">\n"
           )
        ++ String.join "\n" (List.filter (not << String.isEmpty) (List.map piece scene.pieces))
        ++ (if List.isEmpty trous then
                ""

            else
                "\n  </g>"
           )
        ++ "\n</svg>\n"
