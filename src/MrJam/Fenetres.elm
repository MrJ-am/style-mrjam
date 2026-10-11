module MrJam.Fenetres exposing (avecModale, avecModalePour, confirmationPour, modale, modalePour)

{-| Dialogue natif, focus et fond inerte du navigateur. Le compagnon fenetres.js
ouvre le dialogue et restitue le focus à sa fermeture. Le contexte de marque
est explicite comme dans les autres composants, pas hérité par CSS.
-}

import Element exposing (Element)
import Element.Font as Police
import Html exposing (Html)
import MrJam
import MrJam.Adaptateurs.Dialogue as Dialogue
import MrJam.Contexte exposing (Contexte)
import MrJam.Theme as Theme


modale : String -> String -> message -> List (Element message) -> Html message
modale =
    modalePour Theme.commune


modalePour : Contexte -> String -> String -> message -> List (Element message) -> Html message
modalePour contexte identifiant titre fermer contenu =
    let
        composants =
            MrJam.pour contexte
    in
    Dialogue.natif identifiant titre fermer <|
        Element.layoutWith { options = [ Element.noStaticStyleSheet, Theme.focusPour contexte ] }
            [ Element.width (Element.maximum 680 Element.fill)
            , Element.height Element.shrink
            , Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]
            , Police.size 16
            ]
            (composants.section titre contenu)


{-| Dialogue de lecture/confirmation historique : les comparaisons disposent
d'une largeur supérieure, la fermeture reste explicite et immédiatement active.
Le navigateur borne la couche au viewport ; aucun positionnement CSS applicatif.
-}
confirmationPour : Contexte -> String -> String -> String -> message -> List (Element message) -> Html message
confirmationPour contexte identifiant titre fermeture fermer contenu =
    let
        composants =
            MrJam.pour contexte
    in
    Dialogue.natif identifiant titre fermer <|
        Element.layoutWith { options = [ Element.noStaticStyleSheet, Theme.focusPour contexte ] }
            [ Element.width
                (Element.maximum
                    (if identifiant == "comparison" then
                        1160

                     else
                        560
                    )
                    Element.fill
                )
            , Element.height (Element.maximum 760 Element.shrink)
            , Element.scrollbarY
            , Police.family [ Police.typeface "Inter", Police.typeface "Aptos", Police.typeface "Segoe UI", Police.sansSerif ]
            , Police.size 16
            ]
            (composants.carte
                (Element.wrappedRow [ Element.width Element.fill, Element.spacing 12 ]
                    [ MrJam.sousTitre titre
                    , Element.el [ Element.alignRight ] (composants.boutonSecondaire fermeture fermer)
                    ]
                    :: contenu
                )
            )


{-| Deux racines ElmUI sœurs : les styles dynamiques de la modale ne remplacent
pas ceux de la page. Le raccord HTML ne porte aucune présentation.
-}
avecModale : Maybe (Html message) -> Html message -> Html message
avecModale dialogue contenu =
    Dialogue.assembler contenu dialogue


{-| Signature historique conservée ; la marque des composants est désormais
explicite. Utiliser le même Contexte dans MrJam.pour et modalePour.
-}
avecModalePour : String -> Maybe (Html message) -> Html message -> Html message
avecModalePour _ =
    avecModale
