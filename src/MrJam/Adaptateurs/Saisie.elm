module MrJam.Adaptateurs.Saisie exposing (date, dateHeure, echap, identifie, intrinseque, nombre, soumettre)

{-| Capacités natives absentes d'Element.Input1.1.8 : types date/nombre,
contrat de reprise de focus, validation clavier et dimensions intrinsèques.
Trois valeurs fixes de dimension seulement ; aucun style, nom d'événement
configurable ou conversion de la valeur saisie.
-}

import Element exposing (Attribute, htmlAttribute)
import Html.Attributes as Attributs
import Html.Events as Evenements
import Json.Decode as Decode
import MrJam.Adaptateurs.Accessibilite as Accessibilite


{-| Length.Content est width:auto ; les enfants de row ont flex-basis:0%.
L'API publique ne possède pas max-content/flex-basis:auto. Ces trois raccords
conservent la largeur préférée des libellés, bornée par leur conteneur, puis
leur repli réel sans tronquer leur hauteur. Taille, police, cadre et disposition
restent elm-ui. Ne pas appliquer cette largeur aux icônes de taille exacte.
-}
intrinseque : List (Attribute message)
intrinseque =
    [ htmlAttribute (Attributs.style "width" "max-content")
    , htmlAttribute (Attributs.style "max-width" "100%")
    , htmlAttribute (Attributs.style "flex-basis" "auto")
    ]


nombre : List (Attribute message)
nombre =
    [ htmlAttribute (Attributs.type_ "number"), htmlAttribute (Attributs.step "any") ]


date : List (Attribute message)
date =
    [ htmlAttribute (Attributs.type_ "date"), htmlAttribute (Attributs.step "any") ]


dateHeure : List (Attribute message)
dateHeure =
    [ htmlAttribute (Attributs.type_ "datetime-local"), htmlAttribute (Attributs.step "any") ]


identifie : { contrat | identifiant : String, exemple : Maybe String, aide : Maybe String, limite : Maybe Int } -> List (Attribute message)
identifie contrat =
    [ Accessibilite.identifiant contrat.identifiant
    , htmlAttribute (Attributs.spellcheck False)
    , htmlAttribute (Attributs.autocomplete False)
    , htmlAttribute (Attributs.attribute "autocapitalize" "off")
    ]
        ++ (contrat.exemple |> Maybe.map (\exemple -> [ htmlAttribute (Attributs.placeholder exemple) ]) |> Maybe.withDefault [])
        ++ (contrat.aide |> Maybe.map (\aide -> [ Accessibilite.decritPar aide ]) |> Maybe.withDefault [])
        ++ (contrat.limite |> Maybe.map (\limite -> [ htmlAttribute (Attributs.maxlength (max 0 limite)) ]) |> Maybe.withDefault [])


soumettre : message -> Attribute message
soumettre message =
    htmlAttribute (Evenements.preventDefaultOn "keydown" (touche "Enter" True message))


echap : Bool -> message -> Attribute message
echap ouvert message =
    htmlAttribute (Evenements.on "keydown" (Decode.map Tuple.first (touche "Escape" ouvert message)))


touche : String -> Bool -> message -> Decode.Decoder ( message, Bool )
touche attendue actif message =
    Decode.field "key" Decode.string
        |> Decode.andThen
            (\valeur ->
                if actif && valeur == attendue then
                    Decode.succeed ( message, True )

                else
                    Decode.fail "Touche ignorée"
            )
