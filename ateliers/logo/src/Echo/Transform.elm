module Echo.Transform exposing (Chirality(..), Matrix, Pose, apply, canonical, determinant, matrix, serialize, terminal)

import Echo.Primitives exposing (origin)


type Chirality
    = Direct
    | Reflected


{-| Angles en radians, échelle uniforme positive, repère SVG (y descendant).
-}
type alias Pose =
    { x : Float, y : Float, angle : Float, scale : Float, chirality : Chirality }


type alias Matrix =
    { a : Float, b : Float, c : Float, d : Float, e : Float, f : Float }


canonical : Pose
canonical =
    { x = origin.x, y = origin.y, angle = 0, scale = 1, chirality = Direct }


{-| t + s R(theta) diag(cos(beta),1). Aucune inversion, même à la tranche.
-}
matrix : Pose -> Float -> Matrix
matrix pose beta =
    let
        k =
            if abs (beta - pi / 2) < 1.0e-12 then
                0

            else if beta <= 0 then
                1

            else if beta >= pi then
                -1

            else
                cos beta

        c =
            cos pose.angle

        s =
            sin pose.angle
    in
    { a = pose.scale * c * k
    , b = pose.scale * s * k
    , c = -pose.scale * s
    , d = pose.scale * c
    , e = pose.x
    , f = pose.y
    }


terminal : Pose -> Matrix
terminal pose =
    matrix pose
        (if pose.chirality == Reflected then
            pi

         else
            0
        )


determinant : Matrix -> Float
determinant m =
    m.a * m.d - m.b * m.c


apply : Matrix -> ( Float, Float ) -> ( Float, Float )
apply m ( x, y ) =
    ( m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f )


serialize : Matrix -> String
serialize m =
    "matrix(" ++ String.join " " (List.map String.fromFloat [ m.a, m.b, m.c, m.d, m.e, m.f ]) ++ ")"
