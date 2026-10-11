module MrJam.GeometrieSpatiale exposing (Bille, Camera, Poignee, Position, Prise, Projection, Vue, deplacementRelatif, placerBilles, placerPoignees, projection, projeter)

{-| Géométrie commune sans DOM, coordonnées métier mutées ou horloge.
Projection orthographique et séparation visuelle reprises de Matheval.
L'ordre des candidats et les tolérances conservent les choix historiques.
-}


type alias Bille =
    { x : Float, y : Float, z : Float }


type alias Position =
    { id : String, x : Float, y : Float }


type alias Camera =
    { azimut : Float, elevation : Float }


type alias Vue =
    { x : Float, y : Float, profondeur : Float }


type alias Projection =
    { horizontal : Bille, vertical : Bille, profondeur : Bille, largeur : Float, hauteur : Float, unite : Float, diametre : Float }


projection : Float -> Float -> Camera -> Projection
projection largeur hauteur camera =
    let
        a =
            camera.azimut

        e =
            camera.elevation

        horizontal =
            Bille (cos a) 0 -(sin a)

        vertical =
            Bille -(sin a * sin e) (cos e) -(cos a * sin e)

        profondeur =
            Bille (sin a * cos e) (sin e) (cos a * cos e)

        enveloppe vecteur =
            20 * (abs vecteur.x + abs vecteur.y + abs vecteur.z)

        diametre =
            max 49 (min 68 (min largeur hauteur * 0.125))

        unite =
            max 1 (min ((largeur - diametre * 1.3 - 32) / enveloppe horizontal) ((hauteur - diametre * 1.3 - 40) / enveloppe vertical))
    in
    { horizontal = horizontal, vertical = vertical, profondeur = profondeur, largeur = largeur, hauteur = hauteur, unite = unite, diametre = diametre }


produit : Bille -> Bille -> Float
produit a b =
    a.x * b.x + a.y * b.y + a.z * b.z


projeter : Projection -> Bille -> Vue
projeter vue bille =
    { x = vue.largeur / 2 + produit bille vue.horizontal * vue.unite
    , y = vue.hauteur / 2 - produit bille vue.vertical * vue.unite
    , profondeur = produit bille vue.profondeur
    }


distance : { a | x : Float, y : Float } -> { b | x : Float, y : Float } -> Float
distance a b =
    sqrt ((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2)


placerBilles : Float -> Float -> Float -> List Position -> List Position
placerBilles largeur hauteur diametre points =
    let
        marge =
            diametre * 0.56 + 6

        ecart =
            diametre * 1.12 + 8

        limite =
            ceiling (max largeur hauteur / ecart)

        borner taille valeur =
            max marge (min (taille - marge) valeur)

        placer point places =
            let
                origine =
                    { point | x = borner largeur point.x, y = borner hauteur point.y }

                candidats =
                    List.range -limite limite
                        |> List.concatMap
                            (\rang ->
                                List.range -limite limite
                                    |> List.map
                                        (\colonne ->
                                            { x = origine.x + toFloat colonne * ecart
                                            , y = origine.y + toFloat rang * ecart
                                            , cout = toFloat (colonne * colonne + rang * rang) + toFloat (abs rang) * 0.01
                                            }
                                        )
                            )
                        |> List.filter (\p -> p.x >= marge && p.x <= largeur - marge && p.y >= marge && p.y <= hauteur - marge)
                        |> List.sortBy .cout

                libre =
                    candidats
                        |> premier (\p -> List.all (\q -> distance p q >= ecart - 0.01) places)

                position =
                    case libre of
                        Just p ->
                            { point | x = p.x, y = p.y }

                        Nothing ->
                            origine
            in
            places ++ [ position ]
    in
    List.foldl placer [] points


type alias Poignee =
    { id : String, numero : Int, valeur : Float }


type alias Prise =
    { y : Float, decalage : Float }


placerPoignees : Float -> String -> Maybe Prise -> List Poignee -> List { id : String, numero : Int, valeur : Float, ancre : Float, x : Float, y : Float }
placerPoignees largeur prioritaire prise points =
    let
        ecart =
            42

        ordonnes =
            List.sortBy
                (\p ->
                    ( if p.id == prioritaire then
                        0

                      else
                        1
                    , p.numero
                    )
                )
                points

        decalages =
            0 :: List.concatMap (\i -> [ -(toFloat i) * ecart, toFloat i * ecart ]) (List.range 1 (List.length points))

        borner =
            clamp 22 (max 22 (largeur - 22))

        placer point places =
            let
                ancre =
                    22 + (clamp -10 10 point.valeur + 10) / 20 * max 1 (largeur - 44)

                libre niveau =
                    let
                        candidats =
                            List.map (\decalage -> { x = borner (ancre + decalage), y = -(toFloat niveau) * ecart }) decalages
                    in
                    case premier (\p -> List.all (\q -> distance p q >= ecart - 0.01) places) candidats of
                        Just p ->
                            p

                        Nothing ->
                            libre (niveau + 1)

                position =
                    case prise of
                        Just tenue ->
                            if point.id == prioritaire then
                                { x = borner (ancre + tenue.decalage), y = tenue.y }

                            else
                                libre 0

                        Nothing ->
                            libre 0
            in
            places ++ [ { id = point.id, numero = point.numero, valeur = point.valeur, ancre = ancre, x = position.x, y = position.y } ]
    in
    List.foldl placer [] ordonnes


{-| Pas positif ; les contrôles existants emploient0,1 et0,25. L'arrondi à
huit décimales élimine le bruit des produits avant le transport JSON.
-}
deplacementRelatif : Float -> Float -> Float -> Float -> Float -> Float -> Float
deplacementRelatif depart dx largeur minimum maximum pas =
    let
        valeur =
            depart + dx / max 1 largeur * (maximum - minimum)

        arrondie =
            clamp minimum maximum (toFloat (round (valeur / pas)) * pas)
    in
    toFloat (round (arrondie * 100000000)) / 100000000


premier : (valeur -> Bool) -> List valeur -> Maybe valeur
premier retenir valeurs =
    case valeurs of
        [] ->
            Nothing

        tete :: suite ->
            if retenir tete then
                Just tete

            else
                premier retenir suite
