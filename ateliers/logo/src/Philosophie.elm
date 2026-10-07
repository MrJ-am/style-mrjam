module Philosophie exposing (main)

import Browser
import Browser.Events
import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.Render as Render
import Echo.Transform as Transform
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
            (Animation.static "#64c29b" [ { id = Primitives.key forme, brick = forme, pose = Transform.canonical } ])
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
                    [ text "Un esprit ouvert à l’expérience." ]
                , MrJam.paragraphe "Le logo met en relation l’esprit, les sens et le corps. Quatre formes simples racontent une même intention : apprendre en donnant du sens à ce que l’on entend, à ce que l’on voit et à ce que l’on fait."
                ]
            , ensemble
                [ visuel "Le logo" "philo-logo" (Animation.static "#64c29b" Composition.logo)
                , visuel "Le personnage X" "philo-x" (Animation.static "#9c3e65" Composition.x)
                , visuel "Le personnage Y" "philo-y" (Animation.static "#64c29b" Composition.y)
                ]
            , chapitre "01 · Le sens des formes"
                "Quatre présences, une même expérience."
                [ "Le petit disque représente l’esprit et les connaissances qu’il contient. Les trois contours qui l’entourent prennent leur sens dans leur relation avec lui : une oreille, un regard, un corps."
                , "Ces modalités se répondent. Écouter, observer et agir sont des portes d’entrée dans une même expérience d’apprentissage ; elles ne répartissent pas les personnes en catégories fixes."
                ]
            , ensemble
                [ brique Esprit "L’esprit" "Un disque, une présence. Il évoque l’activité intérieure et les connaissances que l’expérience vient enrichir."
                , brique Auditif "Écouter" "À gauche, la forme auditive et le disque suggèrent une oreille : accueillir une parole, un rythme, une résonance."
                ]
            , ensemble
                [ brique Visuel "Regarder" "À droite, la forme visuelle et le disque évoquent l’œil et son sourcil : observer, distinguer, mettre en relation."
                , brique Kinesthesique "Agir" "La forme qui descend, associée au disque, fait apparaître un corps et sa tête : éprouver, manipuler, mettre en mouvement."
                ]
            , chapitre "02 · Des proportions qui se répondent"
                "La croissance inscrite dans le dessin."
                [ "Le dessin repose sur des arcs de cercle. Le disque-esprit a un rayon de 2 ; les raccords aux trois modalités utilisent un rayon de 3. Les rayons principaux 3, 6 et 12 se doublent, tandis que d’autres arcs font apparaître 5, 8 et 13."
                , "On y rencontre donc une progression de raison 2 et les nombres 2, 3, 5, 8, 13 de la suite de Fibonacci. Ces rapports donnent une cohérence aux courbes et portent l’idée d’effets qui se multiplient : les expériences et les connaissances prennent une autre portée lorsqu’elles se relient. C’est le langage symbolique du logo."
                ]
            , Ui.card [ Fond.color (Element.rgb255 234 245 239), padding 24, spacing 12 ]
                [ Ui.label "Une géométrie commune"
                , wrappedRow [ width fill, spacing 16 ] [ Ui.badge "Rayon de l’esprit · 2", Ui.badge "Progression · 3 → 6 → 12", Ui.badge "Fibonacci · 2, 3, 5, 8, 13" ]
                ]
            , chapitre "03 · Un vocabulaire à recomposer"
                "Changer de figure, garder ses formes."
                [ "X et Y prolongent ce vocabulaire. Leurs silhouettes naissent de copies des mêmes briques, déplacées, tournées, agrandies ou réfléchies. Leurs contours restent ceux du logo. Une forme peut changer de place et de rôle tout en gardant son identité."
                , "X réunit sept occurrences. Y en conserve huit, dont deux doublons historiques : six placements distincts composent sa silhouette. Aucun des deux personnages ne contient le petit disque comme pièce séparée. L’atelier rend ces choix visibles et permet de remonter du personnage au logo."
                ]
            , chapitre "04 · Le mouvement comme lecture"
                "Voir les relations se construire."
                [ "L’animation permet de suivre une brique, de repérer ses copies et de comprendre un retournement. La rotation autour de l’esprit fait apparaître les relations entre les trois modalités ; la recomposition montre comment un même ensemble engendre d’autres figures."
                , "Le mouvement reste à votre rythme : lancer, arrêter, revenir, observer une étape. L’immobilité fait aussi partie de l’exploration."
                ]
            , MrJam.lien "Explorer les briques dans l’atelier →" "./?vue=geometrie&cible=Y"
            , Ui.divider
            , column [ width fill, spacing 12 ]
                [ Ui.heading 2 "Une construction, une histoire"
                , MrJam.paragraphe "La construction géométrique a été élaborée dans GeoGebra, puis transcrite en SVG et en TikZ. Le dépôt Signature conserve l’identité de référence. Cet atelier en expose les briques et les transformations, à partir du logo et des dessins X et Y fournis."
                , MrJam.lien "Consulter le logo de référence dans Signature" "https://github.com/MrJ-am/Signature/blob/17495b13cefa24473e37434b98336b27caec8cdf/artwork/Echologo.svg"
                , MrJam.lien "Voir les sources et les mesures de l’atelier" "https://github.com/MrJ-am/style-mrjam/tree/main/ateliers/logo"
                , Ui.small "Logo, signature et déclinaisons : toute utilisation est strictement réservée. Leur présence publique ne vaut pas autorisation de reproduction, de modification ou de redistribution. Les licences des dépendances ne s’étendent pas à ces éléments d’identité."
                , Ui.small "MrJ.am · Écho"
                ]
            ]
        )
