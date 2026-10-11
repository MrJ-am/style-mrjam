# Espace et axes communs

`MrJam.Espace` reçoit les objets, leurs coordonnées et les pôles du domaine ;
`MrJam.AxesSpatiaux` reçoit les valeurs et leur état facultatif. Les messages
retournent des intentions d’ouverture, rotation, aperçu, annulation ou validation.
Aucune fonction ne détient de corpus, n’effectue de sauvegarde ou ne valide
elle-même une réponse scientifique. Le consommateur contrôle ces intentions.

`GeometrieSpatiale` conserve projection orthographique, séparation des billes,
placement des poignées et déplacement relatif. La prise ne saute pas à la
position cliquée ; une poignée surélevée garde sa ligne et son décalage. Le
clavier propose des pas de 0,1 ou 1, Home/End et Entrée/Espace pour lire. La
caméra change la projection, jamais les coordonnées des objets.

La présentation est elm-ui. L’adaptateur privé `GraphiqueSpatial` est limité
aux plans/axes/guides SVG et au gradient radial des sphères, capacités absentes
de l’API elm-ui1.1.8 ; les textes, aperçus et contrôles restent elm-ui.
`Adaptateurs.Espace/Axes` fixe métadonnées, événements et touch-action ; aucun
attribut, CSS ou dessin libre n’est exposé aux applications. elm-review central
contrôle couples module/fonction, symboles résolus et valeurs fixes. elm/svg1.0.1
est la dépendance déjà verrouillée de la bibliothèque, sans mise à niveau.

Les ponts `assets/mrjam/espace.js` et `axes.js` ne construisent ni DOM ni styles.
Ils mesurent les surfaces, capturent/libèrent les pointeurs, focalisent et
transmettent les événements. ResizeObserver n’est actif que pour une surface
présente ; les observateurs et handlers sont retirés lorsqu’elle disparaît.
Une inactivation libère la capture. Aucun RAF, animation ou polling JavaScript.
Les transitions de vue sont celles du socle `MrJam.Transitions`, indépendantes
des validations métier. Le consommateur annule les gestes avant une ouverture.

La qualification locale centrale compile séparément `exemples/Geometrie.elm`
puis exerce les références historiques frontend Matheval dans des fixtures
synthétiques : positions, ordres, arrondis, prises surélevées, annulations,
validations et fins doubles. Ce programme de test n’entre pas dans galerie.js.
Les parcours Matheval sur SBCL/PostgreSQL isolés restent requis : vrais pointeurs,
clavier, changements de format, focus, persistance, réduction des mouvements et
arrêt des frames. Un test pur ne prouve ni l’expérience ni une publication.
