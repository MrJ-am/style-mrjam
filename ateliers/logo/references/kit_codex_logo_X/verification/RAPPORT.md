# Vérifications du kit fourni à Codex

Ces vérifications portent sur les références graphiques, leur factorisation et les équations proposées. **La page Elm est à implémenter par Codex. Aucune compilation Elm, exécution d’Elm Animator ou validation navigateur de cette future page n’est déclarée ici.**

## Géométrie

Toutes les transformations ancêtres du X original sont composées. Les trois briques non circulaires sont essayées avec les deux chiralités, les deux sens de parcours et trois points de départ. Un ajustement libre est calculé, puis des angles entiers et les deux échelles issues des rayons sont retenus après vérification de la tolérance. Les translations sont ajustées numériquement.

| Path | Brique | Miroir | Erreur maximale échantillonnée | Borne continue conservative |
|---|---|---|---:|---:|
| path4 | Kinesthesique | Non | 1.07045918e-05 | 4.43147423e-05 |
| path6 | Kinesthesique | Oui | 1.17537515e-05 | 4.54046008e-05 |
| path8 | Visuel | Oui | 7.89855114e-06 | 3.04464387e-05 |
| path10 | Auditif | Non | 9.71513883e-06 | 4.57486632e-05 |
| path12 | Kinesthesique | Oui | 1.33662143e-05 | 5.10107989e-05 |
| path16 | Visuel | Oui | 9.62215682e-06 | 3.34975098e-05 |
| path18 | Visuel | Non | 9.93001487e-06 | 3.82310389e-05 |

Unités : viewBox 30 × 30. Échantillonnage : 129 points par arc. Seuil : 10⁻⁴. Les nombres arrondis des SVG ne permettent pas de revendiquer une identité symbolique exacte.

Pour la borne continue, chaque arc circulaire transformé s’écrit C + v·exp(i·δ·t), avec 0 ≤ t ≤ 1. L’écart de deux paramétrisations correspondantes est majoré par |ΔC| + |Δv| + |v_cible|·|Δδ|. Les très petites fermetures implicites des contours sont ajoutées conservativement. Il s’agit d’une borne calculée en arithmétique flottante, pas d’une certification formelle par arithmétique d’intervalles.

## Tests de référence

La commande suivante a été exécutée : **21 tests passent**. Le journal est `tests-python.txt`.

```sh
python -m unittest discover -s outils -p 'test_*.py' -v
```

Les tests de miroir valident l’identité au départ, la réflexion à l’arrivée, le déterminant nul à la tranche, la continuité de la projection et l’absence de valeurs non finies. Ils ne remplacent pas les tests Elm et navigateur de la chorégraphie finale.

## Contrôle raster statique

CairoSVG 2.8.2, 1200 × 1200 pixels : le logo factorisé est identique pixel à pixel à sa référence dans ce rendu. Pour X, l’écart moyen absolu par composante est environ 0,000989 sur 255 ; l’écart maximal est 5 sur 255. Les écarts sont concentrés sur les contours anticrénelés. Rapport détaillé : `comparaison-raster.json`. Ce contrôle concerne un moteur et une résolution donnés ; il n’établit pas l’égalité pixel à pixel dans tous les navigateurs.

```sh
python outils/verifier_geometrie.py --sortie verification/geometrie.json
python outils/preparer_references.py
# Contrôle facultatif, CairoSVG et Pillow requis :
python outils/comparer_rasters.py
```

## Intégrité

`SHA256SUMS.txt` à la racine recense les fichiers distribués, sauf lui-même. Les SHA-256 des deux SVG sources figurent également dans le rapport géométrique. `sources/Echo.ggb` est une copie de l’archive fournie ; son intégrité ZIP a été vérifiée. Aucun script GeoGebra embarqué n’a été exécuté.
