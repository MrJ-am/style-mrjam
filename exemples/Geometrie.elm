port module Geometrie exposing (main)

{-| Entrée différentielle synthétique des calculs purs, sans navigateur ni métier.
-}

import Json.Decode as D
import Json.Encode as E
import MrJam.AxesSpatiaux as Axes
import MrJam.Espace as Espace
import MrJam.GeometrieSpatiale as G
import Platform


port geometrieEntree : (E.Value -> message) -> Sub message


port geometrieSortie : E.Value -> Cmd message


type Message
    = Calculer E.Value


main : Program () () Message
main =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = \(Calculer entree) _ -> ( (), geometrieSortie (calculer entree) )
        , subscriptions = \_ -> geometrieEntree Calculer
        }


position : D.Decoder G.Position
position =
    D.map3 G.Position (D.field "id" D.string) (D.field "x" D.float) (D.field "y" D.float)


encoderPosition : G.Position -> E.Value
encoderPosition p =
    E.object [ ( "id", E.string p.id ), ( "x", E.float p.x ), ( "y", E.float p.y ) ]


calculer : E.Value -> E.Value
calculer entree =
    let
        programme =
            D.field "calcul" D.string
                |> D.andThen
                    (\calcul ->
                        case calcul of
                            "gestes" ->
                                D.succeed gestes

                            "billes" ->
                                D.map4 G.placerBilles
                                    (D.field "largeur" D.float)
                                    (D.field "hauteur" D.float)
                                    (D.field "diametre" D.float)
                                    (D.field "points" (D.list position))
                                    |> D.map (E.list encoderPosition)

                            "poignees" ->
                                D.map4 G.placerPoignees
                                    (D.field "largeur" D.float)
                                    (D.field "prioritaire" D.string)
                                    (D.field "prise" (D.nullable (D.map2 G.Prise (D.field "y" D.float) (D.field "decalage" D.float))))
                                    (D.field "points" (D.list (D.map3 G.Poignee (D.field "id" D.string) (D.field "numero" D.int) (D.field "valeur" D.float))))
                                    |> D.map
                                        (E.list (\p -> E.object [ ( "id", E.string p.id ), ( "numero", E.int p.numero ), ( "valeur", E.float p.valeur ), ( "ancre", E.float p.ancre ), ( "x", E.float p.x ), ( "y", E.float p.y ) ]))

                            "deplacement" ->
                                D.map6 G.deplacementRelatif
                                    (D.field "depart" D.float)
                                    (D.field "dx" D.float)
                                    (D.field "largeur" D.float)
                                    (D.field "minimum" D.float)
                                    (D.field "maximum" D.float)
                                    (D.field "pas" D.float)
                                    |> D.map E.float

                            "projection" ->
                                D.map4
                                    (\largeur hauteur camera billes ->
                                        let
                                            vue =
                                                G.projection largeur hauteur camera
                                        in
                                        E.object
                                            [ ( "diametre", E.float vue.diametre )
                                            , ( "unite", E.float vue.unite )
                                            , ( "points", E.list (G.projeter vue >> (\p -> E.object [ ( "x", E.float p.x ), ( "y", E.float p.y ), ( "profondeur", E.float p.profondeur ) ])) billes )
                                            ]
                                    )
                                    (D.field "largeur" D.float)
                                    (D.field "hauteur" D.float)
                                    (D.field "camera" (D.map2 G.Camera (D.field "azimut" D.float) (D.field "elevation" D.float)))
                                    (D.field "billes" (D.list (D.map3 G.Bille (D.field "x" D.float) (D.field "y" D.float) (D.field "z" D.float))))

                            _ ->
                                D.fail "Calcul inconnu"
                    )
    in
    case D.decodeValue programme entree of
        Ok resultat ->
            resultat

        Err erreur ->
            E.object [ ( "erreur", E.string (D.errorToString erreur) ) ]


{-| Séquences réellement calculées par les deux machines de gestes communes.
Aucune assertion ne dépend d'une traduction parallèle de leur implémentation.
-}
gestes : E.Value
gestes =
    let
        points =
            [ Axes.Poignee "a" 1 0 True, Axes.Poignee "b" 2 0 True, Axes.Poignee "c" 3 0 True ]

        axe message modele =
            Axes.actualiser 42 "a" points message modele

        debut =
            (axe (Axes.Mesurer 220) Axes.initialiser).modele

        prise =
            (axe (Axes.Prendre "a" 0 0 True True) debut).modele

        hesitant =
            axe (Axes.Deplacer 2 9) prise

        glisse =
            axe (Axes.Deplacer 40 35) hesitant.modele

        annule =
            axe (Axes.Terminer True) glisse.modele

        valide =
            axe (Axes.Terminer False) glisse.modele

        verticale =
            (axe (Axes.Prendre "a" 0 0 False False) debut).modele |> axe (Axes.Deplacer 2 20)

        encode resultat =
            E.object [ ( "proposition", Maybe.map (\( id, v, termine ) -> E.object [ ( "id", E.string id ), ( "valeur", E.float v ), ( "validee", E.bool termine ) ]) resultat.proposition |> Maybe.withDefault E.null ), ( "ouvrir", Maybe.map E.string resultat.ouvrir |> Maybe.withDefault E.null ) ]

        espace message modele =
            Espace.actualiser message modele

        cameraPrise =
            (espace (Espace.Prendre 0 0 (Just "a")) Espace.initialiser).modele

        cameraGlisse =
            (espace (Espace.Deplacer 10 20) cameraPrise).modele

        encodeCamera resultat =
            E.object [ ( "ouvrir", Maybe.map E.string resultat.ouvrir |> Maybe.withDefault E.null ), ( "tourne", E.bool resultat.tourne ), ( "azimut", E.float resultat.modele.camera.azimut ), ( "elevation", E.float resultat.modele.camera.elevation ) ]
    in
    E.object
        [ ( "prise", encode (axe (Axes.Prendre "a" 0 0 True True) debut) )
        , ( "hesitant", encode hesitant )
        , ( "glisse", encode glisse )
        , ( "annule", encode annule )
        , ( "valide", encode valide )
        , ( "clic", encode (axe (Axes.Terminer False) prise) )
        , ( "verticale", encode (axe (Axes.Terminer False) verticale.modele) )
        , ( "home", encode (axe (Axes.Clavier "a" "Home" False) debut) )
        , ( "end", encode (axe (Axes.Clavier "a" "End" False) debut) )
        , ( "cameraClic", encodeCamera (espace (Espace.Terminer False) cameraPrise) )
        , ( "cameraAnnule", encodeCamera (espace (Espace.Terminer True) cameraGlisse) )
        , ( "cameraValide", encodeCamera (espace (Espace.Terminer False) cameraGlisse) )
        , ( "cameraFinDouble", encodeCamera (espace (Espace.Terminer False) (espace (Espace.Terminer False) cameraGlisse).modele) )
        ]
