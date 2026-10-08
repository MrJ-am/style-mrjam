# Licorne rose invisible — modèle retenu

La composition approuvée apparaît dans la galerie Géométrie de l’atelier, sur `philosophie.html#licorne` et dans la carte du huitième sommet de `palette.html`. Elle complète le carré des personnages sans devenir un quatrième tuteur ni une huitième couleur principale.

## Forme, factorisation et dégradé

Le modèle garde le **museau très long**, la crinière proche du visage, deux mèches basses et la corne en cinq segments séparés. Le grand poitrail et les mèches isolées en haut à gauche ont été retirés lors des essais approuvés.

| Fonction | Audio | Visio | Kino |
|---|---:|---:|---:|
| Crinière | 0 | 1 | 5 |
| Oreilles | 0 | 1 | 1 |
| Corne | 4 | 1 | 0 |
| Œil | 1 | 0 | 0 |
| Mâchoire, front, chanfrein, joue, museau | 1 | 1 | 3 |
| **Total : 19 occurrences** | **6** | **4** | **9** |

Chaque contour est défini **une seule fois** et réutilisé par `<use>` avec translation, rotation, réflexion et homothétie uniforme. Aucun contour n’est redessiné ni déformé indépendamment suivant x et y. Le museau réutilise Audio et ses arcs intérieurs. Le fond est un disque ; aucun disque ne remplit la silhouette.

Le modèle accepté est conservé dans `references/licorne/modele-valide.svg`. `scripts/importer-licorne.py` normalise tout son cadrage vers `0 0 30 30` par une unique homothétie et génère `Echo.Licorne.placements` ; il conserve les 19 transformations et les deux extrémités du dégradé. `--check` vérifie la concordance sans écrire. Les contours restent dans `Echo.Primitives`, communs au logo, à X/Y/Z et à la Licorne.

Le disque rose reste uni. **Un seul champ de dégradé continu**, blanc vers la pointe de la corne et rose vers le bas gauche de la crinière, est révélé par un masque réunissant les 19 occurrences blanches. Le rectangle du champ et le masque sont des supports de rendu, pas de nouvelles pièces du dessin. Le dégradé n’est jamais appliqué séparément à chaque `<use>` : il ne tourne pas et ne redémarre pas avec les pièces. Son rose est exactement celui du disque courant ; l’interpolation est explicitement sRGB.

`Echo.Render` fournit ce même rendu au site et à l’export factorisé. Le téléchargement utilise la [palette définitive](PALETTE.md), avec le rose à `h = (angleOr + 225°) modulo 360°`, soit environ 2,507764°. Le vieux rose du fichier de référence sert uniquement à conserver l’essai accepté ; sa géométrie est inchangée dans le rendu actuel.

## Sens et sources

La Licorne rose invisible est une divinité fictive de religion parodique, popularisée dans les milieux sceptiques d’Internet au début des années 1990. L’association de la couleur rose à l’invisibilité sert à discuter les affirmations invérifiables et la charge de la preuve. Ne pas pouvoir réfuter une existence ne suffit pas à la prouver. Dans ÉcoLogo, elle ouvre cette discussion sur les analogies, les hypothèses et la logique.

Sources consultées le 8 octobre 2026 :

- [Wikipédia en français — Licorne rose invisible](https://fr.wikipedia.org/wiki/Licorne_rose_invisible).
- [Wikipédia en anglais — Invisible Pink Unicorn](https://en.wikipedia.org/wiki/Invisible_Pink_Unicorn), pour recouper l’origine sur Usenet et l’usage satirique.

Aucun site officiel actif n’a pu être vérifié. Les anciennes adresses citées par les articles ne justifient pas cette qualification : `theinvisiblepinkunicorn.com` affiche une page de domaine susceptible d’être vendu ; `invisiblepinkunicorn.com/Home/About` et `pinkunicorn.net` renvoient HTTP 403 lors de la consultation. Le site de l’atelier renvoie donc à l’article encyclopédique, sans recommander ces domaines.

## Vérifications et usage de la page

« Rendre invisible » masque les pièces, mais conserve le fond et le huitième rôle dans le calcul du gamut. « Voir les pièces » désactive le dégradé et distingue les trois familles avec les couleurs diagnostiques de l’atelier. Les commandes restent accessibles au clavier et se conservent pendant l’exploration de L et C.

Les contrôles comparent les contours canoniques, les 19 transformations, le cadrage et le dégradé au modèle accepté. Une comparaison raster dans Chromium et Firefox vérifie le SVG exporté face à la source approuvée recolorée avec la référence actuelle. Les tests couvrent aussi le masque global, les commandes, la recoloration et les petits écrans.

**Toute utilisation du logo et de ses déclinaisons est strictement réservée.**
