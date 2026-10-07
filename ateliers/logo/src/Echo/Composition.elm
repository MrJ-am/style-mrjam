module Echo.Composition exposing (Cible(..), Instance, connaissance, description, donnees, fond, instances, logo, nom, pictogramme, prenom, reference, x, y, z)

import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.ReferenceData as Reference
import Echo.Transform as Transform exposing (Chirality(..), Pose)


type alias Instance =
    { id : String, brick : Brick, pose : Pose }


logo : List Instance
logo =
    List.map (\brick -> { id = Primitives.key brick ++ "-0", brick = brick, pose = Transform.canonical }) Primitives.all


connaissance : Instance
connaissance =
    { id = "connaissance-0", brick = Connaissance, pose = Transform.canonical }


{-| Un pictogramme sensoriel associe son contour au disque de connaissance.
Le disque partagé n'est dessiné qu'une fois dans le logo complet.
-}
pictogramme : Brick -> List Instance
pictogramme forme =
    if forme == Connaissance then
        [ connaissance ]

    else
        [ connaissance, { id = Primitives.key forme ++ "-0", brick = forme, pose = Transform.canonical } ]


{-| Ordre historique de dessin : 4, 6, 8, 10, 12, 16, 18.
-}
x : List Instance
x =
    depuisDonnees Reference.targets


y : List Instance
y =
    depuisDonnees Reference.ciblesY


z : List Instance
z =
    depuisDonnees Reference.ciblesZ


depuisDonnees : List Reference.Target -> List Instance
depuisDonnees cibles =
    List.map
        (\target ->
            { id = target.id
            , brick = target.brick
            , pose =
                { x = target.x
                , y = target.y
                , angle = degrees target.angle
                , scale = target.scale
                , chirality =
                    if target.reflected then
                        Reflected

                    else
                        Direct
                }
            }
        )
        cibles


type Cible
    = X
    | Y
    | Z


nom : Cible -> String
nom cible =
    case cible of
        X ->
            "X"

        Y ->
            "Y"

        Z ->
            "Z"


prenom : Cible -> String
prenom cible =
    case cible of
        X ->
            "Xiaoyu"

        Y ->
            "Idriss"

        Z ->
            "Zoé"


instances : Cible -> List Instance
instances cible =
    case cible of
        X ->
            x

        Y ->
            y

        Z ->
            z


donnees : Cible -> List Reference.Target
donnees cible =
    case cible of
        X ->
            Reference.targets

        Y ->
            Reference.ciblesY

        Z ->
            Reference.ciblesZ


reference : Cible -> String
reference cible =
    case cible of
        X ->
            Reference.xSource

        Y ->
            Reference.sourceY

        Z ->
            Reference.sourceZ


fond : Cible -> String
fond cible =
    case cible of
        X ->
            "#9c3e65"

        Y ->
            "#64c29b"

        Z ->
            "#087f71"


description : Cible -> String
description cible =
    case cible of
        X ->
            "Xiaoyu · Sept occurrences de contours : 1 audio, 3 visio et 3 kino. Le disque de connaissance n’est pas une pièce séparée dans le dessin X fourni."

        Y ->
            "Idriss · Huit occurrences de contours : 2 audio, 2 visio et 4 kino. Six placements distincts : path14 double path8, path16 double path10. Ces superpositions originales sont conservées. Le disque de connaissance n’est pas une pièce séparée dans le dessin Y fourni."

        Z ->
            "Zoé · Cinq occurrences de contours : 1 audio, 1 visio et 3 kino. Les bras, le corps en diagonale et les jambes dessinent un Z. Cette nouvelle composition réutilise les courbes du logo ; sa tête se lit dans l’espace entre elles."
