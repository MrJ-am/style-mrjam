port module Exporter exposing (main)

import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Render as Render
import Platform


port files : List { name : String, content : String } -> Cmd msg


main : Program () () Never
main =
    Platform.worker
        { init = \_ -> ( (), files [ { name = "Logo-factorise.svg", content = Render.svgString "logo" "0 0 30 30" (Animation.static "#64c29b" Composition.logo) }, { name = "X-factorise.svg", content = Render.svgString "x" "0 0 30 30" (Animation.static "#9c3e65" Composition.x) }, { name = "Y-factorise.svg", content = Render.svgString "y" "0 0 30 30" (Animation.static "#64c29b" Composition.y) } ] )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
