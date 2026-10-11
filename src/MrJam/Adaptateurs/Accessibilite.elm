module MrJam.Adaptateurs.Accessibilite exposing (banniere, cellule, compagnon, controle, decritPar, depliement, desactive, dialogue, elementListe, enteteColonne, etat, fermerDialogue, gestionDialogue, identifiant, image, inactif, infoBulle, liste, masque, modale, nomGroupe, occupe, pageCourante, pressee, progression, rangee, region, restituerFocus, selectionnee, tableau, tabulation)

{-| Attributs nécessaires absents de l'API publique elm-ui1.1.8.
Les libellés utilisent Element.Region.description ; nomGroupe compense
uniquement le filtrage de Describe dans Input.radioHelper.
Aucun nom d'attribut arbitraire, classe ou style ; exceptions centralement
limitées à ces fonctions et aux symboles/littéraux correspondants.
-}

import Browser.Dom
import Element exposing (Attribute)
import Html.Attributes as Attributs
import Task


identifiant : String -> Attribute message
identifiant valeur =
    Element.htmlAttribute (Attributs.id valeur)


{-| radioHelper d'elm-ui1.1.8 ne transmet pas les attributs Describe au
radiogroup (events ne retient que Internal.Attr). Region.description nomme
la zone interne ; cet attribut borné nomme aussi le groupe focalisable.
-}
nomGroupe : String -> Attribute message
nomGroupe libelle =
    Element.htmlAttribute (Attributs.attribute "aria-label" libelle)


controle : String -> Attribute message
controle cible =
    Element.htmlAttribute (Attributs.attribute "aria-controls" cible)


decritPar : String -> Attribute message
decritPar cible =
    Element.htmlAttribute (Attributs.attribute "aria-describedby" cible)


depliement : Bool -> Attribute message
depliement ouvert =
    Element.htmlAttribute
        (Attributs.attribute "aria-expanded"
            (if ouvert then
                "true"

             else
                "false"
            )
        )


tabulation : Int -> Attribute message
tabulation index =
    -- Aucun ordre de tabulation positif artificiel.
    Element.htmlAttribute (Attributs.tabindex (clamp -1 0 index))


{-| Le rendu Elm peut déplacer un nœud avec clé sans conserver son focus dans
le navigateur. Exprimer la cible stable de l'interaction après le rendu ; ne
pas attendre une animation, ni chercher un élément par texte ou classe CSS.
La réponse conserve un éventuel NotFound pour que l'application le traite.
-}
restituerFocus : String -> (Result Browser.Dom.Error () -> message) -> Cmd message
restituerFocus cible retour =
    Task.attempt retour (Browser.Dom.focus cible)


tableau : Attribute message
tableau =
    Element.htmlAttribute (Attributs.attribute "role" "table")


rangee : Attribute message
rangee =
    Element.htmlAttribute (Attributs.attribute "role" "row")


cellule : Attribute message
cellule =
    Element.htmlAttribute (Attributs.attribute "role" "cell")


enteteColonne : Attribute message
enteteColonne =
    Element.htmlAttribute (Attributs.attribute "role" "columnheader")


region : Attribute message
region =
    Element.htmlAttribute (Attributs.attribute "role" "region")


image : Attribute message
image =
    Element.htmlAttribute (Attributs.attribute "role" "img")


banniere : Attribute message
banniere =
    Element.htmlAttribute (Attributs.attribute "role" "banner")


liste : Attribute message
liste =
    Element.htmlAttribute (Attributs.attribute "role" "list")


elementListe : Attribute message
elementListe =
    Element.htmlAttribute (Attributs.attribute "role" "listitem")


dialogue : Attribute message
dialogue =
    Element.htmlAttribute (Attributs.attribute "role" "dialog")


modale : Attribute message
modale =
    Element.htmlAttribute (Attributs.attribute "aria-modal" "true")


gestionDialogue : Attribute message
gestionDialogue =
    Element.htmlAttribute (Attributs.attribute "data-mrjam-dialogue" "")


fermerDialogue : Attribute message
fermerDialogue =
    Element.htmlAttribute (Attributs.attribute "data-mrjam-fermer" "")


compagnon : Attribute message
compagnon =
    Element.htmlAttribute (Attributs.attribute "data-mrjam-compagnon" "")


masque : Attribute message
masque =
    Element.htmlAttribute (Attributs.attribute "aria-hidden" "true")


inactif : Attribute message
inactif =
    Element.htmlAttribute (Attributs.attribute "aria-disabled" "true")


occupe : Attribute message
occupe =
    Element.htmlAttribute (Attributs.attribute "aria-busy" "true")


pageCourante : Attribute message
pageCourante =
    Element.htmlAttribute (Attributs.attribute "aria-current" "page")


infoBulle : String -> Attribute message
infoBulle contenu =
    Element.htmlAttribute (Attributs.title contenu)


selectionnee : Bool -> Attribute message
selectionnee actif =
    Element.htmlAttribute (Attributs.attribute "aria-selected" (booleen actif))


pressee : Bool -> Attribute message
pressee actif =
    Element.htmlAttribute (Attributs.attribute "aria-pressed" (booleen actif))


booleen : Bool -> String
booleen actif =
    if actif then
        "true"

    else
        "false"


desactive : Bool -> Attribute message
desactive valeur =
    Element.htmlAttribute (Attributs.attribute "aria-disabled" (booleen valeur))


progression : Float -> List (Attribute message)
progression valeur =
    List.map Element.htmlAttribute
        [ Attributs.attribute "role" "progressbar"
        , Attributs.attribute "aria-valuemin" "0"
        , Attributs.attribute "aria-valuemax" "100"
        , Attributs.attribute "aria-valuenow" (String.fromFloat (clamp 0 100 valeur))
        ]


etat : Attribute message
etat =
    Element.htmlAttribute (Attributs.attribute "role" "status")
