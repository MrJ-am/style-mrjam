module MrJam.Dessin exposing (Definition, Degrade, Options, Scene, contour, disque, quadrillage, vue)

{-| Rendu vectoriel spécialisé : définitions, matrices, masques et comparaison.
Aucun HTML, CSS, événement ou modèle métier n'est accepté en paramètre.
La taille et la disposition du dessin restent des boîtes elm-ui.
-}

import Element exposing (Element)
import MrJam.Adaptateurs.Dessin as Rendu
import MrJam.Dessin.Types as Types


type alias Definition =
    Types.Definition


type alias Degrade =
    Types.Degrade


type alias Options =
    Types.Options


type alias Scene =
    Types.Scene


contour : String -> String -> Definition
contour cle chemin =
    { cle = cle, forme = Types.Contour chemin }


disque : String -> Float -> Definition
disque cle rayon =
    { cle = cle, forme = Types.Disque rayon }


vue : Options -> Scene -> Element message
vue =
    Rendu.vue


quadrillage : String -> Element message
quadrillage =
    Rendu.quadrillage
