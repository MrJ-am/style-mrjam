module MrJam.Blocs exposing (Etat(..), cavite, emboitable, objectif, proposition)

{-| Contours génériques pour des constructions emboîtées. Une liste de cavités
forme une seule silhouette ouverte : C pour une cavité, E pour deux. Le module
ne connaît ni propositions logiques, ni règles, ni contexte métier. L'application
fournit le contenu ElmUI et les attributs techniques de saisie et de dépôt.
-}

import Element as UI exposing (Attribute, Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Html.Attributes as A
import MrJam.Theme exposing (couleurs)


type Etat
    = Neutre
    | Selectionne
    | Verifie
    | ACompleter
    | Incorrect


emboitable : Etat -> List (Attribute msg) -> Element msg -> List (Element msg) -> Element msg -> Element msg
emboitable etat attributs entete cavites pied =
    let
        teinte =
            if etat == Incorrect then
                couleurs.danger

            else
                couleurs.accent

        bande contenu =
            UI.el [ UI.width UI.fill, UI.paddingXY 12 12 ] contenu
    in
    UI.column
        ([ UI.width (UI.minimum 0 UI.fill)
         , UI.spacing 0
         , Fond.color couleurs.doux
         , Police.color couleurs.encre
         , Bordure.rounded 10
         , UI.htmlAttribute (A.class "mrjam-bloc")
         , UI.htmlAttribute
            (A.style "box-shadow"
                (if etat == Selectionne then
                    "0 0 0 3px #087f71"

                 else
                    "0 2px 0 #b7d4cc"
                )
            )
         , UI.htmlAttribute (A.style "clip-path" "polygon(0 0, 22px 0, 29px 7px, 49px 7px, 56px 0, 100% 0, 100% calc(100% - 7px), 56px calc(100% - 7px), 49px 100%, 29px 100%, 22px calc(100% - 7px), 0 calc(100% - 7px))")
         , UI.paddingEach { top = 7, right = 0, bottom = 12, left = 0 }
         ]
            ++ attributs
        )
        (bande entete
            :: List.map
                (\contenu ->
                    UI.row [ UI.width UI.fill, UI.spacing 0 ]
                        [ UI.el [ UI.width (UI.px 14), UI.height UI.fill, Fond.color teinte ] UI.none
                        , UI.el
                            [ UI.width (UI.minimum 0 UI.fill)
                            , UI.paddingXY 10 9
                            , Fond.color couleurs.papier
                            , Bordure.roundEach { topLeft = 10, bottomLeft = 10, topRight = 0, bottomRight = 0 }
                            , UI.htmlAttribute (A.class "mrjam-cavite")
                            ]
                            contenu
                        ]
                        |> UI.el [ UI.width UI.fill, UI.paddingEach { top = 0, right = 0, bottom = 10, left = 0 } ]
                )
                cavites
            ++ [ bande pied ]
        )


cavite : List (Attribute msg) -> Element msg -> Element msg
cavite attributs contenu =
    UI.el
        ([ UI.width (UI.minimum 0 UI.fill)
         , UI.height (UI.minimum 48 UI.shrink)
         , UI.padding 8
         , Bordure.dashed
         , Bordure.width 1
         , Bordure.color couleurs.ligne
         , Bordure.rounded 6
         , UI.htmlAttribute (A.class "mrjam-emplacement")
         ]
            ++ attributs
        )
        contenu


proposition : List (Attribute msg) -> Element msg -> Element msg
proposition attributs contenu =
    UI.el
        ([ UI.paddingXY 12 7
         , UI.width UI.shrink
         , UI.htmlAttribute (A.style "width" "max-content")
         , UI.htmlAttribute (A.style "max-width" "100%")
         , UI.htmlAttribute (A.style "flex-basis" "auto")
         , Fond.color couleurs.surface
         , Bordure.rounded 24
         , Bordure.width 1
         , Bordure.color couleurs.accent
         , UI.htmlAttribute (A.class "mrjam-proposition")
         ]
            ++ attributs
        )
        contenu


objectif : Element msg -> Element msg
objectif =
    UI.el
        [ UI.width (UI.minimum 0 UI.fill)
        , UI.paddingXY 12 10
        , Bordure.widthEach { top = 0, right = 0, bottom = 0, left = 3 }
        , Bordure.color couleurs.accent
        , Fond.color couleurs.surface
        ]
