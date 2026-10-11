module Blocs exposing (main)

import Browser
import Element as UI
import MrJam
import MrJam.Blocs as Blocs
import MrJam.Disposition as Disposition
import MrJam.Ecran as Ecran


type alias Modele =
    { compteur : Int, dimensions : Ecran.Dimensions, atelier : Bool }


type Message
    = Agir
    | Dimensionner Ecran.Dimensions
    | OuvrirAtelier


pieces : Int -> UI.Element Message
pieces n =
    Blocs.emboitable Blocs.Neutre
        []
        (MrJam.paragraphe "Une construction à deux cavités")
        [ Blocs.cavite [] (MrJam.bouton "Placer dans la première cavité" Agir)
        , Blocs.emboitable Blocs.Selectionne
            []
            (MrJam.paragraphe "Une construction imbriquée")
            [ Blocs.cavite [] (Blocs.proposition [] (UI.text "Objet sélectionnable")) ]
            (MrJam.paragraphe "Sortie intérieure")
        ]
        (MrJam.paragraphe ("Actions : " ++ String.fromInt n))


objets : UI.Element Message
objets =
    Blocs.propositionNiveau 0
        []
        (UI.row [ UI.spacing 5 ]
            [ UI.text "A ∧"
            , Blocs.propositionNiveau 1
                []
                (UI.row [ UI.spacing 5 ]
                    [ UI.text "B ∧", Blocs.propositionNiveau 2 [] (UI.text "C") ]
                )
            ]
        )


vue modele =
    if modele.atelier then
        Disposition.cadre []
            (Blocs.espace modele.dimensions
                (MrJam.actions [ Blocs.outil "Annuler" "↶" Agir, Blocs.onglet True "regles" "Construire" Agir, Blocs.onglet False "propositions" "Propositions" Agir ])
                (Blocs.emboitableAvec Blocs.Miniature Blocs.Neutre [] (UI.text "Palette") [ Blocs.logement [] (UI.text "…") ] UI.none)
                (UI.el [ UI.width (UI.minimum 0 UI.fill), UI.height (UI.minimum 0 UI.fill), UI.scrollbars ] (UI.column [ UI.width UI.shrink, UI.spacing 16, UI.padding 20 ] [ pieces modele.compteur, objets ]))
                (UI.text ("Actions : " ++ String.fromInt modele.compteur))
            )

    else
        MrJam.page "Constructions emboîtées"
            [ UI.el [ UI.width (UI.minimum 0 UI.fill), UI.scrollbarX ] (pieces modele.compteur)
            , objets
            , MrJam.bouton "Ouvrir l’atelier" OuvrirAtelier
            ]


main : Program () Modele Message
main =
    Browser.element
        { init = \() -> ( { compteur = 0, dimensions = { largeur = 0, hauteur = 0 }, atelier = False }, Ecran.initiale Dimensionner )
        , update =
            \message modele ->
                case message of
                    Agir ->
                        ( { modele | compteur = modele.compteur + 1 }, Cmd.none )

                    Dimensionner dimensions ->
                        ( { modele | dimensions = dimensions }, Cmd.none )

                    OuvrirAtelier ->
                        ( { modele | atelier = True }, Cmd.none )
        , subscriptions = always (Ecran.changements Dimensionner)
        , view = vue
        }
