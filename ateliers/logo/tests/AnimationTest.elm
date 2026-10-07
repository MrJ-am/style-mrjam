module AnimationTest exposing (suite)

import Echo.Animation as Animation exposing (Strategy(..))
import Echo.Composition as Composition
import Echo.Player as Player exposing (Cycle(..))
import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.ReferenceData as Reference
import Echo.Render as Render
import Echo.Settings as Settings
import Echo.Transform as Transform exposing (Chirality(..))
import Expect
import Fuzz
import Test exposing (Test, describe, fuzz, test)
import Time


near : Float -> Float -> Expect.Expectation
near =
    Expect.within (Expect.Absolute 0.000001)


matrixValues : Transform.Matrix -> List Float
matrixValues m =
    [ m.a, m.b, m.c, m.d, m.e, m.f ]


finite : Float -> Bool
finite n =
    not (isNaN n || isInfinite n)


visible : Animation.Scene -> List String
visible scene =
    scene.pieces |> List.filter (\p -> p.opacity > 0) |> List.map (.source >> .id) |> List.sort


visibleFaces : Animation.Scene -> List ( String, Transform.Matrix, Float )
visibleFaces scene =
    List.concatMap (\v -> Animation.faces scene.strategy v |> List.filter (\( _, a ) -> a > 0) |> List.map (\( m, a ) -> ( v.source.id, m, a ))) scene.pieces


suite : Test
suite =
    let
        s =
            Animation.defaults

        opposite =
            { s | strategy = LocalFade }

        get id scene =
            scene.pieces |> List.filter (\v -> v.source.id == id) |> List.head

        start =
            Player.start 1 0 Once 1 Player.init
    in
    describe "Contrats de géométrie, de scène et de chronologie"
        [ describe "Primitives et compositions"
            [ test "quatre primitives, dont trois contours circulaires inchangés" <|
                \_ ->
                    Expect.equal ( 4, 3 )
                        ( List.length Primitives.all
                        , List.length
                            (List.filter
                                (\b ->
                                    case Primitives.shape b of
                                        Primitives.Contour _ ->
                                            True

                                        _ ->
                                            False
                                )
                                Primitives.all
                            )
                        )
            , test "logo : les quatre poses sont exactement canoniques" <|
                \_ ->
                    assertTrue "poses et identité" (List.all (\i -> i.pose == Transform.canonical && String.endsWith "-0" i.id) Composition.logo)
            , test "X : répartition 1/3/3, sans esprit, ordre historique" <|
                \_ ->
                    Expect.equal [ Kinesthesique, Kinesthesique, Visuel, Auditif, Kinesthesique, Visuel, Visuel ] (List.map .brick Composition.x)
            , test "les deux échelles sont positives et explicites" <|
                \_ ->
                    Expect.equal [ 0.5624999968333334, 0.7381124958447001 ] (List.map (.pose >> .scale) Composition.x |> List.sort |> unique)
            , test "quatre occurrences finales ont un déterminant négatif" <|
                \_ ->
                    Expect.equal 4 (Composition.x |> List.filter (\i -> Transform.determinant (Transform.terminal i.pose) < 0) |> List.length)
            , test "réflexion puis rotation puis translation sur un point connu" <|
                \_ ->
                    let
                        pose =
                            { x = 4, y = 5, angle = pi / 2, scale = 2, chirality = Reflected }

                        ( x, y ) =
                            Transform.apply (Transform.terminal pose) ( 1, 3 )
                    in
                    Expect.all [ \_ -> near -2 x, \_ -> near 3 y ] ()
            , test "les similitudes terminales préservent les rapports de longueurs" <|
                \_ ->
                    let
                        error instance =
                            let
                                ( ax, ay ) =
                                    Transform.apply (Transform.terminal instance.pose) ( -2, 1 )

                                ( bx, by ) =
                                    Transform.apply (Transform.terminal instance.pose) ( 4, 9 )
                            in
                            abs (sqrt ((bx - ax) ^ 2 + (by - ay) ^ 2) - 10 * instance.pose.scale) < 1.0e-10
                    in
                    assertTrue "longueurs" (List.all error Composition.x)
            , test "export X : trois path dans les defs, sept use" <|
                \_ ->
                    let
                        svg =
                            Render.svgString "test-x" "0 0 30 30" (Animation.static "#9c3e65" Composition.x)
                    in
                    Expect.equal ( 3, 7 ) ( List.length (String.indexes "<path " svg), List.length (String.indexes "<use " svg) )
            , test "export logo : quatre occurrences visibles" <|
                \_ ->
                    Render.svgString "test-logo" "0 0 30 30" (Animation.static "#64c29b" Composition.logo)
                        |> String.indexes "<use "
                        |> List.length
                        |> Expect.equal 4
            , test "les bornes continues calculées respectent le seuil de recette" <|
                \_ ->
                    assertTrue "borne < 1e-4" (List.all (\t -> t.bound < 0.0001 && t.error <= t.bound) Reference.targets)
            ]
        , describe "Recomposition et stratégies de miroir"
            [ test "p=0 : quatre instances visibles, copies canoniques transparentes" <|
                \_ ->
                    let
                        scene =
                            Animation.recomposition s 0
                    in
                    Expect.all
                        [ \_ -> Expect.equal (List.map .id Composition.logo |> List.sort) (visible scene)
                        , \_ -> assertTrue "poses" (List.all (\v -> v.pose == Transform.canonical && v.mirror == 0) scene.pieces)
                        ]
                        ()
            , test "p=1 : sept instances exactes, esprit éteint" <|
                \_ ->
                    let
                        scene =
                            Animation.recomposition s 1
                    in
                    Expect.all
                        [ \_ -> Expect.equal (List.map .id Composition.x |> List.sort) (visible scene)
                        , \_ -> Expect.equal (Just 0) (get "esprit-0" scene |> Maybe.map .opacity)
                        , \_ -> assertTrue "cibles exactes" (List.all (\v -> v.pose == v.source.pose) scene.pieces)
                        ]
                        ()
            , test "dédoublement : une copie devient visible au voisinage de sa source" <|
                \_ ->
                    case get "kinesthesique-1" (Animation.recomposition s 0.07) of
                        Nothing ->
                            Expect.fail "identité absente"

                        Just v ->
                            assertTrue "copie séparée doucement" (v.opacity > 0 && v.opacity < 0.02 && abs (v.pose.x - 13.8) < 0.01 && abs (v.pose.y - 9) < 0.01 && v.mirror == 0)
            , test "couleurs exactes et fond fixe lorsque le fondu est désactivé" <|
                \_ ->
                    Expect.equal [ "#64c29b", "#9c3e65", "#64c29b" ] [ (Animation.recomposition s 0).background, (Animation.recomposition s 1).background, (Animation.recomposition { s | fadeBackground = False } 1).background ]
            , test "les deux stratégies ont les mêmes faces visibles aux extrémités" <|
                \_ ->
                    Expect.equal (List.map (Animation.recomposition s >> visibleFaces) [ 0, 1 ]) (List.map (Animation.recomposition opposite >> visibleFaces) [ 0, 1 ])
            , test "les instances directes sont indépendantes du choix du miroir" <|
                \_ ->
                    let
                        direct scene =
                            scene.pieces |> List.filter (\v -> v.source.pose.chirality == Direct) |> List.concatMap (Animation.faces scene.strategy)
                    in
                    Expect.equal (direct (Animation.recomposition s 0.55)) (direct (Animation.recomposition opposite 0.55))
            , test "les identifiants restent stables pendant le retour et les changements de face" <|
                \_ ->
                    let
                        ids p =
                            (Animation.recomposition s p).pieces |> List.map (.source >> .id)
                    in
                    assertTrue "identités" (List.all (\p -> ids p == ids 0) [ 0.2, 0.5, 1, 0.7, 0 ])
            , test "beta=0,pi/4,pi/2,3pi/4,pi : signe et valeur du déterminant" <|
                \_ ->
                    let
                        check instance =
                            [ 0, pi / 4, pi / 2, 3 * pi / 4, pi ] |> List.all (\beta -> abs (Transform.determinant (Transform.matrix instance.pose beta) - instance.pose.scale ^ 2 * cos beta) < 1.0e-10)
                    in
                    assertTrue "déterminants" (List.all check Composition.x)
            , test "la matrice terminale projetée égale la similitude réfléchie" <|
                \_ ->
                    assertTrue "matrices terminales" (Composition.x |> List.filter (\i -> i.pose.chirality == Reflected) |> List.all (\i -> Transform.matrix i.pose pi == Transform.terminal i.pose))
            , test "tranche : colonne nulle et aucun NaN" <|
                \_ ->
                    let
                        matrices =
                            List.map (\i -> Transform.matrix i.pose (pi / 2)) Composition.x
                    in
                    assertTrue "singularité prévue" (List.all (\m -> m.a == 0 && m.b == 0 && Transform.determinant m == 0 && List.all finite (matrixValues m)) matrices)
            , test "la projection reste continue autour de la tranche" <|
                \_ ->
                    let
                        left =
                            Transform.matrix Transform.canonical (pi / 2 - 1.0e-7)

                        right =
                            Transform.matrix Transform.canonical (pi / 2 + 1.0e-7)
                    in
                    assertTrue "continuité" (List.map2 (\a b -> abs (a - b) < 0.000001) (matrixValues left) (matrixValues right) |> List.all identity)
            , test "fondu local : deux faces sous la même identité et poids réversibles" <|
                \_ ->
                    let
                        weights p =
                            Animation.faces LocalFade { source = List.head (List.drop 1 Composition.x) |> Maybe.withDefault Composition.spirit, pose = Transform.canonical, opacity = 0.8, mirror = p } |> List.map Tuple.second
                    in
                    Expect.equal [ [ 0.8, 0 ], [ 0.4, 0.4 ], [ 0, 0.8 ], [ 0.4, 0.4 ], [ 0.8, 0 ] ] (List.map weights [ 0, 0.5, 1, 0.5, 0 ])
            , fuzz (Fuzz.floatRange 0 1) "toutes les matrices restent finies aux réglages extrêmes" <|
                \p ->
                    let
                        extreme =
                            Animation.normalize { s | duration = 0, stagger = 1, mirrorWidth = 0, mobileDuration = -1, omegaReference = 0, turns = 8, spread = 6 }
                    in
                    [ Animation.recomposition extreme p, Animation.recomposition { extreme | strategy = LocalFade } p, Animation.rotation extreme p ]
                        |> List.concatMap (\scene -> List.concatMap (Animation.faces scene.strategy) scene.pieces)
                        |> List.all (\( m, opacity ) -> List.all finite (opacity :: matrixValues m))
                        |> assertTrue "valeurs finies"
            , fuzz (Fuzz.floatRange 0 1) "les contours exportés restent les trois contours canoniques" <|
                \p ->
                    let
                        svg =
                            Render.svgString "check" "0 0 30 30" (Animation.recomposition s p)
                    in
                    assertTrue "contours inchangés"
                        (List.length (String.indexes "<path " svg)
                            == 3
                            && List.all
                                (\b ->
                                    case Primitives.shape b of
                                        Primitives.Disc _ ->
                                            True

                                        Primitives.Contour d ->
                                            String.contains d svg
                                )
                                Primitives.all
                        )
            ]
        , describe "Centrifugation"
            [ test "les arrêts retrouvent exactement le logo" <|
                \_ ->
                    Expect.equal (List.map .pose Composition.logo) (List.map .pose (Animation.rotation s 1).pieces)
            , test "vitesse et écartement nuls pendant les deux repos" <|
                \_ ->
                    assertTrue "repos"
                        (List.all
                            (\p ->
                                let
                                    st =
                                        Animation.rotationStats s p
                                in
                                st.omega == 0 && st.spread == 0
                            )
                            [ 0, 0.01, 0.99, 1 ]
                        )
            , test "omega est la dérivée temporelle de l’angle affiché" <|
                \_ ->
                    let
                        p =
                            0.4

                        delta =
                            0.000001

                        derivative =
                            ((Animation.rotationStats s (p + delta)).angle - (Animation.rotationStats s (p - delta)).angle) / (2 * delta * Animation.rotationDuration s)
                    in
                    near derivative (Animation.rotationStats s p).omega
            , test "une vitesse supérieure augmente la dispersion avant saturation" <|
                \_ ->
                    let
                        slow =
                            Animation.rotationStats { s | turns = 1, mobileDuration = 12 } 0.5

                        fast =
                            Animation.rotationStats { s | turns = 1, mobileDuration = 6 } 0.5
                    in
                    assertTrue "référence fixe" (fast.omega > slow.omega && fast.spread > slow.spread && fast.spread < s.spread)
            , test "dispersion saturée et invariance sous inversion du sens" <|
                \_ ->
                    let
                        fast =
                            Animation.rotationStats { s | mobileDuration = 0.2, turns = 8 } 0.5

                        reverse =
                            Animation.rotationStats { s | spinDirection = -1 } 0.5

                        forward =
                            Animation.rotationStats s 0.5
                    in
                    assertTrue "saturation et sens" (fast.spread == s.spread && reverse.spread == forward.spread && reverse.omega == -forward.omega)
            , fuzz (Fuzz.floatRange 0 1) "zéro tour conserve la scène canonique, esprit immobile" <|
                \p ->
                    Expect.equal (List.map .pose Composition.logo) (List.map .pose (Animation.rotation { s | turns = 0 } p).pieces)
            , fuzz (Fuzz.floatRange 0 1) "aucune brique centrifugée ne change de taille" <|
                \p ->
                    assertTrue "échelles" (List.all (\v -> v.pose.scale == 1 && v.mirror == 0) (Animation.rotation s p).pieces)
            ]
        , describe "Elm Animator et horloge suspendue"
            [ test "Animator interpole linéairement la progression" <| \_ -> near 0.5 (Player.advance 500 start).progress
            , test "pause fige progression, poses et couleur" <|
                \_ ->
                    let
                        paused =
                            Player.advance 351 start |> Player.pause
                    in
                    Expect.equal (Animation.recomposition s paused.progress) (Animation.recomposition s (Player.advance 100000 paused).progress)
            , test "reprise sans saut après une longue pause" <|
                \_ ->
                    start |> Player.advance 350 |> Player.pause |> Player.advance 50000 |> Player.start 1 0 Once 1 |> Player.advance 150 |> .progress |> near 0.5
            , test "inversion en cours de route sans téléportation" <|
                \_ ->
                    start |> Player.advance 600 |> Player.start 1 0 Once -1 |> Player.advance 200 |> .progress |> near 0.4
            , test "la première frame ignore le temps passé hors lecture" <|
                \_ ->
                    start |> Player.tick (Time.millisToPosix 100000) |> .progress |> near 0
            , test "les clics rapides remplacent la timeline au lieu de remplir une file" <|
                \_ ->
                    List.range 1 20 |> List.foldl (\_ player -> Player.start 1 0 Once 1 player) (Player.advance 250 start) |> Player.advance 750 |> .progress |> near 1
            , test "dix boucles complètes : aucune dérive ni easing cumulé" <|
                \_ ->
                    Player.start 1 0 Repeat 1 Player.init |> Player.advance 10000 |> .progress |> near 0
            , test "cinq aller-retour avec repos : retour exact et sens initial" <|
                \_ ->
                    let
                        player =
                            Player.start 1 0.6 PingPong 1 Player.init |> Player.advance 16000
                    in
                    Expect.equal ( 0, 1 ) ( player.progress, player.direction )
            , test "le résultat est indépendant du découpage en frames" <|
                \_ ->
                    let
                        many =
                            List.range 1 37 |> List.foldl (\_ -> Player.advance 10) start
                    in
                    near (Player.advance 370 start).progress many.progress
            , test "navigation manuelle et lecture donnent exactement la même scène" <|
                \_ ->
                    let
                        playing =
                            Player.advance 450 start
                    in
                    Expect.equal (Animation.recomposition s (Player.seek playing.progress Player.init).progress) (Animation.recomposition s playing.progress)
            , test "scrub interrompt effectivement la lecture" <|
                \_ ->
                    let
                        stopped =
                            Player.seek 0.75 start |> Player.advance 500
                    in
                    Expect.equal ( False, 0.75 ) ( stopped.running, stopped.progress )
            ]
        , describe "Réglages JSON"
            [ test "aller-retour JSON sans perte" <|
                \_ ->
                    Expect.equal (Ok s) (Settings.decode (Settings.encode s))
            , test "une entrée invalide est refusée" <|
                \_ ->
                    case Settings.decode "{\"version\":2}" of
                        Err _ ->
                            Expect.pass

                        Ok _ ->
                            Expect.fail "version inconnue acceptée"
            , test "paramètres importés bornés" <|
                \_ ->
                    let
                        limited =
                            Animation.normalize { s | duration = -1, turns = -2, spread = 100 }
                    in
                    Expect.equal ( 0.2, 0, 6 ) ( limited.duration, limited.turns, limited.spread )
            ]
        ]


unique : List comparable -> List comparable
unique values =
    List.foldr
        (\v acc ->
            if List.member v acc then
                acc

            else
                v :: acc
        )
        []
        values


assertTrue : String -> Bool -> Expect.Expectation
assertTrue description condition =
    if condition then
        Expect.pass

    else
        Expect.fail description
