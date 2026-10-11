module MrJam.AxesSpatiaux exposing (Message(..), Modele, Poignee, Resultat, actualiser, initialiser, vue)

{-| Axe relatif multipoignées. Une prise ne valide aucune valeur. L'aperçu,
l'annulation et la validation sont distincts ; aucune donnée métier ici.
-}

import Element as UI exposing (Element)
import Element.Border as Bordure
import Element.Font as Police
import Element.Keyed as Cle
import Element.Region as Region
import MrJam.Accessibilite as A
import MrJam.Adaptateurs.Axes as Native
import MrJam.Adaptateurs.GraphiqueSpatial as Graphique
import MrJam.Adaptateurs.Spatial as Spatial
import MrJam.Contexte exposing (Contexte)
import MrJam.Controles as Controles
import MrJam.GeometrieSpatiale as G
import MrJam.Manipulation as Manipulation
import MrJam.Theme as Theme


type alias Poignee =
    { id : String, numero : Int, valeur : Float, attente : Bool }


type alias Modele =
    { largeur : Int, geste : Maybe Geste }


type alias Geste =
    { id : String, x : Float, y : Float, valeur : Float, courante : Float, largeur : Float, prise : G.Prise, base : Float, direct : Bool, intention : Maybe Bool, mouvement : Bool, horizontal : Bool }


type Message
    = Mesurer Int
    | Prendre String Float Float Bool Bool
    | Deplacer Float Float
    | Terminer Bool
    | Clavier String String Bool


type alias Resultat =
    { modele : Modele, proposition : Maybe ( String, Float, Bool ), ouvrir : Maybe String }


initialiser : Modele
initialiser =
    { largeur = 280, geste = Nothing }


positions : String -> List Poignee -> Modele -> List { id : String, numero : Int, valeur : Float, ancre : Float, x : Float, y : Float }
positions selection points modele =
    G.placerPoignees (toFloat modele.largeur) (Maybe.map .id modele.geste |> Maybe.withDefault selection) (Maybe.map .prise modele.geste) (List.map (\p -> G.Poignee p.id p.numero p.valeur) points)


baseline : Float -> List { a | y : Float } -> Float
baseline reserve places =
    max reserve (List.map (.y >> negate) places |> List.maximum |> Maybe.withDefault 0) + 22


actualiser : Float -> String -> List Poignee -> Message -> Modele -> Resultat
actualiser reserve selection points message modele =
    let
        sansEffet prochain =
            { modele = prochain, proposition = Nothing, ouvrir = Nothing }

        valeur id =
            List.filter (\p -> p.id == id) points |> List.head |> Maybe.map .valeur |> Maybe.withDefault 0
    in
    case message of
        Mesurer largeur ->
            sansEffet { modele | largeur = max 1 largeur }

        Prendre id x y direct verrou ->
            if modele.geste /= Nothing then
                sansEffet modele

            else
                let
                    places =
                        positions selection points modele

                    position =
                        List.filter (\p -> p.id == id) places |> List.head
                in
                case position of
                    Nothing ->
                        sansEffet modele

                    Just p ->
                        sansEffet
                            { modele
                                | geste =
                                    Just
                                        { id = id
                                        , x = x
                                        , y = y
                                        , valeur = p.valeur
                                        , courante = p.valeur
                                        , largeur = toFloat modele.largeur - 44
                                        , prise = { y = p.y, decalage = p.x - p.ancre }
                                        , base = baseline reserve places
                                        , direct = direct
                                        , intention =
                                            if verrou then
                                                Just True

                                            else
                                                Nothing
                                        , mouvement = False
                                        , horizontal = False
                                        }
                            }

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

                        mouvement =
                            geste.mouvement || sqrt (dx * dx + dy * dy) > 4

                        intention =
                            if mouvement && geste.intention == Nothing then
                                Just (abs dx >= abs dy)

                            else
                                geste.intention

                        horizontal =
                            geste.horizontal || (intention == Just True && abs dx > 4)

                        courante =
                            if mouvement && horizontal && intention == Just True then
                                G.deplacementRelatif geste.valeur dx geste.largeur -10 10 0.1

                            else
                                geste.courante

                        prochain =
                            { modele | geste = Just { geste | mouvement = mouvement, intention = intention, horizontal = horizontal, courante = courante } }
                    in
                    { modele = prochain
                    , ouvrir = Nothing
                    , proposition =
                        if courante /= geste.courante then
                            Just ( geste.id, courante, False )

                        else
                            Nothing
                    }

        Terminer annule ->
            case modele.geste of
                Nothing ->
                    sansEffet modele

                Just geste ->
                    let
                        abandon =
                            annule || geste.intention == Just False
                    in
                    { modele = { modele | geste = Nothing }
                    , proposition =
                        if abandon && geste.courante /= geste.valeur then
                            Just ( geste.id, geste.valeur, False )

                        else if not abandon && geste.horizontal then
                            Just ( geste.id, geste.courante, True )

                        else
                            Nothing
                    , ouvrir =
                        if not abandon && not geste.mouvement && geste.direct then
                            Just geste.id

                        else
                            Nothing
                    }

        Clavier id touche majuscule ->
            let
                pas =
                    if majuscule then
                        1

                    else
                        0.1

                courante =
                    valeur id

                prochaine =
                    case touche of
                        "Home" ->
                            -10

                        "End" ->
                            10

                        "ArrowLeft" ->
                            courante - pas

                        "ArrowDown" ->
                            courante - pas

                        _ ->
                            courante + pas
            in
            { modele = modele, ouvrir = Nothing, proposition = Just ( id, G.deplacementRelatif prochaine 0 1 -10 10 0.1, True ) }


vue : Contexte -> String -> String -> String -> String -> Float -> Modele -> String -> Bool -> (Message -> message) -> (String -> message) -> List Poignee -> Element message
vue contexte nom libelle negatif positif reserve modele selection lecteur envoyer ouvrir points =
    let
        couleurs =
            Theme.palette contexte

        places =
            positions selection points modele

        base =
            Maybe.map .base modele.geste |> Maybe.withDefault (baseline reserve places)

        hauteur =
            base + 22

        active =
            Maybe.map .id modele.geste |> Maybe.withDefault selection

        place p =
            let
                objet =
                    List.filter (\o -> o.id == p.id) points |> List.head

                attente =
                    Maybe.map .attente objet |> Maybe.withDefault True

                lecture =
                    if attente then
                        "À placer"

                    else if p.valeur == 0 then
                        "Au repère central"

                    else
                        "Vers "
                            ++ (if p.valeur < 0 then
                                    negatif

                                else
                                    positif
                               )

                attributs =
                    [ UI.width (UI.px 38)
                    , UI.height (UI.px 38)
                    , UI.padding 0
                    , Bordure.rounded 38
                    , Bordure.width
                        (if p.id == active then
                            2

                         else
                            1
                        )
                    , Bordure.color couleurs.accent
                    , Theme.fond couleurs.doux
                    , Spatial.surface
                    , Region.description ("Rédaction " ++ String.fromInt p.numero ++ " · " ++ libelle)
                    , A.pressee (p.id == active)
                    , Manipulation.test "slider-thumb"
                    , UI.focused [ Bordure.glow couleurs.accent 3 ]
                    , Native.clavier (ouvrir p.id) (\touche maj -> envoyer (Clavier p.id touche maj))
                    ]
                        ++ Native.poignee p.id p.valeur p.ancre p.x -p.y lecture
                        ++ (if attente then
                                [ Bordure.dashed ]

                            else
                                []
                           )
            in
            ( p.id
            , UI.el
                [ UI.width (UI.px 0)
                , UI.height (UI.px 0)
                , UI.moveRight (p.x - 19)
                , UI.moveDown (base + p.y - 19)
                , Spatial.ancrage
                , UI.inFront
                    (Controles.surface attributs
                        { onPress =
                            if lecteur then
                                Nothing

                            else
                                Just (ouvrir p.id)
                        , label = UI.el [ UI.centerX, UI.centerY, Police.size 15, Police.semiBold ] (UI.text (String.fromInt p.numero))
                        }
                    )
                ]
                UI.none
            )
    in
    UI.column [ UI.width UI.fill, UI.spacing 2, A.identifiant ("axis-" ++ nom), Manipulation.test "axis-slider" ]
        [ UI.row [ UI.width UI.fill, Police.size 12, Police.color couleurs.discret, Manipulation.test "slider-poles" ] [ UI.text negatif, UI.el [ UI.alignRight ] (UI.text positif) ]
        , UI.el
            ([ UI.width UI.fill
             , UI.height (UI.px (round hauteur))
             , Manipulation.test "slider-field"
             , UI.behindContent (UI.el [ Spatial.ancrage, A.masque ] (Graphique.liens (toFloat modele.largeur) hauteur base places))
             , UI.inFront (Cle.column [ UI.width (UI.px 0), UI.height (UI.px 0), Spatial.ancrage ] (List.map place places))
             ]
                ++ Native.cadre lecteur
                ++ Native.evenements (Mesurer >> envoyer) (\id x y direct verrou -> envoyer (Prendre id x y direct verrou)) (\x y -> envoyer (Deplacer x y)) (Terminer >> envoyer)
            )
            (UI.el [ UI.width (UI.fill |> UI.maximum (max 1 (modele.largeur - 44))), UI.centerX, UI.height (UI.px 4), UI.moveDown base, UI.moveUp 2, Theme.fond couleurs.ligne, Bordure.rounded 4, Native.rail, Manipulation.test "slider-rail", UI.inFront (UI.el [ UI.width (UI.px 2), UI.height (UI.px 10), UI.centerX, UI.moveUp 3, Theme.fond couleurs.accent, Spatial.ancrage ] UI.none) ] UI.none)
        ]
