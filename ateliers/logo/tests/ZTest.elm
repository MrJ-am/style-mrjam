module ZTest exposing (suite)

import Echo.Animation as Animation exposing (Strategy(..))
import Echo.Composition as Composition
import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.Transform as Transform
import Expect
import Fuzz
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Connaissance, pictogrammes complets et Zoé"
        [ test "audio, visio et kino incluent chacun la connaissance à la même origine" <|
            \_ ->
                List.map
                    (\forme ->
                        List.map (\i -> ( i.brick, i.pose )) (Composition.pictogramme forme)
                    )
                    [ Auditif, Visuel, Kinesthesique ]
                    |> Expect.equal
                        (List.map (\forme -> [ ( Connaissance, Transform.canonical ), ( forme, Transform.canonical ) ]) [ Auditif, Visuel, Kinesthesique ])
        , test "le fond fixe de Z reste celui du logo lorsque le fondu est désactivé" <|
            \_ ->
                let
                    defauts =
                        Animation.defaults
                in
                (Animation.recomposer Composition.Z { defauts | fadeBackground = False } 1).background
                    |> Expect.equal "#64c29b"
        , describe "Aller et retour" (List.map verifierStrategie [ Relief, LocalFade ])
        ]


verifierStrategie : Strategy -> Test
verifierStrategie strategie =
    let
        defauts =
            Animation.defaults

        scene =
            Animation.recomposer Composition.Z { defauts | strategy = strategie }

        visibles p =
            (scene p).pieces |> List.filter (\v -> v.opacity > 0)
    in
    describe
        (if strategie == Relief then
            "Relief"

         else
            "Fondu local"
        )
        [ test "le retour au départ retrouve exactement les quatre pièces du logo" <|
            \_ ->
                Expect.equal
                    (List.map (\b -> ( Primitives.key b, Transform.canonical, 0 )) Primitives.all |> List.sortBy (\( cle, _, _ ) -> cle))
                    (visibles 0 |> List.map (\v -> ( Primitives.key v.source.brick, v.pose, v.mirror )) |> List.sortBy (\( cle, _, _ ) -> cle))
        , test "l’arrivée restitue les cinq poses et le fond de Zoé" <|
            \_ ->
                Expect.equal
                    ( List.map (\i -> ( Transform.terminal i.pose, 1 )) Composition.z, "#087f71" )
                    ( visibles 1 |> List.concatMap (Animation.faces strategie) |> List.filter (\( _, alpha ) -> alpha > 0), (scene 1).background )
        , fuzz (Fuzz.floatRange 0 1) "les matrices restent finies et les opacités bornées" <|
            \p ->
                (scene p).pieces
                    |> List.concatMap (Animation.faces strategie)
                    |> List.all (\( m, alpha ) -> alpha >= 0 && alpha <= 1 && List.all (\v -> not (isNaN v || isInfinite v)) [ m.a, m.b, m.c, m.d, m.e, m.f ])
                    |> Expect.equal True
        ]
