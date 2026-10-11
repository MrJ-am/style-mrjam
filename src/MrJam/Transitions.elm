module MrJam.Transitions exposing (Cycle(..), Player, Transition, abonnement, abonnementLecteur, actif, advance, aller, arrive, courant, init, initialiser, mettreAJour, nombre, pause, reduire, seek, start, tick)

{-| Politique commune de transitions et lecteur Elm Animator 2.0.0.
Le lecteur existant est déplacé ici sans changer ses calculs ; géométrie et
intentions restent dans les applications. Leurs subscriptions passent par ce socle.
La timeline interpole une progression linéaire. Une horloge virtuelle suspendue
permet pause et reprise sans dépendre d'une API de pause inexistante.
-}

import Animator
import Animator.Timeline as Timeline
import Animator.Transition as Courbe
import Animator.Value as Value
import Browser.Events
import Time


type Cycle
    = Once
    | Repeat
    | PingPong


type alias Player =
    { timeline : Timeline.Timeline Float
    , progress : Float
    , elapsed : Float
    , travel : Float
    , duration : Float
    , dwell : Float
    , direction : Int
    , cycle : Cycle
    , running : Bool
    , lastFrame : Maybe Time.Posix
    }


init : Player
init =
    { timeline = Timeline.init 0, progress = 0, elapsed = 0, travel = 0, duration = 4000, dwell = 0, direction = 1, cycle = Once, running = False, lastFrame = Nothing }


seek : Float -> Player -> Player
seek p player =
    let
        progress =
            if isNaN p || isInfinite p then
                0

            else
                clamp 0 1 p
    in
    { player | timeline = Timeline.init progress, progress = progress, elapsed = 0, running = False, lastFrame = Nothing }


pause : Player -> Player
pause player =
    { player | running = False, lastFrame = Nothing }


start : Float -> Float -> Cycle -> Int -> Player -> Player
start seconds rest cycle direction player =
    let
        duration =
            max 0.2 seconds * 1000

        target =
            if direction < 0 then
                0

            else
                1

        travel =
            max 1 (abs (target - player.progress) * duration)

        dwell =
            if cycle == Once then
                0

            else
                max 0 rest * 1000

        timeline =
            Timeline.init player.progress
                |> Timeline.update (Time.millisToPosix 0)
                |> Timeline.interrupt
                    [ Timeline.transitionTo (Animator.ms travel) target
                    , Timeline.wait (Animator.ms dwell)
                    ]
                |> Timeline.update (Time.millisToPosix 0)
    in
    { player | timeline = timeline, elapsed = 0, travel = travel, duration = duration, dwell = dwell, direction = direction, cycle = cycle, running = True, lastFrame = Nothing }


{-| Le temps réel est mesuré, jamais compté en frames. La première frame ne saute pas.
-}
tick : Time.Posix -> Player -> Player
tick now player =
    if not player.running then
        player

    else
        case player.lastFrame of
            Nothing ->
                { player | lastFrame = Just now }

            Just previous ->
                let
                    next =
                        advance (toFloat (max 0 (Time.posixToMillis now - Time.posixToMillis previous))) player
                in
                { next | lastFrame = Just now }


{-| Consomme aussi un dépassement de fin de cycle : pas de dérive par boucle.
-}
advance : Float -> Player -> Player
advance milliseconds player =
    if not player.running then
        player

    else
        let
            elapsed =
                player.elapsed + max 0 milliseconds

            timeline =
                Timeline.update (Time.millisToPosix (round (min elapsed player.travel))) player.timeline

            p =
                -- La courbe linéaire standard utilise des points 0.2/0.8,
                -- puis une recherche numérique de tolérance 0.0005.
                -- Avec 1/3 et 2/3, x(t)=y(t)=t : même interpolation linéaire,
                -- sans erreur de recherche lors des reprises et inversions.
                Value.float timeline (\value -> Value.to value |> Value.withTransition (Courbe.bezier (1 / 3) (1 / 3) (2 / 3) (2 / 3)))

            target =
                if player.direction < 0 then
                    0

                else
                    1

            next =
                { player
                    | elapsed = elapsed
                    , timeline = timeline
                    , progress =
                        if elapsed >= player.travel then
                            target

                        else
                            clamp 0 1 p
                }
        in
        if elapsed < player.travel + player.dwell then
            next

        else
            case player.cycle of
                Once ->
                    { next | progress = target, running = False, lastFrame = Nothing }

                Repeat ->
                    seek (1 - target) next
                        |> start (player.duration / 1000) (player.dwell / 1000) Repeat player.direction
                        |> advance (elapsed - player.travel - player.dwell)

                PingPong ->
                    seek target next
                        |> start (player.duration / 1000) (player.dwell / 1000) PingPong -player.direction
                        |> advance (elapsed - player.travel - player.dwell)


{-| État purement visuel. La cible est disponible immédiatement, indépendamment
de la fin du mouvement ; aucune écriture métier n'attend la chronologie.
Les états visuels sont des valeurs (identifiants, variantes), sans fonctions.
-}
type alias Transition etat =
    { chronologie : Timeline.Timeline etat, cible : etat, reduite : Bool, enMouvement : Bool }


initialiser : etat -> Transition etat
initialiser etat =
    { chronologie = Timeline.init etat, cible = etat, reduite = False, enMouvement = False }


aller : Float -> etat -> Transition etat -> Transition etat
aller millisecondes cible etat =
    if cible == etat.cible && millisecondes > 0 then
        etat

    else
        { etat
            | cible = cible
            , enMouvement = not etat.reduite && millisecondes > 0
            , chronologie =
                if etat.reduite || millisecondes <= 0 then
                    Timeline.init cible

                else
                    Timeline.to (Animator.ms (clamp 0 600 millisecondes)) cible etat.chronologie
        }


reduire : Bool -> Transition etat -> Transition etat
reduire preference etat =
    { etat
        | reduite = preference
        , enMouvement = etat.enMouvement && not preference
        , chronologie =
            if preference then
                Timeline.init etat.cible

            else
                etat.chronologie
    }


mettreAJour : Time.Posix -> Transition etat -> Transition etat
mettreAJour maintenant etat =
    if not (actif etat) then
        etat

    else
        let
            chronologie =
                Timeline.update maintenant etat.chronologie
        in
        { etat | chronologie = chronologie, enMouvement = Timeline.isRunning chronologie }


courant : Transition etat -> etat
courant etat =
    etat.cible


arrive : Transition etat -> etat
arrive etat =
    Timeline.arrived etat.chronologie


{-| Une valeur numérique pour les attributs elm-ui (alpha, déplacements, etc.).
Aucun Html/CSS ni renderer Animator.node/Inline dans le code applicatif.
-}
nombre : (etat -> Float) -> Transition etat -> Float
nombre valeur etat =
    if not (actif etat) then
        valeur etat.cible

    else
        Value.float etat.chronologie (valeur >> Value.to)


actif : Transition etat -> Bool
actif etat =
    not etat.reduite && etat.enMouvement


abonnement : (Time.Posix -> message) -> Transition etat -> Sub message
abonnement message etat =
    if actif etat then
        Browser.Events.onAnimationFrame message

    else
        Sub.none


abonnementLecteur : Bool -> (Time.Posix -> message) -> Player -> Sub message
abonnementLecteur reduite message lecteur =
    if lecteur.running && not reduite then
        Browser.Events.onAnimationFrame message

    else
        Sub.none
