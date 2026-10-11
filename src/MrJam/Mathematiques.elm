module MrJam.Mathematiques exposing (document, formule, ligne, texte)

{-| Texte/TeX historique et documents scientifiques. Les espaces initiaux
expriment la portée d'une preuve : ils sont conservés en unités ch, sans
changer le corpus. Markdown est un sous-ensemble échappé, jamais du HTML injecté.
-}

import Element exposing (Element)
import Element.Font as Police
import Element.Region as Region
import MrJam.Adaptateurs.Accessibilite as A
import MrJam.Adaptateurs.Mathematiques as Native
import MrJam.Adaptateurs.Texte as Texte


ligne : String -> List (Element message)
ligne source =
    source
        |> String.split "$"
        |> List.indexedMap
            (\indice segment ->
                if modBy 2 indice == 0 then
                    Element.text segment

                else
                    Native.expression False segment
            )


texte : String -> Element message
texte source =
    Element.paragraph [ Element.width Element.fill, Element.spacing 6 ] (ligne source)


formule : String -> Element message
formule source =
    Element.el [ Element.width (Element.minimum 0 Element.fill), Element.scrollbarX ]
        (Native.expression True source)


type Bloc
    = Prose (List String)
    | Liste (List String)
    | Titre Int String


document : String -> Element message
document source =
    source
        |> String.replace "\u{000D}\n" "\n"
        |> String.replace "\u{000D}" "\n"
        |> String.lines
        |> blocs [] [] []
        |> List.map afficherBloc
        |> Element.column [ Element.width Element.fill, Element.spacing 16, Texte.document source ]


blocs : List Bloc -> List String -> List String -> List String -> List Bloc
blocs termines prose liste restantes =
    let
        fermer =
            termines
                ++ (if List.isEmpty prose then
                        []

                    else
                        [ Prose prose ]
                   )
                ++ (if List.isEmpty liste then
                        []

                    else
                        [ Liste liste ]
                   )
    in
    case restantes of
        [] ->
            fermer

        entree :: suite ->
            if String.isEmpty (String.trim entree) then
                blocs fermer [] [] suite

            else if String.startsWith "- " (String.trimLeft entree) then
                blocs
                    (termines
                        ++ (if List.isEmpty prose then
                                []

                            else
                                [ Prose prose ]
                           )
                    )
                    []
                    (liste ++ [ String.dropLeft 2 (String.trimLeft entree) |> String.trimLeft ])
                    suite

            else
                case titre entree of
                    Just ( niveau, contenu ) ->
                        blocs (fermer ++ [ Titre niveau contenu ]) [] [] suite

                    Nothing ->
                        blocs
                            (termines
                                ++ (if List.isEmpty liste then
                                        []

                                    else
                                        [ Liste liste ]
                                   )
                            )
                            (prose ++ [ entree ])
                            []
                            suite


titre : String -> Maybe ( Int, String )
titre source =
    [ 3, 2, 1 ]
        |> List.filterMap
            (\niveau ->
                let
                    marque =
                        String.repeat niveau "#" ++ " "
                in
                if String.startsWith marque source then
                    Just ( niveau, String.dropLeft (String.length marque) source |> String.trimLeft )

                else
                    Nothing
            )
        |> List.head


afficherBloc : Bloc -> Element message
afficherBloc bloc =
    case bloc of
        Titre niveau contenu ->
            Element.paragraph [ Element.width Element.fill, Region.heading niveau, Police.bold, Police.size (28 - niveau * 2) ] (enLigne contenu)

        Liste entrees ->
            Element.column [ Element.width Element.fill, Element.spacing 8, A.liste ]
                (List.map (\contenu -> Element.paragraph [ Element.width Element.fill, A.elementListe ] (Element.text "• " :: enLigne contenu)) entrees)

        Prose lignes ->
            let
                portees =
                    List.any (String.startsWith " ") lignes

                afficher contenu =
                    let
                        espaces =
                            String.length contenu - String.length (retirerEspaces contenu)
                    in
                    Element.paragraph
                        ([ Element.width (Element.minimum 0 Element.fill) ]
                            ++ Texte.litteral
                            ++ (if portees then
                                    Texte.portee espaces

                                else
                                    []
                               )
                        )
                        (enLigne
                            (if portees then
                                String.dropLeft espaces contenu

                             else
                                contenu
                            )
                        )
            in
            Element.column [ Element.width (Element.minimum 0 Element.fill), Element.spacing 0 ] (List.map afficher lignes)


retirerEspaces : String -> String
retirerEspaces source =
    if String.startsWith " " source then
        retirerEspaces (String.dropLeft 1 source)

    else
        source


{-| La priorité préserve code, gras et les deux délimiteurs KaTeX. Un marqueur
non fermé reste littéral ; le contenu de code n'est jamais envoyé à KaTeX.
-}
enLigne : String -> List (Element message)
enLigne source =
    let
        candidats =
            [ "`", "**", "$$", "$" ]
                |> List.indexedMap Tuple.pair
                |> List.filterMap (\( priorite, marque ) -> String.indexes marque source |> List.head |> Maybe.map (\index -> ( index, priorite, marque )))
                |> List.sortBy (\( index, priorite, _ ) -> ( index, priorite ))
    in
    case List.head candidats of
        Nothing ->
            [ Texte.texte source ]

        Just ( debut, _, marque ) ->
            let
                reste =
                    String.dropLeft (debut + String.length marque) source
            in
            case List.head (String.indexes marque reste) of
                Nothing ->
                    Texte.texte (String.left (debut + String.length marque) source) :: enLigne reste

                Just fin ->
                    let
                        contenu =
                            String.left fin reste

                        rendu =
                            case marque of
                                "`" ->
                                    Element.el [ Police.family [ Police.monospace ] ] (Texte.texte contenu)

                                "**" ->
                                    Element.paragraph [ Police.bold ] (enLigne contenu)

                                _ ->
                                    Native.expression (marque == "$$") contenu
                    in
                    Texte.texte (String.left debut source) :: rendu :: enLigne (String.dropLeft (fin + String.length marque) reste)
