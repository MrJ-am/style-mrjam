# Atelier du logo Écho : X et Y

Atelier Elm/ElmUI avec une chronologie Elm Animator : recomposition réversible du logo en X ou Y, rotation centrifuge, comparaison aux originaux, inspecteur des symétries et exports SVG. La [page de philosophie](https://mrj-am.github.io/style-mrjam/philosophie.html) présente l’intention symbolique, les quatre briques et leurs proportions.

- [Ouvrir l’atelier](https://mrj-am.github.io/style-mrjam/)
- [Explorer Y](https://mrj-am.github.io/style-mrjam/?cible=Y)
- [Fichiers factorisés versionnés](../../public/assets/mrjam/factorises/)
- [Géométrie de X](docs/GEOMETRIE.md) et [géométrie de Y](docs/Y.md)
- [Validation et publication](docs/VALIDATION.md)

## Utilisation

Choisir **Personnage X** ou **Personnage Y**, puis lancer la lecture ou déplacer le curseur. Le changement de cible revient au logo en pause. Les réglages de mouvement sont communs aux deux personnages. La rotation centrifuge porte sur le logo original.

L’onglet Géométrie permet de comparer l’original et la factorisation, sélectionner ou masquer une occurrence, isoler une brique et examiner sa réflexion. Le retournement en relief et le fondu local aboutissent aux mêmes poses. Les deux doublons de Y restent inspectables séparément et conservent l’ordre de dessin original.

Les fichiers JSON enregistrent les réglages de mouvement, indépendamment de la cible choisie. Le téléchargement de la scène fige son état courant ; les exports Logo, X et Y donnent les compositions statiques complètes.

Aucune lecture automatique. `prefers-reduced-motion` sélectionne le fondu local. Le clavier, les pauses, les inversions et l’absence de rattrapage après masquage sont contrôlés.

Paramètres d’ouverture : `?cible=Y&p=1`, `?vue=geometrie&cible=Y&miroir=0.5`, `?vue=rotation&p=0.5` et `?strategie=fondu`.

## Construction et vérification

Depuis ce dossier, avec Node.js 24, Python 3 et les navigateurs Playwright :

```sh
npm ci
python3 -m pip install -r requirements-verification.txt
npx playwright install --with-deps chromium firefox
npm run build
npm run format:check
npm test -- --seed 20261007
npm run test:reference
npm run test:geometry
npm run test:browser
npm run test:raster
npm run dev
```

`dist/` contient deux pages autonomes (`index.html`, `philosophie.html`), une copie téléchargeable `atelier-logo.html` et `exports/`. Les pages emploient des liens relatifs et fonctionnent sous le préfixe GitHub Pages `/style-mrjam/`. Les références SVG et les licences des dépendances sont embarquées ; aucune fonte réservée ni requête tierce n’est nécessaire à l’atelier.

Depuis la racine, `npm run compiler:pages` assemble les deux pages et leurs exports dans `.pages/`. Le workflow `pages.yml` exécute les contrôles avant de publier l’artefact sur GitHub Pages. Les vérifications d’une pull request ne publient pas le site.

## Organisation

- `src/Echo/Primitives.elm` : les quatre définitions canoniques ; trois contours et un disque.
- `Composition.elm`, `Transform.elm` : occurrences, poses et matrices.
- `Animation.elm`, `Player.elm` : scène pure et chronologie suspendable.
- `Render.elm`, `Exporter.elm` : même géométrie pour la scène et les SVG exportés.
- `src/Shared/Ui.elm` : adaptation aux composants existants `MrJam` et `MrJam.Disposition`. Le curseur natif évite les annonces `aria-live` à chaque frame.
- `scripts/analyser-y.py`, `generate-data.py` : reconnaissance des arcs et génération des données Elm.
- `references/` : originaux et outils de mesure ; `donnees/` : poses et rapport Y.

Les contours du logo fourni sont identiques à ceux du logo de Signature épinglé dans `../../identite.json`, vérification incluse. Les nouveaux fichiers sont des déclinaisons explicites ; ils ne remplacent pas le logo original distribué par la bibliothèque.

**Logo, signature et déclinaisons : toute utilisation est strictement réservée.** Leur publication n’accorde aucun droit de reproduction, modification, intégration ou redistribution. Les licences des dépendances dans `docs/third-party-licenses.json` ne s’étendent pas à l’identité.
