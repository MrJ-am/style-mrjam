# Décomposition de X et correspondances

Les sept occurrences utilisent les trois mêmes contours non circulaires. Le petit disque de connaissance ne figure pas dans X. Les transformations ci-dessous sont celles effectivement sérialisées par le code Elm et vérifiées contre le SVG historique.

`T(p) = t + s R(theta) F^m p`, `F(x,y)=(-x,y)`. Origine locale O=(13,8 ; 9), angles en degrés SVG, échelle uniforme positive. Ordre effectif : réflexion, échelle, rotation, translation.

| Path | Instance | tx | ty | Angle | Échelle | Face | Erreur échantillonnée | Borne continue |
| --- | --- | ---: | ---: | ---: | ---: | --- | ---: | ---: |
| path4 | kinesthesique-0 | 16.230500874791 | 18.459958418320 | 15° | 0.5624999968333334 | Directe | 1.07045918e-05 | 4.43147423e-05 |
| path6 | kinesthesique-1 | 16.230501244730 | 18.459973327030 | -15° | 0.5624999968333334 | Réfléchie | 1.17537515e-05 | 4.54046008e-05 |
| path8 | visuel-1 | 14.605360609844 | 11.732154305092 | 45° | 0.5624999968333334 | Réfléchie | 7.89855114e-06 | 3.04464387e-05 |
| path10 | auditif-0 | 11.950691574212 | 11.382670188127 | 90° | 0.5624999968333334 | Directe | 9.71513883e-06 | 4.57486632e-05 |
| path12 | kinesthesique-2 | 14.605346382776 | 11.732157806695 | 165° | 0.5624999968333334 | Réfléchie | 1.33662143e-05 | 5.10107989e-05 |
| path16 | visuel-2 | 16.687547146037 | 17.872035417457 | 15° | 0.7381124958447001 | Réfléchie | 9.62215682e-06 | 3.34975098e-05 |
| path18 | visuel-0 | 16.466336699344 | 18.406089582638 | -60° | 0.7381124958447001 | Directe | 9.93001487e-06 | 3.82310389e-05 |

129 points par arc, seuil géométrique 10⁻⁴ unité du viewBox. La borne continue inclut les très petits segments de fermeture dus aux arrondis. Elle est calculée en flottants, sans certification par arithmétique d’intervalles.

Le déterminant terminal vaut +s² pour une occurrence directe et −s² pour une occurrence réfléchie. Les rapports de longueurs de la primitive sont conservés. L’amincissement transitoire appartient à la projection spatiale ; il ne change jamais le contour canonique.

Données complètes : `../../../public/assets/mrjam/factorises/decomposition-X.json` ; matrices et mesures des exports réels : `../verification/production-geometrie.json`.
