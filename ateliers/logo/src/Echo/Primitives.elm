module Echo.Primitives exposing (Brick(..), Shape(..), all, color, key, label, origin, radii, shape)

{-| Les quatre contours canoniques. Les commandes d'arc restent intactes.
Le décalage (-13.8, -9) est un changement de repère, jamais une déformation.
Les rayons 3, 6, 12 suivent une progression de raison 2 ; 2, 3, 5, 8, 13
appartiennent à la suite de Fibonacci. Le disque de fond n'est pas une brique.
-}


type Brick
    = Esprit
    | Auditif
    | Visuel
    | Kinesthesique


type Shape
    = Disc Float
    | Contour String


origin : { x : Float, y : Float }
origin =
    { x = 13.8, y = 9 }


all : List Brick
all =
    [ Esprit, Auditif, Visuel, Kinesthesique ]


shape : Brick -> Shape
shape brick =
    case brick of
        Esprit ->
            Disc 2

        Auditif ->
            Contour "M 12.3,6.4019238 A 3,3 0 0 0 11.201924,10.5 5,5 0 0 1 12.3,2.1592831 a 3,3 0 0 0 0,4.2426407"

        Visuel ->
            Contour "m13.8 6a3 3 0 0 1 3 3 6 6 0 0 1 8.485281 0 8 8 0 0 0-11.485281-3"

        Kinesthesique ->
            Contour "M 12.3,11.598076 A 3,3 0 0 0 16.398076,10.5 13,13 0 0 1 12.3,28.568639 a 12,12 0 0 0 0,-16.970563"


key : Brick -> String
key brick =
    case brick of
        Esprit ->
            "esprit"

        Auditif ->
            "auditif"

        Visuel ->
            "visuel"

        Kinesthesique ->
            "kinesthesique"


label : Brick -> String
label brick =
    case brick of
        Esprit ->
            "Esprit"

        Auditif ->
            "Auditif"

        Visuel ->
            "Visuel"

        Kinesthesique ->
            "Kinesthésique"


color : Brick -> String
color brick =
    case brick of
        Esprit ->
            "#ffffff"

        Auditif ->
            "#ffca91"

        Visuel ->
            "#9ed8fa"

        Kinesthesique ->
            "#e8b8ed"


radii : Brick -> String
radii brick =
    case brick of
        Esprit ->
            "Rayon 2"

        Auditif ->
            "Rayons 3 · 5"

        Visuel ->
            "Rayons 3 · 6 · 8"

        Kinesthesique ->
            "Rayons 3 · 12 · 13"
