module MrJam.Diagrammes.Types exposing (Courbe, Plan, Sommet, Tetrades)

{-| Entrées scientifiques du dessin, calculées sans présentation par l'application.
Aucun nœud, attribut, classe ou événement arbitraire.
-}


type alias Courbe =
    { cle : String, nom : String, teinte : Float, chemin : String, couleur : String, tirets : String }


type alias Plan =
    { zone : String, limite : String, courbes : List Courbe, selection : Maybe String, x : Float, y : Float }


type alias Sommet =
    { cle : String, x : Float, y : Float, lx : Float, ly : Float, couleur : String, pointille : Bool }


type alias Tetrades =
    { premier : String, second : String, sommets : List Sommet }
