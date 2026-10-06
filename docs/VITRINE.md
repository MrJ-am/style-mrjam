# Présentation et découverte

Les API `MrJam.Vitrine`, `MrJam.Pictogrammes` et `Documents.espaceMarque` sont
ajoutées pour la nouvelle présentation de Vision. Les consommateurs qui restent
à leur révision épinglée ne changent pas. `Documents.espace` conserve le cadre
historique avec logo, titre et signature de bas de page.

`Vitrine.hero`, `benefices`, `partie`, `etapes` et `conclusion` reçoivent les textes
et actions du produit. `illustration` accompagne un dessin d’un texte alternatif
et d’une légende. `capture` ajoute un accès à sa taille originale. `details`
utilise un complément natif accessible au clavier. Sa racine ElmUI imbriquée
n’injecte pas les règles globales du cadre.

```elm
Pictogrammes.action Pictogrammes.Modifier "Modifier la fiche" Editer
Pictogrammes.lien Pictogrammes.Bouclier "Confidentialité" "/privacy"
```

Les dessins SVG sont masqués aux lecteurs d’écran ; le contrôle porte son nom
accessible et une infobulle. Le moteur des boutons reste `Controles`. Les
commandes compactes mesurent 34 px avec une souris et 44 px avec un pointeur
principal tactile. Les textes des actions qui nécessitent une explication
peuvent rester visibles.

`espaceMarque "Vision"` compose le texte sélectionnable « Vision.MrJ.am ».
Le préfixe utilise la Parisienne complète de Signature sous le nom local
`MrJamEcriture`. La signature continue à utiliser ses glyphes exacts sous
`MrJamSignature`. Le consommateur fournit ces polices depuis la révision
Signature autorisée ; aucune police n’est ajoutée au dépôt public de style.

Ajouter `elm/svg` 1.0.1 aux dépendances directes et intégrer localement
`assets/mrjam/vitrine.css` depuis la même révision que les modules. Les textes,
photos et captures appartiennent au consommateur. La feuille ne contient que
les adaptations responsives de ces compositions. Aucun contenu privé ni aucune
adresse de déploiement ne réside dans la bibliothèque.

Les parcours publics et privés de Vision doivent être vérifiés ensemble. La
galerie contrôle les pictogrammes et les compléments ; elle ne valide pas les
polices absentes de sa distribution publique. Le test de Vision vérifie les
trois fontes réellement chargées et la marque avant publication.
