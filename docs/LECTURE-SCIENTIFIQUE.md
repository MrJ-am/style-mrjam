# Documents scientifiques

`MrJam.Mathematiques.document source` compose le texte avec elm-ui, titres
(1–3), listes, code, gras, formules `$…$`/`$$…$$` et portées initiales.
Le HTML reste du texte échappé. Le contenu de code n'est pas traité par KaTeX.
Les paragraphes normalisent CRLF pour le rendu ; la source exacte reste dans
la métadonnée `data-mrjam-document`, sans modification du corpus.

Les espaces initiaux des preuves sont des données scientifiques, pas un choix
décoratif. Une ligne indentée entraîne le rendu par lignes du paragraphe entier,
avec chaque retrait exprimé en ch comme dans l'ancien lecteur Matheval.
elm-ui1.1.8 ne possède pas cette unité : l'adaptateur privé Texte.portee est borné
à une expression numérique positive, une propriété et des métadonnées fixes.
Les applications n'importent pas l'adaptateur. La qualification centrale ajoute
les règles AST et `tests/scientifique.py` (TeX réel, portées/repli, HTML hostile,
Markdown et clavier). Les comparaisons avec l'ancien lecteur restent des preuves
de développement ; elles ne qualifient pas les consommateurs ni la production.

`texte` et `ligne` conservent le découpage historique par dollars de Logique.
`formule` conserve le rendu TeX affiché. KaTeX est une dépendance existante,
verrouillée par le consommateur, avec trust=false dans le pont commun.
