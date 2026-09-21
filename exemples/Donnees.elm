module Donnees exposing (main)

import Browser
import MrJam exposing (..)
import MrJam.Donnees exposing (date, dateHeure, lecture, nombre, tableau)


type alias Modele =
    { nombre : String, date : String, instant : String, compteur : Int }


type Message
    = Nombre String
    | Date String
    | Instant String
    | Ouvrir


actualiser message modele =
    case message of
        Nombre valeur ->
            { modele | nombre = valeur }

        Date valeur ->
            { modele | date = valeur }

        Instant valeur ->
            { modele | instant = valeur }

        Ouvrir ->
            { modele | compteur = modele.compteur + 1 }


vue modele =
    page "Données partagées"
        [ section "Saisie"
            [ nombre "Valeur numérique" modele.nombre Nombre
            , date "Date civile" modele.date Date
            , dateHeure "Date et heure locales" modele.instant Instant
            , paragraphe ("Nombre saisi : " ++ modele.nombre)
            , paragraphe ("Date saisie : " ++ modele.date)
            , paragraphe ("Instant saisi : " ++ modele.instant)
            ]
        , section "Lecture"
            [ lecture "  Deux espaces\n    Quatre espaces\n<script>window.intrusion = true</script>"
            , lecture (String.repeat 200 "x")
            ]
        , section "Tableau"
            [ tableau "Exemple de données"
                [ ( "Titre", \titre -> lecture titre )
                , ( "État", \_ -> paragraphe "Conservé" )
                , ( "Action", \_ -> bouton "Ouvrir" Ouvrir )
                ]
                [ "Première ligne", "Deuxième ligne" ]
            , paragraphe ("Ouvertures : " ++ String.fromInt modele.compteur)
            ]
        ]


main =
    Browser.sandbox
        { init = { nombre = "", date = "", instant = "", compteur = 0 }
        , update = actualiser
        , view = vue
        }
