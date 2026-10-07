# Décomposition de Y

Le fichier fourni contient huit tracés blancs mais six placements distincts. Les couples path8/path14 et path10/path16 possèdent exactement les mêmes arcs et transformations cumulées. Ils sont conservés dans leur ordre original : supprimer un doublon modifierait notamment l’anticrénelage de ses bords.

Le fond est `#64c29b`, identique à celui du logo. Y ne contient pas de disque de connaissance explicite.

La formule et l’origine sont celles de [X](GEOMETRIE.md) : `T(p) = t + s R(θ) Fᵐ p`, O=(13,8 ; 9). Les rotations entières et les échelles dérivées des rayons sont retenues après vérification de la borne, jamais par simple arrondi supposé.

| Tracé | Contour | tx | ty | Angle | Échelle | Face | Borne continue |
|---|---|---:|---:|---:|---:|---|---:|
| path4 | visio | 14.136732644972 | 12.561555972981 | 117° | 1.000000032 | Reflechie | 7.37372699e-05 |
| path6 | visio | 16.019638434855 | 12.842961481679 | -100° | 1.000000032 | Directe | 7.16325786e-05 |
| path8 | kino | 15.079212386953 | 13.886925717560 | 0° | 0.750000024 | Reflechie | 5.82511406e-05 |
| path10 | kino | 14.255651040587 | 14.710500153363 | 0° | 0.750000024 | Directe | 5.82511406e-05 |
| path14 | kino | 15.079212386953 | 13.886925717560 | 0° | 0.750000024 | Reflechie | 5.82511406e-05 |
| path16 | kino | 14.255651040587 | 14.710500153363 | 0° | 0.750000024 | Directe | 5.82511406e-05 |
| path22 | audio | 14.703647000420 | 2.934771538101 | 171° | 0.750000031648561 | Directe | 6.14506325e-05 |
| path24 | audio | 17.034785013074 | 6.738828395119 | 6° | 0.750000031648561 | Directe | 6.15495978e-05 |

L’arc auditif possède plusieurs correspondances géométriques valides. Comme dans le vérificateur X, une similitude directe est privilégiée lorsqu’elle satisfait le seuil : les deux occurrences auditives sont donc directes dans cette réalisation. Trois occurrences se retournent, dont deux rejoignent le même placement kinesthésique. Le sens de parcours des arcs est traité indépendamment de la chiralité.

129 points par arc. Erreur échantillonnée maximale : **1,946025574 × 10⁻⁵** ; borne continue maximale : **7,373726994 × 10⁻⁵**, inférieure au seuil commun **10⁻⁴**. Calcul flottant conservatif des arcs circulaires et des petites fermetures, pas preuve d’égalité symbolique.

Les matrices des SVG exportés par Elm sont recontrôlées dans `scripts/verify-production.py`. Les deux navigateurs comparent aussi les originaux, exports et scènes finales à 1 200 × 1 200 pixels. Les différences observées restent dans la bande de trois pixels autour des contours.
