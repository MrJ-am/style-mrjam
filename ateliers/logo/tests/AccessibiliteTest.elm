module AccessibiliteTest exposing (suite)

import Element
import Expect
import Html.Attributes as Attributs
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


verifier attributs attendus =
    Element.layout [] (Element.el attributs (Element.text "contenu"))
        |> Query.fromHtml
        |> Query.has attendus


suite : Test
suite =
    describe "Adaptateur borné d'accessibilité"
        [ test "ID et description désignent les éléments fournis" <|
            \() ->
                verifier [ Accessibilite.identifiant "champ", Accessibilite.decritPar "aide" ]
                    [ Selector.all [ Selector.id "champ", Selector.attribute (Attributs.attribute "aria-describedby" "aide") ] ]
        , test "contrôle ouvert : relation et état cohérents" <|
            \() ->
                verifier [ Accessibilite.controle "contenu", Accessibilite.depliement True ]
                    [ Selector.all [ Selector.attribute (Attributs.attribute "aria-controls" "contenu"), Selector.attribute (Attributs.attribute "aria-expanded" "true") ] ]
        , test "contrôle fermé : état explicite" <|
            \() ->
                verifier [ Accessibilite.depliement False ]
                    [ Selector.attribute (Attributs.attribute "aria-expanded" "false") ]
        , test "focus programmatique sans ajouter au parcours clavier" <|
            \() ->
                verifier [ Accessibilite.tabulation -1 ] [ Selector.attribute (Attributs.tabindex -1) ]
        , test "un ordre positif est ramené au parcours naturel" <|
            \() ->
                verifier [ Accessibilite.tabulation 42 ] [ Selector.attribute (Attributs.tabindex 0) ]
        , test "tableau et cellules possèdent leurs rôles sémantiques" <|
            \() ->
                Element.layout []
                    (Element.column [ Accessibilite.tableau ]
                        [ Element.row [ Accessibilite.rangee ]
                            [ Element.el [ Accessibilite.enteteColonne ] (Element.text "Titre")
                            , Element.el [ Accessibilite.cellule ] (Element.text "Réponse")
                            ]
                        ]
                    )
                    |> Query.fromHtml
                    |> Expect.all
                        (List.map
                            (\role -> Query.has [ Selector.attribute (Attributs.attribute "role" role) ])
                            [ "table", "row", "columnheader", "cell" ]
                        )
        , test "états de contrôle explicites ne rendent pas une couleur sémantique" <|
            \() ->
                verifier [ Accessibilite.pressee True, Accessibilite.desactive False, Accessibilite.occupe ]
                    [ Selector.all
                        [ Selector.attribute (Attributs.attribute "aria-pressed" "true")
                        , Selector.attribute (Attributs.attribute "aria-disabled" "false")
                        , Selector.attribute (Attributs.attribute "aria-busy" "true")
                        ]
                    ]
        , test "progression bornée même si la valeur est hors limites" <|
            \() ->
                verifier (Accessibilite.progression 124)
                    [ Selector.all
                        [ Selector.attribute (Attributs.attribute "role" "progressbar")
                        , Selector.attribute (Attributs.attribute "aria-valuemin" "0")
                        , Selector.attribute (Attributs.attribute "aria-valuemax" "100")
                        , Selector.attribute (Attributs.attribute "aria-valuenow" "100")
                        ]
                    ]
        ]
