module Palette.Couleurs exposing (Couleur, Frontiere, Limite, Parametres, Rgb, Role(..), angle, angleOr, chromaAffiche, chromaPlan, cle, cmax, cmaxCommun, couleur, couleurs, css, dansGamut, decoder, depuisSrgb, encoder, frontiere, frontieres, hex, initial, limiteCommune, limites, lineaire, nom, normaliser, roles, srgb, tetrade, toleranceLimites)

{-| Source mathématique unique de la palette candidate.
Matrices OKLab D65 : Björn Ottosson, <https://bottosson.github.io/posts/oklab/>
Transfert sRGB : IEC 61966-2-1 / CSS Color 4. Aucune correction RGB par canal.
-}


type alias Parametres =
    { l : Float, c : Float }


type alias Couleur =
    { l : Float, c : Float, h : Float }


type alias Rgb =
    { r : Float, g : Float, b : Float }


type Role
    = Logo
    | Audio
    | Visio
    | Kino
    | Xiaoping
    | Ydris
    | Zoe
    | Licorne


angleOr : Float
angleOr =
    let
        phi =
            (1 + sqrt 5) / 2
    in
    360 / (phi * phi)


roles : List Role
roles =
    [ Logo, Ydris, Visio, Zoe, Kino, Licorne, Audio, Xiaoping ]


indice : Role -> Int
indice role =
    case role of
        Logo ->
            0

        Ydris ->
            1

        Visio ->
            2

        Zoe ->
            3

        Kino ->
            4

        Licorne ->
            5

        Audio ->
            6

        Xiaoping ->
            7


angle : Role -> Float
angle role =
    let
        brut =
            angleOr + 45 * toFloat (indice role)
    in
    brut - 360 * toFloat (floor (brut / 360))


nom : Role -> String
nom role =
    case role of
        Logo ->
            "Logo"

        Audio ->
            "Audio"

        Visio ->
            "Visio"

        Kino ->
            "Kino"

        Xiaoping ->
            "Xiaoping"

        Ydris ->
            "Ydris"

        Zoe ->
            "Zoé"

        Licorne ->
            "Licorne rose invisible"


cle : Role -> String
cle role =
    case role of
        Logo ->
            "logo"

        Audio ->
            "mode-audio"

        Visio ->
            "mode-visio"

        Kino ->
            "mode-kino"

        Xiaoping ->
            "xiaoping"

        Ydris ->
            "ydris"

        Zoe ->
            "zoe"

        Licorne ->
            "licorne"


tetrade : Role -> Int
tetrade role =
    modBy 2 (indice role) + 1


couleur : Parametres -> Role -> Couleur
couleur p role =
    { l = p.l, c = p.c, h = angle role }


couleurs : Parametres -> List Couleur
couleurs p =
    List.map (couleur p) roles


lineaire : Couleur -> Rgb
lineaire col =
    let
        a =
            col.c * cos (degrees col.h)

        b =
            col.c * sin (degrees col.h)

        l =
            (col.l + 0.3963377774 * a + 0.2158037573 * b) ^ 3

        m =
            (col.l - 0.1055613458 * a - 0.0638541728 * b) ^ 3

        s =
            (col.l - 0.0894841775 * a - 1.291485548 * b) ^ 3
    in
    { r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    , g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    , b = -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s
    }


fini : Float -> Bool
fini n =
    not (isNaN n || isInfinite n)


dansGamut : Couleur -> Bool
dansGamut col =
    let
        rgb =
            lineaire col

        canal v =
            fini v && v >= 0 && v <= 1
    in
    col.l >= 0 && col.l <= 1 && col.c >= 0 && List.all canal [ rgb.r, rgb.g, rgb.b ]


srgb : Couleur -> Rgb
srgb col =
    let
        rgb =
            lineaire col

        transfert v =
            if abs v <= 0.0031308 then
                12.92 * v

            else
                (if v < 0 then
                    -1

                 else
                    1
                )
                    * (1.055 * abs v ^ (1 / 2.4) - 0.055)
    in
    { r = transfert rgb.r, g = transfert rgb.g, b = transfert rgb.b }


{-| Inverse pour comparer la couleur actuelle du logo, sans ajuster la candidate.
-}
depuisSrgb : Rgb -> Couleur
depuisSrgb rgb =
    let
        inverse v =
            if v <= 0.04045 then
                v / 12.92

            else
                ((v + 0.055) / 1.055) ^ 2.4

        r =
            inverse rgb.r

        g =
            inverse rgb.g

        b =
            inverse rgb.b

        l =
            (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)

        m =
            (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)

        s =
            (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ^ (1 / 3)

        a =
            1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s

        bb =
            0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s

        h =
            atan2 bb a * 180 / pi
    in
    { l = 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s
    , c = sqrt (a * a + bb * bb)
    , h =
        if h < 0 then
            h + 360

        else
            h
    }


{-| Recherche sur un rayon depuis l’axe achromatique, borne invalide doublée
jusqu’à sortir du gamut, puis 44 dichotomies. La borne inférieure est valide.
-}
cmax : Float -> Float -> Float
cmax l h =
    if not (fini l && fini h) || l <= 0 || l >= 1 then
        0

    else
        let
            valide c =
                dansGamut { l = l, c = c, h = h }

            borner c =
                if valide c then
                    borner (2 * c)

                else
                    c

            chercher n bas haut =
                if n == 0 then
                    bas

                else
                    let
                        milieu =
                            (bas + haut) / 2
                    in
                    if valide milieu then
                        chercher (n - 1) milieu haut

                    else
                        chercher (n - 1) bas milieu
        in
        chercher 44 0 (borner 0.05)


cmaxCommun : Float -> Float
cmaxCommun l =
    (limiteCommune l).c


type alias Limite =
    { role : Role, c : Float }


limites : Float -> List Limite
limites l =
    List.map (\role -> { role = role, c = cmax l (angle role) }) roles


toleranceLimites : Float
toleranceLimites =
    1.0e-9


limiteCommune : Float -> { c : Float, roles : List Role }
limiteCommune l =
    let
        valeurs =
            limites l

        minimum =
            List.map .c valeurs |> List.minimum |> Maybe.withDefault 0
    in
    { c = minimum
    , roles = List.filter (\v -> abs (v.c - minimum) <= toleranceLimites) valeurs |> List.map .role
    }


normaliser : Parametres -> Parametres
normaliser p =
    let
        l =
            if fini p.l then
                clamp 0 1 p.l

            else
                0.7

        c =
            if fini p.c then
                p.c

            else
                0.1
    in
    { l = l, c = clamp 0 (cmaxCommun l) c }


initial : Parametres
initial =
    normaliser { l = 0.7, c = 0.1 }


{-| Échantillonnage destiné au tracé seulement ; la sélection est toujours
projetée avec le calcul exact à sa propre clarté. Constantes calculées une fois.
-}
type alias Frontiere =
    { role : Role, points : List Parametres }



-- Table commune aux neuf tracés, évaluée une fois ; aucune conversion lors du dessin.


echantillons : List { l : Float, limites : List Limite }
echantillons =
    List.range 0 512
        |> List.map
            (\i ->
                let
                    l =
                        toFloat i / 512
                in
                { l = l, limites = limites l }
            )


frontieres : List Frontiere
frontieres =
    List.indexedMap
        (\index role ->
            { role = role
            , points =
                List.map
                    (\ligne ->
                        { l = ligne.l
                        , c = List.drop index ligne.limites |> List.head |> Maybe.map .c |> Maybe.withDefault 0
                        }
                    )
                    echantillons
            }
        )
        roles


frontiere : List Parametres
frontiere =
    List.map (\ligne -> { l = ligne.l, c = List.map .c ligne.limites |> List.minimum |> Maybe.withDefault 0 }) echantillons



-- Le plan C,L contient toutes les limites individuelles ; le diagramme a,b
-- garde son échelle propre pour ne pas réduire l’octogone déjà présenté.


chromaPlan : Float
chromaPlan =
    1.05 * (List.concatMap (.points >> List.map .c) frontieres |> List.maximum |> Maybe.withDefault 0.1)


chromaAffiche : Float
chromaAffiche =
    1.12 * (List.map .c frontiere |> List.maximum |> Maybe.withDefault 0.1)


css : Couleur -> String
css col =
    "oklch(" ++ String.fromFloat col.l ++ " " ++ String.fromFloat col.c ++ " " ++ String.fromFloat col.h ++ ")"


hex : Couleur -> Maybe String
hex col =
    if not (dansGamut col) then
        Nothing

    else
        let
            rgb =
                srgb col

            chiffre n =
                String.slice n (n + 1) "0123456789abcdef"

            canal v =
                let
                    n =
                        round (v * 255)
                in
                chiffre (n // 16) ++ chiffre (modBy 16 n)
        in
        Just ("#" ++ canal rgb.r ++ canal rgb.g ++ canal rgb.b)


encoder : Parametres -> String
encoder p =
    "L=" ++ String.fromFloat p.l ++ "&C=" ++ String.fromFloat p.c


decoder : String -> Parametres
decoder query =
    let
        valeurs =
            String.split "&"
                (if String.startsWith "?" query then
                    String.dropLeft 1 query

                 else
                    query
                )

        lire cle_ defaut =
            valeurs
                |> List.filterMap
                    (\partie ->
                        case String.split "=" partie of
                            [ k, v ] ->
                                if k == cle_ then
                                    String.toFloat v

                                else
                                    Nothing

                            _ ->
                                Nothing
                    )
                |> List.head
                |> Maybe.withDefault defaut
    in
    normaliser { l = lire "L" initial.l, c = lire "C" initial.c }
