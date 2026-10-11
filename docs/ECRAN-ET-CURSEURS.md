# Écran, fenêtres et curseurs

`page` et `Disposition.cadre` occupent au minimum la hauteur visible
et la largeur disponible, sans largeur minimale implicite. Un contenu long garde
son défilement. Les fenêtres occupent la hauteur visible et leur contenu défile
à l'intérieur ; une disposition ElmUI imbriquée ne reprend pas `100vh`.

Une navigation contextuelle doit utiliser `Disposition.dialogue` ou `Fenetres`,
pas un panneau `below` qui peut dépasser le bord de l'écran.

`MrJam.Curseurs.continu` conserve clavier et tactile avec une saisie native,
une piste et une poignée elm-ui. Il ne crée ni horloge d'animation ni annonce
automatique à chaque frame. Son contexte de marque est explicite.

La feuille CSS historique `axis-slider`/`grade-slider` est retirée du nouveau
socle ; les consommateurs anciens conservent leur révision verrouillée.
Les contrôles géométriques Matheval restent à porter en composants partagés
elm-ui et adaptateurs spécialisés bornés, en préservant billes, gestes, valeurs
et scène 3D. Matheval ne doit pas adopter ce socle avant cette qualification.
Référence pour le portage :
[source historique](https://github.com/MrJ-am/style-mrjam/blob/c9663ce7e53dc9cbd61b7f980d651bdae31357df/public/assets/mrjam/curseurs.css).

Contrôles : galerie HTTP à 320, 390, 768 et 1440 px, redimensionnement d'un
dialogue ouvert en portrait court et paysage. Matheval complète ces contrôles
par des gestes souris/tactiles et les tests de caméra et de reconnexion 3D.
Chaque consommateur doit être reconstruit et validé avant activation commune.
