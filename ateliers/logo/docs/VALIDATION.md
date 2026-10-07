# Validation de l’atelier X/Y/Z

Vérifications locales du 7 octobre 2026 : Elm 0.19.1, ElmUI 1.1.8, Elm Animator 2.0.0, Node.js 24.19.0 et Playwright 1.61.0. Les versions npm et Elm sont verrouillées.

- Bibliothèque : format, empreintes de Signature, compilation des deux points d’entrée existants et trois contrôles d’architecture réussis.
- Atelier : compilation optimisée de Main, Philosophie et Exporter ; 61 tests Elm réussis (100 tirages, graine 20261007) ; 21 tests Python du kit réussis.
- Navigateurs : 69 parcours dans Chromium 151 et Firefox 151, un contrôle `file:` non exécuté dans Chromium en raison de la politique du navigateur géré. L’ouverture directe est vérifiée dans Firefox ; les deux navigateurs couvrent la version HTTP.
- Quatre largeurs : 320, 375, 768 et 1440 px. Navigation entre pages, contrôles clavier, interaction tactile simulée, préférence de mouvement réduit, absence de débordement, pause/reprise/inversion et exports vérifiés.
- Pictogrammes : le disque de connaissance est rendu avec son contour dans les deux pages et dans chacun des trois SVG téléchargés. Les libellés audio, visio et kino et les noms des tuteurs sont présents.
- Z : ébauche originale conservée et téléchargeable, comparaison avant/après, bras droit réfléchi, cinq poses terminales, retour exact au logo, deux stratégies, export de scène, sélection des placements et cadrage de toutes les étapes contrôlés. Les boutons suivent le contrat commun d’actions compactes, nominal 34 px ; leur position reste dans l’écran à 320 et 1440 px.

La CI Linux a aussi révélé un pied de page trop large à 320 px avec DejaVu Sans. Son texte dispose maintenant d’une largeur bornée et peut passer à la ligne ; les parcours à 320 px imposent cette fonte de repli pour couvrir le défaut.

La première comparaison textuelle de l’export Y détectait une différence du dernier bit de `Math.cos` entre moteurs JavaScript. Le contrôle compare désormais les matrices avec une tolérance de 10⁻¹², en exigeant l’identité du reste du SVG. Le seuil géométrique des arcs reste 10⁻⁴.

## Géométrie effectivement exportée

| Composition | Occurrences | Erreur échantillonnée maximale | Borne continue maximale |
|---|---:|---:|---:|
| Logo | 4 | 0 | Identité des poses canoniques |
| X | 7 | 1,336621426 × 10⁻⁵ | 5,101079886 × 10⁻⁵ |
| Y | 8, dont deux doublons | 1,946025574 × 10⁻⁵ | 7,373726994 × 10⁻⁵ |
| Z | 5 | Comparaison dessin/export < 10⁻¹² | Ébauche reconnue avant retouches : 4,973185660 × 10⁻⁵ |
| Audio, Visio, Kino | 2 chacun | 0 | Disque + contour au placement canonique |

Trois contours canoniques et un disque, chacun défini une seule fois par SVG. Les mesures portent sur les matrices de `dist/exports/`, pas seulement sur les tables d’entrée. Le logo du kit est comparé à la copie d’autorité de Signature du dépôt.

## Comparaison d’images

À 1 200 × 1 200 pixels, les exports et les scènes finales donnent les mêmes résultats face aux dessins de référence. Le logo est identique pixel pour pixel dans les deux moteurs. Pour X, Y et Z, toutes les différences restent dans la bande de trois pixels autour des contours de la référence. Pour Z, cette référence est le dessin retravaillé ; les écarts volontaires avec l’ébauche originale sont présentés séparément dans l’atelier.

| Navigateur | Composition | Erreur moyenne par composante, sur 255 | Pixels différents |
|---|---|---:|---:|
| Chromium | X | 0,000384 | 232 |
| Chromium | Y | 0,000136 | 234 |
| Firefox | X | 0,014428 | 2 049 |
| Firefox | Y | 0,011869 | 3 411 |
| Chromium | Z | 0,00002049 | 33 |
| Firefox | Z | 0 | 0 |

La tolérance moyenne reste 0,02/255, commune à toutes les compositions. Il s’agit d’une équivalence géométrique à précision mesurée ; l’anticrénelage n’est pas présenté comme une identité symbolique.

Les rapports JSON sont dans `../verification/`. Captures, rasters et traces sont générés par les commandes du README et conservés comme artefacts de la CI, sans encombrer les sources Git. Les contrôles des navigateurs simulés ne revendiquent pas un essai sur tablette physique.

## Publication

Le workflow [pages.yml](../../../.github/workflows/pages.yml) reconstruit et contrôle le site avant chaque publication. Le manifeste `https://mrj-am.github.io/style-mrjam/revision.json` identifie le commit effectivement servi et les empreintes des fichiers. Les exécutions et les captures de validation sont disponibles dans l’onglet Actions du dépôt.
