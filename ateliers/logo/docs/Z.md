# Zoé : reprise de l’ébauche de l’axe Z

Zoé est un personnage de religieuse, en lien avec Ève. Elle invite à prendre de la hauteur et incarne **conceptualiser** : relier, structurer et abstraire. Avec Xiaoping (expérimenter) et Ydris (apprendre), elle accompagne une direction complémentaire de l’apprentissage, sans imposer un ordre entre les trois axes.

Le prénom fait aussi écho au lojban **zo’e**. La [grammaire de référence, § 7.7](https://lojban.org/publications/cll/cll_v1.1_xhtml-section-chunks/section-zohe-cohe-series.html), le décrit comme un substitut pour un argument (*sumti*) laissé implicite ou non précisé. Sa valeur dépend du contexte. L’« objet abstrait absolu » est ici une image symbolique du projet, et non la définition du mot en lojban : le rapprochement avec Zoé évoque le fait de laisser les détails d’un objet de côté pour penser les relations. L’abstraction grammaticale en lojban est décrite séparément au [chapitre 11](https://lojban.org/publications/cll/cll_v1.1_xhtml-section-chunks/chapter-abstractions.html#section-syntax). Sources consultées le 7 octobre 2026.

La reprise part du [Z original retrouvé](../references/Z-original.svg), conservé sans modification. La photographie fournie permet d’identifier le personnage parmi les essais de la feuille : une tête détachée, deux bras, un corps en diagonale et un pied. Le disque isolé, les deux contours d’essai et le rectangle vert restent dans l’archive originale.

## Retouches

La silhouette conserve son mouvement et ses cinq pièces : **1 audio, 2 visio et 2 kino**. La tête en croissant est légèrement rapprochée du buste ; les épaules sont alignées sur le corps et le pied rejoint la pointe de la diagonale. Les angles sont ramenés à des degrés entiers et les cinq pièces partagent la même échelle. Les courbes du logo ne sont pas redessinées.

Le bras droit utilise une réflexion du contour visio. Le fond circulaire `#087f71` reprend l’accent de la palette MrJ.am. Le [recadrage de l’ébauche](../references/Z-reference.svg) applique seulement une translation et une réduction uniforme aux cinq tracés originaux, sur ce même fond : la comparaison de l’atelier montre ainsi les retouches de placement. Elle ne prétend pas à l’identité entre avant et après.

| Pièce | Source originale | Contour | Angle | Face |
|---|---|---|---:|---|
| Tête | path6 | audio | −54° | Directe |
| Bras gauche | path8 | visio | 163° | Directe |
| Pied | path10 | kino | −86° | Directe |
| Diagonale | path10-2 | kino | 43° | Directe |
| Bras droit | path8-2 | visio | −107° | Réfléchie |

Les pictogrammes complets audio, visio et kino associent toujours leur contour au disque de **connaissance**. La recomposition des personnages utilise les contours, comme dans les dessins X et Y.

## Sources et vérifications

`scripts/analyser-z.py` reconnaît les cinq contours de l’original avec une borne continue inférieure à 10⁻⁴, enregistre leurs mesures et les empreintes des sources dans [geometrie-Z-original.json](../donnees/geometrie-Z-original.json), puis produit le recadrage et les [placements retravaillés](../donnees/decomposition-Z.json). Ces placements distinguent le tracé original de sa fonction dans le personnage. Les translations des bras et du pied sont calculées à partir des points de raccord du corps.

`scripts/construire-z.py` produit [Z.svg](../dessins/Z.svg) avec cinq tracés explicites ; Elm produit `Z-factorise.svg` avec cinq occurrences `<use>`. La vérification des matrices et des arcs impose un écart dessin/export inférieur à 10⁻¹², contrôle les trois raccords à 10⁻⁶ et le maintien de la silhouette dans le disque. Les rendus du dessin retravaillé, de l’export et de l’animation sont comparés dans Chromium et Firefox.

La transformation démarre avec les quatre pièces du logo. Une copie de visio et une copie de kino deviennent visibles, le disque central s’efface et le bras droit se retourne. Les deux stratégies de retournement et le retour au logo sont vérifiés dans les navigateurs.

**Toute utilisation du logo et de ses déclinaisons est strictement réservée.**
