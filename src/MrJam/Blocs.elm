module MrJam.Blocs exposing (Etat(..), Format(..), cavite, commande, emboitable, emboitableAvec, espace, logement, logementImbrique, objectif, onglet, outil, poignee, proposition, propositionNiveau)

{-| Constructions à encoches, cavités ouvertes et propositions emboîtées.
Disposition, palette et contrôles en elm-ui ; seuls les contours non rectangulaires
absents de son API passent par l'adaptateur Constructions. Aucune injection CSS.
La profondeur et le format sont explicites : aucune cascade entre pièces voisines.
-}

import Element as UI exposing (Attribute, Element)
import Element.Background as Fond
import Element.Border as Bordure
import Element.Font as Police
import Element.Input as Entree
import Element.Region as Region
import MrJam.Adaptateurs.Accessibilite as Accessibilite
import MrJam.Adaptateurs.Constructions as Formes
import MrJam.Adaptateurs.Manipulation as Gestes
import MrJam.OKLab as OKLab


type Etat
    = Neutre
    | Selectionne
    | Verifie
    | ACompleter
    | Incorrect


type Format
    = Normal
    | Miniature


couleur : Float -> Float -> Float -> UI.Color
couleur l c h =
    let
        rgb =
            OKLab.srgb { l = l, c = c, h = h }
    in
    UI.rgb rgb.r rgb.g rgb.b


jaune : UI.Color
jaune =
    couleur 0.86490792 0.16195309 87.81475507


commande : List (Attribute msg) -> Element msg -> msg -> Element msg
commande attributs contenu message =
    Entree.button
        ([ UI.width UI.shrink
         , UI.height (UI.minimum 28 UI.shrink)
         , UI.paddingXY 4 2
         , Bordure.rounded 4
         , UI.mouseOver [ Fond.color (UI.rgba 1 1 1 0.188235) ]
         ]
            ++ attributs
        )
        { onPress = Just message, label = contenu }


outil : String -> String -> msg -> Element msg
outil nom dessin =
    commande
        [ Region.description nom
        , Accessibilite.infoBulle nom
        , UI.width (UI.minimum 34 UI.shrink)
        , UI.height (UI.minimum 34 UI.shrink)
        , Bordure.width 1
        , Bordure.rounded 6
        , Bordure.color (couleur 0.89341231 0.01396946 174.12521093)
        , Fond.color (UI.rgb 1 1 1)
        , Police.size 20
        , UI.paddingXY 7 3
        , UI.mouseOver [ Fond.color (couleur 0.95052939 0.01034397 174.26731464) ]
        ]
        (UI.text dessin)


poignee : String -> msg -> Element msg
poignee nom =
    commande
        [ Accessibilite.infoBulle "Glisser ou sélectionner, puis placer"
        , Police.semiBold
        , UI.height (UI.minimum 30 UI.shrink)
        , UI.paddingXY 0 2
        ]
        (UI.paragraph [ UI.width UI.fill ] [ UI.text nom ])


onglet : Bool -> String -> String -> msg -> Element msg
onglet actif famille nom =
    commande
        ([ Accessibilite.pressee actif
         , UI.height (UI.minimum 38 UI.shrink)
         , UI.paddingXY 8 7
         , Bordure.rounded 6
         , Police.size 12
         , Police.semiBold
         , UI.mouseOver [ Fond.color (UI.rgba 1 1 1 0.721569) ]
         ]
            ++ (if actif then
                    [ Fond.color (UI.rgb 1 1 1), Bordure.shadow { offset = ( 0, 1 ), blur = 4, size = 0, color = UI.rgba 0.12 0.25 0.24 0.12549 } ]

                else
                    []
               )
        )
        (UI.row [ UI.spacing 5 ]
            [ UI.el
                [ UI.width (UI.px 9)
                , UI.height (UI.px 9)
                , Bordure.rounded 5
                , Fond.color
                    (case famille of
                        "regles" ->
                            couleur 0.77955609 0.15708441 84.14249701

                        "propositions" ->
                            couleur 0.64713852 0.15612522 144.42735754

                        _ ->
                            couleur 0.66487089 0.03013693 170.70240566
                    )
                ]
                UI.none
            , UI.paragraph [ UI.width UI.fill ] [ UI.text nom ]
            ]
        )


emboitable : Etat -> List (Attribute msg) -> Element msg -> List (Element msg) -> Element msg -> Element msg
emboitable =
    emboitableAvec Normal


emboitableAvec : Format -> Etat -> List (Attribute msg) -> Element msg -> List (Element msg) -> Element msg -> Element msg
emboitableAvec format etat attributs entete cavites pied =
    let
        compacte =
            format == Miniature

        minimum =
            if compacte then
                116

            else
                148

        branche index contenu =
            (if index == 0 then
                []

             else
                [ UI.el (Gestes.prise ++ [ Formes.repere Formes.Traverse, UI.width UI.fill, UI.height (UI.px 10), Fond.color jaune ]) UI.none ]
            )
                ++ [ UI.row [ UI.width UI.fill, UI.spacing 0 ]
                        [ UI.el (Gestes.prise ++ [ Formes.repere Formes.Epine, UI.width (UI.px 12), UI.height UI.fill, Fond.color jaune ]) UI.none
                        , UI.el [ Formes.repere Formes.Cavite, UI.width (UI.minimum 0 UI.fill), UI.paddingEach { top = 7, bottom = 7, left = 9, right = 0 } ] contenu
                        ]
                   ]

        contour =
            case etat of
                Selectionne ->
                    Formes.selectionne

                Incorrect ->
                    Formes.incorrect

                _ ->
                    Formes.neutre
    in
    UI.column
        ([ Formes.repere Formes.Bloc
         , contour
         , UI.width (UI.minimum minimum UI.shrink)
         , UI.spacing 0
         , Police.size
            (if compacte then
                12

             else
                13
            )
         , Police.color (couleur 0.34078969 0.05929159 87.79306492)
         ]
            ++ attributs
        )
        ([ UI.el
            ([ Formes.repere Formes.Entete
             , UI.width UI.fill
             , UI.height
                (UI.minimum
                    (if compacte then
                        38

                     else
                        48
                    )
                    UI.shrink
                )
             , UI.paddingEach
                { top =
                    if compacte then
                        10

                    else
                        12
                , bottom =
                    if compacte then
                        5

                    else
                        7
                , left =
                    if compacte then
                        8

                    else
                        10
                , right =
                    if compacte then
                        8

                    else
                        10
                }
             , Fond.color jaune
             , Bordure.roundEach { topLeft = 5, topRight = 5, bottomLeft = 0, bottomRight = 0 }
             ]
                ++ Gestes.prise
                ++ Formes.encocheEntete
            )
            entete
         ]
            ++ List.concat (List.indexedMap branche cavites)
            ++ [ UI.el
                    ([ Formes.repere Formes.Pied
                     , UI.width UI.fill
                     , UI.height
                        (UI.minimum
                            (if compacte then
                                18

                             else
                                22
                            )
                            UI.shrink
                        )
                     , UI.paddingEach
                        { top =
                            if compacte then
                                4

                            else
                                5
                        , bottom =
                            if compacte then
                                8

                            else
                                10
                        , left =
                            if compacte then
                                8

                            else
                                10
                        , right =
                            if compacte then
                                8

                            else
                                10
                        }
                     , Fond.color jaune
                     , Bordure.roundEach { topLeft = 0, topRight = 0, bottomLeft = 5, bottomRight = 5 }
                     ]
                        ++ Gestes.prise
                        ++ Formes.encochePied
                    )
                    pied
               ]
        )


cavite : List (Attribute msg) -> Element msg -> Element msg
cavite attributs contenu =
    UI.el
        ([ Formes.repere Formes.Emplacement
         , UI.width (UI.minimum 126 UI.fill)
         , UI.height (UI.minimum 48 UI.shrink)
         , UI.paddingXY 7 3
         , Bordure.width 1
         , Bordure.dashed
         , Bordure.rounded 5
         , Bordure.color (couleur 0.84208244 0.01728958 168.41214448)
         , Fond.color (UI.rgba 1 1 1 0.564706)
         , Police.color (couleur 0.63025462 0.03738496 175.41817258)
         ]
            ++ attributs
        )
        contenu


proposition : List (Attribute msg) -> Element msg -> Element msg
proposition =
    propositionNiveau 0


propositionNiveau : Int -> List (Attribute msg) -> Element msg -> Element msg
propositionNiveau niveau attributs contenu =
    UI.el
        ([ Formes.repere Formes.Objet
         , UI.width UI.shrink
         , UI.height (UI.minimum 30 UI.shrink)
         , UI.paddingXY 12 3
         , Police.semiBold
         , Police.color (couleur 0.32033187 0.07658181 147.05165907)
         , Fond.color
            (case clamp 0 2 niveau of
                0 ->
                    couleur 0.69625331 0.1635566 142.66498337

                1 ->
                    couleur 0.79627472 0.14419378 142.84664037

                _ ->
                    couleur 0.8627799 0.09821111 142.98792553
            )
         ]
            ++ Gestes.prise
            ++ Formes.objet
            ++ attributs
        )
        contenu


logement : List (Attribute msg) -> Element msg -> Element msg
logement =
    logementPour False


logementImbrique : List (Attribute msg) -> Element msg -> Element msg
logementImbrique =
    logementPour True


logementPour : Bool -> List (Attribute msg) -> Element msg -> Element msg
logementPour imbrique attributs contenu =
    UI.el
        ([ Formes.repere Formes.Logement
         , UI.width (UI.minimum 34 UI.shrink)
         , UI.height (UI.minimum 28 UI.shrink)
         , UI.paddingXY 8 2
         , Bordure.width 1
         , Bordure.dashed
         , Bordure.rounded 16
         , Bordure.color
            (if imbrique then
                couleur 0.457297 0.11020435 146.30140343

             else
                couleur 0.47740079 0.10053223 143.08118201
            )
         , Fond.color
            (if imbrique then
                couleur 0.53588404 0.13191884 146.27997504

             else
                couleur 0.94976137 0.02936145 132.59366667
            )
         , Police.color
            (if imbrique then
                UI.rgb 1 1 1

             else
                couleur 0.44135608 0.08189646 141.05325377
            )
         , Police.center
         ]
            ++ attributs
        )
        contenu


objectif : Element msg -> Element msg
objectif =
    UI.el [ UI.width UI.shrink, UI.paddingXY 0 4 ]


{-| Dimensions réelles du navigateur ; l'atelier possède ses deux défilements,
sans faire déborder la page. Les commandes et le statut restent toujours présents.
-}
espace : { largeur : Int, hauteur : Int } -> Element msg -> Element msg -> Element msg -> Element msg -> Element msg
espace dimensions commandes palette canevas statut =
    let
        largeurPalette =
            if dimensions.largeur <= 480 then
                140

            else if dimensions.largeur <= 900 then
                184

            else
                258
    in
    UI.column
        [ Formes.repere Formes.Atelier
        , UI.width UI.fill
        , UI.height (UI.px (max 340 dimensions.hauteur))
        , UI.clip
        , Police.size
            (if dimensions.largeur <= 900 then
                13

             else
                14
            )
        , Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]
        , Fond.color (couleur 0.98386999 0.00251617 228.78342335)
        , Police.color (couleur 0.33176209 0.04255047 183.46459586)
        ]
        [ UI.el
            [ UI.width UI.fill
            , UI.paddingXY 14
                (if dimensions.hauteur < 500 then
                    4

                 else
                    8
                )
            , Fond.color (UI.rgb 1 1 1)
            , Bordure.widthEach { bottom = 1, top = 0, left = 0, right = 0 }
            , Bordure.color (couleur 0.89443874 0.01249561 177.98573901)
            ]
            commandes
        , UI.row [ UI.width UI.fill, UI.height (UI.minimum 0 UI.fill), UI.clip ]
            [ UI.el [ Formes.repere Formes.Palette, UI.width (UI.px largeurPalette), UI.height (UI.minimum 0 UI.fill), UI.scrollbars, UI.paddingXY 10 12, Fond.color (couleur 0.9638412 0.00444983 179.73377469), Bordure.widthEach { right = 1, bottom = 0, top = 0, left = 0 }, Bordure.color (couleur 0.87427756 0.01503221 175.66661719) ] palette
            , UI.el [ UI.width (UI.minimum 0 UI.fill), UI.height (UI.minimum 0 UI.fill), UI.clip ] canevas
            ]
        , UI.el [ UI.width UI.fill, UI.height (UI.minimum 32 UI.shrink), UI.paddingXY 12 6, Police.size 12, Fond.color (UI.rgb 1 1 1), Bordure.widthEach { top = 1, bottom = 0, left = 0, right = 0 }, Bordure.color (couleur 0.89443874 0.01249561 177.98573901) ] statut
        ]
