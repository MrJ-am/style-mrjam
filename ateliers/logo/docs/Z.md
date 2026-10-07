# Zoé : construction de l’axe Z

Xiaoyu (X), Ydriss (Y) et Zoé (Z) sont trois tuteurs, chacun faisant travailler l’élève dans une direction. La silhouette reprend l’initiale du prénom et la lettre de l’axe.

Contrairement à X et Y, aucun dessin Z antérieur n’a été fourni. Zoé est une nouvelle composition : une ligne de bras, un corps en diagonale et une ligne de jambes forment un Z. Deux petits contours complètent la tête en haut à droite. Sa couleur `#087f71` est l’accent déjà présent dans la palette MrJ.am.

Les cinq tracés réutilisent exactement les contours du logo. Aucun point de leurs arcs n’est redessiné. Les pictogrammes complets audio, visio et kino associent leur contour au disque central de **connaissance** ; la recomposition des personnages utilise les contours, comme les X et Y fournis.

| Tracé | Contour | Translation | Angle | Échelle | Face |
|---|---|---|---:|---:|---|
| bras | kino | (22 ; 8) | 90° | 0,9 | Directe |
| diagonale | kino | (22 ; 9) | 50° | 0,9 | Directe |
| jambes | kino | (6 ; 23) | −90° | 0,9 | Directe |
| tete-visio | visio | (22 ; 8) | −105° | 0,4 | Directe |
| tete-audio | audio | (22 ; 8) | 100° | 0,7 | Directe |

La formule est `T(p) = translation + échelle × R(angle) × p`, après centrage des contours sur O=(13,8 ; 9). Les poses sont définies dans [decomposition-Z.json](../donnees/decomposition-Z.json). Ce sont des choix de dessin, pas des mesures obtenues en ajustant un fichier historique.

`scripts/construire-z.py` produit [Z.svg](../dessins/Z.svg) avec cinq tracés explicites. Le module Elm `Exporter` produit `Z-factorise.svg` avec cinq occurrences `<use>`. La vérification indépendante des matrices et des arcs impose un écart inférieur à 10⁻¹² et contrôle que les contours restent dans le disque de fond. Les rendus du dessin, de l’export et de l’animation sont comparés dans Chromium et Firefox.

La transformation démarre avec les quatre pièces du logo : une connaissance et un contour de chaque modalité. Deux copies de kino deviennent visibles, le disque central s’efface et les cinq contours prennent leur pose finale. La tête se lit alors dans l’espace entre les courbes. Le même calcul de scène sert à l’aller et au retour, sans lecture automatique.

**Toute utilisation du logo et de ses déclinaisons est strictement réservée.**
