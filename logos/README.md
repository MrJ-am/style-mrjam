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
