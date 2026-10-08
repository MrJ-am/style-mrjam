module Palette.Exports exposing (exports, fond, manifeste)

{-| Fichiers dérivés de la référence commune, sans palette parallèle.
Les SVG utilisent sRGB en pourcentages non arrondis pour les éditeurs vectoriels.
Le manifeste conserve les coordonnées OKLCH qui font autorité.
-}

import Echo.Animation as Animation
import Echo.Composition as Composition
import Echo.Licorne as Licorne
import Echo.Primitives as Primitives
import Echo.Render as Render
import Json.Encode as E
import Palette.Couleurs as P exposing (Role(..))


fond : Role -> String
fond role =
    let
        rgb =
            P.srgb (P.couleur P.reference role)
    in
    "rgb(" ++ String.join "," (List.map (\v -> String.fromFloat (100 * v) ++ "%") [ rgb.r, rgb.g, rgb.b ]) ++ ")"


manifeste : String
manifeste =
    E.encode 2
        (E.object
            [ ( "nom", E.string "ÉcoLogo — palette de référence" )
            , ( "espace", E.string "OKLCH / OKLab D65 ; gamut sRGB" )
            , ( "critere", E.string "Maximum du chroma commun aux huit teintes, Licorne comprise" )
            , ( "L", E.float P.reference.l )
            , ( "C", E.float P.reference.c )
            , ( "angleOr", E.float P.angleOr )
            , ( "teintesLimitantes", E.list (P.cle >> E.string) (P.limiteCommune P.reference.l).roles )
            , ( "couleurs"
              , E.list
                    (\role ->
                        E.object
                            [ ( "role", E.string (P.cle role) )
                            , ( "nom", E.string (P.nom role) )
                            , ( "h", E.float (P.angle role) )
                            , ( "tetrade", E.int (P.tetrade role) )
                            , ( "principale", E.bool (role /= Licorne) )
                            , ( "oklch", E.string (P.css (P.couleur P.reference role)) )
                            , ( "srgb", E.string (fond role) )
                            , ( "hex", E.string (P.hex (P.couleur P.reference role) |> Maybe.withDefault "") )
                            ]
                    )
                    P.roles
              )
            ]
        )


exports : List { name : String, content : String }
exports =
    let
        dessin nom role pieces =
            { name = "Palette-" ++ nom ++ ".svg"
            , content = Render.svgString (P.cle role) "0 0 30 30" (Animation.static (fond role) pieces)
            }
    in
    [ dessin "Logo" Logo Composition.logo
    , dessin "X" Xiaoping Composition.x
    , dessin "Y" Ydris Composition.y
    , dessin "Z" Zoe Composition.z
    , dessin "Audio" Audio (Composition.pictogramme Primitives.Auditif)
    , dessin "Visio" Visio (Composition.pictogramme Primitives.Visuel)
    , dessin "Kino" Kino (Composition.pictogramme Primitives.Kinesthesique)
    , { name = "Licorne-factorisee.svg", content = Render.svgStringAvecDegrade "licorne" "0 0 30 30" Licorne.degrade (Animation.static (fond Licorne) Composition.licorne) }
    , { name = "palette.json", content = manifeste ++ "\n" }
    , { name = "palette.css"
      , content =
            "/* Généré depuis Palette.Couleurs : ne pas modifier les valeurs isolément. */\n:root {\n  --palette-l: "
                ++ String.fromFloat P.reference.l
                ++ ";\n  --palette-c: "
                ++ String.fromFloat P.reference.c
                ++ ";\n"
                ++ String.join "\n" (List.map (\role -> "  --palette-" ++ P.cle role ++ ": oklch(var(--palette-l) var(--palette-c) " ++ String.fromFloat (P.angle role) ++ ");") P.roles)
                ++ "\n}\n"
      }
    ]
