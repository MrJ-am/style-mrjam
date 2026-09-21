# Compléments communs préparés pour les interfaces d’administration

Cette branche prépare des composants manquants ; elle ne remplace pas la révision `52ad33f881b50feef91d60915d17bae90abfc592` verrouillée dans Mémoire. Aucune application ne doit suivre cette branche mobile. Leur adoption exige une nouvelle révision complète approuvée et les tests de chaque application avant la publication coordonnée.

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

`MrJam.Tableaux` construit les rangées et cellules en ElmUI avec les rôles de table, groupes de rangées, rangées, en-têtes et cellules. Il conserve les valeurs fournies, dont zéro. Le nom du tableau est visible et accessible. Le défilement est horizontal et local, avec accès clavier et indication du focus. Une liste de données vide conserve les en-têtes et affiche « Aucune donnée. » ; une liste de colonnes vide n’affiche rien. Le tri, la pagination et les formats métier ne sont pas cachés dans ce composant. Ce premier tableau utilise des colonnes de largeur commune ; les variantes de largeur ou de contenu devront rester définies sémantiquement dans la bibliothèque.

La galerie et ses tests couvrent les nouveaux champs, les rôles, le zéro, l’état vide, les actions au clavier et le défilement à 320 et 390 pixels. Ils ne constituent ni un audit complet d’accessibilité ni les tests de l’administration réelle.

Aucun symbole existant n’est renommé. Aucun logo, manifeste d’identité, droit réservé ou composition de signature n’est modifié. La typographie exacte de la signature reste à intégrer depuis la source autorisée. Cette branche ne contient aucun déploiement.
