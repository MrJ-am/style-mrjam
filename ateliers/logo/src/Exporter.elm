port module Exporter exposing (main)

import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Primitives as Primitives
import Echo.Render as Render
import Palette.Exports as Palette
import Platform


port files : List { name : String, content : String } -> Cmd msg


main : Program () () Never
main =
    Platform.worker
        { init = \_ -> ( (), files exports )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


exports : List { name : String, content : String }
exports =
    { name = "Logo-factorise.svg", content = Render.svgString "logo" "0 0 30 30" (Animation.static "#64c29b" Composition.logo) }
        :: (List.map
                (\cible ->
                    { name = Composition.nom cible ++ "-factorise.svg"
                    , content = Render.svgString (String.toLower (Composition.nom cible)) "0 0 30 30" (Animation.static (Composition.fond cible) (Composition.instances cible))
                    }
                )
                [ Composition.X, Composition.Y, Composition.Z ]
                ++ Palette.exports
                ++ List.map
                    (\forme ->
                        { name = Primitives.label forme ++ ".svg"
                        , content = Render.svgString (Primitives.key forme) "0 0 30 30" (Animation.static "#64c29b" (Composition.pictogramme forme))
                        }
                    )
                    [ Primitives.Auditif, Primitives.Visuel, Primitives.Kinesthesique ]
           )
