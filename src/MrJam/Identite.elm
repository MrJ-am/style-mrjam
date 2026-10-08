module MrJam.Identite exposing (logo, logoPour, marque, piedDePage, signature)

{-| Les ressources sont copiées à la compilation depuis une révision précise
de Signature. Ne pas redessiner le logo ni remplacer la signature par une image.
Toute utilisation de ces signes d'identité est strictement réservée.
-}

import Element exposing (Element, el, fill, height, image, paddingXY, px, text, width, wrappedRow)
import Element.Font as Police
import Html.Attributes as Attributs
import MrJam.Theme as Theme exposing (couleurs)


logo : Element message
logo =
    image [ width (px 44), height (px 44) ]
        { src = "assets/mrjam/Echologo.svg", description = "Logo MrJ.am" }


logoPour : String -> Element message
logoPour nom =
    if nom == "Vision" then
        image [ width (px 44), height (px 44) ]
            { src = "assets/mrjam/palette/Palette-Visio.svg", description = "Logo Vision" }

    else
        logo


signature : Element message
signature =
    -- La métrique exacte de Signature est fractionnaire ; spacing est entier.
    Element.paragraph
        [ width Element.shrink
        , Element.spacing 0
        , Element.htmlAttribute (Attributs.class "mrjam")
        , Element.htmlAttribute (Attributs.style "line-height" "1.183")
        , Police.family [ Police.typeface "MrJamSignature", Police.serif ]
        , Police.size 28
        ]
        [ text "MrJ.am" ]


{-| Nom de l'application dans la Parisienne originale, suivi de la signature
intacte. La fonte complète est fournie par le consommateur depuis Signature ;
la fonte de signature ne contient volontairement que ses six caractères.
-}
marque : String -> Element message
marque nom =
    -- Une même ligne partage la baseline : centrer deux boîtes indépendantes
    -- décale les lettres, car Parisienne et Signature ont des métriques différentes.
    Element.paragraph
        [ width Element.shrink
        , Element.spacing 0
        , Element.htmlAttribute (Attributs.class "mrjam-marque")
        , paddingXY 0 3
        , Police.family [ Police.typeface "MrJamEcriture", Police.serif ]
        , Police.size 28
        , Element.htmlAttribute (Attributs.style "line-height" "1.183")
        ]
        [ text nom
        , pointMarque
        , el
            [ Element.htmlAttribute (Attributs.class "mrjam")
            , Police.family [ Police.typeface "MrJamSignature", Police.serif ]
            , Police.size 28
            ]
            (text "MrJ.am")
        ]


{-| EchoPoint contient le même dessin que le point de Signature. La composition
originale dans mrjam.sty l'agrandit ×2 et l'abaisse de .01 em ; à cette taille
double, le décalage vaut donc -.005 em. Le caractère copié reste un point U+002E.
-}
pointMarque : Element message
pointMarque =
    el
        [ Element.htmlAttribute (Attributs.class "echo-point mrjam-marque-point")
        , Element.htmlAttribute (Attributs.style "line-height" "0")
        , Element.htmlAttribute (Attributs.style "vertical-align" "-0.005em")
        , Police.family [ Police.typeface "EchoPoint", Police.serif ]
        , Police.size 56
        ]
        (text ".")


piedDePage : Element message
piedDePage =
    wrappedRow [ width fill, Element.centerX, Element.spacing 8, paddingXY 0 12, Police.size 14, Theme.police couleurs.discret ]
        [ el [] (text "Une application de"), signature ]
