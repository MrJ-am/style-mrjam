module MrJam.Accessibilite exposing (controle, decritPar, depliement, etat, evitement, identifiant, infoBulle, masque, tabulation)

{-| Sémantique publique des compositions applicatives. Chaque capacité est
bornée par l'adaptateur commun : aucun nom d'attribut, classe ou style libre.
Les rôles ordinaires utilisent Element.Region.
-}

import Element as UI
import Element.Border as Bordure
import MrJam.Adaptateurs.Accessibilite as Native
import MrJam.Theme as Theme


identifiant =
    Native.identifiant


controle =
    Native.controle


decritPar =
    Native.decritPar


depliement =
    Native.depliement


etat =
    Native.etat


infoBulle =
    Native.infoBulle


masque =
    Native.masque


tabulation =
    Native.tabulation


{-| Lien d'évitement hors écran au repos, révélé par le focus natif elm-ui.
Aucune feuille CSS parallèle ni interaction décorative imposée.
-}
evitement : String -> UI.Attribute message
evitement cible =
    UI.inFront
        (UI.el [ UI.alignTop, UI.alignLeft ]
            (UI.link
                [ UI.moveUp 100
                , UI.alpha 0
                , UI.focused [ UI.moveDown 12, UI.alpha 1 ]
                , UI.padding 12
                , Theme.fond Theme.couleurs.surface
                , Theme.police Theme.couleurs.encre
                , Bordure.width 3
                , Theme.bordure Theme.couleurs.accent
                ]
                { url = "#" ++ cible, label = UI.text "Aller au contenu" }
            )
        )
