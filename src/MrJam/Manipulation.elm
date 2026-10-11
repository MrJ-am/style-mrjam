module MrJam.Manipulation exposing (Geste, bloc, chemin, cible, decoder, defilement, fantome, fond, formule, piece, prise, source, sousFormule, test, zoom)

{-| État visuel transitoire, jamais inclus dans un document métier. Le pont
transmet les coordonnées ; Elm construit le fantôme et signale la destination.
L'horloge de défilement vient de Transitions, uniquement pendant le geste.
-}

import Element as UI
import Element.Border as Bordure
import Json.Decode as D
import MrJam.Adaptateurs.Manipulation as Native


type alias Geste =
    { source : String, cible : Maybe String, x : Float, y : Float, largeur : Float }


decoder : D.Decoder Geste
decoder =
    D.map5 Geste
        (D.field "source" D.string)
        (D.field "cible" (D.nullable D.string))
        (D.field "x" D.float |> D.map (clamp -10000 10000))
        (D.field "y" D.float |> D.map (clamp -10000 10000))
        (D.field "largeur" D.float |> D.map (clamp 30 500))


source =
    Native.source


piece =
    Native.piece


bloc =
    Native.bloc


test =
    Native.test


sousFormule =
    Native.sousFormule


formule =
    Native.formule


chemin =
    Native.chemin


defilement =
    Native.defilement


fond =
    Native.fond


zoom =
    Native.zoom


prise : Maybe Geste -> String -> List (UI.Attribute message)
prise geste identifiant =
    Native.prise
        ++ [ UI.alpha
                (if Maybe.map .source geste == Just identifiant then
                    0.45

                 else
                    1
                )
           ]


cible : Maybe Geste -> String -> List (UI.Attribute message)
cible geste identifiant =
    [ Native.cible identifiant ]
        ++ (if (geste |> Maybe.andThen .cible) == Just identifiant then
                [ Native.depot, Bordure.glow (UI.rgb255 8 127 113) 3 ]

            else
                []
           )


{-| Le fantôme reste dans la couche elm-ui de l'atelier. Il ne porte aucun
identifiant métier ; inert interdit le focus et les interactions de ses enfants.
-}
fantome : Geste -> UI.Element message -> UI.Attribute message
fantome geste contenu =
    UI.inFront
        (UI.el
            ([ UI.alignTop
             , UI.alignLeft
             , UI.moveRight (geste.x + 12)
             , UI.moveDown (geste.y + 12)
             , UI.width (UI.px (round geste.largeur))
             , UI.height (UI.maximum 280 UI.shrink)
             , UI.clip
             , UI.alpha 0.85
             ]
                ++ Native.fantome
            )
            contenu
        )
