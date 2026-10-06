module MrJam.Pictogrammes exposing (Icone(..), action, lien, vue)

{-| Pictogrammes communs. Le dessin est décoratif ; chaque commande conserve
un nom accessible et une infobulle. Une commande utilise le moteur des boutons.
-}

import Element as UI exposing (Element)
import Element.Font as Police
import Html.Attributes as A
import MrJam.Controles as Controles exposing (Intention(..))
import MrJam.Theme exposing (couleurs)
import Svg
import Svg.Attributes as S


type Icone
    = Ajouter
    | Modifier
    | Enregistrer
    | Fermer
    | Retour
    | Filtrer
    | Trier
    | Reglages
    | Livre
    | Horloge
    | Lien
    | Archiver
    | Sortir
    | Copier
    | Fleche
    | Dialogue
    | Etoile
    | Bouclier
    | Loupe


vue : Icone -> Element message
vue icone =
    UI.el [ UI.width (UI.px 22), UI.height (UI.px 22) ] <|
        UI.html <|
            Svg.svg
                [ S.viewBox "0 0 24 24", S.width "22", S.height "22", S.fill "none", S.stroke "currentColor", S.strokeWidth "1.7", S.strokeLinecap "round", S.strokeLinejoin "round", A.attribute "aria-hidden" "true", A.attribute "focusable" "false" ]
                (List.map (\trace -> Svg.path [ S.d trace ] []) (traces icone))


{-| Une commande compacte avec un nom compréhensible sans le pictogramme.
-}
action : Icone -> String -> message -> Element message
action icone libelle message =
    Controles.actionAvecContenu Icone
        [ UI.htmlAttribute (A.attribute "aria-label" libelle)
        , UI.htmlAttribute (A.title libelle)
        , UI.htmlAttribute (A.class "mrjam-picto-action")
        ]
        (vue icone)
        (Just message)


lien : Icone -> String -> String -> Element message
lien icone libelle url =
    UI.link
        [ UI.width (UI.px 44)
        , UI.height (UI.px 44)
        , UI.htmlAttribute (A.attribute "aria-label" libelle)
        , UI.htmlAttribute (A.title libelle)
        , Police.color couleurs.encre
        , UI.mouseOver [ Police.color couleurs.accent ]
        ]
        { url = url, label = UI.el [ UI.centerX, UI.centerY ] (vue icone) }


traces : Icone -> List String
traces icone =
    case icone of
        Ajouter ->
            [ "M12 5v14M5 12h14" ]

        Modifier ->
            [ "m15 5 4 4M4 20l4-1L20 7a2.8 2.8 0 0 0-4-4L4 15z" ]

        Enregistrer ->
            [ "m5 12 4 4L19 6" ]

        Fermer ->
            [ "m6 6 12 12M6 18 18 6" ]

        Retour ->
            [ "m10 5-7 7 7 7M3 12h18" ]

        Filtrer ->
            [ "M4 7h16M7 12h10M10 17h4" ]

        Trier ->
            [ "M8 4v16m-4-4 4 4 4-4M16 20V4m-4 4 4-4 4 4" ]

        Reglages ->
            [ "M4 7h16M4 17h16M8 4v6M16 14v6" ]

        Livre ->
            [ "M12 6C9 4 5 4 3 5v14c3-1 6-1 9 1 3-2 6-2 9-1V5c-2-1-6-1-9 1v14" ]

        Horloge ->
            [ "M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0M12 7v5l3 2" ]

        Lien ->
            [ "m10 13 4-4M8 15l-1 1a3.5 3.5 0 0 1-5-5l4-4a3.5 3.5 0 0 1 5 0m2 2 1-1a3.5 3.5 0 0 1 5 5l-4 4a3.5 3.5 0 0 1-5 0" ]

        Archiver ->
            [ "M4 8h16v12H4zM3 4h18v4H3zM9 12h6" ]

        Sortir ->
            [ "M9 4H4v16h5M10 12h11m-4-4 4 4-4 4" ]

        Copier ->
            [ "M9 9h11v11H9zM15 9V4H4v11h5" ]

        Fleche ->
            [ "M4 12h16m-6-6 6 6-6 6" ]

        Dialogue ->
            [ "M21 11a8 8 0 0 1-8 8H8l-5 3 1-6a8 8 0 1 1 17-5M8 10h8M8 14h5" ]

        Bouclier ->
            [ "M12 3 21 7v5c0 5-4 8-9 10-5-2-9-5-9-10V7z", "m8 12 3 3 5-6" ]

        Loupe ->
            [ "M16 10a6 6 0 1 1-12 0 6 6 0 0 1 12 0m-1.5 4.5L21 21" ]

        Etoile ->
            [ "m12 3 2.5 5 5.5.8-4 4 1 5.5-5-2.6L7 18.3l1-5.5-4-4L9.5 8z" ]
