module Echo.Composition exposing (Cible(..), Instance, connaissance, description, donnees, fond, instances, licorne, logo, nom, pictogramme, prenom, reference, trousLicorne, x, y, z)

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


{-| Huit contours : tête, oreille, trois mèches
et trois pièces en homothétie pour la corne en spirale. Aucun tracé ajouté.
-}
licorne : List Instance
licorne =
    let
        placer id brick xPose yPose angle echelle face =
            { id = id, brick = brick, pose = { x = xPose, y = yPose, angle = degrees angle, scale = echelle, chirality = face } }
    in
    [ placer "tete" Visuel 14.075 11.1 25 1.092 Direct
    , placer "corne-pointe" Visuel 21.3445100917 6.5166525594 -52 0.322 Direct
    , placer "corne-milieu" Visuel 19.6740772534 9.5642998704 -52 0.476 Direct
    , placer "corne-base" Visuel 17.995 13.76 -52 0.672 Direct
    , placer "oreille" Auditif 16.875 11.1 0 0.462 Direct
    , placer "criniere-haute" Visuel 15.875 12.5 -5 1.0 Reflected
    , placer "criniere-milieu" Visuel 13.375 16.0 -20 0.8125 Reflected
    , placer "criniere-basse" Visuel 11.75 20.125 -40 0.625 Reflected
    ]


{-| Un seul petit évidement pour l’œil. Le disque canonique
sert de découpe et ne devient jamais une pièce de remplissage de la silhouette.
-}
trousLicorne : List Instance
trousLicorne =
    let
        placer id brick xPose yPose angle echelle face =
            { id = id, brick = brick, pose = { x = xPose, y = yPose, angle = degrees angle, scale = echelle, chirality = face } }
    in
    [ placer "oeil" Connaissance 18.975 10.96 0 0.224 Direct
    ]


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
            "Xiaoping"

        Y ->
            "Ydris"

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
            "Xiaoping · Sept occurrences de contours : 1 audio, 3 visio et 3 kino. Le disque de connaissance n’est pas une pièce séparée dans le dessin X fourni."

        Y ->
            "Ydris · Huit occurrences de contours : 2 audio, 2 visio et 4 kino. Six placements distincts : path14 double path8, path16 double path10. Ces superpositions originales sont conservées. Le disque de connaissance n’est pas une pièce séparée dans le dessin Y fourni."

        Z ->
            "Zoé · Cinq occurrences de contours : 1 audio, 2 visio et 2 kino. Une tête détachée, deux bras, une diagonale et un pied dessinent un Z en mouvement. La reprise de l’ébauche conserve les courbes du logo et aligne leurs raccords."
