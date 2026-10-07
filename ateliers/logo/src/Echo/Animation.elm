module Echo.Animation exposing (Scene, Settings, Strategy(..), Visual, defaults, faces, mirrorProgress, normalize, recomposer, recomposition, rotation, rotationDuration, rotationStats, smooth, static, window)

import Echo.Composition as Composition exposing (Instance)
import Echo.Primitives exposing (Brick(..), origin)
import Echo.Transform as Transform exposing (Chirality(..), Matrix, Pose)


type Strategy
    = Relief
    | LocalFade


type alias Settings =
    { duration : Float
    , stagger : Float
    , mirrorWidth : Float
    , fadeBackground : Bool
    , strategy : Strategy
    , mobileDuration : Float
    , rest : Float
    , turns : Int
    , spread : Float
    , omegaReference : Float
    , spinDirection : Int
    }


type alias Visual =
    { source : Instance, pose : Pose, opacity : Float, mirror : Float }


type alias Scene =
    { pieces : List Visual, background : String, strategy : Strategy }


defaults : Settings
defaults =
    { duration = 4
    , stagger = 0.06
    , mirrorWidth = 0.5
    , fadeBackground = True
    , strategy = Relief
    , mobileDuration = 4
    , rest = 0.6
    , turns = 2
    , spread = 3
    , omegaReference = 2 * pi * 2 / 4 * 1.875
    , spinDirection = 1
    }


normalize : Settings -> Settings
normalize s =
    { s
        | duration = safe 0.2 16 4 s.duration
        , stagger = safe 0 0.25 0.06 s.stagger
        , mirrorWidth = safe 0.1 0.9 0.5 s.mirrorWidth
        , mobileDuration = safe 0.2 12 4 s.mobileDuration
        , rest = safe 0 2 0.6 s.rest
        , turns = clamp 0 8 s.turns
        , spread = safe 0 6 3 s.spread
        , omegaReference = safe 1 20 defaults.omegaReference s.omegaReference
        , spinDirection =
            if s.spinDirection < 0 then
                -1

            else
                1
    }


safe : Float -> Float -> Float -> Float -> Float
safe low high fallback value =
    if isNaN value || isInfinite value then
        fallback

    else
        clamp low high value


smooth : Float -> Float
smooth value =
    let
        v =
            safe 0 1 0 value
    in
    v * v * v * (10 + v * (-15 + 6 * v))


window : Float -> Float -> Float -> Float
window start end p =
    clamp 0 1 ((p - start) / max 0.0001 (end - start))


mirrorProgress : Settings -> Float -> Float
mirrorProgress settings v =
    smooth (window (0.5 - settings.mirrorWidth / 2) (0.5 + settings.mirrorWidth / 2) v)


static : String -> List Instance -> Scene
static background instances =
    { pieces =
        List.map
            (\i ->
                { source = i
                , pose = i.pose
                , opacity = 1
                , mirror =
                    if i.pose.chirality == Reflected then
                        1

                    else
                        0
                }
            )
            instances
    , background = background
    , strategy = Relief
    }


{-| Une scène pure pour les deux sens, la lecture et l'inspection manuelle.
Les copies partent de leur source. Les états terminaux sont affectés exactement.
-}
recomposition : Settings -> Float -> Scene
recomposition =
    recomposer Composition.X


recomposer : Composition.Cible -> Settings -> Float -> Scene
recomposer cible rawSettings rawP =
    let
        settings =
            normalize rawSettings

        p =
            safe 0 1 0 rawP

        piece index source =
            let
                delay =
                    min 0.3 (toFloat index * settings.stagger / settings.duration)

                v =
                    window (0.05 + delay) 0.94 p

                h =
                    smooth v

                target =
                    source.pose

                original =
                    String.endsWith "-0" source.id

                bend =
                    (if modBy 2 index == 0 then
                        1

                     else
                        -1
                    )
                        * 1.2
                        * sin (pi * h)

                pose =
                    if p == 0 then
                        Transform.canonical

                    else if p == 1 then
                        target

                    else
                        { x = origin.x + (target.x - origin.x) * h + bend
                        , y = origin.y + (target.y - origin.y) * h
                        , angle = target.angle * h
                        , scale = 1 + (target.scale - 1) * h
                        , chirality = target.chirality
                        }
            in
            { source = source
            , pose = pose
            , opacity =
                if original then
                    1

                else
                    smooth (window 0 0.18 v)
            , mirror =
                if target.chirality == Reflected then
                    mirrorProgress settings v

                else
                    0
            }

        centre =
            { source = Composition.connaissance, pose = Transform.canonical, opacity = 1 - smooth (window 0.06 0.45 p), mirror = 0 }
    in
    { pieces = centre :: List.indexedMap piece (Composition.instances cible)
    , background = backgroundColor cible settings.fadeBackground p
    , strategy = settings.strategy
    }


{-| Interpolation des composantes sRGB, bornée. Les hexadécimaux terminaux sont exacts.
-}
backgroundColor : Composition.Cible -> Bool -> Float -> String
backgroundColor cible enabled p =
    if not enabled || p <= 0 then
        "#64c29b"

    else if p >= 1 then
        Composition.fond cible

    else
        let
            h =
                smooth p

            component a b =
                String.fromInt (round (a + (b - a) * h))

            ( rouge, vert, bleu ) =
                case cible of
                    Composition.X ->
                        ( 156, 62, 101 )

                    Composition.Y ->
                        ( 100, 194, 155 )

                    Composition.Z ->
                        ( 8, 127, 113 )
        in
        if cible == Composition.Y then
            Composition.fond cible

        else
            "rgb(" ++ component 100 rouge ++ "," ++ component 194 vert ++ "," ++ component 155 bleu ++ ")"


{-| Les opacités source-over du fondu local ne sont pas additives à l'intersection.
Les faces d'une même instance partagent toujours son contour canonique.
-}
faces : Strategy -> Visual -> List ( Matrix, Float )
faces strategy visual =
    if strategy == LocalFade && visual.source.pose.chirality == Reflected then
        [ ( Transform.matrix visual.pose 0, visual.opacity * (1 - visual.mirror) )
        , ( Transform.matrix visual.pose pi, visual.opacity * visual.mirror )
        ]

    else
        [ ( Transform.matrix visual.pose (pi * visual.mirror), visual.opacity ) ]


rotationDuration : Settings -> Float
rotationDuration settings =
    settings.mobileDuration + 2 * settings.rest


rotationStats : Settings -> Float -> { angle : Float, omega : Float, spread : Float, u : Float }
rotationStats rawSettings p =
    let
        s =
            normalize rawSettings

        u =
            clamp 0 1 ((safe 0 1 0 p * rotationDuration s - s.rest) / s.mobileDuration)

        theta =
            2 * pi * toFloat (s.turns * s.spinDirection) * smooth u

        omega =
            2 * pi * toFloat (s.turns * s.spinDirection) / s.mobileDuration * 30 * u * u * (1 - u) * (1 - u)

        ratio =
            min 1 (abs omega / s.omegaReference)
    in
    { angle = theta, omega = omega, spread = s.spread * ratio * ratio, u = u }


rotation : Settings -> Float -> Scene
rotation settings p =
    let
        stats =
            rotationStats settings p

        angle =
            if stats.u == 0 || stats.u == 1 then
                0

            else
                stats.angle

        move source =
            let
                -- Bissectrices des raccords : -165°, -45°, 75°, espacées de 120°.
                direction =
                    case source.brick of
                        Auditif ->
                            degrees -165

                        Visuel ->
                            degrees -45

                        Kinesthesique ->
                            degrees 75

                        Connaissance ->
                            0

                pose =
                    if source.brick == Connaissance then
                        Transform.canonical

                    else
                        { x = origin.x + stats.spread * cos (direction + angle)
                        , y = origin.y + stats.spread * sin (direction + angle)
                        , angle = angle
                        , scale = 1
                        , chirality = Direct
                        }
            in
            { source = source, pose = pose, opacity = 1, mirror = 0 }
    in
    { pieces = List.map move Composition.logo, background = "#64c29b", strategy = Relief }
