module MrJam.Adaptateurs.Axes exposing (cadre, clavier, evenements, poignee, rail)

import Element as UI
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D


cadre : Bool -> List (UI.Attribute message)
cadre inactif =
    [ UI.htmlAttribute (A.attribute "data-mrjam-axe" "")
    , UI.htmlAttribute
        (A.attribute "data-inactif"
            (if inactif then
                "true"

             else
                "false"
            )
        )
    , UI.htmlAttribute (A.style "touch-action" "pan-y")
    ]


rail : UI.Attribute message
rail =
    UI.htmlAttribute (A.attribute "data-mrjam-rail" "")


poignee : String -> Float -> Float -> Float -> Float -> String -> List (UI.Attribute message)
poignee identifiant valeur ancre x levee lecture =
    [ UI.htmlAttribute (A.attribute "data-mrjam-poignee" identifiant)
    , UI.htmlAttribute (A.attribute "data-value" (String.fromFloat valeur))
    , UI.htmlAttribute (A.attribute "data-anchor" (String.fromFloat ancre))
    , UI.htmlAttribute (A.attribute "data-lift" (String.fromFloat levee))
    , UI.htmlAttribute (A.attribute "data-position" (String.fromFloat x))
    , UI.htmlAttribute (A.attribute "role" "slider")
    , UI.htmlAttribute (A.attribute "aria-valuemin" "-10")
    , UI.htmlAttribute (A.attribute "aria-valuemax" "10")
    , UI.htmlAttribute (A.attribute "aria-valuenow" (String.fromFloat valeur))
    , UI.htmlAttribute (A.attribute "aria-valuetext" lecture)
    , UI.htmlAttribute (A.attribute "aria-orientation" "horizontal")
    , UI.htmlAttribute (A.attribute "aria-keyshortcuts" "Enter ArrowLeft ArrowRight Home End")
    , UI.htmlAttribute (A.style "touch-action" "none")
    ]


evenements : (Int -> message) -> (String -> Float -> Float -> Bool -> Bool -> message) -> (Float -> Float -> message) -> (Bool -> message) -> List (UI.Attribute message)
evenements mesurer prendre deplacer terminer =
    [ UI.htmlAttribute (E.on "mrjam-axe-mesure" (D.map mesurer (D.field "detail" D.int)))
    , UI.htmlAttribute (E.on "mrjam-axe-prise" (D.field "detail" (D.map5 prendre (D.field "id" D.string) (D.field "x" D.float) (D.field "y" D.float) (D.field "direct" D.bool) (D.field "verrou" D.bool))))
    , UI.htmlAttribute (E.on "mrjam-axe-mouvement" (D.field "detail" (D.map2 deplacer (D.field "x" D.float) (D.field "y" D.float))))
    , UI.htmlAttribute (E.on "mrjam-axe-fin" (D.field "detail" (D.map terminer (D.field "annule" D.bool))))
    ]


clavier : message -> (String -> Bool -> message) -> UI.Attribute message
clavier ouvrir envoyer =
    UI.htmlAttribute
        (E.preventDefaultOn "keydown"
            (D.map2 Tuple.pair (D.field "key" D.string) (D.field "shiftKey" D.bool)
                |> D.andThen
                    (\( touche, majuscule ) ->
                        if touche == "Enter" || touche == " " then
                            D.succeed ( ouvrir, True )

                        else if List.member touche [ "ArrowLeft", "ArrowRight", "ArrowUp", "ArrowDown", "Home", "End" ] then
                            D.succeed ( envoyer touche majuscule, True )

                        else
                            D.fail "Autre touche"
                    )
            )
        )
