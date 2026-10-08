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
import Palette.Couleurs as Palette
import Shared.Licorne as Licorne
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


couleur : Palette.Role -> String
couleur role =
    Palette.css (Palette.couleur Palette.reference role)


brique : Brick -> String -> String -> Element msg
brique forme titre sens =
    Ui.card [ width fill, spacing 14 ]
        [ illustration ("sens-" ++ Primitives.key forme)
            titre
            (Animation.static
                (couleur
                    (case forme of
                        Connaissance ->
                            Palette.Logo

                        Auditif ->
                            Palette.Audio

                        Visuel ->
                            Palette.Visio

                        Kinesthesique ->
                            Palette.Kino
                    )
                )
                (Composition.pictogramme forme)
            )
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
                [ Ui.label "ÉcoLogo · Philosophie du logo"
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
                , MrJam.paragraphe "ÉcoLogo : l’étude des échos, des correspondances et des analogies. Apprendre, c’est aussi reconnaître une relation dans une situation nouvelle, rapprocher des concepts et examiner ce qui se répond. Le nom évoque le logos — la parole et le raisonnement — et la logique, au cœur des enseignements. Cette idée relie les formes, les personnages et les couleurs."
                , MrJam.paragraphe "Le logo relie la manière de manipuler une information à ce qu’elle signifie. Audio, visio et kino portent les modalités sensorielles ; le disque central représente la connaissance, l’aspect sémantique de l’apprentissage."
                ]
            , ensemble
                [ visuel "Le logo" "philo-logo" (Animation.static (couleur Palette.Logo) Composition.logo)
                , visuel "X · Xiaoping" "philo-x" (Animation.static (couleur Palette.Xiaoping) Composition.x)
                , visuel "Y · Ydris" "philo-y" (Animation.static (couleur Palette.Ydris) Composition.y)
                , visuel "Z · Zoé" "philo-z" (Animation.static (couleur Palette.Zoe) Composition.z)
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
            , chapitre "03 · Les correspondances"
                "Un quatre caché dans le trois."
                [ "Les trois branches du logo se répartissent régulièrement autour du centre. Leur orientation raconte pourtant autre chose : d’audio à visio, puis de visio à kino, on passe chaque fois d’un quart de tour. Trois positions font ainsi pressentir une quatrième. La répartition des branches et l’orientation de leurs formes sont deux lectures différentes du même dessin."
                , "Cette présence d’un quatrième terme fait écho à la proportion : 2 est à 3 ce que 4 est à 6. Trois nombres suffisent à poser la question du quatrième, la quatrième proportionnelle. Dans une analogie, on cherche de même une correspondance entre deux relations : A est à B ce que C est à D."
                , "C’est une manière de travailler les concepts : chercher ce qui joue le même rôle, transférer une relation, puis vérifier jusqu’où elle reste valable. Une ressemblance donne une piste ; le raisonnement et l’expérience permettent de l’examiner. Les deux groupes de couleurs reprennent ce motif : trois termes accompagnés d’un quatrième."
                ]
            , chapitre "04 · Les trois axes"
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
            , column [ width fill, spacing 16, htmlAttribute (A.id "palette") ]
                [ chapitre "05 · La palette"
                    "Deux carrés, un octogone."
                    [ "La palette est construite dans OKLab, un espace conçu pour rapprocher les distances numériques des différences de couleur perçues. Sa forme polaire OKLCH décrit chaque couleur par L, la clarté, C, le chroma — la distance à l’axe des gris — et h, l’angle de teinte. Les huit couleurs partagent exactement L et C ; seule leur teinte change."
                    , "La couleur du logo part de l’angle d’or : 360° / φ², soit environ 137,507764°, où φ = (1 + √5) / 2. Le lien avec Fibonacci est précis : les rapports de deux termes consécutifs de la suite tendent vers φ. Ce choix chromatique fait ainsi écho aux nombres de Fibonacci déjà présents dans les rayons du dessin."
                    , "On ajoute ensuite 45° à chaque sommet. Les huit teintes forment un octogone régulier dans le plan a,b d’OKLab. Une teinte sur deux forme un carré : ce sont deux harmonies tétradiques, décalées de 45°. Leurs sommets sont séparés de 90°, comme un quart de tour."
                    , "La première tétrade réunit Audio orangé, Visio bleu et Kino mauve, avec le logo vert pour quatrième terme. La seconde réunit Xiaoping jaune, Ydris vert et Zoé bleu, avec la Licorne rose invisible pour quatrième terme. Sept couleurs composent l’identité principale ; la huitième complète la construction et participe pleinement au calcul du gamut."
                    , "La paire de référence est choisie au maximum du chroma commun en sRGB. Pour chaque L, on calcule la limite de chacune des huit teintes, puis on prend la plus petite. On retient le point où cette enveloppe atteint son C le plus élevé. Ydris et Zoé imposent ensemble cette limite. L’allure presque triangulaire du domaine vient des véritables frontières : aucune approximation par un triangle n’entre dans le choix."
                    ]
                , wrappedRow [ width fill, spacing 16 ]
                    [ Ui.badge ("L ≈ " ++ Ui.format 9 Palette.reference.l)
                    , Ui.badge ("C ≈ " ++ Ui.format 9 Palette.reference.c)
                    , Ui.badge "8 teintes · 7 couleurs principales"
                    ]
                , MrJam.lien "Voir la palette de référence et explorer ses frontières →" "palette.html"
                , MrJam.lien "OKLab : définition par Björn Ottosson" "https://bottosson.github.io/posts/oklab/"
                ]
            , column [ width fill, spacing 16, htmlAttribute (A.id "licorne") ]
                [ chapitre "06 · Le quatrième terme"
                    "La Licorne rose invisible."
                    [ "La Licorne rose invisible est une divinité fictive de religion parodique, popularisée dans les échanges sceptiques sur Internet au début des années 1990. Elle parodie certaines affirmations religieuses : dire qu’elle est rose tout en la déclarant invisible met en scène une propriété qu’on ne peut pas observer."
                    , "Elle invite à distinguer une affirmation de ce qui permet de la vérifier. L’impossibilité de réfuter une existence ne suffit pas à la prouver. Ici, ce personnage prolonge le travail sur les analogies et la logique : que permet de conclure un raisonnement, et sur quoi s’appuie-t-il ?"
                    ]
                , ensemble
                    [ Ui.card [ width fill, spacing 12 ]
                        [ Licorne.illustration "philo-licorne" 280
                        , MrJam.lien "↓ Licorne — SVG factorisé" "exports/Licorne-factorisee.svg"
                        ]
                    , column [ width fill, spacing 16 ]
                        [ MrJam.paragraphe "Dans la palette, elle occupe le sommet rose à environ 2,507764°. Elle complète le carré des personnages sans devenir un quatrième tuteur. Son dessin laisse la crinière se fondre dans le disque rose ; un dégradé continu s’éclaircit vers la corne."
                        , MrJam.paragraphe "La silhouette garde le museau très long et la corne en cinq éléments séparés. Dix-neuf occurrences réutilisent uniquement les trois contours Audio, Visio et Kino, par translations, rotations, réflexions et homothéties. Le SVG définit chaque contour une seule fois."
                        , MrJam.lien "La Licorne rose invisible sur Wikipédia" "https://fr.wikipedia.org/wiki/Licorne_rose_invisible"
                        ]
                    ]
                ]
            , chapitre "07 · Le mouvement"
                "Voir les relations se construire."
                [ "L’animation permet de suivre un contour, de repérer ses copies et de comprendre un retournement. La rotation garde la connaissance au centre ; la recomposition montre les placements qui font apparaître chaque personnage."
                , "Le mouvement reste à votre rythme : lancer, arrêter, revenir, observer une étape. L’immobilité fait aussi partie de l’exploration."
                ]
            , MrJam.lien "Explorer les briques dans l’atelier →" "./?vue=geometrie&cible=Z"
            , Ui.divider
            , column [ width fill, spacing 12 ]
                [ Ui.heading 2 "Une construction, une histoire"
                , MrJam.paragraphe "La construction géométrique du logo a été élaborée dans GeoGebra, puis transcrite en SVG et en TikZ. Le dépôt Signature conserve l’identité de référence. Cet atelier conserve ces sources géométriques et présente leurs déclinaisons : Xiaoping, Ydris, Zoé, les pictogrammes complets et la Licorne rose invisible, avec la palette ÉcoLogo de référence."
                , MrJam.lien "Consulter le logo de référence dans Signature" "https://github.com/MrJ-am/Signature/blob/17495b13cefa24473e37434b98336b27caec8cdf/artwork/Echologo.svg"
                , MrJam.lien "Voir les sources et les mesures de l’atelier" "https://github.com/MrJ-am/style-mrjam/tree/main/ateliers/logo"
                , Ui.small "Logo, signature et déclinaisons : toute utilisation est strictement réservée. Leur présence publique ne vaut pas autorisation de reproduction, de modification ou de redistribution. Les licences des dépendances ne s’étendent pas à ces éléments d’identité."
                , Ui.small "MrJ.am · ÉcoLogo"
                ]
            ]
        )
