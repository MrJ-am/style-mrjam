module MrJam.Lecture exposing (markdown)

{-| Sous-ensemble Markdown historique : titres, listes, citations, code, gras et
italique. Le HTML, les liens et les images restent du texte, sans HTML injecté.
-}

import Element exposing (Element, el, fill, htmlAttribute, padding, paragraph, spacing, text, width)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Html.Attributes as A
import MrJam
import MrJam.Donnees as Donnees
import MrJam.Theme exposing (couleurs)


markdown : String -> Element message
markdown source =
    MrJam.pile (blocs False (String.split "```" source))


blocs : Bool -> List String -> List (Element message)
blocs code morceaux =
    case morceaux of
        [] ->
            []

        morceau :: suite ->
            (if code then
                [ el [ width fill, padding 14, Fond.color couleurs.doux, Police.family [ Police.monospace ] ]
                    (Donnees.lecture (String.join "\n" (List.drop 1 (String.split "\n" morceau))))
                ]

             else
                String.split "\n\n" morceau |> List.filter (not << String.isEmpty) |> List.map bloc
            )
                ++ blocs (not code) suite


bloc : String -> Element message
bloc contenu =
    let
        lignes =
            String.lines contenu

        titre =
            String.startsWith "# " contenu || String.startsWith "## " contenu || String.startsWith "### " contenu || String.startsWith "#### " contenu || String.startsWith "##### " contenu || String.startsWith "###### " contenu

        sansMarque =
            String.join " " (List.drop 1 (String.split " " contenu))
    in
    if titre then
        paragraph [ width fill, Region.heading 2, Police.size 23, Police.bold ] (enLigne sansMarque)

    else if List.all (\ligne -> String.startsWith "- " ligne || String.startsWith "* " ligne) lignes then
        Element.column [ width fill, spacing 8, htmlAttribute (A.attribute "role" "list") ]
            (List.map (\ligne -> paragraph [ width fill, htmlAttribute (A.attribute "role" "listitem") ] (text "• " :: enLigne (String.dropLeft 2 ligne))) lignes)

    else if String.startsWith "> " contenu then
        el [ width fill, padding 14, Bordure.widthEach { left = 3, right = 0, top = 0, bottom = 0 }, Bordure.color couleurs.accent ]
            (prose
                (String.join "\n"
                    (List.map
                        (\ligne ->
                            if String.startsWith "> " ligne then
                                String.dropLeft 2 ligne

                            else
                                ligne
                        )
                        lignes
                    )
                )
            )

    else
        prose contenu


prose : String -> Element message
prose contenu =
    paragraph [ width fill, htmlAttribute (A.style "white-space" "pre-wrap"), htmlAttribute (A.style "overflow-wrap" "anywhere") ] (enLigne contenu)


enLigne : String -> List (Element message)
enLigne contenu =
    let
        marques =
            [ ( "`", Police.family [ Police.monospace ] ), ( "**", Police.bold ), ( "*", Police.italic ) ]

        candidates =
            List.filterMap (\( marque, style ) -> List.head (String.indexes marque contenu) |> Maybe.map (\index -> ( index, marque, style ))) marques
    in
    case List.head (List.sortBy (\( index, _, _ ) -> index) candidates) of
        Nothing ->
            [ text contenu ]

        Just ( index, marque, style ) ->
            let
                reste =
                    String.dropLeft (index + String.length marque) contenu
            in
            case List.head (String.indexes marque reste) of
                Nothing ->
                    text (String.left (index + String.length marque) contenu) :: enLigne reste

                Just fin ->
                    [ text (String.left index contenu), el [ style ] (text (String.left fin reste)) ]
                        ++ enLigne (String.dropLeft (fin + String.length marque) reste)
