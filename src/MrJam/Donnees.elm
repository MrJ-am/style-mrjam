module MrJam.Donnees exposing (Interface, date, dateHeure, lecture, nombre, pour, tableau)

{-| Contrôles communs de données. Les valeurs de saisie restent des chaînes :
les valeurs vides et les validations métier appartiennent aux applications.
Aucune conversion de fuseau horaire ni modification de données n'est implicite.
-}

import Element exposing (Attribute, Element, fill, text, width)
import Element.Font as Police
import Element.Input as Saisie
import MrJam.Adaptateurs.Saisie as Native
import MrJam.Adaptateurs.Texte as Texte
import MrJam.Tableaux as Tableaux
import MrJam.Theme as Theme


type alias Interface ligne message =
    { nombre : String -> String -> (String -> message) -> Element message
    , date : String -> String -> (String -> message) -> Element message
    , dateHeure : String -> String -> (String -> message) -> Element message
    , tableau : String -> List ( String, ligne -> Element message ) -> List ligne -> Element message
    }


pour : Theme.Contexte -> Interface ligne message
pour contexte =
    { nombre = saisie contexte Native.nombre
    , date = saisie contexte Native.date
    , dateHeure = saisie contexte Native.dateHeure
    , tableau = tableauPour contexte
    }


nombre : String -> String -> (String -> message) -> Element message
nombre =
    saisie Theme.commune Native.nombre


date : String -> String -> (String -> message) -> Element message
date =
    saisie Theme.commune Native.date


dateHeure : String -> String -> (String -> message) -> Element message
dateHeure =
    saisie Theme.commune Native.dateHeure


saisie : Theme.Contexte -> List (Attribute message) -> String -> String -> (String -> message) -> Element message
saisie contexte nature libelle valeur modifier =
    Saisie.text
        (Theme.champPour contexte
            ++ nature
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
        (width fill :: Texte.litteral)
        [ Texte.texte contenu ]


{-| Tableau de lecture, pas une grille d'édition. Les cellules peuvent contenir
les actions sémantiques ordinaires. Le défilement horizontal est local et
accessible au clavier ; aucun tri ou changement de page n'est implicite.
-}
tableau : String -> List ( String, ligne -> Element message ) -> List ligne -> Element message
tableau =
    tableauPour Theme.commune


tableauPour : Theme.Contexte -> String -> List ( String, ligne -> Element message ) -> List ligne -> Element message
tableauPour contexte libelle colonnes lignes =
    (Tableaux.pour contexte).tableau libelle (List.map (\( nom, afficher ) -> Tableaux.colonne nom afficher) colonnes) lignes
