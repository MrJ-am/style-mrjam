module MrJam.Theme exposing (bordure, champ, couleurs, disposition, ecran, focus, fond, identite, identiteHtml, panneau, police, styles, survol, survolPolice)

{-| Réglages internes. Les applications utilisent les composants de `MrJam`,
pas cette palette pour reconstruire leur propre version d'un bouton.
-}

import Element exposing (Attribute, Color, Option, fill, minimum, padding, shrink, spacing, width)
import Element.Border as Bordure
import Html exposing (Html)
import Html.Attributes as Attributs
import MrJam.OKLab as OKLab


ecran : List (Attribute message)
ecran =
    [ width fill
    , Element.htmlAttribute (Attributs.class "mrjam-ecran")
    , Element.htmlAttribute (Attributs.style "min-width" "0")
    , Element.htmlAttribute (Attributs.style "min-height" "100dvh")
    , Element.htmlAttribute (Attributs.style "height" "auto")
    , Element.htmlAttribute (Attributs.style "max-width" "100%")
    ]


couleurs : { encre : Color, discret : Color, accent : Color, accentSurvol : Color, ligne : Color, controle : Color, papier : Color, surface : Color, doux : Color, danger : Color, dangerSurvol : Color }
couleurs =
    { encre = rendu "encre"
    , discret = rendu "discret"
    , accent = rendu "accent"
    , accentSurvol = rendu "accentSurvol"
    , ligne = rendu "ligne"
    , controle = rendu "controle"
    , papier = rendu "papier"
    , surface = rendu "surface"
    , doux = rendu "doux"
    , danger = rendu "danger"
    , dangerSurvol = rendu "dangerSurvol"
    }


{-| Tous les composants héritent des mêmes rôles. La marque fixe la teinte ;
les arrière-plans abaissent le chroma et les actions assombrissent la clarté.
-}
palette : Float -> List ( String, OKLab.Couleur )
palette h =
    [ ( "encre", { l = 0.25, c = 0.035, h = h } )
    , ( "discret", { l = 0.45, c = 0.025, h = h } )
    , ( "accent", { l = 0.46, c = 0.08, h = h } )
    , ( "accentSurvol", { l = 0.39, c = 0.07, h = h } )
    , ( "ligne", { l = 0.88, c = 0.016, h = h } )
    , ( "controle", { l = 0.65, c = 0.022, h = h } )
    , ( "papier", { l = 0.98, c = 0.004, h = h } )
    , ( "surface", { l = 1, c = 0, h = h } )
    , ( "doux", { l = 0.95, c = 0.012, h = h } )
    , ( "danger", { l = 0.46, c = 0.12, h = 28 } )
    , ( "dangerSurvol", { l = 0.39, c = 0.1, h = 28 } )
    ]


rendu : String -> Color
rendu nom =
    palette 137.50776405003785
        |> List.filter (Tuple.first >> (==) nom)
        |> List.head
        |> Maybe.map (Tuple.second >> OKLab.srgb >> (\rgb -> Element.rgb rgb.r rgb.g rgb.b))
        |> Maybe.withDefault (Element.rgb 0 0 0)


nomCouleur : Color -> String
nomCouleur col =
    palette 137.50776405003785
        |> List.filter (\( nom, _ ) -> rendu nom == col)
        |> List.head
        |> Maybe.map Tuple.first
        |> Maybe.withDefault "encre"


variable : Color -> String
variable col =
    "var(--mrjam-" ++ nomCouleur col ++ ")"


fond : Color -> Attribute message
fond col =
    Element.htmlAttribute (Attributs.style "background-color" (variable col))


police : Color -> Attribute message
police col =
    Element.htmlAttribute (Attributs.style "color" (variable col))


bordure : Color -> Attribute message
bordure col =
    Element.htmlAttribute (Attributs.style "border-color" (variable col))


survol : Color -> Attribute message
survol col =
    Element.htmlAttribute (Attributs.class ("mrjam-survol-" ++ nomCouleur col))


survolPolice : Color -> Attribute message
survolPolice col =
    Element.htmlAttribute (Attributs.class ("mrjam-survol-texte-" ++ nomCouleur col))


identite : String -> List (Attribute message)
identite marque =
    List.map Element.htmlAttribute (identiteHtml marque)


identiteHtml : String -> List (Html.Attribute message)
identiteHtml marque =
    [ Attributs.class
        (case marque of
            "Vision" ->
                "mrjam-identite-vision"

            "Xiaoping" ->
                "mrjam-identite-xiaoping"

            "Ydris" ->
                "mrjam-identite-ydris"

            "Zoé" ->
                "mrjam-identite-zoe"

            _ ->
                "mrjam-identite-commune"
        )
    ]


variables : Float -> String
variables h =
    String.join ";" (List.map (\( nom, col ) -> "--mrjam-" ++ nom ++ ":" ++ OKLab.css col) (palette h))


styles : Html message
styles =
    Html.node "style"
        []
        [ Html.text
            (":root{"
                ++ variables 137.50776405003785
                ++ "}"
                ++ String.concat
                    (List.map (\( marque, teinte ) -> ".mrjam-identite-" ++ marque ++ "{" ++ variables teinte ++ "}")
                        [ ( "commune", 137.50776405003785 ), ( "vision", 227.50776405003785 ), ( "xiaoping", 92.50776405003785 ), ( "ydris", 182.50776405003785 ), ( "zoe", 272.50776405003785 ) ]
                    )
                ++ String.concat (List.map (\( nom, _ ) -> ".mrjam-survol-" ++ nom ++ ":hover{background-color:var(--mrjam-" ++ nom ++ ")!important}.mrjam-survol-texte-" ++ nom ++ ":hover{color:var(--mrjam-" ++ nom ++ ")!important}") (palette 137.50776405003785))
                ++ "button:focus-visible,a:focus-visible,input:focus-visible,textarea:focus-visible,select:focus-visible{outline:3px solid var(--mrjam-accent);outline-offset:2px}"
            )
        ]


focus : Option
focus =
    Element.focusStyle
        { borderColor = Just couleurs.accent
        , backgroundColor = Nothing
        , shadow = Nothing
        }


disposition : List (Attribute message)
disposition =
    [ width fill, spacing 16 ]


panneau : List (Attribute message)
panneau =
    disposition
        ++ [ padding 16
           , fond couleurs.surface
           , bordure couleurs.ligne
           , Bordure.width 1
           , Bordure.rounded 6
           ]


champ : List (Attribute message)
champ =
    [ width fill
    , Element.height (minimum 36 shrink)
    , Element.paddingXY 10 7
    , fond couleurs.surface
    , police couleurs.encre
    , bordure couleurs.controle
    , Bordure.width 1
    , Bordure.rounded 5
    ]
