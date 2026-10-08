module Echo.Licorne exposing (degrade, placements)

{-| Données du modèle approuvé : museau très long, sans poitrail.
Généré par scripts/importer-licorne.py. Les trois contours restent dans Primitives.
Le dégradé global va du blanc de la corne au rose du disque dans la crinière.
-}

import Echo.Primitives exposing (Brick(..))


type alias Placement =
    { id : String, brick : Brick, x : Float, y : Float, angle : Float, scale : Float, reflected : Bool }


degrade : { x1 : Float, y1 : Float, x2 : Float, y2 : Float }
degrade =
    { x1 = 22.66063565899783, y1 = 3.0222516792292806, x2 = 2.574234669898312, y2 = 23.108652668328798 }


placements : List Placement
placements =
    [ { id = "criniere-front", brick = Visuel, x = 13.526185563323368, y = 13.51939147485685, angle = 21.780812772483213, scale = 0.44671594647438856, reflected = True }
    , { id = "criniere-tempe", brick = Kinesthesique, x = 12.41225804972465, y = 13.120524933423102, angle = 42.005344303665964, scale = 0.4274904611985575, reflected = True }
    , { id = "criniere-joue", brick = Kinesthesique, x = 11.38173386805457, y = 14.510313307964108, angle = 6.492984783949996, scale = 0.4826477328902436, reflected = True }
    , { id = "criniere-arriere", brick = Kinesthesique, x = 3.3823118746921694, y = 24.507575736030848, angle = -140.73315283167827, scale = 0.40796879748741915, reflected = True }
    , { id = "criniere-basse-1", brick = Kinesthesique, x = 9.578213041314315, y = 23.715846518758507, angle = 52.275379258163575, scale = 0.2355202071449016, reflected = False }
    , { id = "criniere-basse-2", brick = Kinesthesique, x = 11.39676664589384, y = 25.889765349799053, angle = 57.47028738594428, scale = 0.17783576329131165, reflected = False }
    , { id = "oreille-arriere", brick = Kinesthesique, x = 13.43770661567374, y = 11.681098585720717, angle = -162.41226862584298, scale = 0.2587612737111469, reflected = False }
    , { id = "oreille-avant", brick = Visuel, x = 15.476065380474953, y = 10.475613807784773, angle = -99.07277396221606, scale = 0.22341505465043918, reflected = False }
    , { id = "corne-base", brick = Auditif, x = 17.64094443687835, y = 11.882157580039717, angle = -9.567143970617785, scale = 0.4976776817903942, reflected = False }
    , { id = "corne-2", brick = Auditif, x = 18.83600980576257, y = 8.012875304287334, angle = -172.53600374209006, scale = 0.4675757332638167, reflected = True }
    , { id = "corne-3", brick = Auditif, x = 19.991259748793812, y = 6.641458663676487, angle = -170.62498459619735, scale = 0.4020144299424312, reflected = True }
    , { id = "corne-4", brick = Auditif, x = 21.11721235590456, y = 5.495383440954843, angle = -160.37623343195307, scale = 0.3403849485641334, reflected = True }
    , { id = "corne-pointe", brick = Visuel, x = 21.21151225330773, y = 5.368087563934058, angle = -58.159507223907674, scale = 0.24037073064634126, reflected = False }
    , { id = "oeil", brick = Auditif, x = 14.579382030327166, y = 15.912173911142974, angle = 118.54297193754597, scale = 0.4306260173893412, reflected = False }
    , { id = "machoire", brick = Visuel, x = 12.962264407032452, y = 20.72587980242767, angle = 12.0620662905087, scale = 0.581342224028939, reflected = False }
    , { id = "front", brick = Kinesthesique, x = 16.141869715459098, y = 12.392166877151485, angle = -40.72979794093047, scale = 0.23407227191523097, reflected = False }
    , { id = "chanfrein", brick = Kinesthesique, x = 23.669350946496827, y = 24.71588547402392, angle = 155.95233291611405, scale = 0.4903802770832804, reflected = True }
    , { id = "joue", brick = Kinesthesique, x = 15.956920190500869, y = 20.49039545221526, angle = 140.01790411674625, scale = 0.3144386825962287, reflected = False }
    , { id = "museau", brick = Auditif, x = 21.00431461926667, y = 23.395631879045446, angle = 57.0092721774006, scale = 0.46816248688466316, reflected = True }
    ]
