module PaletteTest exposing (suite)

import Expect
import Fuzz
import Palette.Couleurs as P exposing (Role(..))
import Test exposing (Test, describe, fuzz, fuzz2, test)


proche : Float -> Float -> Expect.Expectation
proche =
    Expect.within (Expect.Absolute 1.0e-9)


ecart : Float -> Float -> Float
ecart a b =
    let
        d =
            b - a
    in
    if d < 0 then
        d + 360

    else
        d


suite : Test
suite =
    describe "Palette OKLCH commune"
        [ test "angle d’or calculé depuis φ" <|
            \_ ->
                proche 137.50776405003785 P.angleOr
        , test "huit teintes distinctes espacées de 45 degrés, fermeture comprise" <|
            \_ ->
                let
                    hs =
                        List.map P.angle P.roles
                in
                List.map2 ecart hs (List.drop 1 hs ++ List.take 1 hs)
                    |> List.all (\d -> abs (d - 45) < 1.0e-10)
                    |> Expect.equal True
        , test "les deux tétrades sont des carrés décalés de 45 degrés" <|
            \_ ->
                let
                    hs t =
                        List.filter (\r -> P.tetrade r == t) P.roles |> List.map P.angle

                    carre vs =
                        List.map2 ecart vs (List.drop 1 vs ++ List.take 1 vs) |> List.all (\d -> abs (d - 90) < 1.0e-10)
                in
                Expect.equal True (carre (hs 1) && carre (hs 2) && List.all (\d -> abs (d - 45) < 1.0e-10) (List.map2 ecart (hs 1) (hs 2)))
        , test "rôles sémantiques, associations des modes conservées" <|
            \_ ->
                [ ( Logo, 137.50776405003785 ), ( Audio, 47.50776405003785 ), ( Visio, 227.50776405003785 ), ( Kino, 317.50776405003785 ), ( Xiaoping, 92.50776405003785 ), ( Ydris, 182.50776405003785 ), ( Zoe, 272.50776405003785 ), ( Licorne, 2.50776405003785 ) ]
                    |> List.all (\( role, h ) -> abs (P.angle role - h) < 1.0e-10)
                    |> Expect.equal True
        , fuzz2 (Fuzz.floatRange 0 1) (Fuzz.floatRange 0 1) "tous les sommets gardent exactement L et C et restent en sRGB" <|
            \l c ->
                let
                    p =
                        P.normaliser { l = l, c = c }
                in
                P.couleurs p |> List.all (\col -> col.l == p.l && col.c == p.c && P.dansGamut col) |> Expect.equal True
        , fuzz (Fuzz.floatRange 0.01 0.99) "frontière commune maximale, incluant la Licorne" <|
            \l ->
                let
                    limite =
                        P.cmaxCommun l

                    sur =
                        P.couleurs { l = l, c = limite }

                    apres =
                        P.couleurs { l = l, c = limite + 1.0e-7 }

                    minimum =
                        List.map (P.angle >> P.cmax l) P.roles |> List.minimum |> Maybe.withDefault -1
                in
                Expect.equal True (limite == minimum && List.all P.dansGamut sur && List.any (not << P.dansGamut) apres)
        , fuzz (Fuzz.floatRange 0.001 0.999) "chaque frontière individuelle est admissible et maximale" <|
            \l ->
                P.roles
                    |> List.all
                        (\role ->
                            let
                                h =
                                    P.angle role

                                c =
                                    P.cmax l h
                            in
                            P.dansGamut { l = l, c = c, h = h }
                                && not (P.dansGamut { l = l, c = c + 1.0e-8, h = h })
                        )
                    |> Expect.equal True
        , fuzz (Fuzz.floatRange 0 1) "toutes les contraintes actives sont retournées à la tolérance annoncée" <|
            \l ->
                let
                    valeurs =
                        P.limites l

                    minimum =
                        List.map .c valeurs |> List.minimum |> Maybe.withDefault -1

                    attendues =
                        List.filter (\v -> abs (v.c - minimum) <= P.toleranceLimites) valeurs |> List.map .role

                    limite =
                        P.limiteCommune l
                in
                Expect.equal ( minimum, attendues, P.roles ) ( limite.c, limite.roles, List.map .role valeurs )
        , test "Ydris limite à L=0,7 ; Zoé limite à L=0,95" <|
            \_ ->
                Expect.equal [ [ Ydris ], [ Zoe ] ] (List.map (P.limiteCommune >> .roles) [ 0.7, 0.95 ])
        , test "aux extrémités les huit contraintes sont actives, Licorne comprise" <|
            \_ ->
                Expect.equal [ { c = 0, roles = P.roles }, { c = 0, roles = P.roles } ]
                    (List.map P.limiteCommune [ 0, 1 ])
        , test "les huit courbes affichées échantillonnent leurs propres teintes, Licorne comprise" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal P.roles (List.map .role P.frontieres)
                    , \_ ->
                        P.frontieres
                            |> List.all (\f -> List.length f.points == 513 && List.all (\p -> p.c == P.cmax p.l (P.angle f.role)) f.points)
                            |> Expect.equal True
                    , \_ ->
                        P.frontiere
                            |> List.all (\p -> p.c == P.cmaxCommun p.l)
                            |> Expect.equal True
                    ]
                    ()
        , test "projection réduit seulement le chroma commun à L fixé" <|
            \_ ->
                Expect.equal { l = 0.6, c = P.cmaxCommun 0.6 } (P.normaliser { l = 0.6, c = 10 })
        , test "noir et blanc : chroma nul, hexadécimaux valides" <|
            \_ ->
                Expect.equal [ ( 0, Just "#000000" ), ( 0, Just "#ffffff" ) ]
                    (List.map (\l -> ( P.cmaxCommun l, P.hex (P.couleur (P.normaliser { l = l, c = 0.2 }) Logo) )) [ 0, 1 ])
        , test "L=0,5 neutre donne le transfert sRGB attendu, sans clipping" <|
            \_ ->
                proche 0.3885728590463344 (P.srgb { l = 0.5, c = 0, h = 0 }).r
        , test "une couleur hors gamut reste hors gamut et ne reçoit pas de hex tronqué" <|
            \_ ->
                let
                    col =
                        { l = 0.7, c = 1, h = P.angle Logo }
                in
                Expect.equal ( False, Nothing ) ( P.dansGamut col, P.hex col )
        , test "coordonnées OKLab du rouge sRGB de référence" <|
            \_ ->
                let
                    col =
                        P.depuisSrgb { r = 1, g = 0, b = 0 }
                in
                Expect.all
                    [ \_ -> Expect.within (Expect.Absolute 1.0e-7) 0.62795536 col.l
                    , \_ -> Expect.within (Expect.Absolute 1.0e-7) 0.25768331 col.c
                    , \_ -> Expect.within (Expect.Absolute 1.0e-5) 29.233885 col.h
                    ]
                    ()
        , fuzz2 (Fuzz.floatRange 0 1) (Fuzz.floatRange 0 1) "l’aller-retour URL conserve exactement les flottants sélectionnés" <|
            \l c ->
                let
                    p =
                        P.normaliser { l = l, c = c }
                in
                Expect.equal p (P.decoder ("?" ++ P.encoder p))
        , test "URL absente ou malformée, valeurs non finies et bornes" <|
            \_ ->
                Expect.all
                    [ \_ -> Expect.equal P.initial (P.decoder "?L=oops&C=NaN")
                    , \_ -> Expect.equal { l = 1, c = 0 } (P.decoder "?L=12&C=20")
                    , \_ -> Expect.equal { l = 0, c = 0 } (P.decoder "?L=-1&C=-1")
                    , \_ -> Expect.equal P.initial (P.normaliser { l = 0 / 0, c = 1 / 0 })
                    ]
                    ()
        , test "état initial exploratoire : 0,7 et 0,1 dans le domaine commun" <|
            \_ ->
                Expect.equal { l = 0.7, c = 0.1 } P.initial
        ]
