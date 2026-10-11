# Table de cartes

`MrJam.TableSpatiale` compose une surface et des cartes elm-ui, avec des couches
à clés stables. Les applications fournissent positions, dimensions, contenu et
intentions. Le socle possède présentation et entrées ; les coordonnées métier
et les calculs de placement restent chez le consommateur. Des légendes d'axes
sont facultatives, sans ajout au démonstrateur de carte.

Les progressions numériques proviennent de `MrJam.Transitions`, avec réduction
initiale et dynamique et abonnement arrêté au repos. Ouvrir/fermer n'attend pas
la fin visuelle. Entrée/Espace actionnent la carte, Échap ferme une carte ouverte.
La carte garde son nœud, son focus et sa position miniature après fermeture.

elm-ui1.1.8 ne propose pas scale. L'adaptateur privé Spatial accepte uniquement
un nombre borné0.1–1.5, pas du CSS libre. Les boîtes non peintes sont transparentes
aux pointeurs : seule la boîte transformée de la carte capte les gestes, sans
recouvrir la zone d'une voisine. Les événements et métadonnées sont fixes et
contrôlés par elm-review central avec cas conformes/non conformes. Pas de HTML
applicatif, de timeline ou de moteur d'animation dans l'adaptateur.

Qualification consommateur : gestes souris/tactile, plein écran et retour,
repli du contenu long, interruptions rapides, clavier/focus, réduction des
animations et arrêt des frames. Main/DemoCard se compilent séparément : leurs
ports homonymes ne peuvent être groupés dans un même bundle Elm. Les preuves de
développement ne remplacent pas le candidat exact ni sa qualification centrale.
