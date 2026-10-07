module YTest exposing (suite)

import Echo.Animation as Animation exposing (Strategy(..))
import Echo.Composition as Composition
import Echo.Primitives as Primitives
import Echo.ReferenceData as Reference
import Echo.Transform as Transform
import Expect
import Fuzz
import Test exposing (Test, describe, fuzz, test)


suite : Test
suite =
    describe "Y : fidélité, doublons et réversibilité"
        [ test "huit occurrences, six placements distincts, trois réflexions choisies" <|
            \_ ->
                Expect.equal ( 8, 6, 3 )
                    ( List.length Composition.y
                    , List.foldl
                        (\i poses ->
                            if List.member i.pose poses then
                                poses

                            else
                                i.pose :: poses
                        )
                        []
                        Composition.y
                        |> List.length
                    , List.filter .reflected Reference.ciblesY |> List.length
                    )
        , test "les mesures de chaque arc restent sous le seuil commun" <|
            \_ ->
                List.all (\r -> r.bound < 0.0001 && r.error <= r.bound) Reference.ciblesY |> Expect.equal True
        , describe "Les deux stratégies" (List.map verifierStrategie [ Relief, LocalFade ])
        ]


verifierStrategie : Strategy -> Test
verifierStrategie strategie =
    let
        defauts =
            Animation.defaults

        reglages =
            { defauts | strategy = strategie }

        scene =
            Animation.recomposer Composition.Y reglages

        visibles p =
            (scene p).pieces |> List.filter (\v -> v.opacity > 0)
    in
    describe
        (if strategie == Relief then
            "Relief"

         else
            "Fondu local"
        )
        [ test "départ : les quatre briques originales, sans copies visibles" <|
            \_ ->
                Expect.equal
                    (List.map (\b -> ( Primitives.key b, Transform.canonical, 0 )) Primitives.all |> List.sortBy (\( cle, _, _ ) -> cle))
                    (visibles 0 |> List.map (\v -> ( Primitives.key v.source.brick, v.pose, v.mirror )) |> List.sortBy (\( cle, _, _ ) -> cle))
        , test "arrivée : huit matrices terminales et fond original" <|
            \_ ->
                Expect.equal
                    ( List.map (\i -> ( Transform.terminal i.pose, 1 )) Composition.y, "#64c29b" )
                    ( visibles 1 |> List.concatMap (Animation.faces strategie) |> List.filter (\( _, alpha ) -> alpha > 0), (scene 1).background )
        , fuzz (Fuzz.floatRange 0 1) "matrices finies et opacités bornées sur tout le trajet" <|
            \p ->
                (scene p).pieces
                    |> List.concatMap (Animation.faces strategie)
                    |> List.all (\( m, alpha ) -> alpha >= 0 && alpha <= 1 && List.all (\v -> not (isNaN v || isInfinite v)) [ m.a, m.b, m.c, m.d, m.e, m.f ])
                    |> Expect.equal True
        ]
