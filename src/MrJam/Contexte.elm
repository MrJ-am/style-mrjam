module MrJam.Contexte exposing (Contexte, commune, pour)

{-| Intention de présentation partagée. Le contexte est opaque et immuable ;
aucune couleur CSS ni réglage de composant n'est exposé à l'application.
Passer le même contexte aux composants d'une vue, y compris ses dialogues.
-}

import MrJam.Theme as Theme


type alias Contexte =
    Theme.Contexte


commune : Contexte
commune =
    Theme.commune


pour : String -> Contexte
pour =
    Theme.pour
