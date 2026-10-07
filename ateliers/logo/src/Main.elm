port module Main exposing (main)

import Browser
import Browser.Events
import Echo.Animation as Animation exposing (Settings, Strategy(..))
import Echo.Composition as Composition
import Echo.Player as Player exposing (Cycle(..))
import Echo.Primitives as Primitives
import Echo.ReferenceData as Reference
import Echo.Render as Render
import Echo.Settings as Settings
import Echo.Transform as Transform exposing (Chirality(..))
import Element exposing (Element, alignRight, centerY, column, el, fill, height, html, htmlAttribute, none, padding, paddingEach, paddingXY, px, row, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Region as Region
import Html
import Html.Attributes as H
import MrJam
import MrJam.Disposition as Disposition
import Shared.Ui as Ui
import Time


port download : { name : String, mime : String, content : String } -> Cmd msg


port chooseSettings : () -> Cmd msg


port receivedSettings : (String -> msg) -> Sub msg


port reducedMotionChanged : (Bool -> msg) -> Sub msg


type Tab
    = Recompose
    | Spin
    | Geometry


type Parameter
    = Duration
    | Stagger
    | MirrorWidth
    | MobileDuration
    | Rest
    | Turns
    | Spread
    | OmegaReference


type alias Flags =
    { width : Int, reducedMotion : Bool, tab : String, progress : Float, mirror : Float, strategy : String, cible : String }


type alias Model =
    { settings : Settings
    , player : Player.Player
    , cible : Composition.Cible
    , tab : Tab
    , width : Int
    , reduced : Bool
    , loop : Bool
    , notice : String
    , diagnostic : Bool
    , axes : Bool
    , selected : String
    , isolate : Bool
    , hidden : List String
    , comparison : Int
    , mirror : Float
    }


type Msg
    = Tick Time.Posix
    | Resize Int Int
    | Visibility Browser.Events.Visibility
    | ReducedMotion Bool
    | ChooseTab Tab
    | ChoisirCible Composition.Cible
    | Scrub Float
    | TogglePlay
    | PlayDirection Int
    | Reset
    | Loop Bool
    | SetParameter Parameter Float
    | ChangeStrategy Strategy
    | FadeBackground Bool
    | SpinDirection Int
    | Diagnostic Bool
    | Axes Bool
    | Selected String
    | Isolate Bool
    | Hide Bool
    | Comparison Int
    | Mirror Float
    | ExportSettings
    | ImportSettings
    | ReceiveSettings String
    | ExportCurrent
    | ExportLogo
    | ExportX
    | ExporterY
    | ExporterZ
    | ExporterPictogramme Primitives.Brick


main : Program Flags Model Msg
main =
    Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        defaults =
            Animation.defaults

        strategy =
            if flags.strategy == "fondu" || (flags.strategy /= "relief" && flags.reducedMotion) then
                LocalFade

            else
                Relief
    in
    ( { settings = { defaults | strategy = strategy }
      , player = Player.seek flags.progress Player.init
      , tab =
            if flags.tab == "rotation" then
                Spin

            else if flags.tab == "geometrie" then
                Geometry

            else
                Recompose
      , cible =
            if String.toUpper flags.cible == "Y" then
                Composition.Y

            else if String.toUpper flags.cible == "Z" then
                Composition.Z

            else
                Composition.X
      , width = flags.width
      , reduced = flags.reducedMotion
      , loop = False
      , notice = "Prêt à explorer. La lecture se lance à votre initiative."
      , diagnostic = False
      , axes = False
      , selected = "kinesthesique-1"
      , isolate = False
      , hidden = []
      , comparison = 0
      , mirror = clamp 0 1 flags.mirror
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.player.running then
            Browser.Events.onAnimationFrame Tick

          else
            Sub.none
        , Browser.Events.onResize Resize
        , Browser.Events.onVisibilityChange Visibility
        , receivedSettings ReceiveSettings
        , reducedMotionChanged ReducedMotion
        ]


resetWith : Settings -> String -> Model -> Model
resetWith settings notice model =
    { model | settings = Animation.normalize settings, player = Player.seek 0 model.player, notice = notice }


play : Int -> Model -> Model
play direction model =
    let
        p =
            model.player.progress

        player =
            if (direction > 0 && p == 1) || (direction < 0 && p == 0) then
                Player.seek
                    (if direction < 0 then
                        1

                     else
                        0
                    )
                    model.player

            else
                model.player

        duration =
            if model.tab == Spin then
                Animation.rotationDuration model.settings

            else
                model.settings.duration

        cycle =
            if not model.loop then
                Once

            else if model.tab == Spin then
                Repeat

            else
                PingPong
    in
    { model
        | player =
            Player.start duration
                (if model.tab == Spin then
                    0

                 else
                    0.6
                )
                cycle
                direction
                player
        , notice = "Lecture en cours. Le curseur permet de prendre la main à tout instant."
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        s =
            model.settings

        done next =
            ( next, Cmd.none )
    in
    case msg of
        Tick now ->
            done { model | player = Player.tick now model.player }

        Resize w _ ->
            done { model | width = w }

        Visibility visibility ->
            if visibility == Browser.Events.Hidden then
                done { model | player = Player.pause model.player, notice = "Lecture suspendue pendant l’absence. Reprenez quand vous le souhaitez." }

            else
                done model

        ReducedMotion reduced ->
            if reduced then
                done (resetWith { s | strategy = LocalFade } "Réduction du mouvement activée : fondu local, lecture volontaire." { model | reduced = True, loop = False })

            else
                done { model | reduced = False }

        ChooseTab tab ->
            done { model | tab = tab, player = Player.seek 0 model.player, notice = "Vue changée. Lecture en pause." }

        ChoisirCible cible ->
            done { model | cible = cible, player = Player.seek 0 model.player, hidden = [], isolate = False, selected = "kinesthesique-1", notice = "Cible " ++ Composition.nom cible ++ " sélectionnée. Retour au logo, lecture en pause." }

        Scrub p ->
            done { model | player = Player.seek p model.player, notice = "Inspection manuelle · toutes les pièces sont immobilisées." }

        TogglePlay ->
            if model.player.running then
                done { model | player = Player.pause model.player, notice = "En pause · positions, retournements et couleur sont figés." }

            else
                done (play model.player.direction model)

        PlayDirection direction ->
            done (play direction model)

        Reset ->
            done { model | player = Player.seek 0 model.player, notice = "Retour exact au logo de référence." }

        Loop enabled ->
            done { model | loop = enabled, player = Player.pause model.player, notice = "Mode de lecture modifié. Appuyez sur Lire pour reprendre." }

        SetParameter parameter value ->
            let
                settings =
                    case parameter of
                        Duration ->
                            { s | duration = value }

                        Stagger ->
                            { s | stagger = value }

                        MirrorWidth ->
                            { s | mirrorWidth = value }

                        MobileDuration ->
                            { s | mobileDuration = value }

                        Rest ->
                            { s | rest = value }

                        Turns ->
                            { s | turns = round value }

                        Spread ->
                            { s | spread = value }

                        OmegaReference ->
                            { s | omegaReference = value }
            in
            done (resetWith settings "Réglage modifié · lecture arrêtée et retour au logo." model)

        ChangeStrategy strategy ->
            done (resetWith { s | strategy = strategy } "Stratégie modifiée · retour au logo pour comparer le même trajet." model)

        FadeBackground enabled ->
            done (resetWith { s | fadeBackground = enabled } "Fond modifié · retour au logo. Sans fondu, le disque reste vert." model)

        SpinDirection direction ->
            done (resetWith { s | spinDirection = direction } "Sens de rotation modifié · retour au logo." model)

        Diagnostic enabled ->
            done { model | diagnostic = enabled }

        Axes enabled ->
            done { model | axes = enabled }

        Selected id ->
            done { model | selected = id }

        Isolate enabled ->
            done { model | isolate = enabled }

        Hide hidden ->
            done
                { model
                    | hidden =
                        if hidden then
                            model.selected :: List.filter ((/=) model.selected) model.hidden

                        else
                            List.filter ((/=) model.selected) model.hidden
                }

        Comparison mode ->
            done { model | comparison = mode }

        Mirror progress ->
            done { model | mirror = clamp 0 1 progress }

        ExportSettings ->
            ( model, download { name = "reglages-logo-x.json", mime = "application/json", content = Settings.encode model.settings } )

        ImportSettings ->
            ( model, chooseSettings () )

        ReceiveSettings content ->
            case Settings.decode content of
                Ok settings ->
                    done (resetWith settings "Réglages importés et bornés aux plages de l’atelier. Lecture en pause." model)

                Err _ ->
                    done { model | notice = "Import impossible : fichier de réglages JSON de version 1 attendu. Les réglages sont conservés." }

        ExportCurrent ->
            ( model, download { name = "scene-logo-" ++ String.toLower (Composition.nom model.cible) ++ ".svg", mime = "image/svg+xml", content = Render.svgString "export" (sceneBox model.tab) (currentScene model) } )

        ExportLogo ->
            ( model, download { name = "Logo-factorise.svg", mime = "image/svg+xml", content = Render.svgString "logo" "0 0 30 30" (Animation.static "#64c29b" Composition.logo) } )

        ExportX ->
            ( model, download { name = "X-factorise.svg", mime = "image/svg+xml", content = Render.svgString "x" "0 0 30 30" (Animation.static "#9c3e65" Composition.x) } )

        ExporterY ->
            ( model, download { name = "Y-factorise.svg", mime = "image/svg+xml", content = Render.svgString "y" "0 0 30 30" (Animation.static (Composition.fond Composition.Y) Composition.y) } )

        ExporterZ ->
            ( model, download { name = "Z-factorise.svg", mime = "image/svg+xml", content = Render.svgString "z" "0 0 30 30" (Animation.static (Composition.fond Composition.Z) Composition.z) } )

        ExporterPictogramme forme ->
            ( model, download { name = Primitives.label forme ++ ".svg", mime = "image/svg+xml", content = Render.svgString (Primitives.key forme) "0 0 30 30" (Animation.static "#64c29b" (Composition.pictogramme forme)) } )


currentScene : Model -> Animation.Scene
currentScene model =
    if model.tab == Spin then
        Animation.rotation model.settings model.player.progress

    else
        Animation.recomposer model.cible model.settings model.player.progress


sceneBox : Tab -> String
sceneBox tab =
    if tab == Spin then
        "-15 -20 60 60"

    else
        "-9 -12 48 48"


view : Model -> Html.Html Msg
view model =
    Disposition.cadre
        [ Background.color Ui.surface
        , Font.color Ui.ink
        , Font.size 14
        , Font.family [ Font.typeface "Inter", Font.typeface "Segoe UI", Font.sansSerif ]
        , htmlAttribute (H.class "app-root")
        ]
        (column
            [ width (Element.maximum 1260 fill)
            , Element.centerX
            , paddingXY
                (if model.width < 650 then
                    18

                 else
                    40
                )
                28
            , spacing 30
            ]
            [ header model
            , intro model
            , navigation
            , choixCible model
            , tabs model
            , if model.tab == Geometry then
                geometryView model

              else
                animationView model
            , footer model
            ]
        )


header : Model -> Element Msg
header model =
    row [ width fill, paddingEach { top = 0, left = 0, right = 0, bottom = 20 }, Border.widthEach { top = 0, left = 0, right = 0, bottom = 1 }, Border.color (Element.rgb255 218 227 220) ]
        [ row [ spacing 11 ]
            [ el [ Font.size 28, Font.bold, Font.letterSpacing -1 ] (text "écho")
            , el [ width (px 1), height (px 22), Background.color (Element.rgb255 198 211 201) ] none
            , column [ spacing 3 ] [ Ui.label "Atelier graphique", Ui.small "Explorer le mouvement" ]
            ]
        , if model.width > 630 then
            el [ alignRight ] (Ui.badge "1 centre · 3 contours")

          else
            none
        ]


intro : Model -> Element Msg
intro model =
    column [ width fill, spacing 12, paddingXY 0 6 ]
        [ Ui.label "Étude de mouvement / 01"
        , Element.paragraph
            [ Region.heading 1
            , Font.family [ Font.typeface "Georgia", Font.serif ]
            , Font.size
                (if model.width < 650 then
                    36

                 else
                    52
                )
            , Font.letterSpacing -1.5
            ]
            [ text "Du logo au mouvement." ]
        , Ui.paragraph "Une connaissance, trois modalités : audio, visio, kino. Explorez leurs formes et composez Xiaoyu, Idriss et Zoé, les trois tuteurs des axes X, Y et Z."
        , if model.reduced then
            Ui.badge "Réduction du mouvement · lecture à votre initiative"

          else
            none
        ]


navigation : Element msg
navigation =
    wrappedRow [ width fill, spacing 24, Region.navigation, htmlAttribute (H.attribute "aria-label" "Pages de l’atelier") ]
        [ MrJam.lienActif True "Atelier du logo" "./"
        , MrJam.lien "Philosophie du logo" "philosophie.html"
        , MrJam.lien "Style MrJ.am" "https://github.com/MrJ-am/style-mrjam"
        ]


choixCible : Model -> Element Msg
choixCible model =
    wrappedRow [ width fill, spacing 12 ]
        [ Ui.label "Composer"
        , Ui.button (model.cible == Composition.X) (ChoisirCible Composition.X) "X · Xiaoyu"
        , Ui.button (model.cible == Composition.Y) (ChoisirCible Composition.Y) "Y · Idriss"
        , Ui.button (model.cible == Composition.Z) (ChoisirCible Composition.Z) "Z · Zoé"
        , Ui.small
            (if model.cible == Composition.Y then
                "8 occurrences · 6 placements distincts"

             else if model.cible == Composition.Z then
                "5 occurrences · une silhouette en Z"

             else
                "7 occurrences · 7 placements distincts"
            )
        ]


tabs : Model -> Element Msg
tabs model =
    wrappedRow [ spacing 8, width fill, Region.navigation ]
        [ Ui.button (model.tab == Recompose) (ChooseTab Recompose) "01  Recomposition"
        , Ui.button (model.tab == Spin) (ChooseTab Spin) "02  Rotation centrifuge"
        , Ui.button (model.tab == Geometry) (ChooseTab Geometry) "03  Géométrie"
        ]


animationView : Model -> Element Msg
animationView model =
    let
        mainColumn =
            column [ width fill, spacing 16, Element.alignTop ] [ stage model, transport model ]

        sidebar =
            column
                [ width
                    (if model.width < 950 then
                        fill

                     else
                        px 320
                    )
                , spacing 16
                , Element.alignTop
                ]
                [ settingsPanel model, anatomy model ]
    in
    column [ width fill, spacing 20 ]
        [ if model.width < 950 then
            column [ width fill, spacing 20 ] [ mainColumn, sidebar ]

          else
            row [ width fill, spacing 24, Element.alignTop ] [ mainColumn, sidebar ]
        , wrappedRow [ spacing 8, width fill ] [ Ui.button False ExportCurrent "↓ Exporter la scène SVG", Ui.button False ExportSettings "↓ Enregistrer les réglages", Ui.button False ImportSettings "↑ Charger des réglages" ]
        ]


stage : Model -> Element Msg
stage model =
    let
        options =
            Render.defaults "main-scene"

        stats =
            Animation.rotationStats model.settings model.player.progress

        metric name value =
            column [ spacing 6 ] [ el [ Font.size 10, Font.color (Element.rgb255 162 189 189), Font.letterSpacing 1 ] (text name), el [ Font.size 15, Font.color Ui.white, Font.family [ Font.monospace ] ] (text value) ]
    in
    column
        [ width fill
        , spacing 0
        , Background.color (Element.rgb255 20 43 49)
        , Border.rounded 18
        , htmlAttribute (H.attribute "data-progress" (String.fromFloat model.player.progress))
        , htmlAttribute
            (H.attribute "data-running"
                (if model.player.running then
                    "true"

                 else
                    "false"
                )
            )
        ]
        [ row [ width fill, paddingXY 22 20 ]
            [ el [ Font.size 10, Font.letterSpacing 1.6, Font.color (Element.rgb255 171 200 193) ]
                (text
                    (if model.tab == Spin then
                        "SCÈNE / ROTATION CENTRIFUGE"

                     else
                        "SCÈNE / LOGO → " ++ Composition.nom model.cible
                    )
                )
            , el [ alignRight, Font.size 11, Font.color (Element.rgb255 200 224 213) ]
                (text
                    (if model.player.running then
                        "●  En lecture"

                     else
                        "○  En pause"
                    )
                )
            ]
        , el [ width fill ]
            (html
                (Html.div [ H.class "scene-svg" ]
                    [ Render.view
                        { options
                            | box = sceneBox model.tab
                            , diagnostic = model.diagnostic
                            , axes = model.axes
                            , title =
                                if model.tab == Spin then
                                    "Rotation centrifuge du logo"

                                else
                                    "Recomposition du logo en personnage " ++ Composition.nom model.cible
                        }
                        (currentScene model)
                    ]
                )
            )
        , row [ width fill, paddingXY 24 22, Element.spaceEvenly ]
            (if model.tab == Spin then
                [ metric "ANGLE" (Ui.format 0 (stats.angle * 180 / pi) ++ "°"), metric "VITESSE" (Ui.format 2 stats.omega ++ " rad/s"), metric "ÉCARTEMENT" (Ui.format 2 stats.spread ++ " u") ]

             else
                [ metric "PRIMITIVES" "04", metric "CIBLE" (String.fromInt (List.length (Composition.instances model.cible)) ++ " pièces"), metric "RETOURNEMENTS" (String.fromInt (List.length (List.filter .reflected (Composition.donnees model.cible)))) ]
            )
        ]


transport : Model -> Element Msg
transport model =
    Ui.card [ padding 20, spacing 18 ]
        [ wrappedRow [ width fill, spacing 8 ]
            [ Ui.primary TogglePlay
                (if model.player.running then
                    "Ⅱ  Pause"

                 else
                    "▷  Lire"
                )
            , Ui.button False Reset "↺  Recommencer"
            , if model.tab == Recompose then
                Ui.button False (PlayDirection 1) ("Logo → " ++ Composition.nom model.cible)

              else
                none
            , if model.tab == Recompose then
                Ui.button False (PlayDirection -1) (Composition.nom model.cible ++ " → Logo")

              else
                none
            ]
        , Ui.slider "Progression" " %" 0 100 0.1 (100 * model.player.progress) (\p -> Scrub (p / 100))
        , row [ width fill ]
            [ Ui.button (model.player.progress == 0) (Scrub 0) "Fixer le logo"
            , el [ alignRight ]
                (Ui.button (model.player.progress == 1)
                    (Scrub 1)
                    (if model.tab == Spin then
                        "Fin du cycle"

                     else
                        "Fixer " ++ Composition.nom model.cible
                    )
                )
            ]
        , Ui.checkbox
            (if model.tab == Spin then
                "Boucler le cycle"

             else
                "Boucle aller-retour · repos de 0,6 s"
            )
            model.loop
            Loop
        ]


settingsPanel : Model -> Element Msg
settingsPanel model =
    let
        s =
            model.settings
    in
    Ui.card []
        ([ row [ width fill ]
            [ Ui.heading 2 "Le mouvement"
            , el [ alignRight ]
                (Ui.badge
                    (if model.tab == Spin then
                        "Rotation"

                     else
                        "Logo ↔ " ++ Composition.nom model.cible
                    )
                )
            ]
         , Ui.small "Chaque réglage arrête la lecture et revient au logo."
         ]
            ++ (if model.tab == Spin then
                    [ Ui.slider "Durée du mouvement" " s" 0.2 12 0.1 s.mobileDuration (SetParameter MobileDuration)
                    , Ui.slider "Repos à chaque extrémité" " s" 0 2 0.1 s.rest (SetParameter Rest)
                    , Ui.slider "Nombre de tours" "" 0 8 1 (toFloat s.turns) (SetParameter Turns)
                    , Ui.slider "Écartement maximal" " u" 0 6 0.1 s.spread (SetParameter Spread)
                    , Ui.slider "Vitesse de référence" " rad/s" 1 20 0.1 s.omegaReference (SetParameter OmegaReference)
                    , wrappedRow [ spacing 6 ] [ Ui.button (s.spinDirection == 1) (SpinDirection 1) "↻ Horaire", Ui.button (s.spinDirection == -1) (SpinDirection -1) "↺ Antihoraire" ]
                    , Ui.small "L’écartement dépend du carré de la vitesse. La référence reste fixe quand la durée ou les tours changent."
                    ]

                else
                    [ Ui.slider "Durée de l’aller" " s" 0.2 16 0.1 s.duration (SetParameter Duration)
                    , Ui.slider "Décalage des départs" " s" 0 0.25 0.01 s.stagger (SetParameter Stagger)
                    , Ui.divider
                    , Ui.label "Animer les symétries"
                    , strategyControls s.strategy
                    , Ui.small
                        (if s.strategy == Relief then
                            "Une rotation hors du plan, représentée en projection. La pièce s’amincit, passe de tranche, puis présente son autre face."

                         else
                            "Les deux faces d’une même pièce se fondent localement. Une légère transparence apparaît pendant leur recouvrement."
                        )
                    , Ui.slider "Fenêtre du retournement" " % du trajet" 10 90 5 (100 * s.mirrorWidth) (\v -> SetParameter MirrorWidth (v / 100))
                    , Ui.checkbox "Fondu du fond" s.fadeBackground FadeBackground
                    , Ui.small
                        (if model.cible == Composition.Y then
                            "Logo et Y partagent le même fond : vert #64c29b."

                         else if s.fadeBackground then
                            "Vert #64c29b → " ++ Composition.fond model.cible

                         else
                            "Fond fixe : vert #64c29b"
                        )
                    ]
               )
        )


strategyControls : Strategy -> Element Msg
strategyControls strategy =
    column [ spacing 8, width fill ]
        [ Ui.button (strategy == Relief) (ChangeStrategy Relief) "Retournement en relief"
        , Ui.button (strategy == LocalFade) (ChangeStrategy LocalFade) "Fondu local"
        ]


anatomy : Model -> Element Msg
anatomy model =
    Ui.card [ Background.color (Element.rgb255 238 243 237), spacing 13 ]
        [ Ui.label "Suivre les briques"
        , if model.cible == Composition.Z then
            MrJam.lien "↓ Ébauche Z originale" "exports/Z-original.svg"

          else
            Element.none
        , Ui.checkbox "Couleurs diagnostiques" model.diagnostic Diagnostic
        , Ui.checkbox "Afficher le repère O" model.axes Axes
        , Ui.small
            (if model.tab == Spin then
                "La connaissance reste en O. Les trois contours tournent et s’écartent suivant des directions espacées de 120°. Le cadrage reste fixe."

             else
                "Les copies naissent sur leur contour source. Le disque central s’efface pendant la recomposition. "
                    ++ (if model.cible == Composition.X then
                            "Deux contours visio et deux contours kino se retournent."

                        else if model.cible == Composition.Y then
                            "Un contour visio et deux contours kino se retournent. Les doublons rejoignent les mêmes placements."

                        else
                            "Les cinq contours de Zoé se déplacent et tournent. Le contour visio du bras droit se retourne."
                       )
            )
        , if model.diagnostic then
            wrappedRow [ spacing 8 ] (List.map (\b -> row [ spacing 5 ] [ el [ width (px 8), height (px 8), Border.rounded 8, htmlAttribute (H.style "background" (Primitives.color b)), Border.width 1, Border.color Ui.muted ] none, Ui.small (Primitives.label b) ]) Primitives.all)

          else
            none
        ]


geometryView : Model -> Element Msg
geometryView model =
    column [ width fill, spacing 24 ]
        [ Ui.heading 2 "Connaissance, audio, visio, kino"
        , Ui.paragraph "Le disque représente la connaissance, l’aspect sémantique. Chaque pictogramme sensoriel réunit ce même disque et un contour. Le logo complet partage un seul disque entre les trois contours."
        , brickGallery model
        , referenceGallery model
        , if model.width < 900 then
            column [ width fill, spacing 20 ] [ comparisonPanel model, mirrorPanel model ]

          else
            row [ width fill, spacing 24, Element.alignTop ] [ comparisonPanel model, el [ width (px 340) ] (mirrorPanel model) ]
        , correspondence model
        , wrappedRow [ spacing 8 ] [ Ui.button False ExportLogo "↓ Logo factorisé SVG", Ui.button False ExportX "↓ X factorisé SVG", Ui.button False ExporterY "↓ Y factorisé SVG", Ui.button False ExporterZ "↓ Z factorisé SVG", MrJam.lien "↓ Z.svg" "exports/Z.svg", Ui.button False ExportSettings "↓ Réglages JSON", Ui.button False ImportSettings "↑ Charger des réglages" ]
        ]


brickGallery : Model -> Element Msg
brickGallery model =
    let
        brickCard brick =
            let
                options =
                    Render.defaults ("brick-" ++ Primitives.key brick)
            in
            Ui.card [ padding 16, spacing 10 ]
                [ el [ width fill, height (px 120), Background.color (Element.rgb255 36 65 68), Border.rounded 10 ] (html (Render.view { options | box = "-3 -4 36 36", title = Primitives.label brick } (Animation.static "none" (Composition.pictogramme brick))))
                , el [ Font.semiBold ] (text (Primitives.label brick))
                , Ui.small
                    (if brick == Primitives.Connaissance then
                        "Disque central · rayon 2"

                     else
                        "Disque + contour · " ++ Primitives.radii brick
                    )
                , if brick == Primitives.Connaissance then
                    none

                  else
                    Ui.button False (ExporterPictogramme brick) ("↓ " ++ Primitives.label brick ++ " SVG")
                ]

        pair a b =
            row [ width fill, spacing 12 ] [ brickCard a, brickCard b ]
    in
    if model.width < 360 then
        column [ width fill, spacing 12 ] (List.map brickCard Primitives.all)

    else if model.width < 700 then
        column [ width fill, spacing 12 ] [ pair Primitives.Connaissance Primitives.Auditif, pair Primitives.Visuel Primitives.Kinesthesique ]

    else
        row [ width fill, spacing 16 ] (List.map brickCard Primitives.all)


referenceGallery : Model -> Element Msg
referenceGallery model =
    let
        sourceCard title url =
            Ui.card [ padding 16, spacing 14 ] [ Ui.label title, Element.image [ width (px 140), height (px 140), Element.centerX ] { src = url, description = title }, Ui.small "Référence originale" ]

        rebuilt title prefix scene =
            let
                options =
                    Render.defaults prefix
            in
            Ui.card [ padding 16, spacing 14 ] [ Ui.label title, el [ width (px 140), height (px 140), Element.centerX ] (html (Render.view { options | box = "0 0 30 30", title = title } scene)), Ui.small "Primitives communes · <use>" ]

        logoPair =
            [ sourceCard "Logo original" Reference.logoSource, rebuilt "Logo reconstruit" "ref-logo" (Animation.static "#64c29b" Composition.logo) ]

        xPair =
            [ sourceCard
                (Composition.nom model.cible
                    ++ (if model.cible == Composition.Z then
                            " · ébauche recadrée"

                        else
                            " original"
                       )
                )
                (Composition.reference model.cible)
            , rebuilt (Composition.nom model.cible ++ " factorisé") "ref-cible" (Animation.static (Composition.fond model.cible) (Composition.instances model.cible))
            ]
    in
    if model.width < 980 then
        column [ width fill, spacing 12 ]
            [ if model.width < 390 then
                column [ width fill, spacing 12 ] logoPair

              else
                row [ width fill, spacing 12 ] logoPair
            , if model.width < 390 then
                column [ width fill, spacing 12 ] xPair

              else
                row [ width fill, spacing 12 ] xPair
            ]

    else
        row [ width fill, spacing 16 ] (logoPair ++ xPair)


comparisonPanel : Model -> Element Msg
comparisonPanel model =
    let
        options =
            Render.defaults "comparison"
    in
    Ui.card []
        [ Ui.heading 2 "Comparer la cible"
        , wrappedRow [ spacing 6 ] [ Ui.button (model.comparison == 0) (Comparison 0) "Factorisation", Ui.button (model.comparison == 1) (Comparison 1) "Superposition", Ui.button (model.comparison == 2) (Comparison 2) "Écart visuel" ]
        , el [ width fill, height (px 310), Background.color (Element.rgb255 20 43 49), Border.rounded 12 ]
            (html
                (Render.view
                    { options
                        | box = "-3 -3 36 36"
                        , title = "Comparaison de " ++ Composition.nom model.cible ++ " factorisé et de sa référence"
                        , diagnostic = model.diagnostic
                        , axes = model.axes
                        , hidden = model.hidden
                        , isolated =
                            if model.isolate then
                                Just model.selected

                            else
                                Nothing
                        , reference =
                            if model.comparison == 0 then
                                Nothing

                            else
                                Just (Composition.reference model.cible)
                        , difference = model.comparison == 2
                    }
                    (Animation.static (Composition.fond model.cible) (Composition.instances model.cible))
                )
            )
        , Ui.small
            (if model.cible == Composition.Z && model.comparison /= 0 then
                "L’ébauche est recadrée sur le même fond que la reprise. Les écarts montrent les retouches de placement : tête rapprochée, épaules et pied alignés. En mode écart, le noir indique le rendu commun. Désactivez le diagnostic et affichez toutes les pièces pour comparer."

             else if model.comparison == 2 then
                "Noir : rendu commun. Pixels colorés : écart, notamment sur les contours anticrénelés. Désactivez le diagnostic et affichez toutes les pièces pour comparer la cible entière."

             else if model.comparison == 1 then
                "La référence originale est superposée à 50 % au rendu factorisé."

             else
                Composition.description model.cible
            )
        , if model.cible == Composition.Z then
            MrJam.lien "↓ Ébauche Z originale" "exports/Z-original.svg"

          else
            Element.none
        , Ui.checkbox "Couleurs diagnostiques" model.diagnostic Diagnostic
        , Ui.checkbox "Afficher le repère O" model.axes Axes
        , Ui.checkbox "Isoler la sélection" model.isolate Isolate
        , Ui.checkbox "Masquer cette occurrence" (List.member model.selected model.hidden) Hide
        ]


mirrorPanel : Model -> Element Msg
mirrorPanel model =
    let
        source =
            List.filter (\i -> i.id == model.selected) (Composition.instances model.cible) |> List.head |> Maybe.withDefault Composition.connaissance

        reflected =
            source.pose.chirality == Reflected

        visual =
            { source = source
            , pose = Transform.canonical
            , opacity = 1
            , mirror =
                if reflected then
                    model.mirror

                else
                    0
            }

        options =
            Render.defaults "mirror-inspector"

        determinant =
            Transform.matrix Transform.canonical (pi * visual.mirror) |> Transform.determinant
    in
    Ui.card []
        [ Ui.heading 2 "Le retournement, de près"
        , Ui.small (Primitives.label source.brick ++ " · " ++ source.id)
        , el [ width fill, height (px 225), Background.color (Element.rgb255 20 43 49), Border.rounded 12 ]
            (html (Render.view { options | axes = True, title = "Inspection locale du retournement autour de l’axe vertical O", box = "-9 -12 48 48" } { pieces = [ visual ], background = "none", strategy = model.settings.strategy }))
        , Ui.slider "Progression locale du miroir" " %" 0 100 0.1 (100 * model.mirror) (\value -> Mirror (value / 100))
        , wrappedRow [ spacing 5 ] (List.map (\p -> Ui.button (model.mirror == p) (Mirror p) (Ui.format 0 (p * 180) ++ "°")) [ 0, 0.25, 0.5, 0.75, 1 ])
        , strategyControls model.settings.strategy
        , if reflected then
            Ui.small
                (if model.settings.strategy == Relief then
                    "β = " ++ Ui.format 1 (180 * model.mirror) ++ "° · déterminant = " ++ Ui.format 4 determinant ++ ". À 90°, la projection a une aire nulle : c’est la vue de tranche."

                 else
                    "Fondu des deux faces de cette seule occurrence. Le contour local et l’échelle sont inchangés."
                )

          else
            Ui.small "Cette occurrence est directe : aucun retournement ni dédoublement de face ne lui est appliqué."
        , Ui.small "Le retournement est une rotation hors du plan, représentée en projection. L’axe appartient à la brique, avant son placement dans la composition."
        ]


correspondence : Model -> Element Msg
correspondence model =
    let
        selected =
            List.filter (\target -> target.id == model.selected) (Composition.donnees model.cible) |> List.head

        mono value =
            el [ Font.size 12, Font.family [ Font.monospace ] ] (text value)

        col title fn =
            { header = Ui.label title, width = fill, view = fn }

        common =
            [ { header = Ui.label "Occurrence", width = fill, view = \t -> Ui.button (t.id == model.selected) (Selected t.id) t.path }
            , col "Échelle" (\t -> mono (Ui.format 4 t.scale))
            , col "Face"
                (\t ->
                    Ui.small
                        (if t.reflected then
                            "Réfléchie"

                         else
                            "Directe"
                        )
                )
            , col "Borne"
                (\t ->
                    mono
                        (if model.cible == Composition.Z then
                            "—"

                         else
                            Ui.format 2 (t.bound * 100000) ++ "e−5"
                        )
                )
            ]

        columns =
            if model.width < 360 then
                List.take 1 common ++ List.drop 2 common

            else if model.width > 750 then
                List.take 1 common ++ [ col "Brique" (\t -> Ui.small (Primitives.label t.brick)), col "Angle" (\t -> mono (Ui.format 0 t.angle ++ "°")) ] ++ List.drop 1 common

            else
                common
    in
    Ui.card []
        [ Ui.heading 2
            (if model.cible == Composition.X then
                "Les sept correspondances"

             else if model.cible == Composition.Y then
                "Les huit correspondances"

             else
                "Les cinq placements de Zoé"
            )
        , Ui.paragraph "Sélectionnez une ligne pour inspecter son placement et sa chiralité dans le viewBox 30 × 30."
        , Element.table [ width fill, spacing 12 ] { data = Composition.donnees model.cible, columns = columns }
        , Ui.divider
        , case selected of
            Nothing ->
                none

            Just target ->
                column [ width fill, spacing 10, htmlAttribute (H.attribute "data-selected" target.id) ]
                    [ wrappedRow [ spacing 8 ] [ Ui.badge target.id, Ui.badge target.path, Ui.badge (Primitives.label target.brick) ]
                    , Ui.paragraph
                        ("Translation ("
                            ++ Ui.format 9 target.x
                            ++ " ; "
                            ++ Ui.format 9 target.y
                            ++ ") · angle "
                            ++ Ui.format 0 target.angle
                            ++ "° · échelle "
                            ++ Ui.format 12 target.scale
                            ++ " · "
                            ++ (if target.reflected then
                                    "chiralité réfléchie"

                                else
                                    "chiralité directe"
                               )
                        )
                    , if model.cible == Composition.Z then
                        Ui.small "Placement retravaillé à partir de l’ébauche de Zoé."

                      else
                        Ui.small ("Erreur maximale échantillonnée : " ++ Ui.format 4 (target.error * 100000) ++ " × 10⁻⁵. Borne continue conservative : " ++ Ui.format 4 (target.bound * 100000) ++ " × 10⁻⁵.")
                    ]
        , if model.cible == Composition.Z then
            Ui.small "L’ébauche retrouvée est conservée. Sa silhouette a été recadrée, sa tête rapprochée et les raccords des épaules et du pied alignés. Le dessin retravaillé et son export factorisé utilisent exactement les mêmes courbes et placements."

          else
            Ui.small ("129 points par arc ; seuil 10⁻⁴. Borne maximale mesurée : " ++ Ui.format 5 (100000 * (List.maximum (List.map .bound (Composition.donnees model.cible)) |> Maybe.withDefault 0)) ++ " × 10⁻⁵. Calcul flottant conservatif sur les arcs et les petites fermetures, sans revendication d’identité symbolique.")
        , if model.cible == Composition.Y then
            Ui.small "L’arc auditif admet plusieurs correspondances équivalentes. Comme pour X, l’ajustement privilégie une similitude directe lorsqu’elle respecte le seuil."

          else
            none
        ]


footer : Model -> Element Msg
footer model =
    column [ width fill, spacing 18, paddingEach { top = 8, left = 0, right = 0, bottom = 12 } ]
        [ el [ width fill, htmlAttribute (H.attribute "role" "status"), htmlAttribute (H.attribute "aria-live" "polite") ] (Ui.small model.notice)
        , Ui.divider
        , Ui.small "Logo, signature et déclinaisons : toute utilisation est strictement réservée. Leur présence publique ne vaut pas autorisation de réutilisation."
        , column [ width fill, spacing 12 ]
            [ Ui.small "Écho · Atelier du logo · MrJ.am"
            , MrJam.texteSecondaire "Contours préservés. Échelles et symétries explicites."
            ]
        ]
