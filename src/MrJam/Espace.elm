module MrJam.Espace exposing (Message(..), Modele, Objet, Resultat, actualiser, initialiser, vue)

{-| Caméra et geste de l'espace commun. Les coordonnées des objets sont des
entrées ; aucune rotation de caméra ne propose une modification de ces données.
Les effets retournés restent des intentions que le consommateur peut autoriser.
-}

import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Keyed as Cle
import Element.Region as Region
import MrJam.Accessibilite as A
import MrJam.Adaptateurs.Espace as Native
import MrJam.Adaptateurs.GraphiqueSpatial as Graphique
import MrJam.Adaptateurs.Spatial as Spatial
import MrJam.Controles as Controles
import MrJam.Ecran exposing (Dimensions)
import MrJam.GeometrieSpatiale as G
import MrJam.Manipulation as Manipulation
import MrJam.Mathematiques as Math


type alias Objet =
    { identifiant : String, numero : Int, contenu : String, point : G.Bille, attente : Bool }


type alias Modele =
    { dimensions : Dimensions
    , camera : G.Camera
    , geste : Maybe Geste
    }


type alias Geste =
    { x : Float, y : Float, camera : G.Camera, objet : Maybe String, mouvement : Bool }


type Message
    = Mesurer Dimensions
    | Prendre Float Float (Maybe String)
    | Deplacer Float Float
    | Terminer Bool
    | Tourner Float Float


type alias Resultat =
    { modele : Modele, ouvrir : Maybe String, tourne : Bool }


initialiser : Modele
initialiser =
    { dimensions = { largeur = 310, hauteur = 350 }, camera = { azimut = 0.64, elevation = 0.38 }, geste = Nothing }


actualiser : Message -> Modele -> Resultat
actualiser message modele =
    let
        sansEffet prochain =
            { modele = prochain, ouvrir = Nothing, tourne = False }
    in
    case message of
        Mesurer dimensions ->
            sansEffet { modele | dimensions = dimensions }

        Prendre x y objet ->
            case modele.geste of
                Just _ ->
                    sansEffet modele

                Nothing ->
                    sansEffet { modele | geste = Just { x = x, y = y, camera = modele.camera, objet = objet, mouvement = False } }

        Deplacer x y ->
            case modele.geste of
                Nothing ->
                    sansEffet modele

                Just geste ->
                    let
                        dx =
                            x - geste.x

                        dy =
                            y - geste.y

                        bouge =
                            geste.mouvement || sqrt (dx * dx + dy * dy) > 5
                    in
                    if bouge then
                        sansEffet
                            { modele
                                | camera = { azimut = geste.camera.azimut - dx * 0.008, elevation = clamp -1.25 1.25 (geste.camera.elevation + dy * 0.007) }
                                , geste = Just { geste | mouvement = True }
                            }

                    else
                        sansEffet modele

        Terminer annule ->
            case modele.geste of
                Nothing ->
                    sansEffet modele

                Just geste ->
                    { modele = { modele | geste = Nothing }
                    , ouvrir =
                        if not annule && not geste.mouvement then
                            geste.objet

                        else
                            Nothing
                    , tourne = not annule && geste.mouvement
                    }

        Tourner azimut elevation ->
            { modele = { modele | camera = { azimut = modele.camera.azimut + azimut, elevation = clamp -1.25 1.25 (modele.camera.elevation + elevation) } }
            , ouvrir = Nothing
            , tourne = True
            }


{-| Surface commune : l'application fournit les objets et les pôles du domaine,
elle reçoit des intentions. Les lignes SVG seules sont un adaptateur technique.
-}
vue : Int -> Int -> Modele -> String -> Bool -> List ( String, String, String ) -> (Message -> message) -> (String -> message) -> List Objet -> Element message
vue largeur hauteur modele selection lecteur axes envoyer ouvrir objets =
    let
        projection =
            G.projection (toFloat modele.dimensions.largeur) (toFloat modele.dimensions.hauteur) modele.camera

        projected =
            List.map (\objet -> ( objet, G.projeter projection objet.point )) objets

        places =
            G.placerBilles projection.largeur projection.hauteur projection.diametre (List.map (\( objet, p ) -> G.Position objet.identifiant p.x p.y) projected)

        position identifiant =
            List.filter (\p -> p.id == identifiant) places |> List.head |> Maybe.withDefault (G.Position identifiant 0 0)

        selectionPoint =
            List.filter (\o -> o.identifiant == selection) objets |> List.head |> Maybe.map .point

        place x y contenu =
            UI.el [ UI.width (UI.px 0), UI.height (UI.px 0), UI.moveRight x, UI.moveDown y, Spatial.ancrage, UI.inFront contenu ] UI.none

        pole ( nom, negatif, positif ) signe =
            let
                p =
                    G.Bille 0 0 0

                coord =
                    if nom == "x" then
                        { p | x = signe * 12.4 }

                    else if nom == "y" then
                        { p | y = signe * 12.4 }

                    else
                        { p | z = signe * 12.4 }

                v =
                    G.projeter projection coord

                texte =
                    if signe < 0 then
                        negatif

                    else
                        positif

                couleur =
                    if nom == "x" then
                        UI.rgb255 8 127 113

                    else if nom == "y" then
                        UI.rgb255 21 123 157

                    else
                        UI.rgb255 112 91 171
            in
            place v.x v.y (UI.el [ UI.moveLeft (toFloat (String.length texte) * 3.8 + 6), UI.moveUp 12, UI.paddingXY 6 3, Bordure.rounded 7, Police.size 13, Police.semiBold, Police.color couleur ] (UI.text texte))

        bille ( objet, p ) =
            let
                pos =
                    position objet.identifiant

                diametre =
                    projection.diametre

                echelle =
                    clamp 0.9 1.12 (0.94 + p.profondeur / 110)

                apercu =
                    diametre * 0.78 / 285

                active =
                    objet.identifiant == selection

                attributs =
                    [ UI.width (UI.px (round diametre))
                    , UI.height (UI.px (round diametre))
                    , Bordure.rounded 100
                    , UI.clip
                    , UI.padding 0
                    , Spatial.taille echelle
                    , Spatial.surface
                    , Region.description ("Rédaction " ++ String.fromInt objet.numero ++ ". Appuyer pour lire.")
                    , Manipulation.test "orb"
                    , Bordure.width
                        (if active then
                            2

                         else
                            1
                        )
                    , Bordure.color
                        (if active then
                            UI.rgb255 50 152 130

                         else
                            UI.rgb255 255 255 255
                        )
                    , Bordure.shadow { offset = ( 0, 15 ), size = -9, blur = 24, color = UI.rgba255 34 92 73 0.27 }
                    , UI.focused [ Bordure.glow (UI.rgb255 8 127 113) 4 ]
                    , UI.behindContent (Graphique.sphere objet.identifiant diametre)
                    , UI.inFront
                        (UI.el
                            [ UI.width (UI.px 285)
                            , UI.height (UI.px 200)
                            , UI.alpha 0.32
                            , A.masque
                            , Spatial.ancrage
                            , Spatial.taille apercu
                            , UI.moveLeft (285 * (1 - apercu) / 2 - diametre * 0.11)
                            , UI.moveUp (200 * (1 - apercu) / 2 - diametre * 0.12)
                            ]
                            (Math.document objet.contenu)
                        )
                    ]
                        ++ Native.bille objet.identifiant objet.attente objet.point.x objet.point.y objet.point.z
                        ++ (if objet.attente then
                                [ Bordure.dashed ]

                            else
                                []
                           )
            in
            ( objet.identifiant
            , place pos.x
                pos.y
                (UI.el [ UI.moveLeft (diametre / 2), UI.moveUp (diametre / 2), Spatial.ancrage ]
                    (Controles.surface
                        (attributs
                            ++ (if lecteur && active then
                                    [ UI.alpha 0 ]

                                else
                                    []
                               )
                        )
                        { onPress =
                            if lecteur then
                                Nothing

                            else
                                Just (ouvrir objet.identifiant)
                        , label = UI.el [ UI.centerX, UI.centerY, Police.size (round (diametre * 0.36)), Police.semiBold, Police.color (UI.rgb255 18 105 84), Manipulation.test "orb-caption" ] (UI.text (String.fromInt objet.numero))
                        }
                    )
                )
            )

        ordonnes =
            List.sortBy
                (\( objet, p ) ->
                    if objet.identifiant == selection then
                        80

                    else
                        round (p.profondeur + 35)
                )
                projected

        liens =
            List.map (\( objet, p ) -> ( p, position objet.identifiant )) projected
    in
    UI.el
        ([ UI.width
            (if largeur <= 0 then
                UI.fill

             else
                UI.px largeur
            )
         , UI.height (UI.px hauteur)
         , UI.clip
         , A.identifiant "space"
         , A.tabulation 0
         , Region.description "Espace à trois dimensions. Faites glisser pour tourner, ou utilisez les flèches du clavier."
         , Manipulation.test "space"
         , UI.behindContent (UI.el [ Spatial.ancrage, A.masque ] (Graphique.scene projection selectionPoint liens))
         , UI.inFront (Cle.column [ UI.width (UI.px 0), UI.height (UI.px 0), Spatial.ancrage, Manipulation.test "orb-layer" ] (List.map bille ordonnes))
         , UI.inFront (UI.column [ UI.width (UI.px 0), UI.height (UI.px 0), Spatial.ancrage ] (List.concatMap (\axe -> List.map (pole axe) [ -1, 1 ]) axes))
         ]
            ++ Native.cadre lecteur
            ++ Native.evenements (Mesurer >> envoyer) (\x y id -> envoyer (Prendre x y id)) (\x y -> envoyer (Deplacer x y)) (Terminer >> envoyer)
            ++ (if lecteur then
                    []

                else
                    [ Native.clavier (\a e -> envoyer (Tourner a e)) ]
               )
        )
        UI.none
