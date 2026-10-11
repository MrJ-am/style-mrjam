module MrJam.Adaptateurs.Typographie exposing (marque, point, signature, signatureEnLigne, titreSecondaireVitrine, titreVitrine)

{-| Métriques de Signature absentes de l'API elm-ui1.1.8 : interligne
fractionnaire, baseline du point agrandi, sélection du texte et interdiction
de synthèse de fonte.
Les deux classes littérales sélectionnent uniquement la bibliothèque typographique
générée par Signature, conservée à son empreinte. Aucun nom/style configurable.
La police, sa taille, sa couleur et la disposition restent des attributs elm-ui.
-}

import Element exposing (Attribute, htmlAttribute)
import Html.Attributes as Attributs


signature : List (Attribute message)
signature =
    signatureEnLigne ++ [ htmlAttribute (Attributs.style "line-height" "1.183") ]


{-| La marque possède sa ligne et baseline ; une deuxième boîte de ligne complète
de Signature agrandirait l'interligne par la combinaison des descentes des fontes.
-}
signatureEnLigne : List (Attribute message)
signatureEnLigne =
    [ htmlAttribute (Attributs.class "mrjam") ]


marque : List (Attribute message)
marque =
    [ htmlAttribute (Attributs.attribute "data-mrjam-marque" "")
    , htmlAttribute (Attributs.style "line-height" "1.183")
    , htmlAttribute (Attributs.style "white-space" "nowrap")
    , htmlAttribute (Attributs.style "font-synthesis" "none")
    , htmlAttribute (Attributs.style "user-select" "text")
    ]


point : List (Attribute message)
point =
    [ htmlAttribute (Attributs.class "echo-point")
    , htmlAttribute (Attributs.style "line-height" "0")
    , htmlAttribute (Attributs.style "vertical-align" "-0.005em")
    ]


{-| Interlignes fractionnaires des titres existants, sans taille ni approche CSS.
-}
titreVitrine : List (Attribute message)
titreVitrine =
    [ htmlAttribute (Attributs.style "line-height" "1.06") ]


titreSecondaireVitrine : List (Attribute message)
titreSecondaireVitrine =
    [ htmlAttribute (Attributs.style "line-height" "1.13") ]
