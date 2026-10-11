module MrJam.Ecran exposing (Dimensions, changements, initiale, largeurInitiale, redimensionnements)

{-| Dimensions du navigateur : même raccord pour les compositions adaptatives.
Aucune boucle de rafraîchissement et aucun état global ; l'application conserve
la largeur dans son modèle. Les flags de démarrage restent inchangés.
-}

import Browser.Dom
import Browser.Events
import Task


type alias Dimensions =
    { largeur : Int, hauteur : Int }


initiale : (Dimensions -> message) -> Cmd message
initiale message =
    Task.perform (\viewport -> message { largeur = round viewport.viewport.width, hauteur = round viewport.viewport.height }) Browser.Dom.getViewport


changements : (Dimensions -> message) -> Sub message
changements message =
    Browser.Events.onResize (\largeur hauteur -> message { largeur = largeur, hauteur = hauteur })


largeurInitiale : (Int -> message) -> Cmd message
largeurInitiale message =
    Task.perform (\viewport -> message (round viewport.viewport.width)) Browser.Dom.getViewport


redimensionnements : (Int -> message) -> Sub message
redimensionnements message =
    Browser.Events.onResize (\largeur _ -> message largeur)
