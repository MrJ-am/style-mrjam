module MrJam.Lectures exposing (Lecteur, aide, mesurerReference, reinitialiser, vue)

{-| Lecture scientifique commune : entête et commandes restent disponibles,
le document seul défile. Le dialogue natif possède focus/fond inerte ; aucune
opération métier n'attend la transition d'entrée.
-}

import Browser.Dom as Dom
import Element as UI exposing (Element)
import Element.Font as Police
import Element.Region as Region
import MrJam
import MrJam.Accessibilite as A
import MrJam.Adaptateurs.Dialogue as Dialogue
import MrJam.Contexte exposing (Contexte)
import MrJam.Ecran exposing (Dimensions)
import MrJam.Manipulation as Repere
import MrJam.Theme as Theme
import MrJam.Transitions as T
import Task


type alias Lecteur message =
    { identifiant : String
    , titre : String
    , fermer : message
    , actions : List (Element message)
    , contenu : Element message
    , commandes : List (Element message)
    }


vue : Contexte -> Dimensions -> Float -> T.Transition Bool -> Lecteur message -> Element message
vue contexte ecran reference transition lecteur =
    let
        debut =
            ceiling (min (toFloat ecran.hauteur * 0.32) (max 12 (reference + 14)))

        progression =
            T.nombre
                (\ouvert ->
                    if ouvert then
                        1

                    else
                        0
                )
                transition
    in
    Dialogue.integrer <|
        Dialogue.natifLecture debut lecteur.identifiant "reading-card" lecteur.titre lecteur.fermer <|
            UI.layoutWith { options = [ UI.noStaticStyleSheet, Theme.focusPour contexte ] }
                [ UI.width (UI.px (min 940 (max 200 (ecran.largeur - 24))))
                , UI.height (UI.px (max 0 (ecran.hauteur - debut - 12)))
                , Police.family [ Police.typeface "Inter", Police.typeface "Segoe UI", Police.sansSerif ]
                , Police.size 16
                ]
                (UI.column (Theme.panneauPour contexte ++ [ UI.height UI.fill ])
                    [ UI.column
                        [ UI.width UI.fill
                        , UI.height UI.fill
                        , UI.spacing 12
                        , UI.alpha progression
                        , UI.moveDown (12 * (1 - progression))
                        ]
                        [ UI.wrappedRow [ UI.width UI.fill, UI.spacing 8 ]
                            [ UI.el [ UI.width UI.fill, A.identifiant "reader-title" ] (MrJam.sousTitre lecteur.titre)
                            , MrJam.actions lecteur.actions
                            ]
                        , if ecran.largeur >= 760 && ecran.hauteur < 600 then
                            UI.row [ UI.width UI.fill, UI.height (UI.minimum 0 UI.fill), UI.spacing 16 ]
                                [ document lecteur.contenu
                                , UI.column [ UI.width (UI.px 260), UI.height (UI.minimum 0 UI.fill), UI.scrollbarY, UI.spacing 8 ] lecteur.commandes
                                ]

                          else
                            UI.column [ UI.width UI.fill, UI.height (UI.minimum 0 UI.fill), UI.spacing 12 ]
                                [ document lecteur.contenu
                                , UI.column [ UI.width UI.fill, UI.spacing 8 ] lecteur.commandes
                                ]
                        ]
                    ]
                )


{-| Aide associée au contrôle dans le même dialogue. Elle reste dans le flux
accessible, sans seconde couche modale ou compagnon rendu inerte.
-}
aide : Contexte -> Dimensions -> String -> String -> String -> message -> Element message
aide contexte ecran titre contenu fermeture fermer =
    let
        composants =
            MrJam.pour contexte
    in
    UI.column
        (Theme.panneauPour contexte ++ [ UI.width (UI.maximum 330 UI.fill), UI.padding 12, UI.spacing 8, Repere.test "context-help" ])
        [ UI.paragraph [ Region.heading 2, Police.size 16, Police.bold ] [ UI.text titre ]
        , UI.el
            [ UI.width UI.fill
            , UI.height (UI.maximum (max 24 (min 240 (round (toFloat ecran.hauteur * 0.45)) - 106)) UI.shrink)
            , UI.scrollbarY
            ]
            (UI.paragraph [ Police.size 14 ] [ UI.text contenu ])
        , composants.boutonSecondaire fermeture fermer
        ]


{-| Réinitialiser le document et son focus après un changement de texte.
Le résultat de l'opération DOM reste explicite.
-}
reinitialiser : (Result Dom.Error () -> message) -> Cmd message
reinitialiser retour =
    Task.attempt retour (Dom.setViewportOf "reader-content" 0 0 |> Task.andThen (\_ -> Dom.focus "reading-card"))


{-| Bord inférieur de l'énoncé dans le viewport, sans état global/rafraîchissement.
L'application demande une nouvelle mesure quand sa référence change.
-}
mesurerReference : String -> (Result Dom.Error Float -> message) -> Cmd message
mesurerReference identifiant retour =
    Task.attempt retour (Dom.getElement identifiant |> Task.map (\element -> element.element.y + element.element.height - element.viewport.y))


document : Element message -> Element message
document contenu =
    UI.el
        [ UI.width (UI.minimum 0 UI.fill)
        , UI.height (UI.minimum 0 UI.fill)
        , UI.scrollbarY
        , A.identifiant "reader-content"
        , Repere.test "reader-content"
        ]
        contenu
