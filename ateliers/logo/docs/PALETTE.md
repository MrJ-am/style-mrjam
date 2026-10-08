# Explorateur OKLCH Mister Jam

Route : [`palette.html`](https://mrj-am.github.io/style-mrjam/palette.html). Les paramètres `L` et `C` sont inscrits dans l’URL sans arrondi ; les autres paramètres et le fragment sont conservés. La page et ses assets sont autonomes, comme l’atelier du logo. La page s’ouvre sur la **palette ÉcoLogo de référence**, choisie au maximum du chroma commun aux huit teintes. Les variantes restent explorables et partageables par URL. Les dessins de la page de philosophie et les nouveaux exports utilisent cette référence ; les sources historiques de Signature et les thèmes des applications épinglées gardent leurs versions existantes.

## Architecture et réemploi

- `src/Palette/Couleurs.elm` : module pur, seule définition des rôles, des angles, des conversions, du gamut et de la sérialisation. Les consommateurs utilisent les rôles `Logo`, `Audio`, `Visio`, `Kino`, `Xiaoping`, `Ydris`, `Zoe`, `Licorne`, ou leurs clés sémantiques.
- `src/Palette.elm` : programme Elm/ElmUI, cartes et champs MrJam, plan L × C, plan OKLab a,b, état local et ports. `Echo.Composition`, `Echo.Animation.static` et `Echo.Render` fournissent les dessins, y compris les disques centraux des pictogrammes. Aucun tracé SVG n’est recopié.
- `web/palette.js` : pont technique Pointer Events avec capture du pointeur, regroupement par animation frame et `history.replaceState`. La colorimétrie et la projection sont entièrement dans Elm. Aucun serveur ni stockage persistant.
- `scripts/build.mjs` et le constructeur Pages de la racine compilent, embarquent et publient la page avec le même template, les mêmes styles et le même manifeste que l’atelier. La navigation des deux pages existantes donne accès à la palette.

Aucune dépendance ajoutée. `avh4/elm-color`, déjà présent indirectement, ne fournit pas ces conversions OKLab. Les matrices D65 viennent de [Björn Ottosson](https://bottosson.github.io/posts/oklab/) ; le transfert sRGB suit [CSS Color 4](https://www.w3.org/TR/css-color-4/#color-conversion-code). Les formules numériques restent centralisées et couvertes par les tests Elm.

## Rôles et géométrie

`φ = (1 + √5) / 2`, `angleOr = 360 / φ²`, `h(n) = (angleOr + 45n) modulo 360`. L’indice, et non une couleur indépendante, définit chaque rôle. Une seule paire L,C est transmise aux huit sommets. Le plan a,b utilise `(C cos h, C sin h)` avec une même échelle sur les deux axes ; les carrés sont réellement carrés. Les labels restent sur un cercle fixe pour demeurer lisibles lorsque C tend vers zéro.

| n | Rôle | Angle approximatif | Tétrade |
|---:|---|---:|---:|
| 0 | Logo | 137,507764° | 1 |
| 1 | Ydris | 182,507764° | 2 |
| 2 | Visio | 227,507764° | 1 |
| 3 | Zoé | 272,507764° | 2 |
| 4 | Kino | 317,507764° | 1 |
| 5 | Licorne rose invisible | 2,507764° | 2 |
| 6 | Audio | 47,507764° | 1 |
| 7 | Xiaoping | 92,507764° | 2 |

Les couleurs diagnostiques existantes de `Echo.Primitives` sont Audio orangé `#ffca91`, Visio bleu `#9ed8fa`, Kino mauve `#e8b8ed`. Cette sémantique détermine l’affectation des trois sommets de la première tétrade. Les associations des personnages suivent la demande. La Licorne participe aux calculs et au diagramme mais sa carte indique explicitement qu’elle est exclue des sept couleurs principales ; son dessin retenu réutilise exclusivement les contours du logo, sans en faire un quatrième tuteur. Voir [la composition de la Licorne](LICORNE.md).

Le logo historique `#64c29b`, conservé comme repère fixe, est converti par le même module : environ `oklch(0.74536012 0.10726360 164.559056°)`.

## Référence retenue : maximiser le chroma commun

Le choix est `argmax_L min_h Cmax(L,h)`, pour les huit teintes :

- **L = 0.742201739040462** ;
- **C = 0.13255534432579458**.

À la précision numérique des matrices, **Ydris et Zoé sont simultanément limitants** : le rouge linéaire d’Ydris atteint 0 et le bleu linéaire de Zoé atteint 1. La Licorne reste incluse dans le minimum, même si elle n’est pas limitante à cette clarté. L’allure presque triangulaire du domaine n’est pas une hypothèse de calcul.

`Palette.Couleurs.reference` utilise les 513 clartés mises en cache pour repérer tous les sommets locaux de cette enveloppe fixe. Chaque intervalle candidat est affiné par **64 itérations de recherche ternaire** sur la véritable fonction `cmaxCommun`, puis les candidats sont comparés. Le C final est recalculé à son L exact avec la dichotomie admissible. Les tests contrôlent les huit couleurs, les deux canaux actifs, les voisins immédiats et une grille indépendante de 4097 clartés. L’optimisation est évaluée une fois, pas à chaque mouvement.

La table n’est donc ni une palette de constantes indépendantes, ni l’approximation du maximum par le meilleur pixel du tracé. La référence et les couleurs continuent d’être dérivées du même moteur. Les dernières décimales peuvent varier d’un arrondi flottant entre moteurs JavaScript ; le critère et le gamut restent identiques.

| Rôle | sRGB hex, arrondi à 8 bits |
|---|---|
| Logo | `#81bf6a` |
| Audio | `#ef905e` |
| Visio | `#30bbec` |
| Kino | `#ce90e2` |
| Xiaoping | `#c9a837` |
| Ydris | `#00c6b3` |
| Zoé | `#8fa5ff` |
| Licorne rose invisible, sommet annexe | `#f086a4` |

`Palette.Exports` produit `exports/palette.json`, `exports/palette.css`, les sept `Palette-*.svg` et `Licorne-factorisee.svg`. Le manifeste conserve L, C, les angles, les rôles et les valeurs complètes. Le CSS expose des noms sémantiques dérivés de `--palette-l` et `--palette-c`. Les SVG portent des pourcentages sRGB non arrondis, utilisables par les éditeurs vectoriels ; les hex ne remplacent jamais la définition OKLCH. Les fichiers sont distribués dans `public/assets/mrjam/palette/`, la Licorne également dans `factorises/`. Le constructeur Pages vérifie leur concordance avec les exports Elm.

## ÉcoLogo : les correspondances

L’angle d’or fait écho à Fibonacci : le rapport de deux termes consécutifs tend vers le nombre d’or φ, et l’angle vaut 360°/φ². Les rayons du logo utilisent déjà plusieurs nombres de cette suite. Ce choix d’orientation de la palette est explicite ; il ne prétend pas que les courbes du logo sont des spirales d’or.

Les harmonies sont **tétradiques** : deux carrés dans le plan a,b, pas des tétraèdres. Chacune rassemble trois couleurs et un quatrième terme : les modalités avec le logo ; les trois tuteurs avec la Licorne. Cette organisation reprend le « quatre caché dans le trois » : les branches sont réparties autour du centre, mais leurs orientations passent d’audio à visio puis à kino par quarts de tour.

La quatrième proportionnelle (`2 : 3 = 4 : 6`) donne une image concrète du terme à chercher. L’analogie rapproche deux relations (`A : B :: C : D`) ; elle invite à construire une hypothèse et à vérifier ses limites. **ÉcoLogo** nomme l’étude des échos, des correspondances et des analogies, avec le logos et la logique au cœur de l’enseignement. La [page de philosophie](https://mrj-am.github.io/style-mrjam/philosophie.html) relie cette idée aux trois directions complémentaires expérimenter, apprendre et conceptualiser.

## Domaine commun sRGB

À L,h fixés, le moteur convertit OKLCH en OKLab, puis en sRGB linéaire. Il exige que les trois canaux soient finis et compris dans `[0,1]`. Il recherche une borne invalide en doublant le chroma, puis effectue **44 dichotomies**, en conservant toujours la borne inférieure valide. Le minimum des huit limites donne `CmaxCommon(L)`, Licorne comprise. Aux deux extrémités L=0 et L=1, la limite est C=0.

La sélection est projetée en conservant L (borné à `[0,1]`) et en ramenant C dans `[0,CmaxCommon(L)]`. Le calcul se fait à chaque clarté sélectionnée ; aucun canal RGB n’est tronqué et aucune teinte n’est ajustée isolément. `hex` renvoie une absence de valeur pour une couleur hors gamut. Le calcul utilise les flottants double précision d’Elm/JavaScript, avec les coefficients publiés des matrices.

Les huit frontières individuelles sont échantillonnées à **513 clartés**, une seule fois ; leur minimum fournit la neuvième frontière. Les polylignes sont mises en cache, indépendamment des interactions. Le plan C,L couvre le maximum des huit courbes avec 5 % de marge. Le diagramme a,b conserve son échelle propre. La région verte à gauche de l’enveloppe sombre est sélectionnable ; le reste du rectangle ne l’est pas. Aucune limite Display-P3 n’est ajoutée.

Chaque courbe porte sa propre teinte, un motif de trait distinct et une légende sélectionnable. Les couleurs de repère utilisent une paire commune fixe, L = 0,52 et C = min(0,14, CmaxCommon(0,52)), pour rester visibles même lorsque la palette candidate est achromatique. Cette annotation ne modifie pas les couleurs candidates. L’enveloppe commune est sombre, pointillée et bordée de blanc.

À chaque L sélectionné, les huit limites exactes sont recalculées, sans interpolation du tracé. Toutes les teintes à moins de **10⁻⁹** du minimum sont indiquées comme limitantes, y compris les huit aux extrémités. L’affichage numérique utilise neuf décimales. L’allure parfois presque triangulaire de l’enveloppe découle du gamut réel : aucune contrainte triangulaire n’est appliquée.

Les aperçus utilisent `oklch()` avec les flottants complets. Les valeurs sRGB affichées sont encodées sur `[0,1]` ; les hexadécimaux sont quantifiés à 8 bits, et ne remplacent pas la définition mathématique.

## Interaction et accessibilité

Glisser à la souris ou au toucher déplace le point en continu, même lors d’une sortie du plan grâce à la capture du pointeur. Le relâchement et l’annulation terminent le geste. Le plan est focalisable : les flèches modifient L ou C par pas de 0,001 ; Maj augmente le pas à 0,01. Les changements au clavier sont annoncés. Deux champs libellés acceptent point ou virgule, avec validation par Entrée ou par le bouton commun. Les erreurs et les projections sont indiquées.

Les pages sont vérifiées à 320, 375, 768 et 1440 px. L’URL conserve exactement les valeurs sélectionnées ; aucune succession d’entrées d’historique n’est ajoutée pendant un geste. La page réagit aussi à `popstate`.

## Vérification

`tests/PaletteTest.elm` vérifie angle d’or, octogone, carrés, rôles, paramètres communs, gamut et frontière, projection, noir/blanc, transfert sRGB, référence rouge et aller-retour URL exact. `browser-tests/palette.spec.cjs` contrôle les vrais SVG, la souris en continu, la capture, le clavier, les saisies, les valeurs extrêmes, les liens entre pages et le cadrage. Le glissement tactile natif est injecté via CDP dans Chromium ; ce contrôle précis est ignoré dans Firefox, où les autres interactions sont couvertes.

Les suites existantes de l’atelier, de la géométrie, des rasters et de la bibliothèque sont conservées. Les captures sont des artefacts de validation, pas des sources graphiques dupliquées. Le choix définitif porte sur les couleurs d’identité ; les contrastes de texte et de commandes restent à vérifier pour chaque usage applicatif. Le blanc du dégradé de la Licorne est un traitement du dessin, pas un neuvième rôle de palette.
