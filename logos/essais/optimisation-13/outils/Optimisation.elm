port module Optimisation exposing (main)

-- Oracle et échantillonnage de l’essai G ; aucune conversion colorimétrique dupliquée.

import Json.Encode as E
import Palette.Couleurs as P
import Platform


port resultat : E.Value -> Cmd msg


base =
    P.depuisSrgb { r = 240 / 255, g = 104 / 255, b = 132 / 255 }


couleur t =
    let
        l =
            base.l + (1 - base.l) * t * t

        q =
            base.c / P.cmax base.l base.h
    in
    { l = l, c = q * P.cmax l base.h, h = base.h }


melange a b t =
    a + (b - a) * t


interpolation a b t =
    { r = melange a.r b.r t, g = melange a.g b.g t, b = melange a.b b.b t }


distance a b =
    let
        x col =
            col.c * cos (degrees col.h)

        y col =
            col.c * sin (degrees col.h)
    in
    sqrt ((a.l - b.l) ^ 2 + (x a - x b) ^ 2 + (y a - y b) ^ 2)


erreur a b t =
    let
        voulu =
            couleur t

        rgb =
            P.srgb voulu

        obtenu =
            interpolation (P.srgb (couleur a)) (P.srgb (couleur b)) ((t - a) / (b - a))
    in
    ( distance voulu (P.depuisSrgb obtenu)
    , List.maximum [ abs (rgb.r - obtenu.r), abs (rgb.g - obtenu.g), abs (rgb.b - obtenu.b) ] |> Maybe.withDefault 0
    )


acceptable tolerance a b =
    List.all
        (\i ->
            let
                ( e, r ) =
                    erreur a b (melange a b (toFloat i / 16))
            in
            e <= tolerance && r <= 0.2475 / 255
        )
        (List.range 1 15)


subdiviser tolerance profondeur a b =
    if acceptable tolerance a b || profondeur >= 20 then
        [ a ]

    else
        let
            m =
                (a + b) / 2
        in
        subdiviser tolerance (profondeur + 1) a m ++ subdiviser tolerance (profondeur + 1) m b



-- Supprime les étapes rendues inutiles par les subdivisions voisines.


reduire tolerance points =
    case points of
        a :: b :: c :: suite ->
            if acceptable tolerance a c then
                reduire tolerance (a :: c :: suite)

            else
                a :: reduire tolerance (b :: c :: suite)

        _ ->
            points



-- Cherche par dichotomie la fin du plus long intervalle admis depuis a.
-- Le contrôle dense final est indépendant des points utilisés pour le placement.


etendre tolerance a iterations bas haut =
    if iterations == 0 then
        bas

    else
        let
            milieu =
                (bas + haut) / 2
        in
        if acceptable tolerance a milieu then
            etendre tolerance a (iterations - 1) milieu haut

        else
            etendre tolerance a (iterations - 1) bas milieu


repartir tolerance a =
    if acceptable tolerance a 1 then
        [ a, 1 ]

    else
        let
            b =
                etendre (tolerance * 0.99) a 32 a 1
        in
        a :: repartir tolerance b


encoder t =
    let
        c =
            couleur t

        rgb =
            P.srgb c
    in
    E.object [ ( "t", E.float t ), ( "L", E.float c.l ), ( "C", E.float c.c ), ( "h", E.float c.h ), ( "rgb", E.list E.float [ rgb.r, rgb.g, rgb.b ] ), ( "gamut", E.bool (P.dansGamut c) ) ]


valider points =
    let
        intervalles t reste =
            case reste of
                a :: b :: suite ->
                    if t <= b then
                        erreur a b t

                    else
                        intervalles t (b :: suite)

                _ ->
                    ( 0, 0 )

        erreurs =
            List.map (\i -> intervalles (toFloat i / 16384) points) (List.range 0 16384)
    in
    E.object
        [ ( "pointsControle", E.int 16385 )
        , ( "erreurOKLabMax", E.float (List.maximum (List.map Tuple.first erreurs) |> Maybe.withDefault 0) )
        , ( "erreurCanal8bitsMax", E.float (255 * (List.maximum (List.map Tuple.second erreurs) |> Maybe.withDefault 0)) )
        ]


experience tolerance =
    let
        initial =
            subdiviser tolerance 0 0 1 ++ [ 1 ]

        points =
            repartir tolerance 0
    in
    E.object
        [ ( "tolerance", E.float tolerance )
        , ( "avantReduction", E.int (List.length initial) )
        , ( "apresSuppression", E.int (List.length (reduire tolerance initial)) )
        , ( "etapes", E.list encoder points )
        , ( "validation", valider points )
        ]


main =
    Platform.worker
        { init =
            \() ->
                ( ()
                , resultat
                    (E.object
                        [ ( "uniforme", E.list (\i -> encoder (toFloat i / 500)) (List.range 0 500) )
                        , ( "experiences", E.list experience [ 0.001, 0.00025, 0.0001, 0.000025 ] )
                        , ( "gamutValide", E.bool (List.all (\i -> P.dansGamut (couleur (toFloat i / 16384))) (List.range 0 16384)) )
                        ]
                    )
                )
        , update = \_ m -> ( m, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
