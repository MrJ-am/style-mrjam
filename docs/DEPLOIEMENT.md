# Reconstruction et publication coordonnées

Ce document décrit le fonctionnement retenu. **L’orchestrateur de publication n’est pas encore installé.** La bibliothèque est publiée séparément ; le raccordement des consommateurs, les autorisations inter-dépôts et la vérification des cibles précèdent l’activation de cet orchestrateur.

Une évolution de la version partagée doit reconstruire et redéployer **tous** les projets concernés, pas seulement le premier utilisateur du composant modifié. Conserver un manifeste privé qui associe une révision exacte de style, une révision exacte de chaque application, une révision de Signature et les empreintes des artefacts.

## Préparer, puis activer

La préparation récupère ces révisions, compile toutes les interfaces, exécute les tests unitaires, les tests de contrats et les contrôles navigateur. Aucun artefact n’est activé si l’un des contrôles échoue. Les droits et secrets de publication restent dans les environnements privés autorisés ; une pull request du dépôt public de style ne doit jamais pouvoir déployer ni accéder aux dépôts privés.

L’activation publie les artefacts déjà testés sans les reconstruire à partir de branches qui auraient bougé. Les ressources JavaScript et d’identité portent la même version de publication. Après chaque activation, contrôler les fichiers réellement servis, l’authentification, les fonctions critiques et le manifeste.

## Cibles à raccorder

Matheval dispose d’un workflow applicatif et d’une commande de publication dédiée. Vision possède une procédure d’intégration côté VPS à respecter. Apprendre à démontrer déclare un hébergement statique dans `.openai/hosting.json` : son workflow de vérification produit `dist`, mais ne prouve pas à lui seul un déploiement. Il faut confirmer et raccorder sa cible réelle, plutôt que supposer que les trois applications sont sur le même serveur.

VPS Infrastructure conserve le contrôle de NixOS, Nginx, PostgreSQL, des domaines et des accès. Cette migration ne justifie aucune modification de schéma, de privilège ou de configuration système. Les opérations serveur passent par les runners GitHub Actions, pas par une connexion SSH depuis l’atelier ChatGPT.

## Échec et retour arrière

Le redéploiement est coordonné, mais plusieurs applications ou hébergeurs ne constituent pas une transaction atomique. Conserver les anciens artefacts applicatifs et préparer le retour des applications déjà activées si une activation suivante échoue. Ne jamais restaurer une base ou supprimer des réponses collectées pour annuler une modification d’interface.

Une page déjà ouverte peut continuer à exécuter son ancien JavaScript : maintenir la compatibilité des contrats et vérifier le rechargement/cache. Enregistrer les commits, exécutions, tests et versions effectivement servis avant d’annoncer la migration achevée.
