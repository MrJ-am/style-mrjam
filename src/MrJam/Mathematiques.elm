module MrJam.Mathematiques exposing (formule, ligne, texte)

{-| Composition elm-ui de texte et de formules TeX. Le découpage historique
par dollars est conservé ; KaTeX reste responsable du rendu mathématique.
-}

import Element exposing (Element)
import MrJam.Adaptateurs.Mathematiques as Native


ligne : String -> List (Element message)
ligne source =
    source
        |> String.split "$"
        |> List.indexedMap
            (\indice segment ->
                if modBy 2 indice == 0 then
                    Element.text segment

                else
                    Native.expression False segment
            )


texte : String -> Element message
texte source =
    Element.paragraph [ Element.width Element.fill, Element.spacing 6 ] (ligne source)


formule : String -> Element message
formule source =
    Element.el [ Element.width (Element.minimum 0 Element.fill), Element.scrollbarX ]
        (Native.expression True source)
