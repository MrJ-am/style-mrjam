module MrJam.TableSpatiale exposing (Carte, Dimensions, cadre, carte, plan)

{-| Table de cartes : présentation et entrées communes, sans corpus ni placement
métier. Coordonnées, dimensions et progression proviennent de l'application et
du socle de transitions ; aucune timeline ni moteur local de présentation.
-}

import Element as UI exposing (Element)
import Element.Background as Fond
import Element.Events as E
import Element.Font as Police
import Element.Keyed as Cle
import Html exposing (Html)
import MrJam.Accessibilite as A
import MrJam.Adaptateurs.Spatial as Native
import MrJam.Contexte as Contexte
import MrJam.Disposition as Disposition
import MrJam.Manipulation as Reperes


type alias Dimensions =
    { largeur : Int, hauteur : Int }


type alias Carte message =
    { repere : String
    , x : Float
    , y : Float
    , largeur : Float
    , hauteur : Float
    , echelle : Float
    , ouverte : Bool
    , mouvement : Bool
    , commencer : Float -> Float -> message
    , ouvrir : message
    , fermer : message
    , contenu : Element message
    }


cadre : Contexte.Contexte -> Dimensions -> List (Element message) -> Html message
cadre contexte dimensions contenu =
    (Disposition.pour contexte).cadre
        [ UI.height (UI.px (max 1 dimensions.hauteur)), UI.clip, Reperes.test "app-root" ]
        (UI.column [ UI.width UI.fill, UI.height UI.fill, UI.padding 12, UI.spacing 12 ] contenu)


plan : Dimensions -> Maybe ( String, String ) -> Bool -> (Float -> Float -> message) -> message -> message -> List ( String, Element message ) -> Element message
plan dimensions legendes glissement deplacer terminer fermer cartes =
    let
        couches =
            Cle.column [ UI.width (UI.px 0), UI.height (UI.px 0), UI.spacing 0, Native.ancrage ] cartes

        axes =
            UI.el
                [ UI.width UI.fill
                , UI.height (UI.px 1)
                , UI.centerY
                , Fond.color (UI.rgb255 185 201 230)
                , UI.inFront (UI.el [ UI.width (UI.px 1), UI.height (UI.px dimensions.hauteur), UI.centerX, UI.moveUp (toFloat dimensions.hauteur / 2), Fond.color (UI.rgb255 185 201 230) ] UI.none)
                ]
                UI.none
    in
    UI.el
        ([ UI.width UI.fill
         , UI.height UI.fill
         , A.identifiant "board"
         , Reperes.test "board"
         , E.onClick fermer
         , UI.inFront couches
         , UI.behindContent
            (if legendes /= Nothing then
                axes

             else
                UI.none
            )
         ]
            ++ Native.fin terminer
            ++ (if glissement then
                    [ Native.toucher deplacer ]

                else
                    []
               )
        )
        (case legendes of
            Just ( horizontale, verticale ) ->
                UI.row [ UI.width UI.fill, UI.alignBottom, UI.paddingXY 10 8, Police.size 12, Police.color (UI.rgb255 76 93 127) ]
                    [ UI.text horizontale, UI.el [ UI.alignRight ] (UI.text verticale) ]

            Nothing ->
                UI.none
        )


carte : Carte message -> Element message
carte contrat =
    let
        attributs =
            [ UI.width (UI.px (max 1 (round contrat.largeur)))
            , UI.height (UI.px (max 1 (round contrat.hauteur)))
            , Reperes.test ("card-" ++ contrat.repere)
            , A.tabulation 0
            , Native.taille contrat.echelle
            , Native.surface
            ]
                ++ Native.etat contrat.ouverte contrat.mouvement
                ++ (if contrat.mouvement || contrat.ouverte then
                        [ UI.scrollbars ]

                    else
                        [ UI.clip ]
                   )
                ++ Native.clic contrat.ouverte contrat.ouvrir contrat.fermer
                ++ (if contrat.ouverte || contrat.mouvement then
                        []

                    else
                        Native.prise contrat.commencer
                   )
    in
    UI.el
        [ UI.width (UI.px 0)
        , UI.height (UI.px 0)
        , UI.moveRight contrat.x
        , UI.moveDown contrat.y
        , Reperes.test ("anchor-" ++ contrat.repere)
        , Native.ancrage
        , UI.inFront
            (UI.el [ UI.moveLeft (contrat.largeur / 2), UI.moveUp (contrat.hauteur / 2), Native.ancrage ]
                (UI.el attributs contrat.contenu)
            )
        ]
        UI.none
