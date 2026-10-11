module MrJam.Theme exposing (Contexte, Palette, bordure, champ, champPour, commune, couleurs, disposition, ecran, focus, focusPour, fond, palette, panneau, panneauPour, police, pour, survol, survolPolice, typographie)

{-| Réglages internes. Les applications composent les composants communs avec
un contexte de marque explicite, créé par MrJam.Contexte. Aucune cascade CSS,
aucune variable globale modifiable et aucune connexion avec un état métier.
-}

import Element exposing (Attribute, Color, Option, fill, minimum, padding, shrink, spacing, width)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import MrJam.OKLab as OKLab


type Contexte
    = Contexte Float


type alias Palette =
    { encre : Color
    , discret : Color
    , accent : Color
    , accentSurvol : Color
    , ligne : Color
    , controle : Color
    , papier : Color
    , surface : Color
    , doux : Color
    , danger : Color
    , dangerSurvol : Color
    }


commune : Contexte
commune =
    Contexte 137.50776405003785


pour : String -> Contexte
pour marque =
    Contexte
        (case marque of
            "Vision" ->
                227.50776405003785

            "Xiaoping" ->
                92.50776405003785

            "Ydris" ->
                182.50776405003785

            "Zoé" ->
                272.50776405003785

            _ ->
                137.50776405003785
        )


{-| Rôles OKLCH historiques inchangés ; seule leur transmission devient explicite.
La conversion sRGB existante raccorde les couleurs à l'API publique elm-ui.
-}
palette : Contexte -> Palette
palette (Contexte teinte) =
    let
        rendu l c h =
            let
                rgb =
                    OKLab.srgb { l = l, c = c, h = h }
            in
            Element.rgb rgb.r rgb.g rgb.b
    in
    { encre = rendu 0.25 0.035 teinte
    , discret = rendu 0.45 0.025 teinte
    , accent = rendu 0.46 0.08 teinte
    , accentSurvol = rendu 0.39 0.07 teinte
    , ligne = rendu 0.88 0.016 teinte
    , controle = rendu 0.65 0.022 teinte
    , papier = rendu 0.98 0.004 teinte
    , surface = rendu 1 0 0
    , doux = rendu 0.95 0.012 teinte
    , danger = rendu 0.46 0.12 28
    , dangerSurvol = rendu 0.39 0.1 28
    }


couleurs : Palette
couleurs =
    palette commune


{-| Même liste historique dans toutes les racines ElmUI, y compris le contenu
des dialogues natifs. Les polices d'identité restent leurs composants dédiés.
-}
typographie : Attribute message
typographie =
    Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]


ecran : List (Attribute message)
ecran =
    -- layout fournit déjà width/min-height100% et height:auto.
    [ width fill ]


fond : Color -> Attribute message
fond =
    Fond.color


police : Color -> Attribute message
police =
    Police.color


bordure : Color -> Attribute message
bordure =
    Bordure.color


survol : Color -> Attribute message
survol col =
    Element.mouseOver [ Fond.color col ]


survolPolice : Color -> Attribute message
survolPolice col =
    Element.mouseOver [ Police.color col ]


focus : Option
focus =
    focusPour commune


focusPour : Contexte -> Option
focusPour contexte =
    let
        accent =
            (palette contexte).accent
    in
    Element.focusStyle
        { borderColor = Just accent
        , backgroundColor = Nothing
        , shadow = Just { color = accent, offset = ( 0, 0 ), blur = 0, size = 3 }
        }


disposition : List (Attribute message)
disposition =
    [ width fill, spacing 16 ]


panneau : List (Attribute message)
panneau =
    panneauPour commune


panneauPour : Contexte -> List (Attribute message)
panneauPour contexte =
    let
        col =
            palette contexte
    in
    disposition
        ++ [ padding 16, fond col.surface, bordure col.ligne, Bordure.width 1, Bordure.rounded 6 ]


champ : List (Attribute message)
champ =
    champPour commune


champPour : Contexte -> List (Attribute message)
champPour contexte =
    let
        col =
            palette contexte
    in
    [ width fill
    , Element.height (minimum 36 shrink)
    , Element.paddingXY 10 7
    , fond col.surface
    , police col.encre
    , bordure col.controle
    , Bordure.width 1
    , Bordure.rounded 5
    ]
