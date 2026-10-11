module MrJam.Adaptateurs.Espace exposing (bille, cadre, clavier, evenements)

{-| Mesure, capture et entrées du navigateur uniquement. Le pont ne peint rien.
Les noms de messages et métadonnées sont fixes ; pas d'attribut libre public.
-}

import Element as UI
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import MrJam.Ecran exposing (Dimensions)


cadre : Bool -> List (UI.Attribute message)
cadre inactif =
    [ UI.htmlAttribute (A.attribute "data-mrjam-espace" "")
    , UI.htmlAttribute
        (A.attribute "data-inactif"
            (if inactif then
                "true"

             else
                "false"
            )
        )
    , UI.htmlAttribute (A.style "touch-action" "none")
    ]


bille : String -> Bool -> Float -> Float -> Float -> List (UI.Attribute message)
bille identifiant attente x y z =
    [ UI.htmlAttribute (A.attribute "data-mrjam-bille" identifiant)
    , UI.htmlAttribute (A.attribute "data-id" identifiant)
    , UI.htmlAttribute
        (A.attribute "data-attente"
            (if attente then
                "true"

             else
                "false"
            )
        )
    , UI.htmlAttribute (A.attribute "data-x" (String.fromFloat x))
    , UI.htmlAttribute (A.attribute "data-y" (String.fromFloat y))
    , UI.htmlAttribute (A.attribute "data-z" (String.fromFloat z))
    ]


evenements : (Dimensions -> message) -> (Float -> Float -> Maybe String -> message) -> (Float -> Float -> message) -> (Bool -> message) -> List (UI.Attribute message)
evenements mesurer prendre deplacer terminer =
    [ UI.htmlAttribute (E.on "mrjam-espace-mesure" (D.map mesurer (D.field "detail" (D.map2 Dimensions (D.field "largeur" D.int) (D.field "hauteur" D.int)))))
    , UI.htmlAttribute (E.on "mrjam-espace-prise" (D.field "detail" (D.map3 prendre (D.field "x" D.float) (D.field "y" D.float) (D.field "id" (D.nullable D.string)))))
    , UI.htmlAttribute (E.on "mrjam-espace-mouvement" (D.field "detail" (D.map2 deplacer (D.field "x" D.float) (D.field "y" D.float))))
    , UI.htmlAttribute (E.on "mrjam-espace-fin" (D.field "detail" (D.map terminer (D.field "annule" D.bool))))
    ]


clavier : (Float -> Float -> message) -> UI.Attribute message
clavier tourner =
    UI.htmlAttribute
        (E.preventDefaultOn "keydown"
            (D.map2 Tuple.pair (D.field "key" D.string) (D.at [ "target", "id" ] D.string)
                |> D.andThen
                    (\( touche, cible ) ->
                        if cible /= "space" then
                            D.fail "Le clavier vise une bille"

                        else
                            case touche of
                                "ArrowLeft" ->
                                    D.succeed ( tourner -0.1 0, True )

                                "ArrowRight" ->
                                    D.succeed ( tourner 0.1 0, True )

                                "ArrowUp" ->
                                    D.succeed ( tourner 0 0.1, True )

                                "ArrowDown" ->
                                    D.succeed ( tourner 0 -0.1, True )

                                _ ->
                                    D.fail "Autre touche"
                    )
            )
        )
