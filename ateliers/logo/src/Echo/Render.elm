module Echo.Render exposing (Degrade, Options, defaults, svgString, svgStringAvecDegrade, svgStringAvecTrous, view)

import Echo.Animation as Animation exposing (Scene)
import Echo.Composition exposing (Instance)
import Echo.Primitives as Primitives exposing (Shape(..))
import Echo.Transform as Transform
import Element exposing (Element)
import MrJam.Dessin as Dessin


type alias Options =
    { prefix : String
    , box : String
    , title : String
    , diagnostic : Bool
    , axes : Bool
    , hidden : List String
    , isolated : Maybe String
    , reference : Maybe String
    , difference : Bool
    , trous : List Instance
    , degrade : Maybe Degrade
    }


type alias Degrade =
    { x1 : Float, y1 : Float, x2 : Float, y2 : Float }


defaults : String -> Options
defaults prefix =
    { prefix = prefix, box = "-9 -12 48 48", title = "Composition vectorielle du logo", diagnostic = False, axes = False, hidden = [], isolated = Nothing, reference = Nothing, difference = False, trous = [], degrade = Nothing }


view : Options -> Scene -> Element msg
view options scene =
    let
        definition brick =
            case Primitives.shape brick of
                Disc rayon ->
                    Dessin.disque (Primitives.key brick) rayon

                Contour chemin ->
                    Dessin.contour (Primitives.key brick) chemin

        piece visual =
            { id = visual.source.id
            , cle = Primitives.key visual.source.brick
            , couleur = Primitives.color visual.source.brick
            , opacite = visual.opacity
            , miroir = visual.mirror
            , faces =
                Animation.faces scene.strategy visual
                    |> List.map (\( matrice, opacite ) -> { matrice = Transform.serialize matrice, opacite = opacite })
            }

        trou occurrence =
            { id = occurrence.id
            , cle = Primitives.key occurrence.brick
            , matrice = Transform.serialize (Transform.terminal occurrence.pose)
            }
    in
    Dessin.vue
        { prefix = options.prefix
        , box = options.box
        , title = options.title
        , diagnostic = options.diagnostic
        , axes = options.axes
        , hidden = options.hidden
        , isolated = options.isolated
        , reference = options.reference
        , difference = options.difference
        , trous = List.map trou options.trous
        , degrade = options.degrade
        }
        { definitions = List.map definition Primitives.all, pieces = List.map piece scene.pieces, fond = scene.background }


{-| Export autonome lisible. Même définition de contour et mêmes matrices que le rendu.
Le cadrage 0 0 30 30 convient aux deux compositions statiques.
-}
svgString : String -> String -> Scene -> String
svgString prefix box scene =
    svgStringAvecTrous prefix box [] scene


svgStringAvecTrous : String -> String -> List Instance -> Scene -> String
svgStringAvecTrous prefix box trous scene =
    exporter prefix box trous Nothing scene


svgStringAvecDegrade : String -> String -> Degrade -> Scene -> String
svgStringAvecDegrade prefix box degrade scene =
    exporter prefix box [] (Just degrade) scene


exporter : String -> String -> List Instance -> Maybe Degrade -> Scene -> String
exporter prefix box trous degrade scene =
    let
        def brick =
            let
                id =
                    prefix ++ "-" ++ Primitives.key brick
            in
            case Primitives.shape brick of
                Disc radius ->
                    "    <circle id=\"" ++ id ++ "\" cx=\"0\" cy=\"0\" r=\"" ++ String.fromFloat radius ++ "\"/>"

                Contour path ->
                    "    <g id=\"" ++ id ++ "\" transform=\"translate(-13.8 -9)\"><path d=\"" ++ path ++ "\"/></g>"

        masqueTexte =
            if List.isEmpty trous then
                ""

            else
                "\n    <mask id=\""
                    ++ prefix
                    ++ "-trous\" maskUnits=\"userSpaceOnUse\" x=\"-20\" y=\"-20\" width=\"70\" height=\"70\"><rect x=\"-20\" y=\"-20\" width=\"70\" height=\"70\" fill=\"white\"/>"
                    ++ String.join "" (List.map (\trou -> "<use data-trou=\"" ++ trou.id ++ "\" href=\"#" ++ prefix ++ "-" ++ Primitives.key trou.brick ++ "\" transform=\"" ++ Transform.serialize (Transform.terminal trou.pose) ++ "\" fill=\"black\"/>") trous)
                    ++ "</mask>"

        piece visual =
            Animation.faces scene.strategy visual
                |> List.filter (\( _, opacity ) -> opacity > 0)
                |> List.map
                    (\( matrix, opacity ) ->
                        "  <use data-instance=\""
                            ++ visual.source.id
                            ++ "\" href=\"#"
                            ++ prefix
                            ++ "-"
                            ++ Primitives.key visual.source.brick
                            ++ "\" transform=\""
                            ++ Transform.serialize matrix
                            ++ "\" opacity=\""
                            ++ String.fromFloat opacity
                            ++ "\" fill=\"#ffffff\" stroke=\"none\"/>"
                    )
                |> String.join "\n"

        pieces =
            String.join "\n" (List.filter (not << String.isEmpty) (List.map piece scene.pieces))

        champ =
            case degrade of
                Nothing ->
                    ""

                Just d ->
                    "\n    <linearGradient id=\"" ++ prefix ++ "-degrade\" gradientUnits=\"userSpaceOnUse\" color-interpolation=\"sRGB\" x1=\"" ++ String.fromFloat d.x1 ++ "\" y1=\"" ++ String.fromFloat d.y1 ++ "\" x2=\"" ++ String.fromFloat d.x2 ++ "\" y2=\"" ++ String.fromFloat d.y2 ++ "\"><stop offset=\"0\" stop-color=\"#ffffff\"/><stop offset=\"1\" stop-color=\"" ++ scene.background ++ "\"/></linearGradient>\n    <mask id=\"" ++ prefix ++ "-silhouette\" maskUnits=\"userSpaceOnUse\" maskContentUnits=\"userSpaceOnUse\" x=\"0\" y=\"0\" width=\"30\" height=\"30\">\n" ++ pieces ++ "\n    </mask>"
    in
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\""
        ++ box
        ++ "\">\n  <defs>\n"
        ++ String.join "\n" (List.map def Primitives.all)
        ++ masqueTexte
        ++ champ
        ++ "\n  </defs>\n  <circle cx=\"15\" cy=\"15\" r=\"15\" fill=\""
        ++ scene.background
        ++ "\"/>\n"
        ++ (if List.isEmpty trous then
                ""

            else
                "  <g mask=\"url(#" ++ prefix ++ "-trous)\">\n"
           )
        ++ (case degrade of
                Nothing ->
                    pieces

                Just _ ->
                    "  <rect x=\"0\" y=\"0\" width=\"30\" height=\"30\" fill=\"url(#" ++ prefix ++ "-degrade)\" mask=\"url(#" ++ prefix ++ "-silhouette)\"/>"
           )
        ++ (if List.isEmpty trous then
                ""

            else
                "\n  </g>"
           )
        ++ "\n</svg>\n"
