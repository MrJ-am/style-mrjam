# Règles du style MrJ.am

<!-- coordination-commune:v1 -->
## Coordination commune

- Identifiant de ce projet : `style`. À chaque reprise (y compris après compaction), lire aussi le [AGENTS.md distant de référence](https://github.com/MrJ-am/style-mrjam/blob/main/AGENTS.md), même sur une ancienne branche.
- Avant de travailler, consulter dans le dépôt privé `MrJ-am/vps-infrastructure`, **branche `main` actuelle**, [coordination/CONTRATS.org](https://github.com/MrJ-am/vps-infrastructure/blob/main/coordination/CONTRATS.org) et [coordination/REGISTRE.org](https://github.com/MrJ-am/vps-infrastructure/blob/main/coordination/REGISTRE.org). Lire le protocole au début du registre à la première utilisation ; ensuite, charger la synthèse et les messages destinés à `style`. Ne pas charger les archives par défaut.
- Reconsulter avant toute modification d'un contrat partagé, avant publication et à la clôture. La commande `python3 scripts/coordination.py lire style`, dans une copie fraîche du dépôt VPS, produit la vue ciblée. Les outils GitHub permettent aussi cette lecture sans clone ni SSH.
- Publier les impacts globaux pour tous les projets ; pour un impact ciblé, nommer explicitement les destinataires et les actions. Informer avant le changement puis consigner le résultat avec commit et preuves. Une demande n'est pas un changement exécuté.
- Acquitter uniquement pour `style`, après lecture réelle, avec l'empreinte du message et le dépôt@commit du contexte. Distinguer LU, BLOQUE et DONE ; DONE exige une preuve. Suivre le protocole pour publier la réponse sur le main VPS sans écraser les autres écritures.
- Si le registre est inaccessible, le dire, poursuivre les tâches indépendantes et suspendre seulement les changements partagés dont les préconditions restent inconnues. Ne pas inventer d'accusé ni demander à l'utilisateur de transporter les messages entre projets.
- Les consignes locales continuent de s'appliquer. Le registre ne donne aucun droit supplémentaire de publication ou d'administration. Après les mises à jour, vérifier l'archivage des échanges intégralement traités ; ne jamais effacer un message non acquitté.

<!-- /coordination-commune:v1 -->

- Lire README.md, docs/INTEGRATION.md et docs/DEPLOIEMENT.md. Lire l’état de chaque consommateur : Vision est publié depuis le 21 septembre 2026 ; cela ne prouve ni la migration des autres sites ni l’activation de l’orchestrateur collectif.
- Écrire les noms, commentaires, tests et explications en français, sauf identifiants imposés par les outils, les bibliothèques et les contrats externes.
- Garder les appels compacts : `bouton "Valider" Valider`. La présentation usuelle doit être entièrement définie ici. Les variantes correspondent à des intentions distinctes, jamais à une suite d’options décoratives répétées dans les applications.
- Mutualiser ce qui est réellement commun ; ne pas importer les données, secrets, autorisations ou règles métier des applications dans cette bibliothèque publique.
- Préserver la palette existante et le logo original. Le logo et la signature sont d’utilisation strictement réservée ; aucune licence de code ne doit les englober.
- Signature est la source d’autorité. Utiliser une révision complète, vérifier les empreintes et conserver le texte sélectionnable `MrJ.am`.
- Ne pas redessiner le logo, transformer la signature en image ou distribuer les polices dans les archives de préparation.
- Compiler une référence avant un renommage de code existant. Renommer un seul symbole de façon cohérente, compiler tous ses consommateurs, puis tester les contrats non couverts par le typage avant le symbole suivant. Ne pas faire de remplacement textuel aveugle dans les chaînes, données ou API.
- Tester le clavier, les libellés accessibles, les états de contrôle, la taille tactile et les petits écrans. Les modales exigent gestion et restitution du focus, Échap et vérification du fond inerte avant publication.
- La compilation seule ne valide ni l’authentification, ni les données, ni un déploiement.
- Publier une version de style en reconstruisant tous les projets concernés, valider tous les artefacts avant activation et conserver les versions applicatives précédentes pour retour arrière. Ne pas toucher aux bases ni à NixOS pendant le portage d’interface.
