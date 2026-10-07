module Philosophie exposing (main)

import Browser
import Browser.Events
import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.Render as Render
import Element exposing (Element, column, el, fill, height, html, htmlAttribute, padding, paddingXY, px, row, spacing, text, width, wrappedRow)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html
import Html.Attributes as A
import MrJam
import MrJam.Disposition as Disposition
import Shared.Ui as Ui


type alias Modele =
    { largeur : Int }


type Message
    = Redimensionner Int Int


main : Program { width : Int } Modele Message
main =
    Browser.element
        { init = \drapeaux -> ( { largeur = drapeaux.width }, Cmd.none )
        , update = \(Redimensionner largeur _) _ -> ( { largeur = largeur }, Cmd.none )
        , subscriptions = \_ -> Browser.Events.onResize Redimensionner
        , view = vue
        }


illustration : String -> String -> Animation.Scene -> Element msg
illustration identifiant titre scene =
    let
        options =
            Render.defaults identifiant
    in
    el [ width fill, height (px 175) ]
        (html (Render.view { options | box = "-3 -3 36 36", title = titre } scene))


brique : Brick -> String -> String -> Element msg
brique forme titre sens =
    Ui.card [ width fill, spacing 14 ]
        [ illustration ("sens-" ++ Primitives.key forme)
            titre
            (Animation.static "#64c29b" (Composition.pictogramme forme))
        , Ui.heading 2 titre
        , MrJam.paragraphe sens
        ]


chapitre : String -> String -> List String -> Element msg
chapitre numero titre paragraphes =
    column [ width fill, spacing 16, paddingXY 0 14 ]
        ([ Ui.label numero, Ui.heading 2 titre ] ++ List.map MrJam.paragraphe paragraphes)


vue : Modele -> Html.Html Message
vue modele =
    let
        compact =
            modele.largeur < 720

        ensemble elements =
            if compact then
                column [ width fill, spacing 18 ] elements

            else
                row [ width fill, spacing 18, Element.alignTop ] elements

        visuel titre identifiant scene =
            Ui.card [ spacing 10 ] [ illustration identifiant titre scene, el [ Element.centerX ] (Ui.label titre) ]
    in
    Disposition.cadre []
        (column
            [ width (Element.maximum 1080 fill)
            , Element.centerX
            , paddingXY
                (if compact then
                    20

                 else
                    48
                )
                28
            , spacing 30
            ]
            [ wrappedRow [ width fill, spacing 24, Region.navigation, htmlAttribute (A.attribute "aria-label" "Pages de l’atelier") ]
                [ MrJam.lien "Atelier du logo" "./"
                , MrJam.lienActif True "Philosophie du logo" "philosophie.html"
                , MrJam.lien "Style MrJ.am" "https://github.com/MrJ-am/style-mrjam"
                ]
            , column [ width fill, spacing 20, paddingXY 0 22 ]
                [ Ui.label "Écho · Philosophie du logo"
                , Element.paragraph
                    [ Region.heading 1
                    , Police.family [ Police.typeface "Georgia", Police.serif ]
                    , Police.size
                        (if compact then
                            38

                         else
                            58
                        )
                    , Police.letterSpacing -1.5
                    ]
                    [ text "Du sensoriel au sens." ]
                , MrJam.paragraphe "Le logo relie la manière de manipuler une information à ce qu’elle signifie. Audio, visio et kino portent les modalités sensorielles ; le disque central représente la connaissance, l’aspect sémantique de l’apprentissage."
                ]
            , ensemble
                [ visuel "Le logo" "philo-logo" (Animation.static "#64c29b" Composition.logo)
                , visuel "X · Xiaoyu" "philo-x" (Animation.static (Composition.fond Composition.X) Composition.x)
                , visuel "Y · Ydriss" "philo-y" (Animation.static (Composition.fond Composition.Y) Composition.y)
                , visuel "Z · Zoé" "philo-z" (Animation.static (Composition.fond Composition.Z) Composition.z)
                ]
            , chapitre "01 · Le sens des formes"
                "Trois modalités, une connaissance."
                [ "La connaissance désigne ici ce que l’élève comprend : le sens qu’iel donne à ce qu’iel entend, observe ou manipule, et les liens qu’iel peut en tirer. Le disque central rend cette dimension commune visible."
                , "Chaque pictogramme comprend deux pièces : son contour et le disque de connaissance. Audio évoque une oreille, visio un œil avec son sourcil, kino un corps avec sa tête. Dans le logo complet, les trois contours partagent le même disque."
                , "Écouter, observer et agir peuvent se combiner au cours d’un même apprentissage. Ces modalités décrivent des activités, pas des catégories fixes d’élèves."
                ]
            , ensemble
                [ brique Connaissance "Connaissance" "Le disque central représente le sens : comprendre une information, l’interpréter et la relier à ce que l’on sait."
                , brique Auditif "Audio" "Le contour audio et le disque central forment ensemble le pictogramme. Écouter une explication, distinguer un son, formuler une idée à voix haute."
                ]
            , ensemble
                [ brique Visuel "Visio" "Le contour visio et le disque central forment ensemble le pictogramme. Observer une figure, lire un schéma, comparer des représentations."
                , brique Kinesthesique "Kino" "Le contour kino et le disque central forment ensemble le pictogramme. Manipuler, faire un geste, essayer et ajuster une action : la dimension kinesthésique."
                ]
            , chapitre "02 · Les proportions"
                "Des proportions reproductibles."
                [ "Le dessin repose sur des arcs de cercle. Le disque de connaissance a un rayon de 2 ; les raccords aux trois contours utilisent un rayon de 3. Les rayons principaux 3, 6 et 12 se doublent, tandis que d’autres arcs utilisent 5, 8 et 13."
                , "La progression 3, 6, 12 et les nombres 2, 3, 5, 8, 13 de la suite de Fibonacci sont des choix de construction. Ils donnent des rapports précis aux courbes et permettent de les reproduire, de les comparer et de les recomposer."
                ]
            , Ui.card [ Fond.color (Element.rgb255 234 245 239), padding 24, spacing 12 ]
                [ Ui.label "Une géométrie commune"
                , wrappedRow [ width fill, spacing 16 ] [ Ui.badge "Disque central · rayon 2", Ui.badge "Progression · 3 → 6 → 12", Ui.badge "Fibonacci · 2, 3, 5, 8, 13" ]
                ]
            , chapitre "03 · Les trois axes"
                "Xiaoyu, Ydriss et Zoé."
                [ "X, Y et Z sont à la fois trois axes et les initiales des prénoms Xiaoyu, Ydriss et Zoé. Ce sont trois tuteurs : iels font travailler l’élève chacun dans une direction. Leurs silhouettes reprennent la lettre de leur axe."
                , "Xiaoyu déploie une silhouette en X. Ydriss lève les bras dans une silhouette en Y. Zoé forme un Z avec ses bras, son corps en diagonale et ses jambes. Les trois personnages utilisent les mêmes contours, déplacés, tournés, mis à l’échelle ou réfléchis."
                , "X et Y conservent les dessins fournis : sept occurrences pour X, huit pour Y dont deux superpositions historiques. Zoé est une nouvelle composition de cinq contours. Dans ces silhouettes, la tête se lit entre les courbes ; le disque de connaissance reste une pièce explicite du logo et des pictogrammes sensoriels."
                ]
            , wrappedRow [ width fill, spacing 16 ]
                [ MrJam.lien "Explorer Xiaoyu →" "./?cible=X&p=1"
                , MrJam.lien "Explorer Ydriss →" "./?cible=Y&p=1"
                , MrJam.lien "Explorer Zoé →" "./?cible=Z&p=1"
                ]
            , chapitre "04 · Le mouvement"
                "Voir les relations se construire."
                [ "L’animation permet de suivre un contour, de repérer ses copies et de comprendre un retournement. La rotation garde la connaissance au centre ; la recomposition montre les placements qui font apparaître chaque personnage."
                , "Le mouvement reste à votre rythme : lancer, arrêter, revenir, observer une étape. L’immobilité fait aussi partie de l’exploration."
                ]
            , MrJam.lien "Explorer les briques dans l’atelier →" "./?vue=geometrie&cible=Z"
            , Ui.divider
            , column [ width fill, spacing 12 ]
                [ Ui.heading 2 "Une construction, une histoire"
                , MrJam.paragraphe "La construction géométrique du logo a été élaborée dans GeoGebra, puis transcrite en SVG et en TikZ. Le dépôt Signature conserve l’identité de référence. Cet atelier présente le logo, les dessins X et Y fournis, les pictogrammes complets et la création de Zoé pour l’axe Z."
                , MrJam.lien "Consulter le logo de référence dans Signature" "https://github.com/MrJ-am/Signature/blob/17495b13cefa24473e37434b98336b27caec8cdf/artwork/Echologo.svg"
                , MrJam.lien "Voir les sources et les mesures de l’atelier" "https://github.com/MrJ-am/style-mrjam/tree/main/ateliers/logo"
                , Ui.small "Logo, signature et déclinaisons : toute utilisation est strictement réservée. Leur présence publique ne vaut pas autorisation de reproduction, de modification ou de redistribution. Les licences des dépendances ne s’étendent pas à ces éléments d’identité."
                , Ui.small "MrJ.am · Écho"
                ]
            ]
        )
