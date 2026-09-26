# Reconstruction et publication coordonnées

Le 26 septembre 2026, la version `3aab7233465ac0abe49464fa26a360765ccb4004` a été publiée sur les trois consommateurs par une opération collective privée : artefacts figés, préparation, retour autonome, activation et constat des fichiers réellement servis. Ce mécanisme exige une demande explicite portant sur les révisions validées ; un push du dépôt public de style ne reçoit aucun secret et ne déclenche pas seul la production.

Une évolution de la version partagée doit reconstruire et redéployer **tous** les projets concernés, pas seulement le premier utilisateur du composant modifié. Conserver un manifeste privé qui associe une révision exacte de style, une révision exacte de chaque application, une révision de Signature et les empreintes des artefacts.

## Préparer, puis activer

La préparation récupère ces révisions, compile toutes les interfaces, exécute les tests unitaires, les tests de contrats et les contrôles navigateur. Aucun artefact n’est activé si l’un des contrôles échoue. Les droits et secrets de publication restent dans les environnements privés autorisés ; une pull request du dépôt public de style ne doit jamais pouvoir déployer ni accéder aux dépôts privés.

L’activation publie les artefacts déjà testés sans les reconstruire à partir de branches qui auraient bougé. Les ressources JavaScript et d’identité portent la même version de publication. Après chaque activation, contrôler les fichiers réellement servis, l’authentification, les fonctions critiques et le manifeste.

## Cibles à raccorder

| Consommateur | Cible réelle | Révision publiée le 26 septembre |
|---|---|---|
| Vision | https://vision.mrj.am/ | `b33ce9f0c20f4b8af5790831b59217408b496fc0` |
| Matheval | https://principiipetit.io/matheval/ | `fc3c2fcd36d920142de946b41154cc6f3a67d76e` |
| Apprendre à démontrer | https://logique.echos.systems/ | `2e2dd6a48cbdad20bbc8d0ac34a9ace67f111a0f` |

Les trois cibles sont sur le VPS existant. La publication collective utilise le publicateur et le compte dédiés de Matheval, bascule ensemble le serveur et l’interface Vision, et change le lien statique de Logique. Les empreintes des ressources, les seize vues publiques, l’authentification et les services ont été vérifiés avant désarmement du retour. Les preuves détaillées restent dans le registre privé VPS ; la configuration historique `.openai/hosting.json` de Logique ne désigne plus sa cible active.

VPS Infrastructure conserve le contrôle de NixOS, Nginx, PostgreSQL, des domaines et des accès. Cette migration ne justifie aucune modification de schéma, de privilège ou de configuration système. Les opérations serveur passent par les runners GitHub Actions, pas par une connexion SSH depuis l’atelier ChatGPT.

## Échec et retour arrière

Le redéploiement est coordonné, mais plusieurs applications ou hébergeurs ne constituent pas une transaction atomique. Conserver les anciens artefacts applicatifs et préparer le retour des applications déjà activées si une activation suivante échoue. Ne jamais restaurer une base ou supprimer des réponses collectées pour annuler une modification d’interface.

Une page déjà ouverte peut continuer à exécuter son ancien JavaScript : maintenir la compatibilité des contrats et vérifier le rechargement/cache. Enregistrer les commits, exécutions, tests et versions effectivement servis avant d’annoncer la migration achevée.
