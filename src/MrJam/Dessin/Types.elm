module MrJam.Dessin.Types exposing (Definition, Degrade, Face, Forme(..), Options, Piece, Scene, Trou)

{-| Données vectorielles, sans modèle métier ni état d'animation.
Les matrices et contours sont calculés par l'application ; le socle les dessine.
-}


type Forme
    = Disque Float
    | Contour String


type alias Definition =
    { cle : String, forme : Forme }


type alias Face =
    { matrice : String, opacite : Float }


type alias Piece =
    { id : String, cle : String, couleur : String, opacite : Float, miroir : Float, faces : List Face }


type alias Trou =
    { id : String, cle : String, matrice : String }


type alias Degrade =
    { x1 : Float, y1 : Float, x2 : Float, y2 : Float }


type alias Scene =
    { definitions : List Definition, pieces : List Piece, fond : String }


type alias Options =
    { prefix : String, box : String, title : String, diagnostic : Bool, axes : Bool, hidden : List String, isolated : Maybe String, reference : Maybe String, difference : Bool, trous : List Trou, degrade : Maybe Degrade }
