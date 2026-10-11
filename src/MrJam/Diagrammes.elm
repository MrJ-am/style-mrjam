module MrJam.Diagrammes exposing (Courbe, Plan, Sommet, Tetrades, carte, geometrie, legende, limite, plan)

{-| Plans scientifiques SVG : sélection native à deux axes et tétrades.
Les calculs et les décisions scientifiques restent chez le consommateur.
-}

import Element exposing (Attribute, Element)
import MrJam.Adaptateurs.Diagrammes as Rendu
import MrJam.Diagrammes.Types as Types


type alias Courbe =
    Types.Courbe


type alias Plan =
    Types.Plan


type alias Sommet =
    Types.Sommet


type alias Tetrades =
    Types.Tetrades


plan : Plan -> (Float -> Float -> message) -> Element message
plan =
    Rendu.plan


legende : Courbe -> Element message
legende =
    Rendu.legende


geometrie : Tetrades -> Element message
geometrie =
    Rendu.geometrie


limite : Float -> List String -> List (Attribute message)
limite =
    Rendu.limite


carte : String -> Float -> Float -> Float -> List (Attribute message)
carte =
    Rendu.carte
