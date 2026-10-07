module Echo.Composition exposing (Cible(..), Instance, description, donnees, fond, instances, logo, nom, reference, spirit, x, y)

import Echo.Primitives as Primitives exposing (Brick(..))
import Echo.ReferenceData as Reference
import Echo.Transform as Transform exposing (Chirality(..), Pose)


type alias Instance =
    { id : String, brick : Brick, pose : Pose }


logo : List Instance
logo =
    List.map (\brick -> { id = Primitives.key brick ++ "-0", brick = brick, pose = Transform.canonical }) Primitives.all


spirit : Instance
spirit =
    { id = "esprit-0", brick = Esprit, pose = Transform.canonical }


{-| Ordre historique de dessin : 4, 6, 8, 10, 12, 16, 18.
-}
x : List Instance
x =
    depuisDonnees Reference.targets


y : List Instance
y =
    depuisDonnees Reference.ciblesY


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


nom : Cible -> String
nom cible =
    case cible of
        X ->
            "X"

        Y ->
            "Y"


instances : Cible -> List Instance
instances cible =
    case cible of
        X ->
            x

        Y ->
            y


donnees : Cible -> List Reference.Target
donnees cible =
    case cible of
        X ->
            Reference.targets

        Y ->
            Reference.ciblesY


reference : Cible -> String
reference cible =
    case cible of
        X ->
            Reference.xSource

        Y ->
            Reference.sourceY


fond : Cible -> String
fond cible =
    case cible of
        X ->
            "#9c3e65"

        Y ->
            "#64c29b"


description : Cible -> String
description cible =
    case cible of
        X ->
            "Sept occurrences : 1 auditive, 3 visuelles et 3 kinesthésiques. Aucun disque-esprit dans X."

        Y ->
            "Huit occurrences : 2 auditives, 2 visuelles et 4 kinesthésiques. Six placements distincts : path14 double path8, path16 double path10. Ces superpositions originales sont conservées. Aucun disque-esprit dans Y."
