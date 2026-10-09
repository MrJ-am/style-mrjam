module MrJam.OKLab exposing (Couleur, Rgb, css, lineaire, srgb)

{-| OKLCH, coordonnées polaires d'OKLab D65. Conversion réservée au rendu.
Matrices : <https://bottosson.github.io/posts/oklab/>.
-}


type alias Couleur =
    { l : Float, c : Float, h : Float }


type alias Rgb =
    { r : Float, g : Float, b : Float }


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


css : Couleur -> String
css col =
    "oklch(" ++ String.fromFloat col.l ++ " " ++ String.fromFloat col.c ++ " " ++ String.fromFloat col.h ++ ")"
