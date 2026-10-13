# Tous les logos

Ce dossier rassemble les **SVG distribués par le site** et les essais de dessin
conservés pour discussion. Les fichiers sont autonomes et téléchargeables depuis
GitHub : ouvrir le fichier, puis utiliser **Download raw file** dans sa barre
d’outils. Pour tout récupérer, le bouton **Code → Download ZIP** du dépôt inclut
ce dossier.

## Logo de référence

[ÉcoLogo original](Echologo.svg), copie exacte de la ressource d’identité
distribuée par le site. Son autorité et ses empreintes restent définies dans
[`identite.json`](../identite.json).

## Versions factorisées

| Dessin | SVG |
| --- | --- |
| ÉcoLogo | [Logo-factorise.svg](factorises/Logo-factorise.svg) |
| Audio, avec le disque central | [Audio.svg](factorises/Audio.svg) |
| Visio, avec le disque central | [Visio.svg](factorises/Visio.svg) |
| Kino, avec le disque central | [Kino.svg](factorises/Kino.svg) |
| Xiaoping — X | [X-factorise.svg](factorises/X-factorise.svg) |
| Ydris — Y | [Y-factorise.svg](factorises/Y-factorise.svg) |
| Zoé — Z | [Z-factorise.svg](factorises/Z-factorise.svg) |
| Zoé — tracés explicites | [Z.svg](factorises/Z.svg) |
| Licorne — modèle du site | [Licorne-factorisee.svg](factorises/Licorne-factorisee.svg) |

## Palette OKLCH de référence

Les mêmes dessins dans les couleurs de la palette de référence :

- [ÉcoLogo](palette/Palette-Logo.svg)
- [Audio](palette/Palette-Audio.svg), [Visio](palette/Palette-Visio.svg), [Kino](palette/Palette-Kino.svg)
- [Xiaoping](palette/Palette-X.svg), [Ydris](palette/Palette-Y.svg), [Zoé](palette/Palette-Z.svg)
- [Licorne](palette/Licorne-factorisee.svg)

Les [paramètres de palette](../public/assets/mrjam/palette/palette.json) et
[leur explication](../ateliers/logo/docs/PALETTE.md) restent à leurs emplacements
de référence.

## Essais de licorne

Ces essais ne remplacent pas le modèle du site.

### Optimisation 13 — moins d’étapes, RGB ou OKLCH

[SVG comparés, méthode et mesures](essais/optimisation-13/README.md) ·
[Comparaison visuelle](essais/optimisation-13/comparaison.png)

Le dégradé G conserve sa silhouette et son chemin `F(t²)` : 29 étapes placées
par contrôle d’erreur remplacent les 501 étapes régulières. Les écritures RGB
et OKLCH sont comparées dans Chromium et Firefox, sans adoption automatique
par le site.

### Chemins 12 — progression quadratique vers le blanc

[Essai G](essais/chemins-12/README.md) ·
[Comparaison E / F / G](essais/chemins-12/comparaison.png)

### Chemins 11 — explorer les trajets OKLCH vers le blanc

[Six dessins, explications et SVG](essais/chemins-11/README.md) ·
[Comparaison](essais/chemins-11/comparaison.png) ·
[Graphique des chemins et du gamut](essais/chemins-11/chemins-oklch.png)

Même silhouette et même teinte : comparaison du trajet direct, d’une baisse
précoce du chroma, d’un fondu retardé et de trois couleurs d’arrivée.
Le trajet linéaire vers le rose pâle est admissible ; celui vers le blanc
sort légèrement du sRGB. Un chemin courbe permet d’atteindre le blanc
sans clipping ni changement de teinte.

### Couleurs 10 — fondu vers un rose pâle, sans disparition

[SVG factorisé](essais/Licorne-rose-10.svg) ·
[Aperçu](essais/Licorne-rose-10.png)

Le dégradé oblique reprend le trajet rose vers blanc de l’essai 07, mais
s’arrête à environ 65 % du mélange sRGB : `#f06884` vers `#facad4`.
La clarté augmente et le chroma diminue ; la fin du drapé conserve une couleur
rose pâle. La silhouette factorisée, les transformations et le cadrage restent
strictement identiques. Le dégradé sRGB est entièrement représentable, sans
clipping. Masque inchangé et aperçu Chromium vérifiés.

### Couleurs 09 — comparer clarté et chroma

[Les trois dessins et SVG](essais/couleurs-09/README.md) ·
[Planche comparative](essais/couleurs-09/comparaison.png)

Trois dégradés obliques sur la forme approuvée : augmenter L à C constant,
diminuer C à L constant, puis combiner les deux variations. Même teinte et
mêmes amplitudes pour isoler les effets, sans sortir du gamut sRGB.

### Couleurs 08 — dégradé oblique, drapé visible

[SVG factorisé](essais/Licorne-rose-08.svg) ·
[Aperçu](essais/Licorne-rose-08.png)

La licorne reste rose sur fond blanc, avec uniquement le dégradé oblique retenu,
du haut à droite vers le bas à gauche. Il relie le rose `#f06884` à un rose plus
sourd `#c08094`, sans aller au blanc : la fin du drapé reste visible.
L’absence du reste du corps peut suggérer l’invisibilité de la licorne.
La silhouette factorisée approuvée de l’étude 06 est strictement inchangée ;
seule la couleur finale du dégradé de l’essai 07 a été remplacée.

### Couleurs 07 — forme approuvée, écusson et fondus

[Planche comparative](essais/couleurs-07/comparaison.png) ·
[Les cinq SVG et leurs aperçus](essais/couleurs-07/README.md)

La forme de l’étude 06 est conservée exactement, sans modification des contours,
des transformations ni des placements. Trois présentations sont comparées dans
deux colonnes : haut vers bas et haut à droite vers bas à gauche. La version
blanche unie est identique dans les deux colonnes. Le rose reste `#f06884`.

### Étude 06 — espaces et raccords

- [Licorne fractale 06 — SVG factorisé](essais/Licorne-fractale-06.svg)
- [Aperçu](essais/Licorne-fractale-06.png)
- [Comparaison des études 05 et 06](essais/Licorne-fractale-06-comparaison.png)
- [Détails avant et après : crinière, corne, museau](essais/Licorne-fractale-06-details.png)

Cinq départs de drapés sont légèrement réduits autour de leur pointe finale,
qui reste fixe. Un espace d’environ quatre pixels à la taille native sépare
désormais chaque drapé du grand contour voisin. Le couple de Visio, sa
répétition sur vingt étages et les autres mèches restent identiques à l’étude 05.

À la base de la corne, les quatre anciennes pièces de raccord sont remplacées
par le Visio suivant dans l’alternance régulière : la pièce `piece-6` est
réutilisée au rapport `1 / 0,65` autour de `(486, 20)`. L’extension s’arrête après
cet élément pour laisser un espace avec l’oreille ; les treize couples déjà
présents vers la pointe sont conservés exactement.

Le petit Audio inférieur du museau est réduit à 88 % autour de `(780, 493)`,
puis déplacé de trois pixels à gauche et huit vers le bas. Ses extrémités
ne se chevauchent plus avec les deux formes voisines ; l’ouverture blanche
est dégagée. Le contour Audio lui-même est inchangé.

Le SVG réutilise les trois contours canoniques et les mêmes motifs factorisés,
pour 406 occurrences développées. Vérifications : XML et références,
similitudes sans étirement, contours et placements non concernés identiques,
pointes fixes, espacements mesurés sur les contours échantillonnés, cadrage
et rendu à taille native et à 300 pixels de large. Aucun JPEG incorporé.

### Étude 05 — le même drapé jusqu’à la pointe

- [Licorne fractale 05 — SVG factorisé](essais/Licorne-fractale-05.svg)
- [Aperçu](essais/Licorne-fractale-05.png)
- [Comparaison des études 04 et 05](essais/Licorne-fractale-05-comparaison.png)
- [Détail du drapé : étude 04 à gauche, étude 05 à droite](essais/Licorne-fractale-05-drape.png)

La mèche choisie alterne deux Visio de sens opposés. L’étude 05 garde exactement
ces deux premières pièces et régularise leur répétition : chaque couple est
réduit au rapport **0,67** vers une même pointe. Dans les coordonnées du motif,
la transformation est `T(P) = F + 0,67 × (P − F)`, avec `F = (513, 1108)`.
Cette règle reprend le mouvement du drapé existant ; elle remplace ses derniers
placements irréguliers par une suite convergente.

Le couple est répété sur vingt étages. À la taille native de 960 × 1280,
tous les étages suivants de la suite infinie seraient à moins de 0,081 pixel
de la pointe, même dans la plus grande utilisation du motif. Aucun élément
différent ne vient fermer cette pointe.

Les **huit suites fractales de la crinière et la mèche du front** utilisent
désormais ce seul `motif-meche`, lui-même factorisé à partir de `couple-drape`.
Leurs orientations et dimensions sont adaptées par similitudes. La corne,
l’oreille, l’œil et le museau gardent leurs contours et placements de l’étude 04.

Le SVG contient toujours uniquement les trois contours canoniques Audio,
Visio et Kino ; les 409 occurrences développées proviennent de références
`<use>`. Contrôles effectués : XML et références, contours identiques,
translations/rotations/homothéties/symétries sans étirement, convergence,
cadrage et rendu à taille native et à 300 pixels de large. Aucun JPEG incorporé.

### Étude 04 — motifs de mèches et corne prolongée

- [Licorne fractale 04 — SVG factorisé](essais/Licorne-fractale-04.svg)
- [Aperçu](essais/Licorne-fractale-04.png)
- [Comparaison des études 03 et 04](essais/Licorne-fractale-04-comparaison.png)

Le motif de neuf pièces de la mèche basse est conservé à sa place et réutilisé
dans deux mèches de la crinière et sur le front. La mèche frontale remplace
l’élément pointu du front et ses deux petits voisins. Le museau et l’œil gardent
leurs placements de l’étude 03.

La corne prolonge le couple de Visio choisi à sa base sur treize étages,
par homothéties de rapport 0,65 vers la pointe commune `(486, 20)`. Les derniers
éléments deviennent inférieurs au pixel à la taille native ; aucune pièce
différente n’est ajoutée pour terminer la pointe.

Le SVG factorise aussi les deux motifs : `motif-meche` et `motif-corne` sont
réutilisés par `<use>`. Après développement des références, le dessin contient
115 occurrences des trois contours canoniques inchangés. Les transformations
restent exclusivement des translations, rotations, homothéties et symétries
axiales ; leur composition a été vérifiée. Aucun JPEG n’est incorporé.

### Étude 03 — reconstitution du dessin de référence

- [Licorne fractale 03 — SVG factorisé](essais/Licorne-fractale-03.svg)
- [Licorne fractale 03 — SVG de travail avec JPEG en calque](essais/Licorne-fractale-03-travail.svg)
- [Comparaison avec le dessin de référence](essais/Licorne-fractale-03-comparaison.png)

L’essai fractal réutilise 86 fois les trois contours Audio, Visio et Kino
inchangés, uniquement par translations, rotations, homothéties et symétries
axiales. Il reste une étude : certaines courbures diffèrent du modèle. La boucle
du museau et les bandes de l’oreille utilisent chacune deux pièces. Le JPEG de
la version de travail est dans un calque séparé et masquable ; le SVG propre
n’embarque aucune image matricielle.

## Maintenir le dossier

Les ressources canoniques du site restent dans
[`public/assets/mrjam/`](../public/assets/mrjam/). Les copies ci-dessus sont
identiques octet pour octet ; ne pas les modifier indépendamment.

Après régénération des exports de l’atelier :

```sh
python3 scripts/synchroniser-logos.py
python3 scripts/synchroniser-logos.py --check
```

Le contrôle signale les copies manquantes, différentes ou sans source. Le script
ne modifie ni les sources du site ni les essais. Les essais sont versionnés
directement dans `essais/` et doivent être présentés comme tels.

**Logo, signature et déclinaisons : utilisation strictement réservée.** La
présence publique de ces fichiers n’accorde aucun droit de reproduction,
modification, intégration, redistribution ou exploitation sans autorisation
préalable expresse du titulaire. Les licences du code et des dépendances ne
s’appliquent pas à ces éléments d’identité.
