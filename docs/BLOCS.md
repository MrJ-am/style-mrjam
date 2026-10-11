# Constructions emboîtées

Les constructions, leur palette et leurs contrôles utilisent elm-ui. L'injection
CSS et les classes de présentation ont été retirées ; aucun appel `styles`.
Le raccord Constructions porte seulement les trois polygones et ombres originales
absents de l'API publique. Les commandes centrales vérifient chaque symbole,
fonction et valeur constante ; aucune exclusion générale de module.

`MrJam.Blocs` conserve les pièces jaunes à encoches, leurs cavités ouvertes,
les objets verts et les logements. `espace dimensions` reçoit la largeur et
la hauteur réelles du navigateur (`MrJam.Ecran`) : palette gauche de258/184/140px,
canevas à droite et défilements internes, commandes et statut hors du défilement.
`emboitableAvec Miniature` exprime le contexte de palette ; `propositionNiveau`
et `logementImbrique` rendent la profondeur explicite, sans cascade entre voisins.
Les marqueurs `data-mrjam-construction` nomment les parties techniques ; ce ne
sont pas des classes de présentation à compléter depuis l'application.

`emboitable etat attributs entete cavites pied` dessine une silhouette continue
avec une épine et des cavités ouvertes : C, E ou davantage selon leur nombre.
`cavite`, `proposition` et `objectif` rendent distincts les emplacements, les
objets syntaxiques et les objectifs. Les textes et les règles restent applicatifs.

Les attributs autorisent les ponts techniques Pointer Events ; aucune validité
métier ne dépend du DOM. Les boutons internes viennent toujours de MrJam.
Les cavités grandissent avec leurs enfants. Les constructions gardent leur largeur
naturelle et le canevas défile dans les deux directions. `commande`, `poignee`,
`outil` et `onglet` fournissent les contrôles compacts de cette composition.
Les étiquettes d'état restent nécessaires : la couleur seule ne fait pas sens.

Qualification locale du socle : tests/blocs.py lit les pixels des encoches et
languettes, les cavités ouvertes, les couleurs originales et trois profondeurs,
le clavier, sept formats et les dimensions/défilements après resize. Ces contrôles
ne qualifient pas le consommateur Logique : il reste à adapter aux nouvelles API,
aux marqueurs et aux contextes, puis à tester ses gestes et son état pédagogique.
