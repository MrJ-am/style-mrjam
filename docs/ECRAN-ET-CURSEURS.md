# Écran, fenêtres et curseurs

`page` et `Disposition.cadre` occupent au minimum la hauteur visible (`100dvh`)
et la largeur disponible, sans largeur minimale implicite. Un contenu long garde
son défilement. Les fenêtres occupent la hauteur visible et leur contenu défile
à l'intérieur ; une disposition ElmUI imbriquée ne reprend pas `100vh`.

Une navigation contextuelle doit utiliser `Disposition.dialogue` ou `Fenetres`,
pas un panneau `below` qui peut dépasser le bord de l'écran.

`public/assets/mrjam/curseurs.css` contient l'apparence des contrôles géométriques
`axis-slider` et `grade-slider`. Le consommateur l'importe depuis sa copie figée.
Les positions des billes ne sont pas animées par CSS pendant une saisie ; leur
géométrie et leur valeur appartiennent au composant interactif du consommateur.
La scène 3D et la répartition de place restent propres à chaque application.

Contrôles : galerie HTTP à 320, 390, 768 et 1440 px, redimensionnement d'un
dialogue ouvert en portrait court et paysage. Matheval complète ces contrôles
par des gestes souris/tactiles et les tests de caméra et de reconnexion 3D.
Chaque consommateur doit être reconstruit et validé avant activation commune.
