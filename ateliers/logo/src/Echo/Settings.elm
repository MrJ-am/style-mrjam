module Echo.Settings exposing (decode, encode)

import Echo.Animation as Animation exposing (Settings, Strategy(..))
import Json.Decode as D
import Json.Encode as E


encode : Settings -> String
encode s =
    E.object
        [ ( "version", E.int 1 )
        , ( "duration", E.float s.duration )
        , ( "stagger", E.float s.stagger )
        , ( "mirrorWidth", E.float s.mirrorWidth )
        , ( "fadeBackground", E.bool s.fadeBackground )
        , ( "strategy"
          , E.string
                (if s.strategy == Relief then
                    "relief"

                 else
                    "fondu"
                )
          )
        , ( "mobileDuration", E.float s.mobileDuration )
        , ( "rest", E.float s.rest )
        , ( "turns", E.int s.turns )
        , ( "spread", E.float s.spread )
        , ( "omegaReference", E.float s.omegaReference )
        , ( "spinDirection", E.int s.spinDirection )
        ]
        |> E.encode 2


decode : String -> Result D.Error Settings
decode =
    D.decodeString
        (D.field "version" D.int
            |> D.andThen
                (\version ->
                    if version == 1 then
                        decoder

                    else
                        D.fail "Version de réglages non prise en charge (version 1 attendue)."
                )
        )


decoder : D.Decoder Settings
decoder =
    let
        strategy =
            D.string
                |> D.andThen
                    (\value ->
                        if value == "relief" then
                            D.succeed Relief

                        else if value == "fondu" then
                            D.succeed LocalFade

                        else
                            D.fail "Stratégie inconnue."
                    )

        first =
            D.map8
                (\duration stagger mirrorWidth fadeBackground mirror mobileDuration rest turns ->
                    let
                        defaults =
                            Animation.defaults
                    in
                    { defaults | duration = duration, stagger = stagger, mirrorWidth = mirrorWidth, fadeBackground = fadeBackground, strategy = mirror, mobileDuration = mobileDuration, rest = rest, turns = turns }
                )
                (D.field "duration" D.float)
                (D.field "stagger" D.float)
                (D.field "mirrorWidth" D.float)
                (D.field "fadeBackground" D.bool)
                (D.field "strategy" strategy)
                (D.field "mobileDuration" D.float)
                (D.field "rest" D.float)
                (D.field "turns" D.int)
    in
    D.map4 (\base spread omegaReference spinDirection -> Animation.normalize { base | spread = spread, omegaReference = omegaReference, spinDirection = spinDirection })
        first
        (D.field "spread" D.float)
        (D.field "omegaReference" D.float)
        (D.field "spinDirection" D.int)
