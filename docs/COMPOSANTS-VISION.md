# Compléments pour Vision

Cette révision conserve les composants existants de `492afe54` et ajoute :

- `MrJam.Donnees` : tableau de lecture, champs numériques et dates, texte littéral ;
- `MrJam.Lecture.markdown` : titres, listes, citations, code, gras et italique ;
- `MrJam.Fenetres.modale` et son compagnon `public/assets/mrjam/fenetres.js` :
  dialogue natif avec fond inerte, clavier et restitution du focus.

Le HTML du contenu est toujours affiché comme texte ; aucun lien, image distante
ou fragment HTML n'est exécuté. Les règles métier et les données restent dans
l'application. Les dates avec fuseau et précision conservée restent des valeurs
applicatives : ne pas les tronquer pour les adapter à `datetime-local`.

La galerie compile les trois modules. Ses contrôles vérifient Markdown, absence
d'exécution HTML, tableaux, dialogue, Tab, Échap, fond inerte et focus restitué.
Les interactions avec l'API restent vérifiées dans Vision.

Ces ajouts ne modifient pas l'apparence ni les contrats des composants consommés
par Mémoire et Apprendre à démontrer. Chaque consommateur conserve son SHA exact.
La livraison de Vision doit consigner le manifeste de son artefact et les
versions des autres sites, dont les déploiements sont coordonnés séparément.
Le logo, la composition et leur source Signature restent inchangés. Les polices
autorisées proviennent du dépôt Signature et restent hors de cette bibliothèque.
