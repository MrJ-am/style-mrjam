module Echo.Composition exposing (Cible(..), Instance, connaissance, description, donnees, fond, instances, licorne, logo, nom, pictogramme, prenom, reference, x, y, z)

import Echo.Licorne as Licorne
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

    else if forme == Visuel then
        -- Union des contours : [11.8,25.285281] × [4.689818…,11].
        -- Homothétie uniforme ×1.6, centrage du cadre en (15,15).
        -- Les arcs et leurs proportions restent ceux du logo de référence.
        let
            pose =
                { x = 7.4117752, y = 16.8481456, angle = 0, scale = 1.6, chirality = Direct }
        in
        [ { connaissance | pose = pose }
        , { id = Primitives.key forme ++ "-0", brick = forme, pose = pose }
        ]

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


{-| Dix-neuf occurrences des contours canoniques ; les placements proviennent
du modèle validé, normalisé par une seule homothétie dans le disque de rayon 15.
-}
licorne : List Instance
licorne =
    depuisDonnees Licorne.placements


depuisDonnees : List { a | id : String, brick : Brick, x : Float, y : Float, angle : Float, scale : Float, reflected : Bool } -> List Instance
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
