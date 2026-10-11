port module Palette exposing (main)

import Browser
import Browser.Events
import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Licorne as Licorne
import Echo.Primitives as Primitives
import Echo.Render as Render
import Element exposing (Element, column, el, fill, height, padding, paddingXY, px, row, spacing, text, width, wrappedRow)
import Element.Font as Police
import Element.Region as Region
import Html
import MrJam
import MrJam.Accessibilite as Accessibilite
import MrJam.Diagrammes as Diagrammes
import MrJam.Disposition as Disposition
import Palette.Couleurs as P exposing (Role(..))
import Shared.Ui as Ui


port selectionPlan : ({ x : Float, y : Float } -> msg) -> Sub msg


port remplacerQuery : String -> Cmd msg


port navigationQuery : (String -> msg) -> Sub msg


type alias Modele =
    { largeur : Int, parametres : P.Parametres, saisieL : String, saisieC : String, message : String, frontiereSelectionnee : Maybe Role, licorneVisible : Bool, licorneDiagnostic : Bool }


type Message
    = Redimensionner Int Int
    | Pointer { x : Float, y : Float }
    | Clavier Float Float
    | SaisirL String
    | SaisirC String
    | Appliquer
    | Reinitialiser
    | Naviguer String
    | Inspecter Role
    | BasculerLicorne
    | InspecterLicorne


modele : Int -> P.Parametres -> Modele
modele largeur p =
    { largeur = largeur, parametres = p, saisieL = String.fromFloat p.l, saisieC = String.fromFloat p.c, message = "", frontiereSelectionnee = Nothing, licorneVisible = True, licorneDiagnostic = False }


main : Program { width : Int, query : String } Modele Message
main =
    Browser.element
        { init =
            \flags ->
                let
                    p =
                        P.decoder flags.query
                in
                ( modele flags.width p, remplacerQuery (P.encoder p) )
        , update = update
        , subscriptions = \_ -> Sub.batch [ Browser.Events.onResize Redimensionner, selectionPlan Pointer, navigationQuery Naviguer ]
        , view = vue
        }


choisir : P.Parametres -> Modele -> ( Modele, Cmd Message )
choisir demande m =
    let
        p =
            P.normaliser demande

        nouveau =
            modele m.largeur p

        message =
            if p /= demande then
                "La paire a été ramenée dans le domaine commun sRGB."

            else
                ""
    in
    ( { nouveau | message = message, frontiereSelectionnee = m.frontiereSelectionnee, licorneVisible = m.licorneVisible, licorneDiagnostic = m.licorneDiagnostic }, remplacerQuery (P.encoder p) )


update : Message -> Modele -> ( Modele, Cmd Message )
update message m =
    case message of
        Redimensionner largeur _ ->
            ( { m | largeur = largeur }, Cmd.none )

        Inspecter role ->
            ( { m
                | frontiereSelectionnee =
                    if m.frontiereSelectionnee == Just role then
                        Nothing

                    else
                        Just role
              }
            , Cmd.none
            )

        BasculerLicorne ->
            ( { m | licorneVisible = not m.licorneVisible }, Cmd.none )

        InspecterLicorne ->
            ( { m | licorneDiagnostic = not m.licorneDiagnostic, licorneVisible = True }, Cmd.none )

        Pointer pos ->
            choisir { l = 1 - pos.y, c = pos.x * P.chromaPlan } m

        Clavier dl dc ->
            let
                ( nouveau, commande ) =
                    choisir { l = m.parametres.l + dl, c = m.parametres.c + dc } m

                annonce =
                    "L = " ++ Ui.format 6 nouveau.parametres.l ++ "; C = " ++ Ui.format 6 nouveau.parametres.c ++ ". " ++ nouveau.message
            in
            ( { nouveau | message = annonce }, commande )

        SaisirL s ->
            ( { m | saisieL = s, message = "" }, Cmd.none )

        SaisirC s ->
            ( { m | saisieC = s, message = "" }, Cmd.none )

        Reinitialiser ->
            choisir P.initial m

        Naviguer query ->
            choisir (P.decoder query) m

        Appliquer ->
            case ( String.toFloat (String.replace "," "." m.saisieL), String.toFloat (String.replace "," "." m.saisieC) ) of
                ( Just l, Just c ) ->
                    if List.any (\v -> isNaN v || isInfinite v) [ l, c ] then
                        ( { m | message = "Saisissez deux nombres finis." }, Cmd.none )

                    else
                        choisir { l = l, c = c } m

                _ ->
                    ( { m | message = "Saisissez deux nombres ; le point et la virgule sont acceptés." }, Cmd.none )


point : P.Parametres -> String
point p =
    String.fromFloat (400 * p.c / P.chromaPlan) ++ "," ++ String.fromFloat (300 * (1 - p.l))


chemin : List P.Parametres -> String
chemin points =
    "M" ++ String.join " L" (List.map point points)


regionValide : String
regionValide =
    chemin P.frontiere ++ " Z"



-- Les chaînes SVG et les couleurs de légende sont constantes, pas recalculées
-- à chaque geste. La teinte reste celle du rôle même lorsque la candidate est grise.


traces : List { role : Role, d : String, couleur : String, tirets : String }
traces =
    let
        motifs =
            [ "none", "8 3", "2 3", "10 3 2 3", "5 3", "1 3", "12 3 4 3", "6 2 1 2" ]

        repere =
            P.normaliser { l = 0.52, c = 0.14 }
    in
    List.map2
        (\frontiere motif ->
            { role = frontiere.role, d = chemin frontiere.points, couleur = P.css (P.couleur repere frontiere.role), tirets = motif }
        )
        P.frontieres
        motifs


traceCommun : String
traceCommun =
    chemin P.frontiere


plan : Modele -> Element Message
plan m =
    let
        p =
            m.parametres

        limite =
            P.limiteCommune p.l

        traceNeutre trace =
            { cle = P.cle trace.role
            , nom = P.nom trace.role
            , teinte = P.angle trace.role
            , chemin = trace.d
            , couleur = trace.couleur
            , tirets = trace.tirets
            }

        legende trace =
            column [ width fill, spacing 5 ]
                [ Diagrammes.legende (traceNeutre trace)
                , Ui.button (m.frontiereSelectionnee == Just trace.role) (Inspecter trace.role) (P.nom trace.role)
                ]
    in
    column [ width fill, spacing 14 ]
        [ Ui.heading 2 "Choisir L et C"
        , Ui.small "L ↑ · clarté : 0 en bas, 1 en haut"
        , el [ width fill, height (px 300) ]
            (Diagrammes.plan
                { zone = regionValide
                , limite = traceCommun
                , courbes = List.map traceNeutre traces
                , selection = Maybe.map P.cle m.frontiereSelectionnee
                , x = 400 * p.c / P.chromaPlan
                , y = 300 * (1 - p.l)
                }
                Clavier
            )
        , Ui.small ("C → · chroma : 0 à " ++ Ui.format 4 P.chromaPlan)
        , el [ width fill, Accessibilite.identifiant "aide-plan" ] (Ui.paragraph "Huit courbes colorées : les limites sRGB individuelles. La ligne sombre bordée de blanc est leur enveloppe commune ; seule la zone verte à sa gauche est sélectionnable. Déplacez le point à la souris ou au toucher. Au clavier : flèches, pas de 0,001 ; Maj + flèches, pas de 0,01. Au-delà de l’enveloppe, le point revient sur la limite commune.")
        , el ([ width fill ] ++ Diagrammes.limite limite.c (List.map P.cle limite.roles))
            (Ui.paragraph ("À cette clarté, C maximal commun = " ++ Ui.format 9 limite.c ++ " — limité par " ++ String.join ", " (List.map P.nom limite.roles)))
        , Ui.small "Sélectionnez un nom pour mettre sa courbe en évidence ; sélectionnez-le à nouveau pour tout rétablir. Les couleurs de repère restent fixes, même à C = 0. Les motifs de trait permettent aussi de distinguer les teintes proches."
        , rangees
            (if m.largeur < 420 then
                1

             else
                2
            )
            (List.map legende traces)
        ]


geometrie : P.Parametres -> Element msg
geometrie p =
    let
        position rayon role =
            ( 160 + rayon * cos (degrees (P.angle role)), 160 - rayon * sin (degrees (P.angle role)) )

        coord role =
            let
                ( x, y ) =
                    position (122 * p.c / P.chromaAffiche) role
            in
            String.fromFloat x ++ "," ++ String.fromFloat y

        sommets =
            List.map
                (\role ->
                    let
                        ( x, y ) =
                            position (122 * p.c / P.chromaAffiche) role

                        ( lx, ly ) =
                            position 143 role
                    in
                    { cle = P.cle role
                    , x = x
                    , y = y
                    , lx = lx
                    , ly = ly
                    , couleur = P.css (P.couleur p role)
                    , pointille = role == Licorne
                    }
                )
                P.roles

        points numero =
            List.filter (\role -> P.tetrade role == numero) P.roles |> List.map coord |> String.join " "
    in
    column [ width fill, spacing 14 ]
        [ Ui.heading 2 "Deux carrés, un octogone"
        , el [ width fill, height (px 300) ] (Diagrammes.geometrie { premier = points 1, second = points 2, sommets = sommets })
        , Ui.small "Trait plein : logo et modalités. Pointillés : personnages et Licorne. Les numéros suivent les huit teintes ci-dessous."
        , Ui.paragraph "L’angle d’or fixe le logo. Chaque sommet suivant ajoute 45°. Les deux tétrades sont séparées de 45° ; chaque carré avance par pas de 90°. Le rayon est le chroma C, sur une échelle fixe. À C = 0, tous les sommets coïncident au centre achromatique."
        ]


scene : Role -> String -> Maybe Animation.Scene
scene role fond =
    case role of
        Logo ->
            Just (Animation.static fond Composition.logo)

        Audio ->
            Just (Animation.static fond (Composition.pictogramme Primitives.Auditif))

        Visio ->
            Just (Animation.static fond (Composition.pictogramme Primitives.Visuel))

        Kino ->
            Just (Animation.static fond (Composition.pictogramme Primitives.Kinesthesique))

        Xiaoping ->
            Just (Animation.static fond Composition.x)

        Ydris ->
            Just (Animation.static fond Composition.y)

        Zoe ->
            Just (Animation.static fond Composition.z)

        Licorne ->
            Just (Animation.static fond Composition.licorne)


illustration : String -> String -> Animation.Scene -> Element msg
illustration identifiant titre rendu =
    let
        options =
            Render.defaults identifiant
    in
    el [ width fill, height (px 155) ] (Render.view { options | box = "-2 -2 34 34", title = titre } rendu)


code : String -> Element msg
code contenu =
    el [ width fill, Police.size 12, Police.family [ Police.monospace ] ] (MrJam.litteral contenu)


carteCouleur : Modele -> Int -> Role -> Element Message
carteCouleur m index role =
    let
        p =
            m.parametres

        col =
            P.couleur p role

        rgb =
            P.srgb col

        css =
            P.css col

        prefixe =
            "palette-" ++ P.cle role
    in
    Ui.card ([ width fill, spacing 12 ] ++ Diagrammes.carte (P.cle role) p.l p.c col.h)
        [ Ui.label (String.fromInt (index + 1) ++ " · Tétrade " ++ String.fromInt (P.tetrade role))
        , Ui.heading 3 (P.nom role)
        , if role == Licorne then
            let
                options =
                    Render.defaults prefixe
            in
            column [ width fill, spacing 12 ]
                [ el [ width fill, height (px 155) ]
                    (Render.view
                        { options
                            | box = "-2 -2 34 34"
                            , title =
                                if m.licorneVisible then
                                    "Licorne : tête, corne en spirale et crinière"

                                else
                                    "Licorne invisible : seul le fond rose reste visible"
                            , degrade = Just Licorne.degrade
                            , diagnostic = m.licorneDiagnostic
                            , hidden =
                                if m.licorneVisible then
                                    []

                                else
                                    List.map .id Composition.licorne
                        }
                        (Animation.static css Composition.licorne)
                    )
                , Ui.small "Modèle retenu · Museau très long, sans poitrail. Dix-neuf occurrences des trois contours du logo ; un dégradé continu se fond dans le rose de la crinière et s’éclaircit vers la corne."
                , wrappedRow [ width fill, spacing 8 ]
                    [ Ui.button (not m.licorneVisible)
                        BasculerLicorne
                        (if m.licorneVisible then
                            "Rendre invisible"

                         else
                            "Révéler la licorne"
                        )
                    , Ui.button m.licorneDiagnostic
                        InspecterLicorne
                        (if m.licorneDiagnostic then
                            "Voir la silhouette"

                         else
                            "Voir les pièces"
                        )
                    ]
                , if m.licorneDiagnostic then
                    Ui.small "Audio : quatre segments de corne, œil et museau. Visio : une mèche, une oreille, pointe de corne et mâchoire. Kino : cinq mèches, une oreille, front, chanfrein et joue. Aucun disque ajouté à la silhouette."

                  else
                    Element.none
                , MrJam.lien "↓ SVG factorisé de référence" "exports/Licorne-factorisee.svg"
                , MrJam.lien "Pourquoi une licorne invisible ?" "philosophie.html#licorne"
                , Ui.small "Sommet géométrique. Non retenu parmi les sept couleurs principales."
                ]

          else
            case scene role css of
                Just rendu ->
                    illustration prefixe (P.nom role ++ " · palette candidate") rendu

                Nothing ->
                    Element.none
        , if role /= Licorne then
            MrJam.lien "↓ SVG — palette de référence"
                ("exports/Palette-"
                    ++ (case role of
                            Xiaoping ->
                                "X"

                            Ydris ->
                                "Y"

                            Zoe ->
                                "Z"

                            _ ->
                                P.nom role
                       )
                    ++ ".svg"
                )

          else
            Element.none
        , code css
        , Ui.small ("h = " ++ Ui.format 6 col.h ++ "°")
        , code ("sRGB = (" ++ String.fromFloat rgb.r ++ ", " ++ String.fromFloat rgb.g ++ ", " ++ String.fromFloat rgb.b ++ ")")
        , code (P.hex col |> Maybe.withDefault "Hors gamut sRGB")
        ]


rangees : Int -> List (Element msg) -> Element msg
rangees nombre elements =
    if List.isEmpty elements then
        Element.none

    else
        column [ width fill, spacing 18 ]
            [ row [ width fill, spacing 18, Element.alignTop ] (List.map (el [ width fill, Element.alignTop ]) (List.take nombre elements))
            , rangees nombre (List.drop nombre elements)
            ]


champ : String -> String -> String -> (String -> Message) -> Element Message
champ identifiant libelle valeur modifier =
    MrJam.champIdentifieSoumis
        { identifiant = identifiant, libelle = libelle, aide = Nothing, exemple = Nothing, limite = Just 32 }
        valeur
        modifier
        Appliquer


vue : Modele -> Html.Html Message
vue m =
    let
        p =
            m.parametres

        nombre =
            if m.largeur < 620 then
                1

            else if m.largeur < 1050 then
                2

            else
                4

        duo a b =
            if m.largeur < 850 then
                column [ width fill, spacing 24 ] [ a, b ]

            else
                row [ width fill, spacing 28, Element.alignTop ] [ el [ width fill, Element.alignTop ] a, el [ width fill, Element.alignTop ] b ]

        actuel =
            P.depuisSrgb { r = 100 / 255, g = 194 / 255, b = 155 / 255 }
    in
    Disposition.cadre []
        (column
            [ width (Element.maximum 1160 fill)
            , Element.centerX
            , paddingXY
                (if m.largeur < 720 then
                    20

                 else
                    48
                )
                28
            , spacing 28
            ]
            [ wrappedRow [ width fill, spacing 24, Region.navigation, Region.description "Pages de l’atelier" ]
                [ MrJam.lien "Atelier du logo" "./", MrJam.lien "Philosophie du logo" "philosophie.html", MrJam.lienActif True "Palette OKLCH" "palette.html" ]
            , Ui.label "Mister Jam · Couleurs"
            , Element.paragraph
                [ width fill
                , Region.heading 1
                , Police.family [ Police.typeface "Georgia", Police.serif ]
                , Police.size
                    (if m.largeur < 720 then
                        38

                     else
                        58
                    )
                , Police.letterSpacing -1.5
                ]
                [ text "Une palette, deux paramètres." ]
            , MrJam.paragraphe "La palette de référence d’ÉcoLogo retient le chroma commun le plus élevé possible en sRGB. Sept couleurs habillent les dessins ; la Licorne rose invisible complète le huitième sommet et participe à la même contrainte. Le plan reste disponible pour comparer d’autres paires L et C."
            , Ui.card [ width fill, padding 24, spacing 18 ]
                [ duo (plan m) (geometrie p)
                , duo (champ "palette-l" "L · clarté" m.saisieL SaisirL) (champ "palette-c" "C · chroma" m.saisieC SaisirC)
                , wrappedRow [ spacing 12, width fill ] [ Ui.primary Appliquer "Appliquer L et C", Ui.button False Reinitialiser "Palette de référence", MrJam.lien "Lien vers cette paire" ("palette.html?" ++ P.encoder p) ]
                , el [ width fill, Accessibilite.etat ] (Ui.small m.message)
                , el [ width fill, Accessibilite.identifiant "valeurs-palette" ] (code ("Paire sélectionnée : L = " ++ String.fromFloat p.l ++ " ; C = " ++ String.fromFloat p.c))
                , Ui.small "L’adresse suit chaque réglage : copiez-la pour retrouver exactement la même paire. Les codes hexadécimaux sont arrondis à 8 bits ; les aperçus utilisent les valeurs OKLCH complètes."
                ]
            , Ui.card [ width fill, spacing 14, Accessibilite.identifiant "reference-palette" ]
                [ Ui.heading 2 "La référence : le chroma commun maximal"
                , code ("L = " ++ String.fromFloat P.reference.l ++ " ; C = " ++ String.fromFloat P.reference.c)
                , Ui.paragraph ("Ce point maximise C sur l’enveloppe réelle des huit gamuts sRGB. À son sommet, les limites se rejoignent pour : " ++ String.join " et " (List.map P.nom (P.limiteCommune P.reference.l).roles) ++ ". Aucun triangle approché ni ajustement par couleur n’intervient dans ce choix.")
                , wrappedRow [ width fill, spacing 16 ] [ MrJam.lien "↓ Palette JSON" "exports/palette.json", MrJam.lien "↓ Variables CSS" "exports/palette.css", MrJam.lien "Le sens de cette construction →" "philosophie.html#palette" ]
                ]
            , Ui.heading 2 "La palette sur les dessins"
            , Ui.paragraph "Les modalités conservent leurs associations : Audio orangé, Visio bleu, Kino mauve. Les personnages prennent les sommets prévus : Xiaoping jaune, Ydris vert, Zoé bleu. Tous partagent exactement le même L et le même C, y compris le sommet invisible."
            , rangees nombre (List.indexedMap (carteCouleur m) P.roles)
            , Ui.card [ width fill, padding 24, spacing 16 ]
                [ Ui.heading 2 "Un repère : le logo historique"
                , duo (illustration "palette-logo-actuel" "Logo actuel · #64c29b" (Animation.static "#64c29b" Composition.logo))
                    (column [ width fill, spacing 12 ]
                        [ code ("#64c29b ≈ " ++ P.css actuel)
                        , Ui.paragraph "Ce repère historique reste fixe. Les nouvelles couleurs sont définies par une paire commune choisie au maximum de chroma. À forte clarté, les formes blanches deviennent moins contrastées ; les aperçus permettent aussi de juger cet effet réel."
                        ]
                    )
                ]
            , Ui.heading 2 "Une contrainte commune, aucune retouche isolée"
            , MrJam.paragraphe "Pour chaque clarté, nous cherchons le chroma maximal sRGB de chacune des huit teintes, puis retenons le plus petit. Le curseur réduit le chroma commun si nécessaire : aucune composante RGB n’est tronquée pour sauver une couleur. La frontière dessinée est échantillonnée ; chaque sélection est vérifiée à sa propre clarté."
            , code ("φ = (1 + √5) / 2 ; angle d’or = 360 / φ² = " ++ String.fromFloat P.angleOr ++ "° ; h(n) = (angle d’or + 45n) modulo 360")
            , MrJam.lien "Définition et conversions OKLab — Björn Ottosson" "https://bottosson.github.io/posts/oklab/"
            , Ui.small "Logo et déclinaisons : toute utilisation est strictement réservée. MrJ.am · ÉcoLogo"
            ]
        )
