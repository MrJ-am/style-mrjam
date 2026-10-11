module MrJam.Adaptateurs.Spatial exposing (ancrage, clic, etat, fin, prise, surface, taille, toucher)

{-| Entrées du navigateur et scale numérique absents de l'API elm-ui1.1.8.
La surface, la carte et leur position restent des éléments elm-ui. Noms fixes,
aucun HTML, CSS libre ou animation ; ces fonctions sont contrôlées centralement.
-}

import Element exposing (Attribute, htmlAttribute)
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import MrJam.Adaptateurs.Manipulation as Geste


taille : Float -> Attribute message
taille facteur =
    htmlAttribute (A.style "transform" ("scale(" ++ String.fromFloat (Basics.clamp 0.1 1.5 facteur) ++ ")"))


{-| Les boîtes de placement non peintes ne capturent pas les gestes destinés
aux cartes voisines. La zone d'entrée est la carte réellement transformée.
-}
ancrage : Attribute message
ancrage =
    htmlAttribute (A.style "pointer-events" "none")


surface : Attribute message
surface =
    htmlAttribute (A.style "pointer-events" "auto")


etat : Bool -> Bool -> List (Attribute message)
etat ouverte mouvement =
    [ htmlAttribute (A.attribute "role" "button")
    , htmlAttribute
        (A.attribute "aria-expanded"
            (if ouverte then
                "true"

             else
                "false"
            )
        )
    , htmlAttribute
        (A.attribute "data-state"
            (if ouverte then
                "expanded"

             else
                "mini"
            )
        )
    , htmlAttribute
        (A.attribute "data-zooming"
            (if mouvement then
                "true"

             else
                "false"
            )
        )
    ]


prise : (Float -> Float -> message) -> List (Attribute message)
prise commencer =
    [ htmlAttribute (E.preventDefaultOn "mousedown" (D.map (\( x, y ) -> ( commencer x y, True )) souris))
    , htmlAttribute (E.on "touchstart" (D.map (\( x, y ) -> commencer x y) doigt))
    ]
        ++ Geste.prise


clic : Bool -> message -> message -> List (Attribute message)
clic ouverte ouvrir fermer =
    let
        message =
            if ouverte then
                fermer

            else
                ouvrir
    in
    [ htmlAttribute (E.stopPropagationOn "click" (D.succeed ( message, True )))
    , htmlAttribute
        (E.preventDefaultOn "keydown"
            (D.field "key" D.string
                |> D.andThen
                    (\touche ->
                        if touche == "Enter" || touche == " " then
                            D.succeed ( message, True )

                        else if touche == "Escape" && ouverte then
                            D.succeed ( fermer, True )

                        else
                            D.fail "Autre touche"
                    )
            )
        )
    ]


toucher : (Float -> Float -> message) -> Attribute message
toucher deplacer =
    htmlAttribute (E.preventDefaultOn "touchmove" (D.map (\( x, y ) -> ( deplacer x y, True )) doigt))


fin : message -> List (Attribute message)
fin message =
    [ htmlAttribute (E.on "touchend" (D.succeed message))
    , htmlAttribute (E.on "touchcancel" (D.succeed message))
    ]


souris : D.Decoder ( Float, Float )
souris =
    D.map2 Tuple.pair (D.field "clientX" D.float) (D.field "clientY" D.float)


doigt : D.Decoder ( Float, Float )
doigt =
    D.oneOf
        [ D.map2 Tuple.pair (D.at [ "touches", "0", "clientX" ] D.float) (D.at [ "touches", "0", "clientY" ] D.float)
        , D.map2 Tuple.pair (D.at [ "changedTouches", "0", "clientX" ] D.float) (D.at [ "changedTouches", "0", "clientY" ] D.float)
        ]
