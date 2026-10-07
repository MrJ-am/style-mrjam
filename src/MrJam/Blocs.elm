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
.mrjam-atelier{--palette:258px;width:100%!important;height:100dvh!important;min-height:340px!important;display:flex!important;flex-direction:column!important;background:#f8fafb;color:#193d38;font:14px/1.35 Inter,Aptos,"Segoe UI",sans-serif;overflow:hidden}
.mrjam-atelier-commandes{flex:0 0 auto!important;width:100%!important;background:#fff;border-bottom:1px solid #d4dfdc;padding:8px 14px!important;z-index:5}
.mrjam-atelier-corps{display:grid!important;grid-template-columns:var(--palette) minmax(0,1fr);width:100%!important;min-height:0!important;flex:1 1 0!important;align-items:stretch!important;overflow:hidden}
.mrjam-atelier-palette{display:block!important;width:auto!important;min-width:0!important;min-height:0!important;overflow:auto!important;overscroll-behavior:contain;background:#f0f4f3;border-right:1px solid #ccd9d5;padding:12px 10px!important}
.mrjam-atelier-travail{display:flex!important;flex-direction:column!important;width:auto!important;min-width:0!important;min-height:0!important;overflow:hidden;position:relative}
.mrjam-atelier-statut{flex:0 0 auto!important;width:100%!important;border-top:1px solid #d4dfdc;background:#fff;padding:6px 12px!important;font-size:12px;min-height:32px!important}
.mrjam-atelier .mrjam-outils{width:100%!important;min-width:0!important;padding:12px!important;background:#fff;border:1px solid #d4dfdc;border-radius:8px}
.mrjam-atelier .mrjam-projet{width:100%!important;padding:8px 14px!important;background:#fff;border-bottom:1px solid #dce6e2;flex:0 0 auto!important;min-height:52px!important}
.mrjam-atelier .mrjam-canevas{display:block!important;width:100%!important;min-width:0!important;min-height:0!important;flex:1 1 0!important;overflow:auto!important;overscroll-behavior:contain;background-color:#fbfcfd;background-image:radial-gradient(#cbd8d4 1px,transparent 1px);background-size:20px 20px;padding:28px 32px 100px!important;scroll-padding:26px}
.mrjam-atelier .mrjam-canevas-contenu{flex:0 0 auto!important;width:max-content!important;min-width:100%!important;min-height:100%!important;align-items:flex-start!important;transform-origin:top left}
.mrjam-atelier .mrjam-atelier-outil{min-width:34px!important;min-height:34px!important;border:1px solid #d3dfdb;border-radius:6px;background:white!important;border:1px solid #d3dfdb!important;font-size:20px;padding:3px 7px!important;text-align:center}
.mrjam-atelier .mrjam-atelier-outil:hover{background:#e8f1ee}
.mrjam-atelier-onglet.mrjam-bloc-commande{min-height:38px!important;padding:7px 8px!important;border-radius:6px;font-size:12px;font-weight:600;white-space:normal!important;max-width:100%;text-align:left}
.mrjam-atelier-onglet::before{content:'';display:inline-block;width:9px;height:9px;border-radius:50%;margin-right:5px;background:#829a91}
.mrjam-atelier-onglet.regles::before{background:#e6ad12}.mrjam-atelier-onglet.propositions::before{background:#47a64c}
.mrjam-atelier-onglet[aria-pressed=true]{background:#fff;box-shadow:0 1px 4px #183e3820}.mrjam-atelier-onglet:hover{background:#ffffffb8}
.mrjam-bloc{display:flex!important;flex-direction:column!important;align-items:stretch!important;gap:0!important;width:max-content!important;min-width:148px!important;max-width:none!important;background:transparent!important;color:#45360e;font-size:13px;line-height:1.25;position:relative;filter:drop-shadow(0 1px 0 #c89412);padding:0!important;margin:0!important;isolation:isolate}
.mrjam-bloc.selectionne{filter:drop-shadow(0 0 2px #196bb6) drop-shadow(0 0 2px #196bb6)}.mrjam-bloc.incorrect{filter:drop-shadow(0 0 2px #b12922)}
.mrjam-bloc-entete,.mrjam-bloc-pied,.mrjam-bloc-traverse,.mrjam-bloc-epine{background:#ffcb38!important}
.mrjam-bloc-entete{flex:0 0 auto!important;width:100%!important;min-width:148px!important;min-height:48px!important;padding:12px 10px 7px!important;border-radius:5px 5px 0 0;clip-path:polygon(0 0,15px 0,21px 5px,38px 5px,44px 0,100% 0,100% 100%,0 100%)}
.mrjam-bloc-pied{flex:0 0 auto!important;width:100%!important;min-height:22px!important;padding:5px 10px 10px!important;border-radius:0 0 5px 5px;clip-path:polygon(0 0,100% 0,100% calc(100% - 5px),44px calc(100% - 5px),38px 100%,21px 100%,15px calc(100% - 5px),0 calc(100% - 5px))}
.mrjam-bloc-traverse{width:100%!important;height:10px!important;min-height:10px!important}
.mrjam-bloc-branche{width:100%!important;display:flex!important;align-items:stretch!important;gap:0!important;flex:0 0 auto!important}
.mrjam-bloc-epine{width:12px!important;min-width:12px!important;align-self:stretch!important;flex:0 0 12px!important}
.mrjam-cavite{width:max-content!important;min-width:calc(100% - 12px)!important;padding:7px 0 7px 9px!important;flex:1 0 auto!important;align-self:stretch!important;background:transparent!important}
.mrjam-bloc-commande{width:max-content!important;flex:0 0 auto!important;border:0!important;background:transparent;color:inherit;font:inherit;min-height:28px!important;min-width:20px!important;padding:2px 4px!important;border-radius:4px;white-space:nowrap;cursor:pointer}
.mrjam-bloc-commande:focus-visible{outline:2px solid #185c9f!important;outline-offset:1px!important}.mrjam-bloc-commande:hover{background:#ffffff30}
.mrjam-bloc-poignee{font-weight:650;padding:2px 0!important;cursor:grab;min-height:30px!important;white-space:normal!important;text-align:left}
.mrjam-proposition{width:max-content!important;max-width:none!important;flex:0 0 auto!important;min-height:30px!important;display:inline-flex!important;align-items:center!important;padding:3px 12px!important;background:#58b653!important;color:#123d1a!important;clip-path:polygon(10px 0,calc(100% - 10px) 0,100% 50%,calc(100% - 10px) 100%,10px 100%,0 50%);font-weight:650;white-space:nowrap;filter:drop-shadow(0 1px 0 #34863a)}
.mrjam-proposition .mrjam-proposition{background:#82d47d!important;margin:1px!important;filter:none}.mrjam-proposition .mrjam-proposition .mrjam-proposition{background:#ace3a8!important}
.mrjam-logement{width:max-content!important;flex:0 0 auto!important;min-width:34px!important;min-height:28px!important;padding:2px 8px!important;border:1px dashed #376b35;border-radius:16px;background:#e7f3df;color:#385e32;text-align:center}
.mrjam-proposition .mrjam-logement{background:#2e813b;color:#fff;border-color:#25672f}
.mrjam-bloc-objectif{width:max-content!important;max-width:100%;display:flex!important;align-items:center;padding:4px 0!important}
.mrjam-emplacement{width:100%!important;min-width:126px!important;min-height:38px!important;border:1px dashed #c1cfc9;border-radius:5px;background:#ffffff90;color:#729188;padding:3px 7px!important;display:flex!important;align-items:center!important}
.mrjam-emplacement.interstice{height:14px!important;min-height:14px!important;padding:0 8px!important;border:0!important;background:transparent!important;opacity:.6}
.mrjam-emplacement.interstice .mrjam-bloc-commande{font-size:10px;min-height:14px!important;padding:0!important}.mrjam-emplacement.interstice:hover,.en-deplacement .mrjam-atelier .mrjam-emplacement.interstice{background:#d7e6e0!important;opacity:1}
.mrjam-emplacement.depart{min-width:235px!important;min-height:86px!important;background:#fff9;box-shadow:0 0 0 5px #ffffff40;padding:18px!important}
.mrjam-atelier .mrjam-palette-blocs{width:max-content!important;min-width:100%!important;align-items:flex-start!important;gap:18px!important}
.mrjam-atelier-palette .mrjam-bloc{min-width:140px!important;max-width:100%!important;font-size:12px}.mrjam-atelier-palette .mrjam-bloc-entete{min-height:38px!important;padding:10px 8px 5px!important}.mrjam-atelier-palette .mrjam-cavite{padding:4px 0 4px 8px!important;min-height:26px!important}.mrjam-atelier-palette .mrjam-bloc-pied{min-height:18px!important;padding:4px 8px 8px!important}
.mrjam-atelier .mrjam-legende{flex:0 0 auto!important;font-size:12px;color:#71877e;white-space:normal}.mrjam-atelier .mrjam-detail{font-size:11px;color:#5e755f;max-width:240px;white-space:normal}
@media(max-width:900px){.mrjam-atelier{--palette:184px;font-size:13px}.mrjam-atelier-commandes{padding:6px 8px!important}.mrjam-atelier .mrjam-canevas{padding:18px 20px 90px!important}.mrjam-atelier-palette{padding:8px 7px!important}.mrjam-atelier .mrjam-projet{padding:6px 8px!important}.mrjam-atelier-statut{font-size:11px;padding:5px 8px!important}}
@media(max-width:480px){.mrjam-atelier{--palette:140px}.mrjam-atelier-onglet.mrjam-bloc-commande{font-size:11px;padding:6px 4px!important;min-height:36px!important}.mrjam-atelier-palette .mrjam-bloc{min-width:116px!important;font-size:11px}.mrjam-atelier-palette .mrjam-bloc-entete{min-width:116px!important;padding-left:6px!important;padding-right:6px!important}.mrjam-atelier-palette .mrjam-proposition{font-size:11px;padding:2px 9px!important;min-height:25px!important}.mrjam-atelier-palette .mrjam-outils{padding:6px!important}.mrjam-atelier-palette .mrjam-bloc-poignee{max-width:111px!important;white-space:normal!important}.mrjam-atelier .mrjam-canevas{padding:14px 16px 90px!important}.mrjam-atelier .mrjam-legende{flex:0 0 auto!important;font-size:11px}}
@media(prefers-reduced-motion:reduce){.mrjam-atelier *{transition:none!important;animation:none!important;scroll-behavior:auto!important}}
"""
