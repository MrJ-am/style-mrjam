# Proposition de Licorne rose invisible

La proposition figure sur `palette.html`, dans la carte du huitième sommet. Elle reste distincte des sept couleurs principales et des trois tuteurs X/Y/Z.

## Lecture et composition

L’image fournie sert de repère pour le profil : une corne projetée vers l’avant, une tête inclinée et une crinière rejetée vers l’arrière. Son petit trait intérieur représente **l’angle du cou, pas un œil**. Les essais ont conduit à incliner davantage l’encolure, conserver une corne en spirale et limiter la crinière à trois mèches. La tête a été agrandie et l’encolure raccourcie : leurs longueurs de référence sont comparables (environ 13 et 11,7 unités), tout en conservant l’oblique. Aucun disque ne remplit la tête. Le visage a ensuite été simplifié : le contour supplémentaire du museau et la narine sont retirés. Seul un petit œil en creux est conservé.

Le dessin assemble exclusivement les contours canoniques du logo :

| Fonction | Élément du logo | Occurrences |
|---|---|---:|
| Oreille | Audio | 1 |
| Tête | Visio | 1 |
| Corne en spirale, tailles décroissantes | Visio | 3 |
| Crinière | Visio | 3 |
| Encolure oblique | Kino | 1 |

Soit **neuf contours : 1 audio, 7 visio, 1 kino**. Les transformations sont des translations, rotations, réflexions et homothéties. `Echo.Composition.licorne` est l’unique définition des placements ; `Echo.Render` réutilise les mêmes définitions SVG que pour le logo et les tuteurs.

Le disque canonique est réutilisé à petite échelle, uniquement pour évider l’œil (`trousLicorne`). Le masque SVG découpe réellement la silhouette : ce point devient transparent si le fond est retiré. Son rectangle blanc est un support de masque, pas une nouvelle pièce du dessin. Le disque rose de fond conserve le cadrage des autres personnages.

## Explorer la proposition

La silhouette blanche apparaît sur le rose calculé avec les paramètres L et C courants, à `h = (angleOr + 225°) modulo 360°`. « Rendre invisible » masque les pièces en conservant le fond et la couleur dans les calculs de gamut. « Révéler la licorne » les restitue. « Voir les pièces » utilise les couleurs diagnostiques existantes d’audio, visio et kino pour montrer la construction ; le fond conserve la couleur candidate. Les commandes fonctionnent au clavier et leurs états persistent pendant les réglages de palette.

Le lien SVG donne la proposition factorisée avec la paire exploratoire initiale L = 0,7 et C = 0,1. Il est produit par `Exporter.elm` à partir des mêmes placements et du même moteur que l’aperçu, puis distribué sous `public/assets/mrjam/factorises/Licorne-factorisee.svg`.

Les contrôles navigateur comparent les tracés aux définitions du logo, vérifient les similitudes, le cadrage dans le disque et la transparence de l’évidement, les commandes de visibilité et d’inspection, la synchronisation du rose et les petits écrans. La reconnaissance du profil reste une appréciation visuelle ; les tests géométriques garantissent la provenance des pièces.

**Toute utilisation du logo et de ses déclinaisons est strictement réservée.**
