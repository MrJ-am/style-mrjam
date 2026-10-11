module MrJam.Lecture exposing (markdown, markdownPour)

{-| Sous-ensemble Markdown historique : titres, listes, citations, code, gras et
italique. Le HTML, les liens et les images restent du texte, sans HTML injecté.
-}

import Element exposing (Element, el, fill, padding, paragraph, spacing, text, width)
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import MrJam
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Texte as Texte
import MrJam.Donnees as Donnees
import MrJam.Theme as Theme


markdown : String -> Element message
markdown =
    markdownPour Theme.commune


markdownPour : Theme.Contexte -> String -> Element message
markdownPour contexte source =
    MrJam.pile (blocs contexte False (String.split "```" source))


blocs : Theme.Contexte -> Bool -> List String -> List (Element message)
blocs contexte code morceaux =
    case morceaux of
        [] ->
            []

        morceau :: suite ->
            (if code then
                [ el [ width fill, padding 14, Theme.fond (Theme.palette contexte).doux, Police.family [ Police.monospace ] ]
                    (Donnees.lecture (String.join "\n" (List.drop 1 (String.split "\n" morceau))))
                ]

             else
                String.split "\n\n" morceau |> List.filter (not << String.isEmpty) |> List.map (bloc contexte)
            )
                ++ blocs contexte (not code) suite


bloc : Theme.Contexte -> String -> Element message
bloc contexte contenu =
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
        Element.column [ width fill, spacing 8, Accessibilite.liste ]
            (List.map (\ligne -> paragraph [ width fill, Accessibilite.elementListe ] (text "• " :: enLigne (String.dropLeft 2 ligne))) lignes)

    else if String.startsWith "> " contenu then
        el [ width fill, padding 14, Bordure.widthEach { left = 3, right = 0, top = 0, bottom = 0 }, Theme.bordure (Theme.palette contexte).accent ]
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
    paragraph (width fill :: Texte.litteral) (enLigne contenu)


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
            [ Texte.texte contenu ]

        Just ( index, marque, style ) ->
            let
                reste =
                    String.dropLeft (index + String.length marque) contenu
            in
            case List.head (String.indexes marque reste) of
                Nothing ->
                    Texte.texte (String.left (index + String.length marque) contenu) :: enLigne reste

                Just fin ->
                    [ Texte.texte (String.left index contenu), el (style :: Texte.litteral) (Texte.texte (String.left fin reste)) ]
                        ++ enLigne (String.dropLeft (fin + String.length marque) reste)
