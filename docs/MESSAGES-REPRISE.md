# Reprise des projets après publication du noyau

Ces consignes permettent de poursuivre la migration. Elles n’annoncent ni un portage terminé ni un redéploiement. La bibliothèque est désormais publiée dans `MrJ-am/style-mrjam` ; elle ne reste pas à créer.

Dans chaque projet, lire `docs/STYLE-MRJAM.md` et `AGENTS.md` sur la branche `migration/style-mrjam`. Le message de reprise transmis au projet doit fournir une révision complète de la bibliothèque dont la vérification GitHub Actions a réussi. La lecture des directives peut suivre une branche ; la compilation des applications doit toujours utiliser une révision exacte.

## Mémoire — MrJ-am/M-moire

Porter toutes les interfaces en ElmUI, administration comprise. Utiliser les composants français partagés. Compiler avant puis après chaque renommage individuel. Préserver le corpus, les espaces initiaux, les données et la séparation avec l’infrastructure. Adapter la copie des sources dans l’atelier de compilation temporaire et compiler Main ainsi que Survey.

## Vision — MrJ-am/vision

Porter l’interface en ElmUI sans réécrire le serveur Common Lisp. Conserver les sessions, CSRF, API, conflits d’édition, filtres, pagination, observations et historiques. Employer le style commun sans répéter les options décoratives dans les vues.

## Apprendre à démontrer — MrJ-am/apprendre-a-demontrer

Porter le style vers les composants ElmUI français partagés, en préservant les exercices, le correcteur, KaTeX, les vidéos et la navigation. Vérifier la cible d’hébergement statique avant le raccordement à la publication collective.

## VPS — MrJ-am/vps-infrastructure

Coordonner la reconstruction et le redéploiement de tous les consommateurs après validation de l’ensemble des artefacts. L’orchestrateur n’est pas encore installé. Ne pas modifier implicitement NixOS, Nginx, PostgreSQL ou les données. Aucun secret d’application ou de déploiement ne doit être ajouté au dépôt public de style.

## Coordination

Aucun projet ne doit annoncer ou déclencher isolément la publication collective. Les composants communs manquants sont ajoutés à la bibliothèque, puis leur nouvelle révision est adoptée par tous les consommateurs après compilation et tests. Les règles métier restent dans chaque application.
