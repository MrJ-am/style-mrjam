# Intégration et francisation

## Contrat de consommation

Chaque application déclare une révision exacte de `MrJ-am/style-mrjam`. Le système de construction récupère cette révision, sans réécrire les modules communs, et fournit son répertoire `src` au compilateur. Les dépendances Elm sont résolues dans le `elm.json` de l’application : `mdgriffith/elm-ui` 1.1.8 est la version validée pour cette préparation.

Les ressources d’identité sont servies localement sous `assets/mrjam/`, relativement à la base de l’application. Vérifier ce contrat sous `/matheval/`, sur un sous-domaine et avec toute route profonde. Une application à routage par chemins peut devoir fournir une base HTML explicite ; ne pas modifier les routes existantes pour contourner le problème.

## Inventaire identifié

- **Mémoire / Matheval** : questionnaire, prototype et administration publiés le 21 septembre 2026 avec `553e5a85fc28d09ab2d034401c6cb912ef97320d`. Les quatre points d’entrée sont `docs/src/Main.elm`, `Survey.elm`, `Administration.elm` et `DemoCard.elm`. Les styles locaux restants concernent le texte mathématique, la scène, les curseurs et leurs ponts géométriques. Les contrats de collecte et le serveur sont conservés. Voir [le relevé applicatif](https://github.com/MrJ-am/M-moire/blob/master/docs/PORTAGE-ELMUI.md).
- **Vision** : interface ElmUI dans `interface/`, publiée le 21 septembre 2026 avec `c7b4d6e00cd0014a0a05e5a4e77627357498faa9`. Le candidat documentaire du 26 septembre retire les fichiers HTML/CSS/JavaScript historiques de `docs/` et porte les pages publiques en ElmUI ; il ne revendique aucune nouvelle publication. Le serveur Common Lisp est conservé. Préserver sessions, pagination serveur, filtres, tri stable, édition, conflits HTTP 409, journaux et archivage réversible.
- **Apprendre à démontrer** : `src/Main.elm`, `public/style.css`, les intégrations `bridge.js` et `video.js`. Conserver le correcteur, les identifiants pédagogiques, KaTeX, les vidéos et la navigation.

Les trois projets partagent notamment l’accent `#087f71`, l’encre `#193d38` et des surfaces claires. Les styles métier ne se réduisent cependant pas à cette palette : tableaux, aide, comparaison, espaces mathématiques et navigation doivent être inventoriés écran par écran.

## Point particulier de Mémoire

`docs/scripts/build-elm.cjs` prépare dans un atelier Linux temporaire les sources de l’application et la révision vérifiée de la bibliothèque. Il compile **Main, Survey, Administration et DemoCard** avant de recopier les sorties, puis installe les ressources d’identité et leurs manifestes. Les JavaScript et copies d’identité sont générés, sans duplication manuelle de sources communes. Garder ce fonctionnement pour le stockage partagé Android.

## Renommer sans perdre la traçabilité

1. Conserver une référence compilable, noter son commit et ses tests.
2. Pour un seul symbole, relever déclaration, usages et exportations dans tous les fichiers concernés. Distinguer le nom interne des chaînes échangées avec JavaScript, JSON, SQL, stockage local ou les API.
3. Renommer ce symbole et tous ses usages contrôlés, sans modifier les autres symboles.
4. Compiler tous les points d’entrée consommateurs. En cas d’échec, corriger ou annuler uniquement ce renommage avant de poursuivre.
5. Exécuter les tests de contrat et d’interaction pertinents. Le compilateur Elm ne vérifie pas la correspondance des noms de ports avec JavaScript, ni les clés JSON attendues par un serveur.
6. Consigner la vérification ; procéder au symbole suivant.

Les identifiants éditoriaux, les données déjà collectées, les migrations historiques et les protocoles externes ne sont pas des noms locaux à traduire librement. Leur éventuelle francisation exige une migration compatible et coordonnée, distincte du simple renommage de variables.

## Critère de migration terminée

Un simple `Element.html` autour de l’ancienne page HTML ne constitue pas une migration ElmUI. Les contrôles usuels doivent appeler les composants partagés ; les styles ordinaires dupliqués sont retirés seulement lorsque toutes leurs vues sont portées et testées. Les ponts spécialisés, comme KaTeX, restent documentés et versionnés localement.
