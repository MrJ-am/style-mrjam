# Références géométriques du kit X

Extrait du kit fourni pour le premier atelier. Les sources SVG, GeoGebra et TikZ, les poses, les exports de référence, les mesures et les outils Python sont conservés. Les instructions de mission du kit ne font pas partie de cette distribution ; l’application est documentée dans [le README de l’atelier](../../README.md).

Les sources `logo-original.svg` et `X-original.svg` ne sont pas modifiées. `SHA256SUMS.txt` porte sur les fichiers conservés dans cet extrait. Les rapports de ce dossier décrivent les vérifications du kit initial ; les résultats sur le rendu Elm actuel sont dans `../../verification/`.

```sh
python3 outils/verifier_geometrie.py
python3 -m unittest discover -s outils -p 'test_*.py' -v
```

GeoGebra et TikZ sont des documents historiques : aucun script de l’archive ni compilation LaTeX n’est exécuté. Les mentions de licence dans le TikZ appartiennent à son document d’origine ; elles n’accordent pas une licence au logo ni au dépôt. L’utilisation du logo, de la signature et des déclinaisons reste strictement réservée.
