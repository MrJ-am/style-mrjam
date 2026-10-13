# Dégradé G : étapes adaptatives et comparaison RGB / OKLCH

[Comparaison visuelle](comparaison.png)

| Échantillonnage | RGB | OKLCH |
| --- | --- | --- |
| 501 étapes régulières | [SVG](G-uniforme-rgb.svg) | [SVG](G-uniforme-oklch.svg) |
| 29 étapes adaptées | [SVG](G-adaptatif-rgb.svg) | [SVG](G-adaptatif-oklch.svg) |

Sur GitHub, ouvrir le SVG puis utiliser **Download raw file**.
Ces essais conservent la silhouette de G, ses trois primitives, son masque,
ses transformations et ses repères obliques. Ils ne remplacent aucun logo du site.

## Calcul et précision

Le chemin reste `F(t²)` de l’[essai 12](../chemins-12/README.md).
Les conversions et la limite du gamut sRGB proviennent des fonctions Elm
existantes `Palette.Couleurs` et `MrJam.OKLab` : aucune seconde implémentation.

La subdivision part des deux extrémités. Chaque intervalle est contrôlé en
15 positions intérieures ; il est coupé en deux si l’interpolation sRGB s’écarte
trop du chemin OKLCH demandé. Ce premier passage produit 33 étapes.
Un second placement cherche par dichotomie la plus grande portée admissible
depuis chaque étape, avec une marge de précision de 1 % : il en reste 29.
Il s’agit d’une recherche gloutonne adaptée à cette courbe, pas d’une preuve
que 29 est le minimum global parmi tous les placements possibles.

La tolérance retenue est une distance euclidienne OKLab de 0,0001, avec un
second plafond de 0,25 niveau RGB sur 255. Ce choix est conservateur ; ce n’est
pas un seuil perceptif universel. Un contrôle indépendant en 16 385 positions
trouve un écart maximal de **0,000099001 en OKLab** et **0,05113 niveau sur 255**.
Les écarts sont des maxima échantillonnés, pas des bornes analytiques continues.
Les 16 385 couleurs de référence sont dans le gamut ; les segments sRGB entre
étapes le sont aussi, par convexité du cube RGB.

| Tolérance OKLab | Étapes après placement | Écart OKLab mesuré | Écart maximal sur un canal de 8 bits |
| --- | ---: | ---: | ---: |
| 0,001 | 13 | 0,000569 | 0,248 |
| 0,00025 | 19 | 0,000248 | 0,128 |
| **0,0001** | **29** | **0,000099** | **0,052** |
| 0,000025 | 57 | 0,0000248 | 0,013 |

Les positions retenues sont non uniformes, mais assez proches d’une répartition
régulière : hors dernier intervalle raccourci, les pas vont de 0,0321 à 0,0385.
Ce résultat vient de la courbure du trajet exprimé en sRGB ; sa vitesse seule
ne permet pas de prédire la bonne répartition.
Les positions et les contrôles sont dans [precision.json](precision.json).

Les SVG RGB et OKLCH possèdent exactement les mêmes positions d’étapes.
Seule leur écriture change : `rgb(...)` ou `oklch(...)`, avec une précision
fractionnaire. Tous conservent `color-interpolation="sRGB"` : l’écriture des
couleurs en OKLCH n’est pas une demande d’interpolation native en OKLCH.
Les espaces LCH CIELAB et OKLCH ne sont pas confondus.

## Résultats de rendu

Chromium 151.0.7922.173 et Firefox 151.0 acceptent les quatre fichiers.
Aux largeurs 320, 800 et 1600 pixels, les comparaisons du rendu canvas sRGB
sur 8 bits avec le témoin à 501 étapes RGB donnent au plus **1 niveau sur 255
par canal**. Dans Firefox, à nombre d’étapes égal, les écritures RGB et OKLCH
produisent exactement les mêmes pixels dans ces essais. Dans Chromium,
quelques pixels diffèrent d’un niveau. La planche native SVG a aussi été
inspectée visuellement : aucune modification discernable du dessin.

## Mesures de temps

Banc local sans interface de production, sans réseau et sans nouvelle dépendance.
Les quatre variantes sont exécutées dans un ordre pseudo-aléatoire reproductible,
avec cinq tours d’échauffement, puis 60 tours à 800 × 1350 pixels et 30 tours
aux largeurs 320 et 1600. Une seconde exécution à 800 pixels confirme les tendances.

« Premier rendu » comprend : nouveau Blob/URL, décodage SVG, dessin sur canvas
et lecture complète des pixels. « Redessin » réutilise la même image décodée,
mais redessine et relit les pixels. La lecture force l’exécution du travail ;
le contexte `willReadFrequently` favorise une voie adaptée aux lectures CPU.
Il ne s’agit donc **ni du temps de peinture GPU d’une page ordinaire, ni de FPS**.
Les nombres ne doivent pas être transposés tels quels à un téléphone.

Médianes de la première série, en millisecondes, à 800 × 1350 pixels :

| Variante | Chromium premier rendu | Firefox premier rendu | Chromium redessin | Firefox redessin |
| --- | ---: | ---: | ---: | ---: |
| 501 RGB | 29,9 | 37 | 13,9 | 4 |
| 501 OKLCH | 33,3 | 37 | 16,2 | 4 |
| 29 RGB | 28,4 | 34 | 15,1 | 4 |
| 29 OKLCH | 31,3 | 33 | 17,7 | 3 |

La répétition donne respectivement 29,3 / 32,2 / 27,1 / 30,3 ms dans Chromium
et 36 / 36 / 32 / 32 ms dans Firefox pour le premier rendu.

Constats limités à ce banc :

- Réduire les étapes diminue le coût de décodage et le premier rendu.
- OKLCH ne montre aucun avantage de vitesse. Firefox reste très proche du RGB ;
  Chromium ajoute environ 3 ms au premier rendu dans ces conditions.
- Moins d’étapes ne signifie pas systématiquement un redessin plus rapide :
  Chromium redessine ici les 29 étapes non uniformes un peu plus lentement.
  Le banc ne permet pas d’attribuer cette différence à une optimisation interne précise.
- Le coût d’un logo statique n’est pas payé continuellement à chaque frame.
  Ce test ne démontre pas que le dégradé constitue un goulot d’étranglement
  dans les pages du projet, ni le contraire pour toutes les configurations.

Les [résultats résumés](resultats.json) comprennent médianes, quantiles et
intervalles bootstrap des différences appariées. Les données complètes figurent
dans [mesures-brutes.json](mesures-brutes.json) et
[mesures-repetition.json](mesures-repetition.json). Ces intervalles décrivent la
variabilité de ce banc ; ils ne couvrent pas la diversité des appareils.
Safari, les éditeurs SVG et les téléphones physiques n’ont pas été testés.

## Taille et choix pratique

| Variante | Octets SVG | Octets après gzip local |
| --- | ---: | ---: |
| 501 RGB | 67 458 | 16 725 |
| 501 OKLCH | 68 457 | 13 243 |
| 29 RGB | 19 314 | 4 771 |
| 29 OKLCH | 19 369 | 4 553 |

L’allègement est net : environ **71 %** du fichier RGB non compressé.
29 étapes RGB constituent un bon export portable ; la version OKLCH conserve
une lecture directe des paramètres, avec un rendu équivalent à la précision
observée. Le calcul source demeure en OKLCH dans les deux cas.
Aucun choix officiel n’est imposé par cette expérience.

## Reproduire

Depuis la racine du dépôt, avec les outils déjà installés dans l’atelier logo :

```sh
python3 logos/essais/optimisation-13/outils/recalculer.py
node logos/essais/optimisation-13/outils/mesurer.cjs
python3 logos/essais/optimisation-13/outils/resumer.py
node logos/essais/optimisation-13/outils/apercu.cjs
```

`recalculer.py --outils /chemin/atelier/logo` permet d’utiliser un atelier existant.
Pour les commandes Node, `OUTILS_LOGO` indique son `package.json`.
`CHROMIUM` sélectionne explicitement le binaire Chromium système ; Firefox doit
être installé pour le Playwright utilisé. Aucun téléchargement automatique.
Pour une répétition ciblée : `BENCH_TAILLES=800 BENCH_SORTIE=mesures-repetition.json`.
Le calcul Elm se compile dans un dossier temporaire, jamais dans le site.
