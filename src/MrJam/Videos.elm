module MrJam.Videos exposing (Message, Modele, Source, initial, mettreAJour, quitter, vue)

{-| Lecteur commun : l'application fournit la vidéo du cours, la bibliothèque
possède ses commandes et états visuels. Positions privées à cette instance,
conservées entre vues ; le SDK ne possède ni le cours ni les réponses.
Aucun iframe avant activation volontaire, aucun accès extérieur pour l'affiche.
-}

import Browser.Dom
import Dict exposing (Dict)
import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Region as Region
import Json.Decode as D
import MrJam
import MrJam.Adaptateurs.Accessibilite as A
import MrJam.Adaptateurs.Video as Native
import MrJam.Controles as Controles
import MrJam.Theme as Theme
import Task
import Url


type alias Source =
    { titre : String, url : String, affiche : String, debut : Int, externe : String }


type Modele
    = Modele
        { generation : Int
        , phase : Phase
        , positions : Dict String Float
        }


type Phase
    = Affiche
    | Ouverture Source String
    | Lecture Source String
    | Echec Source


type Message
    = Activer Source Bool
    | Arreter
    | Reessayer
    | Evenement Source Int D.Value
    | FocusTermine (Result Browser.Dom.Error ())


initial : Modele
initial =
    Modele { generation = 0, phase = Affiche, positions = Dict.empty }


cle : Source -> String
cle source =
    source.url ++ "|" ++ String.fromInt source.debut


quitter : Modele -> Modele
quitter (Modele modele) =
    Modele { modele | phase = Affiche, generation = modele.generation + 1 }


focus : String -> Cmd Message
focus cible =
    Task.attempt FocusTermine (Browser.Dom.focus cible)


adresse : Source -> Float -> Maybe String
adresse source instant =
    Url.fromString source.url
        |> Maybe.andThen
            (\url ->
                if url.protocol == Url.Https && List.member url.host [ "player.vimeo.com", "www.youtube-nocookie.com" ] && (url.port_ == Nothing || url.port_ == Just 443) then
                    Just
                        (Url.toString
                            { url
                                | query = Just (Maybe.map (\query -> query ++ "&autoplay=1&dnt=1") url.query |> Maybe.withDefault "autoplay=1&dnt=1")
                                , fragment = Just ("t=" ++ String.fromInt (floor (max 0 instant)) ++ "s")
                            }
                        )

                else
                    Nothing
            )


mettreAJour : Message -> Modele -> ( Modele, Cmd Message )
mettreAJour message (Modele modele) =
    case message of
        Activer source depuisDebut ->
            let
                position =
                    if depuisDebut then
                        0

                    else
                        Dict.get (cle source) modele.positions |> Maybe.withDefault (toFloat source.debut)

                phase =
                    adresse source position |> Maybe.map (Ouverture source) |> Maybe.withDefault (Echec source)
            in
            ( Modele
                { modele
                    | generation = modele.generation + 1
                    , phase = phase
                    , positions =
                        if depuisDebut then
                            Dict.remove (cle source) modele.positions

                        else
                            modele.positions
                }
            , case phase of
                Echec _ ->
                    focus "video-externe-secours"

                _ ->
                    Cmd.none
            )

        Arreter ->
            ( quitter (Modele modele), focus "video-activer" )

        Reessayer ->
            ( quitter (Modele modele), focus "video-activer" )

        FocusTermine _ ->
            ( Modele modele, Cmd.none )

        Evenement source generation valeur ->
            -- Un ancien lecteur peut terminer une Promise après sa disparition.
            -- Sa génération ne peut jamais changer le lecteur courant.
            if generation /= modele.generation then
                ( Modele modele, Cmd.none )

            else
                case D.decodeValue (D.field "type" D.string) valeur of
                    Ok "pret" ->
                        ( Modele
                            { modele
                                | phase =
                                    case modele.phase of
                                        Ouverture active url ->
                                            Lecture active url

                                        autre ->
                                            autre
                            }
                        , Cmd.none
                        )

                    Ok "position" ->
                        case D.decodeValue (D.field "secondes" D.float) valeur of
                            Ok secondes ->
                                if isNaN secondes || isInfinite secondes || secondes < 0 || secondes > 86400 then
                                    ( Modele modele, Cmd.none )

                                else
                                    ( Modele { modele | positions = Dict.insert (cle source) secondes modele.positions }, Cmd.none )

                            _ ->
                                ( Modele modele, Cmd.none )

                    Ok "termine" ->
                        ( Modele { modele | positions = Dict.remove (cle source) modele.positions }, Cmd.none )

                    Ok "erreur" ->
                        ( Modele { modele | phase = Echec source, generation = modele.generation + 1 }, focus "video-externe-secours" )

                    _ ->
                        ( Modele modele, Cmd.none )


horloge : Float -> String
horloge secondes =
    String.fromInt (floor secondes // 60) ++ ":" ++ String.padLeft 2 '0' (String.fromInt (modBy 60 (floor secondes)))


vue : Source -> Modele -> Element Message
vue source (Modele modele) =
    let
        surface contenu =
            UI.column [ UI.width (UI.minimum 0 UI.fill), UI.spacing 12, A.identifiant "lecteur-video", Region.description ("Vidéo : " ++ source.titre) ] contenu

        lecture active url charge =
            surface
                [ if charge then
                    UI.el [ A.etat, A.occupe ] (MrJam.texteSecondaire "Ouverture de la vidéo…")

                  else
                    UI.none
                , UI.el [ UI.width UI.fill ] (Native.lecteur { url = url, titre = active.titre, generation = modele.generation } (Evenement active modele.generation))
                , MrJam.boutonSecondaire "Arrêter la vidéo" Arreter
                ]

        affiche =
            let
                reprise =
                    Dict.get (cle source) modele.positions

                position =
                    reprise |> Maybe.withDefault (toFloat source.debut)

                libelle =
                    (if reprise /= Nothing then
                        "Reprendre"

                     else
                        "Lire"
                    )
                        ++ " "
                        ++ source.titre
                        ++ " à "
                        ++ horloge position

                texte =
                    if reprise /= Nothing then
                        "Reprendre à " ++ horloge position

                    else if source.debut > 0 then
                        "Regarder à partir de " ++ horloge (toFloat source.debut)

                    else
                        "Regarder la vidéo"
            in
            surface
                [ UI.el [ A.identifiant "information-video" ] (MrJam.texteSecondaire "Activer ce lecteur contacte l’hébergeur vidéo, qui reçoit votre adresse IP et peut utiliser des traceurs. Vous pouvez poursuivre les exercices sans l’activer.")
                , UI.el
                    [ UI.width UI.fill
                    , Native.format
                    , Bordure.rounded 17
                    , Fond.color (UI.rgb255 220 235 225)
                    , UI.inFront
                        (UI.column [ UI.width (UI.minimum 0 UI.fill), UI.centerX, UI.centerY, UI.padding 8, UI.spacing 8 ]
                            [ Controles.actionPour Theme.commune
                                Controles.Principale
                                [ UI.height (UI.minimum 44 UI.shrink), A.identifiant "video-activer", A.decritPar "information-video", Region.description libelle ]
                                ("▶ " ++ texte)
                                (Just (Activer source False))
                            , if position > 0 then
                                MrJam.boutonSecondaire "Depuis le début" (Activer source True)

                              else
                                UI.none
                            ]
                        )
                    ]
                    (if String.startsWith "./" source.affiche && not (String.startsWith "./\\" source.affiche) then
                        UI.image [ UI.width UI.fill ] { src = source.affiche, description = "" }

                     else
                        UI.el [ UI.width UI.fill ] UI.none
                    )
                ]
    in
    case modele.phase of
        Ouverture active url ->
            if cle active == cle source then
                lecture active url True

            else
                affiche

        Lecture active url ->
            if cle active == cle source then
                lecture active url False

            else
                affiche

        Echec active ->
            if cle active == cle source then
                surface
                    [ UI.column [ UI.width UI.fill, UI.padding 24, UI.spacing 14, A.etat, Fond.color (UI.rgb255 225 238 229), Bordure.rounded 17 ]
                        [ UI.el [ Police.size 24 ] (UI.text "▷")
                        , MrJam.sousTitre "Retrouvez cette vidéo sur Vimeo"
                        , MrJam.paragraphe "La lecture intégrée est indisponible pour le moment. Vous pouvez regarder la vidéo sur Vimeo, puis revenir aux questions."
                        , UI.newTabLink [ A.identifiant "video-externe-secours", Region.description "Regarder sur Vimeo — nouvel onglet" ]
                            { url = source.externe, label = MrJam.paragraphe "Regarder sur Vimeo ↗" }
                        , MrJam.boutonSecondaire "Réessayer ici" Reessayer
                        ]
                    ]

            else
                affiche

        Affiche ->
            affiche
