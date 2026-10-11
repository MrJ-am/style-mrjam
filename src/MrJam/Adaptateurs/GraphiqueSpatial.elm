module MrJam.Adaptateurs.GraphiqueSpatial exposing (liens, scene, sphere)

{-| SVG technique : projection de coordonnées, guides et gradient radial absent
de l'API elm-ui. Aucun texte, contrôle, CSS, HTML ou forme libre fourni par l'app.
Le consommateur reçoit trois rendus bornés, les coordonnées restent numériques.
-}

import Element as UI exposing (Element)
import MrJam.GeometrieSpatiale as G
import Svg as S
import Svg.Attributes as A


couleur : String -> String
couleur axe =
    case axe of
        "x" ->
            "#087f71"

        "y" ->
            "#087ea2"

        _ ->
            "#7260b3"


point : String -> Float -> G.Bille -> G.Bille
point axe valeur p =
    case axe of
        "x" ->
            { p | x = valeur }

        "y" ->
            { p | y = valeur }

        _ ->
            { p | z = valeur }


ligne : { a | x : Float, y : Float } -> { b | x : Float, y : Float } -> String -> String -> Float -> S.Svg message
ligne p q couleurTrait tirets epaisseur =
    S.line [ A.x1 (String.fromFloat p.x), A.y1 (String.fromFloat p.y), A.x2 (String.fromFloat q.x), A.y2 (String.fromFloat q.y), A.stroke couleurTrait, A.strokeWidth (String.fromFloat epaisseur), A.strokeLinecap "round", A.strokeDasharray tirets ] []


scene : G.Projection -> Maybe G.Bille -> List ( G.Vue, G.Position ) -> Element message
scene projection selection places =
    let
        projeter =
            G.projeter projection

        zero =
            G.Bille 0 0 0

        mur ( a, b, cache ) =
            let
                coins =
                    List.map (\( u, v ) -> projeter (zero |> point cache -10 |> point a u |> point b v)) [ ( -10, -10 ), ( 10, -10 ), ( 10, 10 ), ( -10, 10 ) ]
            in
            S.polygon [ A.points (String.join " " (List.map (\p -> String.fromFloat p.x ++ "," ++ String.fromFloat p.y) coins)), A.fill (couleur cache), A.fillOpacity "0.045" ] []

        axe nom =
            ligne (projeter (point nom -10.5 zero)) (projeter (point nom 10.5 zero)) (couleur nom) "" 1.5

        guide p nom =
            ligne (projeter p) (projeter (point nom -10 p)) (couleur nom) "4 4" 1.3

        separation ( p, q ) =
            if p.x == q.x && p.y == q.y then
                []

            else
                [ ligne p q "#526f68" "3 3" 1.1, S.circle [ A.cx (String.fromFloat p.x), A.cy (String.fromFloat p.y), A.r "4", A.fill "#087f71", A.stroke "white", A.strokeWidth "1.5" ] [] ]
    in
    UI.html
        (S.svg [ A.width (String.fromFloat projection.largeur), A.height (String.fromFloat projection.hauteur), A.viewBox ("0 0 " ++ String.fromFloat projection.largeur ++ " " ++ String.fromFloat projection.hauteur) ]
            [ S.g [] (List.map mur [ ( "x", "y", "z" ), ( "x", "z", "y" ), ( "y", "z", "x" ) ])
            , S.g [ A.opacity "0.7" ] (List.map axe [ "x", "y", "z" ] ++ [ S.circle [ A.cx (String.fromFloat (projeter zero).x), A.cy (String.fromFloat (projeter zero).y), A.r "3", A.fill "#456962" ] [] ])
            , S.g [ A.opacity "0.65" ] (Maybe.map (\p -> List.map (guide p) [ "x", "y", "z" ]) selection |> Maybe.withDefault [])
            , S.g [] (List.concatMap separation places)
            ]
        )


sphere : String -> Float -> Element message
sphere identifiant diametre =
    UI.html
        (S.svg [ A.width (String.fromFloat diametre), A.height (String.fromFloat diametre), A.viewBox "0 0 100 100" ]
            [ S.defs []
                [ S.radialGradient [ A.id ("bille-" ++ identifiant), A.cx "29%", A.cy "22%", A.r "85%" ]
                    [ S.stop [ A.offset "0%", A.stopColor "#ffffff", A.stopOpacity "0.98" ] [], S.stop [ A.offset "30%", A.stopColor "#eefaf3", A.stopOpacity "0.9" ] [], S.stop [ A.offset "80%", A.stopColor "#a9dbca", A.stopOpacity "0.7" ] [], S.stop [ A.offset "100%", A.stopColor "#6cb8a1", A.stopOpacity "0.6" ] [] ]
                ]
            , S.circle [ A.cx "50", A.cy "50", A.r "49", A.fill ("url(#bille-" ++ identifiant ++ ")") ] []
            ]
        )


liens : Float -> Float -> Float -> List { a | x : Float, y : Float, ancre : Float } -> Element message
liens largeur hauteur base places =
    UI.html
        (S.svg [ A.width (String.fromFloat largeur), A.height (String.fromFloat hauteur), A.viewBox ("0 0 " ++ String.fromFloat largeur ++ " " ++ String.fromFloat hauteur) ]
            (List.concatMap
                (\p ->
                    if p.y == 0 && p.x == p.ancre then
                        []

                    else
                        [ ligne { x = p.ancre, y = base } { x = p.x, y = base + p.y } "#5b7871" "3 3" 1, S.circle [ A.cx (String.fromFloat p.ancre), A.cy (String.fromFloat base), A.r "3", A.fill "#087f71" ] [] ]
                )
                places
            )
        )
