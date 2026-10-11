module TransitionsTest exposing (suite)

import Expect
import MrJam.Transitions as Transitions
import Test exposing (Test, describe, test)
import Time


valeur : Bool -> Float
valeur ouvert =
    if ouvert then
        1

    else
        0


suite : Test
suite =
    describe "Politique commune de transitions"
        [ test "aucune frame demandée au repos" <|
            \() ->
                Expect.equal False (Transitions.actif (Transitions.initialiser False))
        , test "l'intention change immédiatement sans attendre l'animation" <|
            \() ->
                Transitions.initialiser False
                    |> Transitions.aller 180 True
                    |> Transitions.courant
                    |> Expect.equal True
        , test "réduction avant l'action : état final et absence de rafraîchissement" <|
            \() ->
                let
                    etat =
                        Transitions.initialiser False
                            |> Transitions.reduire True
                            |> Transitions.aller 180 True
                in
                Expect.equal ( 1, False ) ( Transitions.nombre valeur etat, Transitions.actif etat )
        , test "réduction pendant le mouvement : destination immédiate, sans frame restante" <|
            \() ->
                let
                    etat =
                        Transitions.initialiser False
                            |> Transitions.aller 180 True
                            |> Transitions.mettreAJour (Time.millisToPosix 0)
                            |> Transitions.mettreAJour (Time.millisToPosix 60)
                            |> Transitions.reduire True
                in
                Expect.equal ( 1, False ) ( Transitions.nombre valeur etat, Transitions.actif etat )
        , test "durée nulle : pas de délai ajouté au métier" <|
            \() ->
                let
                    etat =
                        Transitions.initialiser False |> Transitions.aller 0 True
                in
                Expect.equal ( True, False ) ( Transitions.courant etat, Transitions.actif etat )
        , test "redemander la même cible ne démarre pas une animation au repos" <|
            \() ->
                Transitions.initialiser True
                    |> Transitions.aller 180 True
                    |> Transitions.actif
                    |> Expect.equal False
        , test "durée nulle pendant le mouvement finit la même cible" <|
            \() ->
                let
                    etat =
                        Transitions.initialiser False
                            |> Transitions.aller 180 True
                            |> Transitions.aller 0 True
                in
                Expect.equal ( 1, False ) ( Transitions.nombre valeur etat, Transitions.actif etat )
        , test "interruption et inversion : continuité de la valeur puis repos final" <|
            \() ->
                let
                    enCours =
                        Transitions.initialiser False
                            |> Transitions.aller 180 True
                            |> Transitions.mettreAJour (Time.millisToPosix 1000)
                            |> Transitions.mettreAJour (Time.millisToPosix 1060)

                    inverse =
                        Transitions.aller 180 False enCours

                    termine =
                        inverse
                            |> Transitions.mettreAJour (Time.millisToPosix 1060)
                            |> Transitions.mettreAJour (Time.millisToPosix 2000)
                in
                Expect.all
                    [ \_ -> Expect.within (Expect.Absolute 0.000001) (Transitions.nombre valeur enCours) (Transitions.nombre valeur inverse)
                    , \_ -> Expect.equal False (Transitions.courant inverse)
                    , \_ -> Expect.equal ( 0, False ) ( Transitions.nombre valeur termine, Transitions.actif termine )
                    ]
                    ()
        ]
