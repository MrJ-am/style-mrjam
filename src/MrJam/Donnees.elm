module MrJam.Donnees exposing (date, dateHeure, lecture, nombre, tableau)

{-| Contrôles communs de données. Les valeurs de saisie restent des chaînes :
les valeurs vides et les validations métier appartiennent aux applications.
Aucune conversion de fuseau horaire ni modification de données n'est implicite.
-}

import Element exposing (Element, el, fill, htmlAttribute, minimum, padding, spacing, text, width)
import Element.Background as Fond
import Element.Font as Police
import Element.Input as Saisie
import Html
import Html.Attributes as Attributs
import MrJam.Theme as Theme exposing (couleurs)


nombre : String -> String -> (String -> message) -> Element message
nombre =
    saisie "number"


date : String -> String -> (String -> message) -> Element message
date =
    saisie "date"


dateHeure : String -> String -> (String -> message) -> Element message
dateHeure =
    saisie "datetime-local"


saisie : String -> String -> String -> (String -> message) -> Element message
saisie nature libelle valeur modifier =
    Saisie.text
        (Theme.champ
            ++ [ htmlAttribute (Attributs.type_ nature)
               , htmlAttribute (Attributs.step "any")
               , htmlAttribute (Attributs.style "min-height" "44px")
               ]
        )
        { onChange = modifier
        , text = valeur
        , placeholder = Nothing
        , label = Saisie.labelAbove [ Police.size 14, Police.semiBold, Element.paddingEach { top = 0, right = 0, bottom = 6, left = 0 } ] (text libelle)
        }


{-| Texte littéral sélectionnable : espaces et retours conservés, jamais du HTML.
Ce composant n'est pas un moteur Markdown.
-}
lecture : String -> Element message
lecture contenu =
    el
        [ width fill
        , htmlAttribute (Attributs.style "white-space" "pre-wrap")
        , htmlAttribute (Attributs.style "overflow-wrap" "anywhere")
        ]
        (Element.html (Html.text contenu))


{-| Tableau de lecture, pas une grille d'édition. Les cellules peuvent contenir
les actions sémantiques ordinaires. Le défilement horizontal est local et
accessible au clavier ; aucun tri ou changement de page n'est implicite.
-}
tableau : String -> List ( String, ligne -> Element message ) -> List ligne -> Element message
tableau libelle colonnes lignes =
    let
        role nom =
            htmlAttribute (Attributs.attribute "role" nom)

        cellule nature contenu =
            el [ role nature, width fill, padding 12, Element.alignTop ] contenu

        rangee attributs cellules =
            Element.row ([ role "row", width fill ] ++ attributs) cellules
    in
    el
        [ width fill
        , Element.scrollbarX
        , htmlAttribute (Attributs.style "flex-basis" "auto")
        , role "region"
        , htmlAttribute (Attributs.attribute "aria-label" (libelle ++ " — défilement horizontal"))
        , htmlAttribute (Attributs.tabindex 0)
        ]
        (Element.column
            [ width (minimum (160 * max 1 (List.length colonnes)) fill)
            , role "table"
            , htmlAttribute (Attributs.attribute "aria-label" libelle)
            , spacing 1
            , Fond.color couleurs.ligne
            ]
            (rangee [ Fond.color couleurs.doux, Police.semiBold ]
                (List.map (\( nom, _ ) -> cellule "columnheader" (lecture nom)) colonnes)
                :: List.map
                    (\ligne ->
                        rangee [ Fond.color couleurs.surface ]
                            (List.map (\( _, afficher ) -> cellule "cell" (afficher ligne)) colonnes)
                    )
                    lignes
            )
        )
