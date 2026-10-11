module MrJam.Vitrine exposing (Interface, benefices, capture, chapitre, conclusion, details, etapes, hero, illustration, introduction, navigation, partie, phrase, pour, texte)

{-| Compositions de présentation et de découverte. Les textes, images et liens
appartiennent au produit. Les espacements, le rythme et les tailles sont communs.
-}

import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Complement as Complement
import MrJam.Adaptateurs.Typographie as Typographie
import MrJam.Pictogrammes as Pictogrammes exposing (Icone)
import MrJam.Theme as Theme


type alias Interface message =
    { navigation : String -> String -> Element message
    , hero : { repere : String, titre : String, texte : String, image : String, description : String } -> List (Element message) -> Element message
    , introduction : String -> String -> String -> Element message
    , benefices : List { icone : Icone, titre : String, texte : String } -> Element message
    , partie : String -> String -> List (Element message) -> Element message
    , illustration : { image : String, description : String, legende : String } -> Element message
    , etapes : List { titre : String, texte : String } -> Element message
    , details : String -> List (Element message) -> Element message
    , conclusion : String -> String -> List (Element message) -> Element message
    , capture : { image : String, description : String, legende : String } -> Element message
    }


{-| Marque et largeur explicites ; les anciennes fonctions gardent le contexte commun.
-}
pour : Theme.Contexte -> Int -> Interface message
pour contexte largeur =
    { navigation = navigationPour contexte
    , hero = heroPour contexte largeur
    , introduction = introductionPour contexte largeur
    , benefices = beneficesPour contexte
    , partie = partiePour contexte largeur
    , illustration = illustrationPour contexte
    , etapes = etapesPour contexte
    , details = detailsPour contexte
    , conclusion = conclusionPour contexte largeur
    , capture = capturePour contexte
    }


texte : String -> Element message
texte contenu =
    UI.paragraph [ UI.width UI.fill, UI.spacing 8, Police.size 17 ] [ UI.text contenu ]


phrase : String -> Element message
phrase contenu =
    UI.paragraph [ UI.width UI.fill, Police.size 24, Police.semiBold ] [ UI.text contenu ]


navigation : String -> String -> Element message
navigation =
    navigationPour Theme.commune


navigationPour : Theme.Contexte -> String -> String -> Element message
navigationPour contexte libelle url =
    UI.link
        [ UI.paddingXY 20 13
        , Bordure.rounded 8
        , Theme.fond (Theme.palette contexte).accent
        , Theme.police (Theme.palette contexte).surface
        , Police.semiBold
        , Theme.survol (Theme.palette contexte).accentSurvol
        ]
        { url = url, label = UI.row [ UI.spacing 12 ] [ UI.text libelle, Pictogrammes.vue Pictogrammes.Fleche ] }


hero : { repere : String, titre : String, texte : String, image : String, description : String } -> List (Element message) -> Element message
hero =
    heroPour Theme.commune 1024


heroPour : Theme.Contexte -> Int -> { repere : String, titre : String, texte : String, image : String, description : String } -> List (Element message) -> Element message
heroPour contexte largeur contenu actions =
    UI.wrappedRow
        [ UI.width UI.fill
        , UI.spacing
            (if largeur <= 600 then
                24

             else
                40
            )
        , UI.paddingXY 0
            (if largeur <= 600 then
                16

             else
                32
            )
        ]
        [ UI.column [ UI.width (UI.minimum 260 UI.fill), UI.spacing 26, UI.centerY ]
            [ etiquette contexte contenu.repere
            , UI.paragraph
                ([ UI.width UI.fill
                 , Region.heading 1
                 , Police.size
                    (if largeur <= 600 then
                        40

                     else
                        58
                    )
                 , Police.bold
                 , Police.letterSpacing
                    (if largeur <= 600 then
                        -1.3

                     else
                        -2.2
                    )
                 ]
                    ++ Typographie.titreVitrine
                )
                [ UI.text contenu.titre ]
            , texte contenu.texte
            , UI.wrappedRow [ UI.spacing 14, UI.width UI.fill ] actions
            ]
        , UI.image [ UI.width (UI.minimum 260 (UI.maximum 560 UI.fill)), Bordure.rounded 28 ]
            { src = contenu.image, description = contenu.description }
        ]


etiquette : Theme.Contexte -> String -> Element message
etiquette contexte contenu =
    UI.paragraph [ Police.size 12, Police.letterSpacing 1.5, Police.bold, Theme.police (Theme.palette contexte).accent ] [ UI.text contenu ]


introduction : String -> String -> String -> Element message
introduction =
    introductionPour Theme.commune 1024


introductionPour : Theme.Contexte -> Int -> String -> String -> String -> Element message
introductionPour contexte largeur repere titre description =
    UI.column [ UI.width (UI.maximum 760 UI.fill), UI.spacing 16, UI.paddingXY 0 28 ]
        [ etiquette contexte repere
        , UI.paragraph
            ([ UI.width UI.fill
             , Region.heading 1
             , Police.size
                (if largeur <= 600 then
                    30

                 else
                    42
                )
             , Police.bold
             , Police.letterSpacing -1
             ]
                ++ Typographie.titreSecondaireVitrine
            )
            [ UI.text titre ]
        , texte description
        ]


benefices : List { icone : Icone, titre : String, texte : String } -> Element message
benefices =
    beneficesPour Theme.commune


beneficesPour : Theme.Contexte -> List { icone : Icone, titre : String, texte : String } -> Element message
beneficesPour contexte contenus =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 24, UI.paddingXY 0 24 ]
        (List.map
            (\contenu ->
                UI.column [ UI.width (UI.minimum 240 UI.fill), UI.spacing 14, UI.paddingXY 0 10 ]
                    [ UI.el [ Theme.police (Theme.palette contexte).accent ] (Pictogrammes.vue contenu.icone)
                    , UI.paragraph [ Region.heading 2, Police.size 20, Police.bold ] [ UI.text contenu.titre ]
                    , texte contenu.texte
                    ]
            )
            contenus
        )


partie : String -> String -> List (Element message) -> Element message
partie =
    partiePour Theme.commune 1024


partiePour : Theme.Contexte -> Int -> String -> String -> List (Element message) -> Element message
partiePour contexte largeur repere titre contenu =
    UI.column
        [ UI.width UI.fill
        , UI.spacing 24
        , UI.paddingXY 0
            (if largeur <= 600 then
                24

             else
                36
            )
        ]
        ([ etiquette contexte repere
         , UI.paragraph
            ([ UI.width (UI.maximum 780 UI.fill)
             , Region.heading 2
             , Police.size
                (if largeur <= 600 then
                    30

                 else
                    36
                )
             , Police.bold
             , Police.letterSpacing -1
             ]
                ++ Typographie.titreSecondaireVitrine
            )
            [ UI.text titre ]
         ]
            ++ contenu
        )


illustration : { image : String, description : String, legende : String } -> Element message
illustration =
    illustrationPour Theme.commune


illustrationPour : Theme.Contexte -> { image : String, description : String, legende : String } -> Element message
illustrationPour contexte contenu =
    UI.column [ UI.width UI.fill, UI.spacing 12 ]
        [ UI.image [ UI.width UI.fill, Bordure.rounded 12, Bordure.width 1, Theme.bordure (Theme.palette contexte).ligne ]
            { src = contenu.image, description = contenu.description }
        , (MrJam.pour contexte).texteSecondaire contenu.legende
        ]


etapes : List { titre : String, texte : String } -> Element message
etapes =
    etapesPour Theme.commune


etapesPour : Theme.Contexte -> List { titre : String, texte : String } -> Element message
etapesPour contexte contenus =
    UI.wrappedRow [ UI.width UI.fill, UI.spacing 28 ]
        (List.indexedMap
            (\numero contenu ->
                UI.column [ UI.width (UI.minimum 240 UI.fill), UI.spacing 12 ]
                    [ UI.el [ Theme.police (Theme.palette contexte).accent, Police.size 32, Police.bold ] (UI.text ("0" ++ String.fromInt (numero + 1)))
                    , UI.paragraph [ Region.heading 3, Police.size 22, Police.bold ] [ UI.text contenu.titre ]
                    , texte contenu.texte
                    ]
            )
            contenus
        )


chapitre : String -> String -> List (Element message) -> Element message
chapitre identifiant titre contenu =
    UI.column [ UI.width (UI.maximum 900 UI.fill), UI.spacing 20, UI.paddingXY 0 24, Accessibilite.identifiant identifiant ]
        ([ UI.paragraph [ Region.heading 2, Police.size 30, Police.bold, UI.width UI.fill, Accessibilite.tabulation -1 ] [ UI.text titre ] ] ++ contenu)


{-| Complément consultable au clavier. Le contenu reste disponible dans le DOM,
sans chargement d'une autre version du texte et sans animation imposée.
-}
details : String -> List (Element message) -> Element message
details =
    detailsPour Theme.commune


detailsPour : Theme.Contexte -> String -> List (Element message) -> Element message
detailsPour contexte titre contenu =
    let
        couleurs =
            Theme.palette contexte

        racine attributs element =
            UI.layoutWith { options = [ UI.noStaticStyleSheet, Theme.focusPour contexte ] }
                ([ UI.width UI.fill, Police.family [ Police.typeface "Inter", Police.sansSerif ], Theme.police couleurs.encre ] ++ attributs)
                element
    in
    UI.el
        [ UI.width UI.fill
        , Bordure.widthEach { top = 1, bottom = 0, left = 0, right = 0 }
        , Theme.bordure couleurs.ligne
        , UI.paddingXY 0 20
        , UI.focused [ Bordure.shadow { offset = ( 0, 0 ), size = 3, blur = 0, color = couleurs.accent } ]
        ]
        (Complement.natif
            (racine [ Police.size 18, Police.semiBold, UI.paddingXY 0 6, UI.pointer ] (UI.paragraph [ UI.width UI.fill ] [ UI.text titre ]))
            (racine [ Police.size 16, Police.regular, UI.paddingXY 0 20 ] (UI.column [ UI.width UI.fill, UI.spacing 18 ] contenu))
        )


conclusion : String -> String -> List (Element message) -> Element message
conclusion =
    conclusionPour Theme.commune 1024


conclusionPour : Theme.Contexte -> Int -> String -> String -> List (Element message) -> Element message
conclusionPour contexte largeur titre description actions =
    UI.column
        [ UI.width UI.fill
        , UI.spacing 22
        , UI.padding
            (if largeur <= 600 then
                24

             else
                32
            )
        , Theme.fond (Theme.palette contexte).papier
        , Bordure.rounded 20
        ]
        [ UI.paragraph [ UI.width UI.fill, Region.heading 2, Police.size 32, Police.bold ] [ UI.text titre ]
        , texte description
        , UI.wrappedRow [ UI.width UI.fill, UI.spacing 18 ] actions
        ]


{-| Capture consultable en taille réelle, notamment lorsque le mobile réduit
la vue. Le lien reste une navigation ordinaire, sans dialogue ou script caché.
-}
capture : { image : String, description : String, legende : String } -> Element message
capture =
    capturePour Theme.commune


capturePour : Theme.Contexte -> { image : String, description : String, legende : String } -> Element message
capturePour contexte contenu =
    UI.column [ UI.width UI.fill, UI.spacing 10 ]
        [ UI.link [ UI.width UI.fill, Accessibilite.infoBulle "Agrandir la capture" ]
            { url = contenu.image
            , label = UI.image [ UI.width UI.fill, Bordure.rounded 12, Bordure.width 1, Theme.bordure (Theme.palette contexte).ligne ] { src = contenu.image, description = contenu.description }
            }
        , UI.wrappedRow [ UI.width UI.fill, UI.spacing 12 ]
            [ (MrJam.pour contexte).texteSecondaire contenu.legende
            , (Pictogrammes.pour contexte).lien Pictogrammes.Loupe "Agrandir la capture" contenu.image
            ]
        ]
