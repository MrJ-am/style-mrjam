# Interface documentaire partagée

La direction du candidat historique du 26 septembre 2026 est conservée :
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
expriment le rôle, pas des options CSS. Le contexte de marque est désormais
explicite : `ui = MrJam.pour contexte`, `documents = Documents.pour contexte`,
`tableaux = Tableaux.pour contexte`, `donnees = Donnees.pour contexte` avec
`contexte = MrJam.Contexte.pour "Vision"`. Les fonctions historiques utilisent
la palette commune. La même valeur sert à `Fenetres.modalePour` ; aucune cascade.

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
| Actions courtes compactes | Hauteur de 32 à 38 px, cible nominale 34 px ; pictogrammes 44px pour le tactile |
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
applicative. `Adaptateurs.Texte` rend uniquement un nœud texte échappé : elm-ui
force sinon white-space:normal sur son enfant texte, même avec pre-wrap sur le
paragraphe. Deux réglages fixes conservent espaces/retours et replient les mots
longs ; aucun élément HTML de présentation ni chaîne interprétée. Saisie et
pictogrammes passent également par les adaptateurs bornés du contrat central.

Les modales utilisent `noStaticStyleSheet` : une deuxième feuille statique ElmUI
injectée après la première racine écrasait les règles dynamiques de typographie
et de marges. Le test reproduit l’ouverture puis contrôle l’invariance.

La signature est un paragraphe ElmUI avec un unique texte sélectionnable. Son
interligne natif de 1,183 est conservé par un attribut technique partagé :
`spacing` n’accepte que des pixels entiers. Le contrôle de hauteur empêche le
reset ElmUI de réduire cette métrique ; les polices et leur CSS restent intacts.

## Exécution

```sh
cd ../vps-infrastructure
python3 scripts/assemblage.py tester --suite frontend-regles
python3 scripts/frontends.py qualifier --composant style
```

La galerie `/?vue=bibliotheque` couvre données, état vide, titre long, action longue
et modale. La commande locale centrale exécute les suites navigateur, dont
Contextes (palettes, données natives, saisie, focus et rendu littéral). La CI/CD
centrale déploie uniquement le candidat qualifié. Le portage complet reste en
cours : une règle verte ou une compilation ciblée n'est pas la conformité des
applications. Les captures sont
synthétiques ; la galerie publique ne contient ni données applicatives ni polices
privées de Signature. Avant adoption, reconstruire et tester tous les consommateurs
avec leurs verrous exacts et conserver leurs artefacts précédents.
