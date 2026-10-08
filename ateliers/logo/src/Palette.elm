port module Palette exposing (main)

import Browser
import Browser.Events
import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Primitives as Primitives
import Echo.Render as Render
import Element exposing (Element, column, el, fill, height, html, htmlAttribute, padding, paddingXY, px, row, spacing, text, width, wrappedRow)
import Element.Font as Police
import Element.Region as Region
import Html
import Html.Attributes as H
import Html.Events as Events
import Json.Decode as D
import MrJam
import MrJam.Disposition as Disposition
import Palette.Couleurs as P exposing (Role(..))
import Shared.Ui as Ui
import Svg
import Svg.Attributes as A


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


clavier : D.Decoder ( Message, Bool )
clavier =
    D.map2 Tuple.pair (D.field "key" D.string) (D.field "shiftKey" D.bool)
        |> D.andThen
            (\( touche, rapide ) ->
                let
                    pas =
                        if rapide then
                            0.01

                        else
                            0.001
                in
                case touche of
                    "ArrowUp" ->
                        D.succeed ( Clavier pas 0, True )

                    "ArrowDown" ->
                        D.succeed ( Clavier -pas 0, True )

                    "ArrowRight" ->
                        D.succeed ( Clavier 0 pas, True )

                    "ArrowLeft" ->
                        D.succeed ( Clavier 0 -pas, True )

                    _ ->
                        D.fail "Touche laissée au navigateur"
            )


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

        courbe trace =
            Svg.path
                [ A.d trace.d
                , A.fill "none"
                , A.stroke trace.couleur
                , A.strokeWidth
                    (if m.frontiereSelectionnee == Just trace.role then
                        "4"

                     else
                        "2"
                    )
                , A.strokeDasharray trace.tirets
                , A.opacity
                    (if m.frontiereSelectionnee == Nothing || m.frontiereSelectionnee == Just trace.role then
                        "1"

                     else
                        "0.25"
                    )
                , H.attribute "vector-effect" "non-scaling-stroke"
                , H.attribute "data-frontiere-role" (P.cle trace.role)
                , H.attribute "data-h" (String.fromFloat (P.angle trace.role))
                ]
                [ Svg.title [] [ Svg.text ("Limite sRGB · " ++ P.nom trace.role) ] ]

        legende trace =
            column [ width fill, spacing 5 ]
                [ html
                    (Svg.svg [ A.viewBox "0 0 100 6", A.width "100%", A.height "6", H.attribute "aria-hidden" "true" ]
                        [ Svg.line [ A.x1 "0", A.x2 "100", A.y1 "3", A.y2 "3", A.stroke trace.couleur, A.strokeWidth "2", A.strokeDasharray trace.tirets ] [] ]
                    )
                , Ui.button (m.frontiereSelectionnee == Just trace.role) (Inspecter trace.role) (P.nom trace.role)
                ]
    in
    column [ width fill, spacing 14 ]
        [ Ui.heading 2 "Choisir L et C"
        , Ui.small "L ↑ · clarté : 0 en bas, 1 en haut"
        , el [ width fill, height (px 300), htmlAttribute (H.style "margin" "8px 0") ]
            (html
                (Svg.svg
                    [ A.viewBox "0 0 400 300"
                    , A.preserveAspectRatio "none"
                    , A.width "100%"
                    , A.height "100%"
                    , H.attribute "data-palette-plan" "true"
                    , H.attribute "role" "group"
                    , H.attribute "tabindex" "0"
                    , H.attribute "aria-label" "Plan L × C"
                    , H.attribute "aria-describedby" "aide-plan valeurs-palette"
                    , H.attribute "aria-roledescription" "sélecteur à deux axes"
                    , H.style "touch-action" "none"
                    , H.style "cursor" "crosshair"
                    , H.style "overflow" "visible"
                    , Events.preventDefaultOn "keydown" clavier
                    ]
                    ([ Svg.title [] [ Svg.text "Huit frontières sRGB et leur enveloppe commune" ]
                     , Svg.rect [ A.width "400", A.height "300", A.fill "#f1eeeb", A.stroke "#b9c8c3", A.strokeWidth "1" ] []
                     , Svg.path [ A.d regionValide, A.fill "#d6e9df", H.attribute "data-gamut-region" "true" ] []
                     , Svg.g [ A.stroke "#193d38", A.strokeOpacity "0.18", A.strokeWidth "1", H.style "pointer-events" "none" ]
                        (List.range 1 3 |> List.map (\i -> Svg.line [ A.x1 "0", A.x2 "400", A.y1 (String.fromInt (i * 75)), A.y2 (String.fromInt (i * 75)) ] []))
                     ]
                        ++ List.map courbe
                            (List.sortBy
                                (\trace ->
                                    if m.frontiereSelectionnee == Just trace.role then
                                        1

                                    else
                                        0
                                )
                                traces
                            )
                        ++ [ Svg.path [ A.d traceCommun, A.fill "none", A.stroke "white", A.strokeWidth "5", H.attribute "vector-effect" "non-scaling-stroke", H.attribute "aria-hidden" "true" ] []
                           , Svg.path [ A.d traceCommun, A.fill "none", A.stroke "#193d38", A.strokeWidth "2.5", A.strokeDasharray "3 2", H.attribute "vector-effect" "non-scaling-stroke", H.attribute "data-gamut-frontiere" "true" ] []
                           , Svg.line [ A.x1 "0", A.x2 "400", A.y1 (String.fromFloat (300 * (1 - p.l))), A.y2 (String.fromFloat (300 * (1 - p.l))), A.stroke "#193d38", A.strokeOpacity "0.35", A.strokeDasharray "3 4" ] []
                           , Svg.circle [ A.cx (String.fromFloat (400 * p.c / P.chromaPlan)), A.cy (String.fromFloat (300 * (1 - p.l))), A.r "7", A.fill "#193d38", A.stroke "white", A.strokeWidth "3", H.attribute "data-palette-curseur" "true" ] []
                           ]
                    )
                )
            )
        , Ui.small ("C → · chroma : 0 à " ++ Ui.format 4 P.chromaPlan)
        , el [ width fill, htmlAttribute (H.id "aide-plan") ] (Ui.paragraph "Huit courbes colorées : les limites sRGB individuelles. La ligne sombre bordée de blanc est leur enveloppe commune ; seule la zone verte à sa gauche est sélectionnable. Déplacez le point à la souris ou au toucher. Au clavier : flèches, pas de 0,001 ; Maj + flèches, pas de 0,01. Au-delà de l’enveloppe, le point revient sur la limite commune.")
        , el [ width fill, htmlAttribute (H.attribute "data-limite-commune" (String.fromFloat limite.c)), htmlAttribute (H.attribute "data-limitantes" (String.join " " (List.map P.cle limite.roles))) ]
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

        carre numero =
            Svg.polygon
                [ A.points (List.filter (\role -> P.tetrade role == numero) P.roles |> List.map coord |> String.join " ")
                , A.fill "none"
                , A.stroke
                    (if numero == 1 then
                        "#193d38"

                     else
                        "#8a5277"
                    )
                , A.strokeWidth "2"
                , A.strokeDasharray
                    (if numero == 1 then
                        "none"

                     else
                        "5 4"
                    )
                , H.attribute "data-tetrade" (String.fromInt numero)
                ]
                []

        sommet index role =
            let
                ( x, y ) =
                    position (122 * p.c / P.chromaAffiche) role

                ( lx, ly ) =
                    position 143 role
            in
            Svg.g []
                [ Svg.circle
                    [ A.cx (String.fromFloat x)
                    , A.cy (String.fromFloat y)
                    , A.r "5"
                    , A.fill (P.css (P.couleur p role))
                    , A.stroke "#193d38"
                    , A.strokeDasharray
                        (if role == Licorne then
                            "2 2"

                         else
                            "none"
                        )
                    , H.attribute "data-sommet" (P.cle role)
                    ]
                    []
                , Svg.text_ [ A.x (String.fromFloat lx), A.y (String.fromFloat ly), A.textAnchor "middle", A.dominantBaseline "middle", A.fontSize "12", A.fill "#193d38" ] [ Svg.text (String.fromInt (index + 1)) ]
                ]
    in
    column [ width fill, spacing 14 ]
        [ Ui.heading 2 "Deux carrés, un octogone"
        , el [ width fill, height (px 300) ]
            (html
                (Svg.svg [ A.viewBox "0 0 320 320", A.width "100%", A.height "100%", H.attribute "role" "img", H.attribute "aria-label" "Plan OKLab a,b : deux carrés décalés de 45 degrés" ]
                    ([ Svg.line [ A.x1 "12", A.y1 "160", A.x2 "308", A.y2 "160", A.stroke "#b9c8c3" ] []
                     , Svg.line [ A.x1 "160", A.y1 "12", A.x2 "160", A.y2 "308", A.stroke "#b9c8c3" ] []
                     , Svg.text_ [ A.x "304", A.y "180", A.fontSize "12" ] [ Svg.text "a" ]
                     , Svg.text_ [ A.x "169", A.y "15", A.fontSize "12" ] [ Svg.text "b" ]
                     , Svg.circle [ A.cx "160", A.cy "160", A.r "2", A.fill "#193d38" ] []
                     , carre 1
                     , carre 2
                     ]
                        ++ List.indexedMap sommet P.roles
                    )
                )
            )
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
    el [ width fill, height (px 155) ] (html (Render.view { options | box = "-2 -2 34 34", title = titre } rendu))


code : String -> Element msg
code contenu =
    el [ width fill, Police.size 12, Police.family [ Police.monospace ], htmlAttribute (H.style "overflow-wrap" "anywhere"), htmlAttribute (H.style "word-break" "break-word") ] (Element.paragraph [ width fill ] [ text contenu ])


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
    Ui.card [ width fill, spacing 12, htmlAttribute (H.attribute "data-role-palette" (P.cle role)), htmlAttribute (H.attribute "data-l" (String.fromFloat p.l)), htmlAttribute (H.attribute "data-c" (String.fromFloat p.c)), htmlAttribute (H.attribute "data-h" (String.fromFloat col.h)) ]
        [ Ui.label (String.fromInt (index + 1) ++ " · Tétrade " ++ String.fromInt (P.tetrade role))
        , Ui.heading 3 (P.nom role)
        , if role == Licorne then
            let
                options =
                    Render.defaults prefixe
            in
            column [ width fill, spacing 12 ]
                [ el [ width fill, height (px 155) ]
                    (html
                        (Render.view
                            { options
                                | box = "-2 -2 34 34"
                                , title =
                                    if m.licorneVisible then
                                        "Licorne : tête, corne en spirale et crinière"

                                    else
                                        "Licorne invisible : seul le fond rose reste visible"
                                , trous = Composition.trousLicorne
                                , diagnostic = m.licorneDiagnostic
                                , hidden =
                                    if m.licorneVisible then
                                        []

                                    else
                                        List.map .id Composition.licorne
                            }
                            (Animation.static css Composition.licorne)
                        )
                    )
                , Ui.small "Proposition · La crinière suggère le profil, sans contour de cou. Huit contours du logo, une corne en spirale et un seul petit évidement pour l’œil."
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
                    Ui.small "Audio : oreille. Visio : tête, trois mèches et trois pièces de la corne. Le disque sert uniquement à évider l’œil."

                  else
                    Element.none
                , MrJam.lien "↓ SVG de la proposition" "exports/Licorne-factorisee.svg"
                , Ui.small "Sommet géométrique. Non retenu parmi les sept couleurs principales."
                ]

          else
            case scene role css of
                Just rendu ->
                    illustration prefixe (P.nom role ++ " · palette candidate") rendu

                Nothing ->
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
            [ wrappedRow [ width fill, spacing 24, Region.navigation, htmlAttribute (H.attribute "aria-label" "Pages de l’atelier") ]
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
            , MrJam.paragraphe "Choisissez une clarté L et un chroma C communs. Sept couleurs habillent les véritables dessins de l’atelier ; un huitième sommet, la Licorne rose invisible, complète la construction. Cette page explore une candidate : elle ne fixe pas la palette définitive."
            , Ui.card [ width fill, padding 24, spacing 18 ]
                [ duo (plan m) (geometrie p)
                , duo (champ "palette-l" "L · clarté" m.saisieL SaisirL) (champ "palette-c" "C · chroma" m.saisieC SaisirC)
                , wrappedRow [ spacing 12, width fill ] [ Ui.primary Appliquer "Appliquer L et C", Ui.button False Reinitialiser "État initial", MrJam.lien "Lien vers cette paire" ("palette.html?" ++ P.encoder p) ]
                , el [ width fill, htmlAttribute (H.attribute "role" "status") ] (Ui.small m.message)
                , el [ width fill, htmlAttribute (H.id "valeurs-palette") ] (code ("Paire sélectionnée : L = " ++ String.fromFloat p.l ++ " ; C = " ++ String.fromFloat p.c))
                , Ui.small "L’adresse suit chaque réglage : copiez-la pour retrouver exactement la même paire. Les codes hexadécimaux sont arrondis à 8 bits ; les aperçus utilisent les valeurs OKLCH complètes."
                ]
            , Ui.heading 2 "La candidate sur les dessins"
            , Ui.paragraph "Les modalités conservent leurs associations : Audio orangé, Visio bleu, Kino mauve. Les personnages prennent les sommets prévus : Xiaoping jaune, Ydris vert, Zoé bleu. Tous partagent exactement le même L et le même C, y compris le sommet invisible."
            , rangees nombre (List.indexedMap (carteCouleur m) P.roles)
            , Ui.card [ width fill, padding 24, spacing 16 ]
                [ Ui.heading 2 "Un repère : le logo actuel"
                , duo (illustration "palette-logo-actuel" "Logo actuel · #64c29b" (Animation.static "#64c29b" Composition.logo))
                    (column [ width fill, spacing 12 ]
                        [ code ("#64c29b ≈ " ++ P.css actuel)
                        , Ui.paragraph "Ce repère reste fixe. L’état initial de la candidate est L = 0,7 et C = 0,1 : un point de départ dans le domaine commun, à explorer. À forte clarté, les formes blanches deviennent moins contrastées ; ces aperçus permettent aussi de juger cet effet réel."
                        ]
                    )
                ]
            , Ui.heading 2 "Une contrainte commune, aucune retouche isolée"
            , MrJam.paragraphe "Pour chaque clarté, nous cherchons le chroma maximal sRGB de chacune des huit teintes, puis retenons le plus petit. Le curseur réduit le chroma commun si nécessaire : aucune composante RGB n’est tronquée pour sauver une couleur. La frontière dessinée est échantillonnée ; chaque sélection est vérifiée à sa propre clarté."
            , code ("φ = (1 + √5) / 2 ; angle d’or = 360 / φ² = " ++ String.fromFloat P.angleOr ++ "° ; h(n) = (angle d’or + 45n) modulo 360")
            , MrJam.lien "Définition et conversions OKLab — Björn Ottosson" "https://bottosson.github.io/posts/oklab/"
            , Ui.small "Logo et déclinaisons : toute utilisation est strictement réservée. MrJ.am · Écho"
            ]
        )
