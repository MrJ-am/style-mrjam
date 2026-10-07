# Déclinaisons factorisées du logo

`Logo-factorise.svg`, `X-factorise.svg` et `Y-factorise.svg` sont des SVG autonomes produits par [l’atelier Elm](../../../../ateliers/logo/). Chacun définit une seule fois les quatre briques canoniques et les réutilise par `<use>` : quatre occurrences pour le logo, sept pour X et huit pour Y. Y comprend six placements distincts et conserve les deux doublons du fichier original.

Les contours ne sont pas redessinés. Les poses complètes sont dans `decomposition-X.json` et `decomposition-Y.json`. Les mesures sur les SVG réellement exportés figurent dans [le rapport](../../../../ateliers/logo/verification/production-geometrie.json).

Pour régénérer : construire et vérifier l’atelier, puis recopier ces cinq exports depuis `ateliers/logo/dist/exports/`. La construction GitHub Pages vérifie que les fichiers distribués correspondent aux exports Elm.

La source d’identité reste `MrJ-am/Signature`, à la révision déclarée dans `identite.json`. Le logo original `../Echologo.svg` et sa feuille de signature restent les copies de référence vérifiées.

**Toute utilisation du logo, de la signature et de leurs déclinaisons est strictement réservée.** Leur présence dans ce dépôt public ne vaut aucune autorisation de reproduction, modification, intégration, redistribution ou exploitation. Une autorisation préalable expresse de leur titulaire est nécessaire. Aucune licence du code ou d’une dépendance ne s’étend à ces éléments.
