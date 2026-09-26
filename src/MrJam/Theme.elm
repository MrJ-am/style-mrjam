module MrJam.Theme exposing (champ, couleurs, disposition, ecran, focus, panneau)

{-| Réglages internes. Les applications utilisent les composants de `MrJam`,
pas cette palette pour reconstruire leur propre version d'un bouton.
-}

import Element exposing (Attribute, Color, Option, fill, minimum, padding, rgb255, rgba255, shrink, spacing, width)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Html.Attributes as Attributs


ecran : List (Attribute message)
ecran =
    [ width fill
    , Element.htmlAttribute (Attributs.class "mrjam-ecran")
    , Element.htmlAttribute (Attributs.style "min-width" "0")
    , Element.htmlAttribute (Attributs.style "min-height" "100dvh")
    , Element.htmlAttribute (Attributs.style "height" "auto")
    , Element.htmlAttribute (Attributs.style "max-width" "100%")
    ]


couleurs : { encre : Color, discret : Color, accent : Color, accentSurvol : Color, ligne : Color, papier : Color, surface : Color, doux : Color, danger : Color, dangerSurvol : Color }
couleurs =
    { encre = rgb255 25 61 56
    , discret = rgb255 91 120 113
    , accent = rgb255 8 127 113
    , accentSurvol = rgb255 6 105 93
    , ligne = rgb255 212 230 224
    , papier = rgb255 245 249 246
    , surface = rgb255 255 255 255
    , doux = rgb255 234 245 239
    , danger = rgb255 158 77 56
    , dangerSurvol = rgb255 130 59 41
    }


focus : Option
focus =
    Element.focusStyle
        { borderColor = Just couleurs.accent
        , backgroundColor = Nothing
        , shadow = Just { color = rgba255 8 127 113 0.35, offset = ( 0, 0 ), blur = 0, size = 3 }
        }


disposition : List (Attribute message)
disposition =
    [ width fill, spacing 16 ]


panneau : List (Attribute message)
panneau =
    disposition
        ++ [ padding 16
           , Fond.color couleurs.surface
           , Bordure.color couleurs.ligne
           , Bordure.width 1
           , Bordure.rounded 6
           ]


champ : List (Attribute message)
champ =
    [ width fill
    , Element.height (minimum 36 shrink)
    , Element.paddingXY 10 7
    , Fond.color couleurs.surface
    , Police.color couleurs.encre
    , Bordure.color couleurs.ligne
    , Bordure.width 1
    , Bordure.rounded 5
    ]
