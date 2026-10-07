module Blocs exposing (main)

import Browser
import Element as UI
import MrJam
import MrJam.Blocs as Blocs


main : Program () Int ()
main =
    Browser.sandbox
        { init = 0
        , update = \_ n -> n + 1
        , view =
            \n ->
                MrJam.page "Constructions emboîtées"
                    [ Blocs.styles
                    , Blocs.emboitable Blocs.Neutre
                        []
                        (MrJam.paragraphe "Une construction à deux cavités")
                        [ Blocs.cavite [] (MrJam.bouton "Placer dans la première cavité" ())
                        , Blocs.emboitable Blocs.Selectionne
                            []
                            (MrJam.paragraphe "Une construction imbriquée")
                            [ Blocs.cavite [] (Blocs.proposition [] (UI.text "Objet sélectionnable")) ]
                            (MrJam.paragraphe "Sortie intérieure")
                        ]
                        (MrJam.paragraphe ("Actions : " ++ String.fromInt n))
                    ]
        }
