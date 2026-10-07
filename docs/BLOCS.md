# Constructions emboîtées

`MrJam.Blocs` ajoute des contours optionnels, sans changer les contrôles existants.
Les constructions sont des pièces jaunes à encoches ; les objets syntaxiques
sont des pièces vertes, avec des logements imbriqués. `espace` fournit un atelier
à palette gauche et canevas droit. Il inclut `styles` ; ajouter celui-ci une seule
fois pour employer les pièces seules dans une autre disposition.
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

Premier consommateur : Atelier de preuves de Logique. Ajout optionnel ; Vision
et Matheval conservent leurs verrous. Leurs composants existants ne sont pas modifiés.
