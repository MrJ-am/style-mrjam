# Déclinaisons factorisées du logo

Les SVG autonomes sont produits par [l’atelier Elm](../../../../ateliers/logo/). Chacun définit une seule fois les contours canoniques et le disque de connaissance, puis réutilise les pièces nécessaires par `<use>`.

| Fichier | Composition |
|---|---|
| `Logo-factorise.svg` | Un disque de connaissance et les trois contours |
| `Audio.svg` | Disque de connaissance + contour audio |
| `Visio.svg` | Disque de connaissance + contour visio |
| `Kino.svg` | Disque de connaissance + contour kino |
| `X-factorise.svg` | Xiaoyu, sept occurrences de contours |
| `Y-factorise.svg` | Ydriss, huit occurrences dont deux doublons historiques |
| `Z-factorise.svg` | Zoé, cinq occurrences de contours |
| `Z.svg` | Même Zoé, cinq tracés explicites |

Les contours ne sont pas redessinés. Les poses complètes sont dans `decomposition-X.json`, `decomposition-Y.json` et `decomposition-Z.json`. Les contrôles sur les SVG réellement exportés figurent dans [le rapport](../../../../ateliers/logo/verification/production-geometrie.json). Z est une création, décrite dans [sa construction](../../../../ateliers/logo/docs/Z.md).

Pour régénérer : construire Z et les données Elm, construire et vérifier l’atelier, puis recopier les huit SVG et les trois décompositions depuis `ateliers/logo/dist/exports/`. La construction GitHub Pages vérifie que tous les fichiers distribués correspondent aux exports contrôlés.

La source d’identité reste `MrJ-am/Signature`, à la révision déclarée dans `identite.json`. Le logo original `../Echologo.svg` et sa feuille de signature restent les copies de référence vérifiées.

**Toute utilisation du logo, de la signature et de leurs déclinaisons est strictement réservée.** Leur présence dans ce dépôt public ne vaut aucune autorisation de reproduction, modification, intégration, redistribution ou exploitation. Une autorisation préalable expresse de leur titulaire est nécessaire. Aucune licence du code ou d’une dépendance ne s’étend à ces éléments.
