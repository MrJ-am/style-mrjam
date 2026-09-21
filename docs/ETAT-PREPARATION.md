# État réel de cette livraison

Préparation du 21 septembre 2026, publiée après la création du dépôt public `MrJ-am/style-mrjam`. Les sources ne sont plus disponibles uniquement sous forme d’archive. Le résultat de la vérification GitHub Actions doit être consulté pour la révision exacte adoptée ; ce document ne préjuge pas du résultat d’une exécution en cours.

## Réalisé lors de la préparation initiale

- Noyau de composants ElmUI 1.1.8 à API française ; aucune API de décoration répétitive au point d’appel.
- Galerie compilée en mode optimisé avec Elm 0.19.1.
- Tests locaux Chromium exécutés à 320, 390, 768 et 1440 pixels, en mode mémoire : clic, Entrée, Espace, état inactif, état occupé, saisie, mot de passe, préservation des espaces et du texte, case à cocher, choix exclusif, messages, tailles tactiles et absence de débordement horizontal.
- Logo et feuille de composition de signature vérifiés octet pour octet contre leurs empreintes Git de référence. Les fichiers typographiques ne sont pas fournis ; le rendu typographique exact de la signature n’est pas attesté par ces tests.
- Verrou npm contrôlé avec `npm ci --dry-run --ignore-scripts --offline`. La compilation et les tests locaux initiaux ont utilisé les versions déjà installées dans l’atelier ; la CI du dépôt vérifie l’installation depuis zéro et les interactions en HTTP.
- Instructions et messages de reprise enregistrés dans quatre branches `migration/style-mrjam`.

## Références historiques des branches de préparation

| Dépôt | Commit initial des consignes |
|---|---|
| MrJ-am/apprendre-a-demontrer | ce018cec7173479ff4c0e9a28bbd152ef38e2814 |
| MrJ-am/M-moire | 879716bdf80affd1e64f93d0c6059d35ab755092 |
| MrJ-am/vision | 9aaf14f9b86ef63a65f7b2c270e6bceb98774bea |
| MrJ-am/vps-infrastructure | 6eda2dc990a56cc77f4f7f0b562974423b436958 |

Ces commits documentent l’état initial. Les consignes actualisées sont à lire sur les branches `migration/style-mrjam`. Les branches par défaut des applications n’ont pas été mises à jour par cette préparation. Aucune pull request n’a été ouverte ou fusionnée et aucun déploiement n’a été effectué dans ce cadre.

## Contrôles de référence des applications

Les vérifications GitHub Actions de référence ont réussi : Apprendre à démontrer `35604499617`, Mémoire `35605792689`, Vision `35604770389`. La récupération des sources de Vision correspond à `35604770475`.

La compilation Elm de Mémoire a aussi été exécutée localement pour Main et Survey lors de la préparation initiale. La chaîne locale complète de reconstruction du corpus n’a pas abouti, car l’archive de travail ciblée n’incluait pas un PDF bibliographique référencé. La chaîne complète a réussi sur le runner qui possédait le dépôt. Ne pas confondre cette limite de l’archive locale avec un défaut des sources applicatives.

## À effectuer avant clôture

Vérifier la CI de la révision publiée, terminer l’extraction des composants spécialisés, porter toutes les interfaces et leurs administrations, franciser l’existant symbole par symbole, intégrer les ressources exactes de Signature, raccorder la construction inter-dépôts, confirmer les cibles de publication et installer l’orchestration collective. Tester les applications puis contrôler leurs versions réellement servies.

Les données, les protocoles, les programmes applicatifs et l’infrastructure active n’ont pas été transformés à ce stade. Cette livraison ne prouve ni la migration des applications ni leur redéploiement.
