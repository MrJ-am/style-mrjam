module MrJam.Identite exposing (logo, piedDePage, signature)

{-| Les ressources sont copiées à la compilation depuis une révision précise
de Signature. Ne pas redessiner le logo ni remplacer la signature par une image.
Toute utilisation de ces signes d'identité est strictement réservée.
-}

import Element exposing (Element, el, fill, height, image, paddingXY, px, text, width, wrappedRow)
import Element.Font as Police
import Html.Attributes as Attributs
import MrJam.Theme exposing (couleurs)


logo : Element message
logo =
    image [ width (px 44), height (px 44) ]
        { src = "assets/mrjam/Echologo.svg", description = "Logo MrJ.am" }


signature : Element message
signature =
    el [ Element.htmlAttribute (Attributs.class "mrjam"), Police.family [ Police.typeface "MrJamSignature", Police.serif ], Police.size 28 ] (text "MrJ.am")


piedDePage : Element message
piedDePage =
    wrappedRow [ width fill, Element.centerX, Element.spacing 8, paddingXY 0 12, Police.size 14, Police.color couleurs.discret ]
        [ el [] (text "Une application de"), signature ]
