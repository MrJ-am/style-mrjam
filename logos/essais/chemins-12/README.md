# Essai G — progression quadratique vers le blanc

[Comparaison E / F / G](comparaison.png) · [SVG G](G-blanc-quadratique.svg) · [Aperçu G](G-blanc-quadratique.png)

La silhouette factorisée, son masque, les trois primitives et les repères obliques
sont identiques à ceux de F dans `../chemins-11/`. Aucune forme n’est modifiée.

Pour la position spatiale t entre les deux isocouleurs extrêmes, on pose u = t².
Le chemin colorimétrique est celui de F :

- L = L₀ + (1 − L₀)u ;
- C = q₀ × Cmax(L, h₀), avec q₀ = C₀ / Cmax(L₀, h₀) ;
- h = h₀, constant.

Départ : L₀ = 0,6915316393559333, C₀ = 0,1686868573164192,
h₀ = 9,870301470439369°. Arrivée : L = 1, C = 0.
La fraction q₀ du chroma maximal garantit le maintien dans le gamut sRGB.
Le blanc reste atteint à la pointe extrême ; le rose persiste plus longtemps
sur le reste de la silhouette.

Les fonctions Elm existantes `Palette.Couleurs` calculent 1001 échantillons.
Un échantillon sur deux fournit les 501 étapes du dégradé SVG natif.
Le navigateur interpole continûment en sRGB entre ces étapes : il ne dessine
pas des bandes uniformes. Le zoom ne transforme pas ces étapes en aplats.
Une quantification de l’affichage peut toutefois produire du banding, comme
pour tout dégradé. Aucun calcul de gamut ni script ne s’exécute dans le SVG.

Vérifications : masque et coordonnées identiques à F ; 1001 points dans le
gamut ; L croissant, C décroissant ; arrivée blanche exacte. L’erreur maximale
mesurée aux 500 milieux entre étapes est de 3,82 × 10⁻⁷ en distance OKLab.
Les segments sRGB restent eux-mêmes dans le gamut par convexité du cube RGB.
Le rendu et la planche ont été vérifiés dans Chromium.
Les valeurs détaillées figurent dans [verification.json](verification.json).

Cet essai ne remplace pas le logo officiel et ne déploie aucune page du site.
