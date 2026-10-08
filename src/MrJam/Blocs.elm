module MrJam.Blocs exposing (Etat(..), cavite, commande, emboitable, espace, logement, objectif, onglet, outil, poignee, proposition, styles)

{-| Pièces d'un atelier graphique : constructions à encoches et objets verts
emboîtables. Les bandes et épines forment un contour continu ; le fond des
cavités reste ouvert sur le canevas. Aucune règle métier ne dépend du dessin.
-}

import Element as UI exposing (Attribute, Element)
import Element.Input as Entree
import Html
import Html.Attributes as A


type Etat
    = Neutre
    | Selectionne
    | Verifie
    | ACompleter
    | Incorrect


classe : String -> Attribute msg
classe =
    A.class >> UI.htmlAttribute


commande : List (Attribute msg) -> Element msg -> msg -> Element msg
commande attributs contenu message =
    Entree.button (classe "mrjam-bloc-commande" :: attributs) { onPress = Just message, label = contenu }


outil : String -> String -> msg -> Element msg
outil nom dessin =
    commande [ classe "mrjam-atelier-outil", UI.htmlAttribute (A.attribute "aria-label" nom), UI.htmlAttribute (A.title nom) ] (UI.text dessin)


poignee : String -> msg -> Element msg
poignee nom =
    commande [ classe "mrjam-bloc-poignee", UI.htmlAttribute (A.title "Glisser ou sélectionner, puis placer") ] (UI.text nom)


onglet : Bool -> String -> String -> msg -> Element msg
onglet actif famille nom =
    commande
        [ classe ("mrjam-atelier-onglet " ++ famille)
        , UI.htmlAttribute
            (A.attribute "aria-pressed"
                (if actif then
                    "true"

                 else
                    "false"
                )
            )
        ]
        (UI.text nom)


emboitable : Etat -> List (Attribute msg) -> Element msg -> List (Element msg) -> Element msg -> Element msg
emboitable etat attributs entete cavites pied =
    let
        nom =
            case etat of
                Selectionne ->
                    "selectionne"

                Incorrect ->
                    "incorrect"

                Verifie ->
                    "verifie"

                ACompleter ->
                    "incomplet"

                Neutre ->
                    "neutre"

        caviteOuverte index contenu =
            (if index == 0 then
                []

             else
                [ UI.el [ classe "mrjam-bloc-traverse" ] UI.none ]
            )
                ++ [ UI.row [ classe "mrjam-bloc-branche" ]
                        [ UI.el [ classe "mrjam-bloc-epine" ] UI.none
                        , UI.el [ classe "mrjam-cavite" ] contenu
                        ]
                   ]
    in
    UI.column (classe ("mrjam-bloc " ++ nom) :: attributs)
        ([ UI.el [ classe "mrjam-bloc-entete" ] entete ]
            ++ (List.indexedMap caviteOuverte cavites |> List.concat)
            ++ [ UI.el [ classe "mrjam-bloc-pied" ] pied ]
        )


cavite : List (Attribute msg) -> Element msg -> Element msg
cavite attributs contenu =
    UI.el (classe "mrjam-emplacement" :: attributs) contenu


proposition : List (Attribute msg) -> Element msg -> Element msg
proposition attributs contenu =
    UI.el (classe "mrjam-proposition" :: attributs) contenu


logement : List (Attribute msg) -> Element msg -> Element msg
logement attributs contenu =
    UI.el (classe "mrjam-logement" :: attributs) contenu


objectif : Element msg -> Element msg
objectif =
    UI.el [ classe "mrjam-bloc-objectif" ]


{-| La palette reste à gauche, le canevas occupe la droite. Les commandes et
la barre d'état restent hors du défilement du dessin.
-}
espace : Element msg -> Element msg -> Element msg -> Element msg -> Element msg
espace commandes palette canevas statut =
    UI.column [ classe "mrjam-atelier", UI.width UI.fill ]
        [ styles
        , UI.el [ classe "mrjam-atelier-commandes" ] commandes
        , UI.row [ classe "mrjam-atelier-corps" ]
            [ UI.el [ classe "mrjam-atelier-palette" ] palette
            , UI.el [ classe "mrjam-atelier-travail" ] canevas
            ]
        , UI.el [ classe "mrjam-atelier-statut" ] statut
        ]


styles : Element msg
styles =
    UI.html (Html.node "style" [] [ Html.text presentation ])


presentation : String
presentation =
    """
.mrjam-atelier{--palette:258px;width:100%!important;height:100dvh!important;min-height:340px!important;display:flex!important;flex-direction:column!important;background:oklch(0.98386999 0.00251617 228.78342335);color:oklch(0.33176209 0.04255047 183.46459586);font:14px/1.35 Inter,Aptos,"Segoe UI",sans-serif;overflow:hidden}
.mrjam-atelier-commandes{flex:0 0 auto!important;width:100%!important;background:oklch(0.99999999 0.00000004 89.87556310);border-bottom:1px solid oklch(0.89443874 0.01249561 177.98573901);padding:8px 14px!important;z-index:5}
.mrjam-atelier-corps{display:grid!important;grid-template-columns:var(--palette) minmax(0,1fr);width:100%!important;min-height:0!important;flex:1 1 0!important;align-items:stretch!important;overflow:hidden}
.mrjam-atelier-palette{display:block!important;width:auto!important;min-width:0!important;min-height:0!important;overflow:auto!important;overscroll-behavior:contain;background:oklch(0.96384120 0.00444983 179.73377469);border-right:1px solid oklch(0.87427756 0.01503221 175.66661719);padding:12px 10px!important}
.mrjam-atelier-travail{display:flex!important;flex-direction:column!important;width:auto!important;min-width:0!important;min-height:0!important;overflow:hidden;position:relative}
.mrjam-atelier-statut{flex:0 0 auto!important;width:100%!important;border-top:1px solid oklch(0.89443874 0.01249561 177.98573901);background:oklch(0.99999999 0.00000004 89.87556310);padding:6px 12px!important;font-size:12px;min-height:32px!important}
.mrjam-atelier .mrjam-outils{width:100%!important;min-width:0!important;padding:12px!important;background:oklch(0.99999999 0.00000004 89.87556310);border:1px solid oklch(0.89443874 0.01249561 177.98573901);border-radius:8px}
.mrjam-atelier .mrjam-projet{width:100%!important;padding:8px 14px!important;background:oklch(0.99999999 0.00000004 89.87556310);border-bottom:1px solid oklch(0.91623284 0.01195729 170.24612387);flex:0 0 auto!important;min-height:52px!important}
.mrjam-atelier .mrjam-canevas{display:block!important;width:100%!important;min-width:0!important;min-height:0!important;flex:1 1 0!important;overflow:auto!important;overscroll-behavior:contain;background-color:oklch(0.99059126 0.00170347 247.83877920);background-image:radial-gradient(oklch(0.87120217 0.01504476 175.66435382) 1px,transparent 1px);background-size:20px 20px;padding:28px 32px 100px!important;scroll-padding:26px}
.mrjam-atelier .mrjam-canevas-contenu{flex:0 0 auto!important;width:max-content!important;min-width:100%!important;min-height:100%!important;align-items:flex-start!important;transform-origin:top left}
.mrjam-atelier .mrjam-atelier-outil{min-width:34px!important;min-height:34px!important;border:1px solid oklch(0.89341231 0.01396946 174.12521093);border-radius:6px;background:oklch(1 0 0)!important;border:1px solid oklch(0.89341231 0.01396946 174.12521093)!important;font-size:20px;padding:3px 7px!important;text-align:center}
.mrjam-atelier .mrjam-atelier-outil:hover{background:oklch(0.95052939 0.01034397 174.26731464)}
.mrjam-atelier-onglet.mrjam-bloc-commande{min-height:38px!important;padding:7px 8px!important;border-radius:6px;font-size:12px;font-weight:600;white-space:normal!important;max-width:100%;text-align:left}
.mrjam-atelier-onglet::before{content:'';display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:5px;background:oklch(0.66487089 0.03013693 170.70240566)}
.mrjam-atelier-onglet.regles::before{background:oklch(0.77955609 0.15708441 84.14249701)}.mrjam-atelier-onglet.propositions::before{background:oklch(0.64713852 0.15612522 144.42735754)}
.mrjam-atelier-onglet[aria-pressed=true]{background:oklch(0.99999999 0.00000004 89.87556310);box-shadow:0 1px 4px oklch(0.33424728 0.04464933 181.71014210 / 0.125490)}.mrjam-atelier-onglet:hover{background:oklch(0.99999999 0.00000004 89.87556310 / 0.721569)}
.mrjam-bloc{display:flex!important;flex-direction:column!important;align-items:stretch!important;gap:0!important;width:max-content!important;min-width:148px!important;max-width:none!important;background:transparent!important;color:oklch(0.34078969 0.05929159 87.79306492);font-size:13px;line-height:1.25;position:relative;filter:drop-shadow(0 1px 0 oklch(0.69802785 0.14003027 82.64614801));padding:0!important;margin:0!important;isolation:isolate}
.mrjam-bloc.selectionne{filter:drop-shadow(0 0 2px oklch(0.52094715 0.13971434 251.30770236)) drop-shadow(0 0 2px oklch(0.52094715 0.13971434 251.30770236))}.mrjam-bloc.incorrect{filter:drop-shadow(0 0 2px oklch(0.50049969 0.17361526 28.26574628))}
.mrjam-bloc-entete,.mrjam-bloc-pied,.mrjam-bloc-traverse,.mrjam-bloc-epine{background:oklch(0.86490792 0.16195309 87.81475507)!important}
.mrjam-bloc-entete{flex:0 0 auto!important;width:100%!important;min-width:148px!important;min-height:48px!important;padding:12px 10px 7px!important;border-radius:5px 5px 0 0;clip-path:polygon(0 0,15px 0,21px 5px,38px 5px,44px 0,100% 0,100% 100%,0 100%)}
.mrjam-bloc-pied{flex:0 0 auto!important;width:100%!important;min-height:22px!important;padding:5px 10px 10px!important;border-radius:0 0 5px 5px;clip-path:polygon(0 0,100% 0,100% calc(100% - 5px),44px calc(100% - 5px),38px 100%,21px 100%,15px calc(100% - 5px),0 calc(100% - 5px))}
.mrjam-bloc-traverse{width:100%!important;height:10px!important;min-height:10px!important}
.mrjam-bloc-branche{width:100%!important;display:flex!important;align-items:stretch!important;gap:0!important;flex:0 0 auto!important}
.mrjam-bloc-epine{width:12px!important;min-width:12px!important;align-self:stretch!important;flex:0 0 12px!important}
.mrjam-cavite{width:max-content!important;min-width:calc(100% - 12px)!important;padding:7px 0 7px 9px!important;flex:1 0 auto!important;align-self:stretch!important;background:transparent!important}
.mrjam-bloc-commande{width:max-content!important;flex:0 0 auto!important;border:0!important;background:transparent;color:inherit;font:inherit;min-height:28px!important;min-width:20px!important;padding:2px 4px!important;border-radius:4px;white-space:nowrap;cursor:pointer}
.mrjam-bloc-commande:focus-visible{outline:2px solid oklch(0.47031050 0.12651013 252.34372959)!important;outline-offset:1px!important}.mrjam-bloc-commande:hover{background:oklch(0.99999999 0.00000004 89.87556310 / 0.188235)}
.mrjam-bloc-poignee{font-weight:650;padding:2px 0!important;cursor:grab;min-height:30px!important;white-space:normal!important;text-align:left}
.mrjam-proposition{width:max-content!important;max-width:none!important;flex:0 0 auto!important;min-height:30px!important;display:inline-flex!important;align-items:center!important;padding:3px 12px!important;background:oklch(0.69625331 0.16355660 142.66498337)!important;color:oklch(0.32033187 0.07658181 147.05165907)!important;clip-path:polygon(10px 0,calc(100% - 10px) 0,100% 50%,calc(100% - 10px) 100%,10px 100%,0 50%);font-weight:650;white-space:nowrap;filter:drop-shadow(0 1px 0 oklch(0.55163012 0.13717295 144.68276832))}
.mrjam-proposition .mrjam-proposition{background:oklch(0.79627472 0.14419378 142.84664037)!important;margin:1px!important;filter:none}.mrjam-proposition .mrjam-proposition .mrjam-proposition{background:oklch(0.86277990 0.09821111 142.98792553)!important}
.mrjam-logement{width:max-content!important;flex:0 0 auto!important;min-width:34px!important;min-height:28px!important;padding:2px 8px!important;border:1px dashed oklch(0.47740079 0.10053223 143.08118201);border-radius:16px;background:oklch(0.94976137 0.02936145 132.59366667);color:oklch(0.44135608 0.08189646 141.05325377);text-align:center}
.mrjam-proposition .mrjam-logement{background:oklch(0.53588404 0.13191884 146.27997504);color:oklch(0.99999999 0.00000004 89.87556310);border-color:oklch(0.45729700 0.11020435 146.30140343)}
.mrjam-bloc-objectif{width:max-content!important;max-width:100%;display:flex!important;align-items:center;padding:4px 0!important}
.mrjam-emplacement{width:100%!important;min-width:126px!important;min-height:38px!important;border:1px dashed oklch(0.84208244 0.01728958 168.41214448);border-radius:5px;background:oklch(0.99999999 0.00000004 89.87556310 / 0.564706);color:oklch(0.63025462 0.03738496 175.41817258);padding:3px 7px!important;display:flex!important;align-items:center!important}
.mrjam-emplacement.interstice{height:14px!important;min-height:14px!important;padding:0 8px!important;border:0!important;background:transparent!important;opacity:.6}
.mrjam-emplacement.interstice .mrjam-bloc-commande{font-size:10px;min-height:14px!important;padding:0!important}.mrjam-emplacement.interstice:hover,.en-deplacement .mrjam-atelier .mrjam-emplacement.interstice{background:oklch(0.91199148 0.01789852 170.05205867)!important;opacity:1}
.mrjam-emplacement.depart{min-width:235px!important;min-height:86px!important;background:oklch(0.99999999 0.00000004 89.87556310 / 0.600000);box-shadow:0 0 0 5px oklch(0.99999999 0.00000004 89.87556310 / 0.250980);padding:18px!important}
.mrjam-atelier .mrjam-palette-blocs{width:max-content!important;min-width:100%!important;align-items:flex-start!important;gap:18px!important}
.mrjam-atelier-palette .mrjam-bloc{min-width:140px!important;max-width:100%!important;font-size:12px}.mrjam-atelier-palette .mrjam-bloc-entete{min-height:38px!important;padding:10px 8px 5px!important}.mrjam-atelier-palette .mrjam-cavite{padding:4px 0 4px 8px!important;min-height:26px!important}.mrjam-atelier-palette .mrjam-bloc-pied{min-height:18px!important;padding:4px 8px 8px!important}
.mrjam-atelier .mrjam-legende{flex:0 0 auto!important;font-size:12px;color:oklch(0.60317656 0.02879184 168.66928022);white-space:normal}.mrjam-atelier .mrjam-detail{font-size:11px;color:oklch(0.53732660 0.04338211 146.07719634);max-width:240px;white-space:normal}
@media(max-width:900px){.mrjam-atelier{--palette:184px;font-size:13px}.mrjam-atelier-commandes{padding:6px 8px!important}.mrjam-atelier .mrjam-canevas{padding:18px 20px 90px!important}.mrjam-atelier-palette{padding:8px 7px!important}.mrjam-atelier .mrjam-projet{padding:6px 8px!important}.mrjam-atelier-statut{font-size:11px;padding:5px 8px!important}}
@media(max-width:480px){.mrjam-atelier{--palette:140px}.mrjam-atelier-onglet.mrjam-bloc-commande{font-size:11px;padding:6px 4px!important;min-height:36px!important}.mrjam-atelier-palette .mrjam-bloc{min-width:116px!important;font-size:11px}.mrjam-atelier-palette .mrjam-bloc-entete{min-width:116px!important;padding-left:6px!important;padding-right:6px!important}.mrjam-atelier-palette .mrjam-proposition{font-size:11px;padding:2px 9px!important;min-height:25px!important}.mrjam-atelier-palette .mrjam-outils{padding:6px!important}.mrjam-atelier-palette .mrjam-bloc-poignee{max-width:111px!important;white-space:normal!important}.mrjam-atelier .mrjam-canevas{padding:14px 16px 90px!important}.mrjam-atelier .mrjam-legende{flex:0 0 auto!important;font-size:11px}}
@media(max-height:550px){.mrjam-atelier-statut [role=status]{position:absolute!important;width:1px!important;height:1px!important;overflow:hidden!important;clip-path:inset(50%)}.mrjam-atelier-commandes img{width:32px!important;height:32px!important}}
@media(prefers-reduced-motion:reduce){.mrjam-atelier *{transition:none!important;animation:none!important;scroll-behavior:auto!important}}
"""
