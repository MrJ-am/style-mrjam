module MrJam.Vitrine exposing (benefices, capture, chapitre, conclusion, details, etapes, hero, illustration, introduction, navigation, partie, phrase, texte)

{-| Compositions de présentation et de découverte. Les textes, images et liens
appartiennent au produit. Les espacements, le rythme et les tailles sont communs.
-}

import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html
import Html.Attributes as A
import MrJam
import MrJam.Pictogrammes as Pictogrammes exposing (Icone)
import MrJam.Theme exposing (couleurs)


classe : String -> UI.Attribute message
classe nom =
    UI.htmlAttribute (A.class ("mrjam-vitrine-" ++ nom))


texte : String -> Element message
texte contenu =
    UI.paragraph [ UI.width UI.fill, UI.spacing 8, Police.size 17 ] [ UI.text contenu ]


phrase : String -> Element message
phrase contenu =
    UI.paragraph [ UI.width UI.fill, Police.size 24, Police.semiBold, classe "phrase" ] [ UI.text contenu ]


navigation : String -> String -> Element message
navigation libelle url =
    UI.link
        [ UI.paddingXY 20 13
        , Bordure.rounded 8
        , Fond.color couleurs.accent
        , Police.color couleurs.surface
        , Police.semiBold
        , UI.mouseOver [ Fond.color couleurs.accentSurvol ]
        ]
        { url = url, label = UI.row [ UI.spacing 12 ] [ UI.text libelle, Pictogrammes.vue Pictogrammes.Fleche ] }


hero : { repere : String, titre : String, texte : String, image : String, description : String } -> List (Element message) -> Element message
hero contenu actions =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 40, UI.paddingXY 0 32, classe "hero" ]
        [ UI.column [ UI.width (UI.minimum 260 UI.fill), UI.spacing 26, UI.centerY ]
            [ etiquette contenu.repere
            , UI.paragraph [ UI.width UI.fill, Region.heading 1, Police.size 58, Police.bold, classe "titre" ] [ UI.text contenu.titre ]
            , texte contenu.texte
            , UI.wrappedRow [ UI.spacing 14, UI.width UI.fill ] actions
            ]
        , UI.image [ UI.width (UI.minimum 260 (UI.maximum 560 UI.fill)), Bordure.rounded 28, classe "hero-image" ]
            { src = contenu.image, description = contenu.description }
        ]


etiquette : String -> Element message
etiquette contenu =
    UI.paragraph [ Police.size 12, Police.letterSpacing 1.5, Police.bold, Police.color couleurs.accent ] [ UI.text contenu ]


introduction : String -> String -> String -> Element message
introduction repere titre description =
    UI.column [ UI.width (UI.maximum 760 UI.fill), UI.spacing 16, UI.paddingXY 0 28 ]
        [ etiquette repere
        , UI.paragraph [ UI.width UI.fill, Region.heading 1, Police.size 42, Police.bold, classe "titre-secondaire" ] [ UI.text titre ]
        , texte description
        ]


benefices : List { icone : Icone, titre : String, texte : String } -> Element message
benefices contenus =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 24, UI.paddingXY 0 24 ]
        (List.map
            (\contenu ->
                UI.column [ UI.width (UI.minimum 240 UI.fill), UI.spacing 14, UI.paddingXY 0 10 ]
                    [ UI.el [ Police.color couleurs.accent ] (Pictogrammes.vue contenu.icone)
                    , UI.paragraph [ Region.heading 2, Police.size 20, Police.bold ] [ UI.text contenu.titre ]
                    , texte contenu.texte
                    ]
            )
            contenus
        )


partie : String -> String -> List (Element message) -> Element message
partie repere titre contenu =
    UI.column [ UI.width UI.fill, UI.spacing 24, UI.paddingXY 0 36, classe "partie" ]
        ([ etiquette repere
         , UI.paragraph [ UI.width (UI.maximum 780 UI.fill), Region.heading 2, Police.size 36, Police.bold, classe "titre-secondaire" ] [ UI.text titre ]
         ]
            ++ contenu
        )


illustration : { image : String, description : String, legende : String } -> Element message
illustration contenu =
    UI.column [ UI.width UI.fill, UI.spacing 12 ]
        [ UI.image [ UI.width UI.fill, Bordure.rounded 12, Bordure.width 1, Bordure.color couleurs.ligne, classe "capture" ]
            { src = contenu.image, description = contenu.description }
        , MrJam.texteSecondaire contenu.legende
        ]


etapes : List { titre : String, texte : String } -> Element message
etapes contenus =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 28 ]
        (List.indexedMap
            (\numero contenu ->
                UI.column [ UI.width (UI.minimum 240 UI.fill), UI.spacing 12 ]
                    [ UI.el [ Police.color couleurs.accent, Police.size 32, Police.bold ] (UI.text ("0" ++ String.fromInt (numero + 1)))
                    , UI.paragraph [ Region.heading 3, Police.size 22, Police.bold ] [ UI.text contenu.titre ]
                    , texte contenu.texte
                    ]
            )
            contenus
        )


chapitre : String -> String -> List (Element message) -> Element message
chapitre identifiant titre contenu =
    UI.column [ UI.width (UI.maximum 900 UI.fill), UI.spacing 20, UI.paddingXY 0 24, UI.htmlAttribute (A.id identifiant) ]
        ([ UI.paragraph [ Region.heading 2, Police.size 30, Police.bold, UI.width UI.fill, UI.htmlAttribute (A.tabindex -1) ] [ UI.text titre ] ] ++ contenu)


{-| Complément consultable au clavier. Le contenu reste disponible dans le DOM,
sans chargement d'une autre version du texte et sans animation imposée.
-}
details : String -> List (Element message) -> Element message
details titre contenu =
    UI.el [ UI.width UI.fill ] <|
        UI.html <|
            Html.details [ A.class "mrjam-vitrine-details" ]
                [ Html.summary [] [ Html.text titre ]

                -- Une racine imbriquée ne doit pas remplacer les styles de la page.
                , UI.layoutWith { options = [ UI.noStaticStyleSheet ] }
                    []
                    (UI.column [ UI.width UI.fill, UI.spacing 18, UI.paddingXY 0 20, Police.family [ Police.typeface "Inter", Police.sansSerif ], Police.size 16, Police.color couleurs.encre ] contenu)
                ]


conclusion : String -> String -> List (Element message) -> Element message
conclusion titre description actions =
    UI.column [ UI.width UI.fill, UI.spacing 22, UI.padding 32, Fond.color couleurs.papier, Bordure.rounded 20, classe "conclusion" ]
        [ UI.paragraph [ UI.width UI.fill, Region.heading 2, Police.size 32, Police.bold ] [ UI.text titre ]
        , texte description
        , UI.wrappedRow [ UI.width UI.fill, UI.spacing 18 ] actions
        ]


{-| Capture consultable en taille réelle, notamment lorsque le mobile réduit
la vue. Le lien reste une navigation ordinaire, sans dialogue ou script caché.
-}
capture : { image : String, description : String, legende : String } -> Element message
capture contenu =
    UI.column [ UI.width UI.fill, UI.spacing 10 ]
        [ UI.link [ UI.width UI.fill, UI.htmlAttribute (A.title "Agrandir la capture") ]
            { url = contenu.image
            , label = UI.image [ UI.width UI.fill, Bordure.rounded 12, Bordure.width 1, Bordure.color couleurs.ligne ] { src = contenu.image, description = contenu.description }
            }
        , UI.wrappedRow [ UI.width UI.fill, UI.spacing 12 ]
            [ MrJam.texteSecondaire contenu.legende
            , Pictogrammes.lien Pictogrammes.Loupe "Agrandir la capture" contenu.image
            ]
        ]
