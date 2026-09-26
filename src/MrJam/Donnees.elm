module MrJam.Donnees exposing (date, dateHeure, lecture, nombre, tableau)

{-| Contrôles communs de données. Les valeurs de saisie restent des chaînes :
les valeurs vides et les validations métier appartiennent aux applications.
Aucune conversion de fuseau horaire ni modification de données n'est implicite.
-}

import Element exposing (Element, fill, htmlAttribute, text, width)
import Element.Font as Police
import Element.Input as Saisie
import Html.Attributes as Attributs
import MrJam.Tableaux as Tableaux
import MrJam.Theme as Theme


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
               , htmlAttribute (Attributs.style "min-height" "36px")
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
    Element.paragraph
        [ width fill
        , htmlAttribute (Attributs.style "white-space" "pre-wrap")
        , htmlAttribute (Attributs.style "overflow-wrap" "anywhere")
        ]
        [ text contenu ]


{-| Tableau de lecture, pas une grille d'édition. Les cellules peuvent contenir
les actions sémantiques ordinaires. Le défilement horizontal est local et
accessible au clavier ; aucun tri ou changement de page n'est implicite.
-}
tableau : String -> List ( String, ligne -> Element message ) -> List ligne -> Element message
tableau libelle colonnes lignes =
    Tableaux.tableau libelle (List.map (\( nom, afficher ) -> Tableaux.colonne nom afficher) colonnes) lignes
