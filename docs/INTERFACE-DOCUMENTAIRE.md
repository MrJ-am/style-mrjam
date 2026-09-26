# Interface documentaire partagée

Le candidat du 26 septembre 2026 adopte une lecture de type base documentaire :
lignes compactes, liens de titre, propriétés alignées, actions secondaires discrètes,
documents sans cartes imbriquées. L’inspiration Notion porte sur cette hiérarchie,
pas sur une copie de ses couleurs, de ses icônes ou de ses dimensions exactes.
La palette, le logo et la signature MrJ.am restent les références.

## Répartition des responsabilités

| Besoin | Source unique | Application |
| --- | --- | --- |
| Boutons, états indisponibles, sélection, icône | `MrJam.Controles` | Texte, disponibilité, message |
| Tableau, colonnes, lignes, état vide, défilement | `MrJam.Tableaux` | Données et rendu sémantique de cellule |
| Navigation documentaire, liens, filtres, pagination, document | `MrJam.Documents` | Destination, état, actions |
| Champs et valeurs de saisie | `MrJam`, `MrJam.Donnees`, `MrJam.Theme` | Validation métier |
| Modale native, focus et fond inerte | `MrJam.Fenetres`, `fenetres.js` | Contenu et décision |
| Logo et texte sélectionnable de signature | `MrJam.Identite` | Aucune décoration locale |

`Controles` et `Theme` sont internes. Le point d’appel demeure
`bouton "Enregistrer" Enregistrer`, sans liste de couleurs ou d’espacements.
`Donnees.tableau` délègue au même moteur que `Tableaux.tableau` pour conserver
la compatibilité. Le type opaque `Colonne` fournit les mêmes dimensions à
l’en-tête et aux cellules ; les variantes `principale`, `mesure`, `commandes`
expriment le rôle, pas des options CSS.

```elm
Tableaux.tableau "Résultats"
    [ Tableaux.principale "Titre" (\objet -> Documents.lien objet.titre objet.url)
    , Tableaux.mesure "Nombre" (\objet -> Element.text (String.fromInt objet.nombre))
    ]
    objets
```

## Contrats graphiques vérifiables

| Critère | Vérification |
| --- | --- |
| Actions courtes compactes | Hauteur de 32 à 38 px, cible nominale 34 px |
| Lignes de lecture courtes | Hauteur de 32 à 48 px |
| Contenu long | Retour à la ligne sans troncature ni hauteur fixe ; cas extrême de galerie ≤ 130 px |
| Navigation dans les données | Vrai lien avec destination, sans cadre de bouton |
| Alignement | Même position et largeur des cellules et de leurs en-têtes |
| Hiérarchie | Séparateurs fins ; pas de cartes imbriquées dans les tables |
| Téléphone | Aucun défilement horizontal du document à partir de 320 px ; table défilante localement |
| Clavier | Entrée/Espace, focus visible, accès au défilement, modale, Échap et restitution du focus |
| États | Vide, indisponible, occupé, sélectionné et libellés longs |
| Stabilité | Ouvrir une modale ne change pas la police de la page |

Ces seuils rendent la direction graphique testable. Ils ne calculent pas un
« pourcentage de ressemblance à Notion » et ne remplacent pas la revue des captures.
Les lignes contenant beaucoup de texte peuvent grandir ; les cases et radios
conservent leurs cibles plus généreuses.

## HTML résiduel justifié

Les éléments ordinaires sont en ElmUI. `select` et ses éléments natifs restent
encapsulés dans `MrJam.selecteur`, car ElmUI ne propose pas ce contrôle.
`dialog` fournit la modalité native, avec un conteneur technique pour les deux
racines ElmUI. Ce sont des adaptateurs centraux, pas une deuxième bibliothèque
applicative. La lecture littérale et la signature n’utilisent plus de `Html.text`
encapsulé dans une présentation HTML.

Les modales utilisent `noStaticStyleSheet` : une deuxième feuille statique ElmUI
injectée après la première racine écrasait les règles dynamiques de typographie
et de marges. Le test reproduit l’ouverture puis contrôle l’invariance.

## Exécution

```sh
npm ci
npm run verifier
python3 -m pip install -r tests/requirements.txt
python3 -m playwright install chromium
python3 tests/navigation.py
python3 tests/documentaire.py
```

La galerie `/?vue=bibliotheque` couvre données, état vide, titre long, action longue
et modale. Les deux suites navigateur sont exécutées par la CI. Les captures sont
synthétiques ; la galerie publique ne contient ni données applicatives ni polices
privées de Signature. Avant adoption, reconstruire et tester tous les consommateurs
avec leurs verrous exacts et conserver leurs artefacts précédents.
