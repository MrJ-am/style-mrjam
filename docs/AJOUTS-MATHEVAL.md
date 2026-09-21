# Composants communs adoptés par Matheval

Ces ajouts complètent les composants adoptés en parallèle par Vision et Logique. Les applications verrouillent une révision Git complète et les empreintes de chaque source. La bibliothèque contient les deux séries de composants ; aucun consommateur ne suit une branche mobile.

## API

```elm
identifiant "Identifiant" modele.identifiant ModifierIdentifiant
nouveauMotDePasse "Nouveau mot de passe" modele.secret ModifierSecret

tableau "Réponses"
    [ colonne "Note" (\reponse -> paragraphe (String.fromInt reponse.note))
    , colonne "Détail" (\reponse -> boutonSecondaire "Consulter" (Consulter reponse.id))
    ]
    reponses
```

Les deux nouveaux champs utilisent le même constructeur ou les mêmes réglages internes que les champs existants. Leur distinction est sémantique : `username`, `new-password` ou `current-password`, sans réglages décoratifs dans les applications. La validation des secrets, leur confirmation et l’authentification restent des responsabilités applicatives et serveur.

`MrJam.Tableaux` compose le tableau commun de `MrJam.Donnees` avec un titre visible et un état vide. Les rôles de table, rangées, en-têtes et cellules viennent de ce constructeur unique. Il conserve les valeurs fournies, dont zéro. Le nom du tableau est visible et accessible. Le défilement est horizontal et local, avec accès clavier et indication du focus. Une liste de données vide conserve les en-têtes et affiche « Aucune donnée. » ; une liste de colonnes vide n’affiche rien. Le tri, la pagination et les formats métier ne sont pas cachés dans ce composant. Le tableau utilise des colonnes de largeur commune ; les variantes de largeur ou de contenu devront rester définies sémantiquement dans la bibliothèque.

La galerie et ses tests couvrent les nouveaux champs, les rôles, le zéro, l’état vide, les actions au clavier et le défilement à 320 et 390 pixels. Ils ne constituent ni un audit complet d’accessibilité ni les tests de l’administration réelle.

Aucun symbole existant n’est renommé. Aucun logo, manifeste d’identité, droit réservé ou composition de signature n’est modifié. Matheval vérifie les polices originales contre la source autorisée à chaque construction. Cette branche ne contient aucun déploiement.

Les fragments ElmUI de `MrJam.Disposition` s’intègrent sous un cadre ou une page ElmUI déjà présents. Ils ne réinjectent jamais la feuille de style statique. Le pont des dialogues animés conserve leur géométrie, rend le fond inerte et restitue le focus.

## Publication attestée

Matheval utilise `553e5a85fc28d09ab2d034401c6cb912ef97320d` en production depuis
le 21 septembre 2026 à 23:11 UTC. Le
[workflow 35665981516](https://github.com/MrJ-am/M-moire/actions/runs/35665981516)
a validé les quatre compilations, 50 parcours navigateur et les tests de
collecte, puis comparé 104 fichiers servis en HTTPS à l’artefact testé.
L’administration est entièrement en ElmUI. Les fontes originales restent
vérifiées par l’application contre la source Signature autorisée.
