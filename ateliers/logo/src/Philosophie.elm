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


axe : Composition.Cible -> String -> String -> String -> Element msg
axe cible titre resume description =
    Ui.card [ width fill, spacing 14, Element.alignTop ]
        [ Ui.label (Composition.prenom cible)
        , Ui.heading 3 (Composition.nom cible ++ " — " ++ titre)
        , el [ Police.semiBold ] (MrJam.paragraphe resume)
        , MrJam.paragraphe description
        , MrJam.lien ("Explorer " ++ Composition.prenom cible ++ " →") ("./?cible=" ++ Composition.nom cible ++ "&p=1")
        ]


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

        axes =
            [ axe Composition.X
                "Expérimenter"
                "Agir et observer."
                "Xiaoping fait écho à XP, les points d’expérience dans les jeux. Expérimenter, c’est jouer avec les objets : les manipuler, essayer et observer les effets pour comprendre leur fonctionnement. Avec Xiaoping, on peut déplacer le point d’appui d’un levier, soulever une charge et sentir ce qui change."
            , axe Composition.Y
                "Apprendre"
                "Acquérir et stabiliser."
                "Le prénom Ydris fait référence à la racine arabe DRS, associée à l’étude et à l’apprentissage. Acquérir des connaissances, répéter, mémoriser et s’entraîner permet de stabiliser ce qui a été acquis. Avec Ydris, on apprend à nommer les parties du levier, on retrouve les notions de mémoire et on s’exerce à les utiliser dans plusieurs situations."
            , axe Composition.Z
                "Conceptualiser"
                "Relier, structurer et abstraire."
                "Zoé est un personnage de religieuse, en lien avec Ève. Elle invite à prendre de la hauteur : relier les connaissances, les organiser et changer de niveau de description. Avec Zoé, abstraire consiste à dégager une relation commune à plusieurs situations en laissant de côté leurs détails particuliers : reconnaître, par exemple, le principe du levier dans des ciseaux et une balançoire."
            ]
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
                , MrJam.lien "Palette OKLCH" "palette.html"
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
                , visuel "X · Xiaoping" "philo-x" (Animation.static (Composition.fond Composition.X) Composition.x)
                , visuel "Y · Ydris" "philo-y" (Animation.static (Composition.fond Composition.Y) Composition.y)
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
                "Expérimenter — Apprendre — Conceptualiser"
                [ "Xiaoping (X), Ydris (Y) et Zoé (Z) incarnent trois directions complémentaires de l’apprentissage. Iels accompagnent l’élève pour agir et observer, acquérir et stabiliser, relier, structurer et abstraire."
                , "Ces trois axes ne sont pas trois étapes successives d’une méthode. L’apprentissage circule continuellement entre eux : une observation suscite une question, une connaissance donne envie d’essayer, une relation comprise éclaire ce que l’on observe."
                ]
            , if modele.largeur < 950 then
                column [ width fill, spacing 18 ] axes

              else
                ensemble axes
            , column [ width fill, spacing 16 ]
                [ Ui.heading 3 "Z : prendre de la hauteur"
                , MrJam.paragraphe "L’axe Z ajoute métaphoriquement une dimension : en prenant de la hauteur, on voit la structure de ce que l’on considérait jusque-là dans le plan. On passe de cet objet et de cet essai à une relation que l’on peut reconnaître et utiliser ailleurs. C’est le rôle particulier de l’abstraction."
                , MrJam.paragraphe "Le prénom Zoé fait aussi écho au lojban zo’e : un mot qui tient la place d’un argument laissé implicite ou non précisé, à comprendre dans le contexte. Dans le projet, ce rapprochement évoque l’idée de laisser les détails d’un objet de côté pour penser les relations. L’image de l’« objet abstrait absolu » exprime cette intention symbolique ; la définition linguistique de zo’e porte sur l’implicite. Cette évocation accompagne le travail d’abstraction de Zoé."
                , MrJam.lien "Source : zo’e dans la grammaire du lojban (§ 7.7)" "https://lojban.org/publications/cll/cll_v1.1_xhtml-section-chunks/section-zohe-cohe-series.html"
                , MrJam.paragraphe "Cette prise de hauteur ramène aussi à l’expérience : le principe du levier invite à essayer un autre point d’appui ; l’entraînement peut faire apparaître une nouvelle question. On revient ainsi d’un axe à l’autre selon ce que l’on cherche à comprendre. Audio, visio et kino peuvent intervenir dans chacune de ces directions."
                , Ui.small "Les silhouettes X, Y et Z donnent un visage à ces trois directions. Elles sont composées des mêmes courbes que le logo ; l’atelier permet d’en explorer les placements et les transformations."
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
                , MrJam.paragraphe "La construction géométrique du logo a été élaborée dans GeoGebra, puis transcrite en SVG et en TikZ. Le dépôt Signature conserve l’identité de référence. Cet atelier présente le logo, les dessins X et Y fournis, les pictogrammes complets et la reprise de l’ébauche retrouvée de Zoé pour l’axe Z."
                , MrJam.lien "Consulter le logo de référence dans Signature" "https://github.com/MrJ-am/Signature/blob/17495b13cefa24473e37434b98336b27caec8cdf/artwork/Echologo.svg"
                , MrJam.lien "Voir les sources et les mesures de l’atelier" "https://github.com/MrJ-am/style-mrjam/tree/main/ateliers/logo"
                , Ui.small "Logo, signature et déclinaisons : toute utilisation est strictement réservée. Leur présence publique ne vaut pas autorisation de reproduction, de modification ou de redistribution. Les licences des dépendances ne s’étendent pas à ces éléments d’identité."
                , Ui.small "MrJ.am · Écho"
                ]
            ]
        )
