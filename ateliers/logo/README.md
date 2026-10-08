# Atelier ÉcoLogo : Xiaoping, Ydris, Zoé et la Licorne rose invisible

Atelier Elm/ElmUI avec une chronologie Elm Animator : recomposition réversible du logo en X, Y ou Z, rotation centrifuge, comparaison des dessins, inspecteur des symétries et exports SVG. La [page de philosophie](https://mrj-am.github.io/style-mrjam/philosophie.html) relie les modalités sensorielles à la connaissance, explique les proportions et présente les trois tuteurs.

- [Ouvrir l’atelier](https://mrj-am.github.io/style-mrjam/)
- [Explorer Y](https://mrj-am.github.io/style-mrjam/?cible=Y)
- [Explorer Zoé, axe Z](https://mrj-am.github.io/style-mrjam/?cible=Z&p=1) · [Z.svg](dessins/Z.svg)
- [Fichiers factorisés versionnés](../../public/assets/mrjam/factorises/)
- [Géométrie de X](docs/GEOMETRIE.md), [géométrie de Y](docs/Y.md) et [construction de Z](docs/Z.md)
- [Validation et publication](docs/VALIDATION.md)

## Utilisation

Choisir **X · Xiaoping**, **Y · Ydris** ou **Z · Zoé**, puis lancer la lecture ou déplacer le curseur. Iels incarnent trois directions complémentaires : expérimenter, apprendre et conceptualiser. Xiaoping fait écho à XP, les points d’expérience dans les jeux : expérimenter, c’est jouer avec les objets. Ydris renvoie à la racine arabe DRS, associée à l’étude et à l’apprentissage. Zoé est un personnage de religieuse, en lien avec Ève ; elle invite à prendre de la hauteur. Son prénom fait aussi écho au lojban zo’e, qui représente un argument implicite ou non précisé ; le lien avec l’abstraction est une évocation propre au projet, [documentée et sourcée](docs/Z.md). La page de philosophie détaille la circulation entre ces axes et la place de l’abstraction. Le changement de cible revient au logo en pause. Les réglages de mouvement sont communs aux trois personnages. La rotation centrifuge porte sur le logo original.

Le centre est nommé **connaissance**, pour sa dimension sémantique. **Audio**, **visio** et **kino** sont des pictogrammes complets : **disque central + contour**. Leur extraction est visible dans les deux pages et téléchargeable dans Géométrie. Les trois contours du logo complet partagent un seul disque ; les pièces géométriques ne doivent pas être confondues avec les pictogrammes. Les identifiants historiques `auditif`, `visuel` et `kinesthesique` des poses X/Y restent stables pour permettre les comparaisons.

L’onglet Géométrie permet de comparer l’original et la factorisation, sélectionner ou masquer une occurrence, isoler une brique et examiner sa réflexion. Le retournement en relief et le fondu local aboutissent aux mêmes poses. Les deux doublons de Y restent inspectables séparément et conservent l’ordre de dessin original.

Les fichiers JSON enregistrent les réglages de mouvement, indépendamment de la cible choisie. Le téléchargement de la scène fige son état courant ; les exports Logo, X, Y et Z donnent les compositions statiques complètes. `Audio.svg`, `Visio.svg` et `Kino.svg` incluent chacun le disque de connaissance. `Z.svg` contient cinq tracés explicites ; `Z-factorise.svg` réutilise les contours par `<use>`.

Aucune lecture automatique. `prefers-reduced-motion` sélectionne le fondu local. Le clavier, les pauses, les inversions et l’absence de rattrapage après masquage sont contrôlés.

Paramètres d’ouverture : `?cible=Z&p=1`, `?vue=geometrie&cible=Y&miroir=0.5`, `?vue=rotation&p=0.5` et `?strategie=fondu`.

## Explorer la palette OKLCH

[Palette interactive](https://mrj-am.github.io/style-mrjam/palette.html) : la référence définitive est **L ≈ 0,742201739 ; C ≈ 0,132555344**, au maximum du chroma commun aux huit teintes sRGB. Ydris et Zoé imposent ensemble cette limite. Les sept dessins principaux et la [Licorne retenue](docs/LICORNE.md) utilisent le même moteur. L’exploration et les URL restent disponibles ; JSON, CSS et SVG donnent la palette de référence. Voir [les formules, le choix et les tests](docs/PALETTE.md). La philosophie explique ÉcoLogo, le « quatre caché dans le trois », les proportions et les analogies.

## Construction et vérification

Depuis ce dossier, avec Node.js 24, Python 3 et les navigateurs Playwright :

```sh
npm ci
python3 -m pip install -r requirements-verification.txt
npx playwright install --with-deps chromium firefox
python3 scripts/analyser-y.py
python3 scripts/analyser-z.py
python3 scripts/construire-z.py
python3 scripts/generate-data.py
npx elm-format src/Echo/ReferenceData.elm --yes
npm run build
npm run format:check
npm test -- --seed 20261007
npm run test:reference
npm run test:geometry
npm run test:browser
npm run test:raster
npm run dev
```

`dist/` contient trois pages autonomes (`index.html`, `philosophie.html`, `palette.html`), une copie téléchargeable `atelier-logo.html` et `exports/`. Les pages emploient des liens relatifs et fonctionnent sous le préfixe GitHub Pages `/style-mrjam/`. Les références SVG et les licences des dépendances sont embarquées ; aucune fonte réservée ni requête tierce n’est nécessaire à l’atelier.

Depuis la racine, `npm run compiler:pages` assemble les trois pages et leurs exports dans `.pages/`. Le workflow `pages.yml` exécute les contrôles avant de publier l’artefact sur GitHub Pages. Les vérifications d’une pull request ne publient pas le site.

## Organisation

- `src/Echo/Primitives.elm` : les quatre définitions canoniques ; trois contours et un disque.
- `Composition.elm`, `Transform.elm` : occurrences, poses et matrices.
- `Animation.elm`, `Player.elm` : scène pure et chronologie suspendable.
- `Render.elm`, `Exporter.elm` : même géométrie pour la scène et les SVG exportés.
- `src/Shared/Ui.elm` : adaptation aux composants existants `MrJam` et `MrJam.Disposition`. Le curseur natif évite les annonces `aria-live` à chaque frame.
- `scripts/analyser-y.py`, `analyser-z.py`, `construire-z.py`, `generate-data.py` : reconnaissance des sources, reprise de Z et génération des données Elm.
- `references/` : originaux et outils de mesure, dont l’ébauche Z intacte et son recadrage ; `donnees/` : poses et rapports ; `dessins/Z.svg` : reprise de Zoé. Voir [les retouches et leur provenance](docs/Z.md).

Les contours du logo fourni sont identiques à ceux du logo de Signature épinglé dans `../../identite.json`, vérification incluse. Les nouveaux fichiers sont des déclinaisons explicites ; ils ne remplacent pas le logo original distribué par la bibliothèque.

**Logo, signature et déclinaisons : toute utilisation est strictement réservée.** Leur publication n’accorde aucun droit de reproduction, modification, intégration ou redistribution. Les licences des dépendances dans `docs/third-party-licenses.json` ne s’étendent pas à l’identité.
