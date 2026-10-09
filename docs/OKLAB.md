# Couleurs communes OKLab et variante Visio

`MrJam.OKLab` définit les conversions et la sérialisation. `MrJam.Theme` est
l'unique palette des composants : coordonnées OKLCH (forme cylindrique
d'OKLab), rôles sémantiques et variables CSS héritées par la page et ses modales.
Les applications emploient les composants français ; elles ne redéfinissent
pas la couleur des boutons. Les classes de marque déclarent les variables :
Elm 0.19 n'applique pas correctement une propriété CSS personnalisée avec son
ancienne affectation de style en ligne.

Vision adopte la teinte 227,507764°, tirée du repère canonique de l'atelier de
palette. Les fonds conservent cette teinte avec chroma faible ; les actions
utilisent un chroma supérieur et une clarté plus basse pour le contraste.
Les rôles de danger emploient leur propre teinte. La valeur de référence du
logo (L 0,742201739 / C 0,132555344) n'est pas réutilisée telle quelle pour un
petit texte ou un bouton. Les bordures de contrôle sont plus sombres que les
séparateurs décoratifs. Les états désactivés et de focus restent sémantiques.

Les conversions sRGB servent aux sorties et bibliothèques qui les exigent,
notamment le conteneur `Element.Color` et les exports SVG. Les choix de palette
ne sont plus définis par des triplets RGB. Le fichier `palette/palette.json`
reste le repère de l'atelier ; les autres consommateurs adoptent cette version
à une révision exacte lors de leur reconstruction et gardent leur retour
applicatif. Leur version actuellement publiée ne change pas automatiquement.

Visio conserve les contours du capteur visuel et du fragment connaissance,
mais utilise un placement commun : translation (7,4117752 ; 16,8481456),
échelle 1,6, orientation directe. Le motif utile est centré dans le disque et
agrandi. `palette/Palette-Visio.svg` est la variante bleue destinée à Vision.
Le logo original Echologo et les fontes Signature demeurent identiques et
d'utilisation réservée. Les autres capteurs ne sont pas déplacés.

Les tests de géométrie vérifient contours et cadrage ; les parcours navigateur
vérifient l'héritage des variables, les contrôles, le focus, les formats étroits
et les modales. Les contrastes doivent être mesurés sur les couleurs réellement
rendues, après conversion et bornage au gamut, avant publication.
