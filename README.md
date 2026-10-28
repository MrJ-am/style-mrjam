# Style MrJ.am

Bibliothèque de composants **ElmUI**, avec une API française, destinée aux applications MrJ.am. Les projets fournissent les textes, les états et les actions ; la bibliothèque porte leur présentation commune.

> **Logo et signature : toute utilisation est strictement réservée.** La présence publique du logo, de la signature MrJ.am, de leurs fichiers et de leurs déclinaisons ne vaut aucune autorisation de reproduction, de modification, d’intégration, de redistribution ou d’exploitation. Toute utilisation exige l’autorisation préalable expresse de leur titulaire. Les éventuelles licences du code et les licences des dépendances ne s’étendent pas à ces éléments d’identité.

## Préparation Rust/Elm

La préparation Rust/Elm du 28 octobre 2026 gèle tous les déploiements.
L'assemblage applicatif est dans [mrjam-plateforme](https://github.com/MrJ-am/mrjam-plateforme),
les propositions de règles indépendantes dans [mrjam-validation](https://github.com/MrJ-am/mrjam-validation),
et l'environnement de développement dans [vps-infrastructure/environment](https://github.com/MrJ-am/vps-infrastructure/tree/main/environment).
La forge cible est https://forge.mrj.am ; son raccordement et les ACL restent à établir.
Ne créer ni workflow, ni déclencheur de déploiement dans ce dépôt.
Une vérification locale ne vaut ni qualification complète ni autorisation de production.
Conserver les révisions exactes des dépendances, les licences et les ressources réservées.
Aucune donnée personnelle, aucun accès de production, aucun secret dans le dépôt.
L'historique Git conserve les versions antérieures ; aucune réécriture forcée.

La licence de réutilisation du code n’a pas été choisie. Le caractère public du dépôt ne remplace pas cette décision. Les dépendances conservent leurs licences propres.

## Atelier du logo

**[Tous les logos et les SVG à télécharger](logos/)** : logo original, modes
Audio/Visio/Kino, personnages X/Y/Z, variantes de palette et essais de licorne.

[Explorer le logo et les axes X, Y, Z sur GitHub Pages](https://mrj-am.github.io/style-mrjam/) · [Philosophie du logo](https://mrj-am.github.io/style-mrjam/philosophie.html) · [Explorer la palette OKLCH](https://mrj-am.github.io/style-mrjam/palette.html)

L’atelier propose la recomposition réversible, la rotation centrifuge et l’inspection des formes du logo. Le disque central représente la **connaissance** ; les pictogrammes **audio, visio et kino** associent chacun leur contour à ce disque. **Xiaoping (X), Ydris (Y) et Zoé (Z)** sont les trois tuteurs des trois axes. Les [versions factorisées et les pictogrammes complets](public/assets/mrjam/factorises/) sont versionnés ; `Z.svg` fournit aussi le dessin explicite de Zoé. X et Y conservent les dessins fournis, y compris les deux doublons de Y. Voir [la documentation de l’atelier](ateliers/logo/README.md).

La **palette ÉcoLogo** est fixée au maximum du chroma commun aux huit teintes sRGB : L ≈ 0,742201739, C ≈ 0,132555344. Les [exports de référence](public/assets/mrjam/palette/) fournissent les SVG factorisés, le manifeste JSON et les variables CSS. La Licorne rose invisible retenue réutilise 19 occurrences des trois contours ; son dégradé s’éclaircit vers la corne. La page de philosophie expose les correspondances, les deux tétrades et le « quatre caché dans le trois ».

La construction et la publication des ateliers appartiennent désormais à l’infrastructure ; aucun workflow satellite. Les adresses publiques existantes restent à préserver. Les composants consommés par les applications restent aux révisions explicitement épinglées ; l’ajout de cet atelier n’entraîne pas leur redéploiement.

## Utiliser les composants

```elm
import MrJam exposing (bouton, boutonDestructif, boutonSecondaire, champ, section)

section "Modifier une fiche"
    [ champ "Titre" modele.titre ModifierTitre
    , bouton "Enregistrer" Enregistrer
    , boutonSecondaire "Annuler" Annuler
    , boutonDestructif "Archiver" DemanderConfirmation
    ]
```

Un lien de navigation utilise `lien`, pas un bouton sans destination. Les états non disponibles utilisent `boutonInactif` ou `boutonEnCours`. Une action destructive porte sa propre définition ; la confirmation et les permissions restent des responsabilités de l’application.

Les composants couvrent les boutons, liens, champs, recherches, mots de passe, zones de texte, cases à cocher, choix exclusifs, sélecteurs, cartes, sections, textes, messages et compositions simples. `MrJam.Donnees` fournit tableaux et valeurs spécialisées, `MrJam.Lecture` le lecteur Markdown et `MrJam.Fenetres` les dialogues accessibles. `MrJam.Disposition` fournit les bandeaux, commandes, progressions, graphiques et dialogues animés ; `MrJam.Tableaux` est le moteur unique des tableaux, avec colonnes sémantiques et état vide. `MrJam.Documents` compose les interfaces documentaires compactes ; voir [INTERFACE-DOCUMENTAIRE.md](docs/INTERFACE-DOCUMENTAIRE.md). Voir [COMPOSANTS-VISION.md](docs/COMPOSANTS-VISION.md) et [AJOUTS-MATHEVAL.md](docs/AJOUTS-MATHEVAL.md). Les autres composants communs sont à extraire selon les besoins, sans les improviser séparément dans chaque projet.

`MrJam.Vitrine` compose les pages de présentation, captures agrandissables et chapitres. `MrJam.Pictogrammes` fournit des commandes SVG avec nom accessible. `Documents.espaceMarque` affiche le nom de l’application avec la signature et retire le footer uniquement pour cette variante. Voir [VITRINE.md](docs/VITRINE.md).

`MrJam.Theme` est interne. Ajouter des couleurs, arrondis ou bordures au point d’appel d’un composant usuel recréerait précisément la duplication à supprimer.

## Vérifier la bibliothèque

Utiliser les [commandes locales centrales](https://github.com/MrJ-am/mrjam-validation/tree/main/frontend-qualification),
les versions verrouillées et [elm-review obligatoire](https://github.com/MrJ-am/mrjam-validation/tree/main/review).
Le socle commun utilise elm-ui et elm-animator ; les tests de transitions/focus
et reduced-motion complètent les règles statiques. Aucun test au push ou
workflow de bibliothèque. Les scripts ci-dessous sont des détails appelés par
l’orchestrateur central, pas un circuit de publication séparé.

`npm run compiler` produit `public/galerie.js`. La galerie se sert depuis `public/`. Les tests vérifient clic, Entrée, Espace, champs libellés, saisie multiligne, états inactifs, cases, choix, taille tactile et absence de débordement à quatre largeurs.

Dans un atelier sans réseau navigateur, `HORS_LIGNE=1` charge le même JavaScript compilé en mémoire. Le logo est alors injecté comme ressource locale, sans requête HTTP ; les polices ne sont pas chargées. Ce contrôle ne remplace ni les tests HTTP des applications ni une vérification du rendu typographique de la signature.

## Partager une version

Les applications récupèrent **une révision Git complète et exacte**, puis ajoutent `src/` de cette révision aux répertoires source Elm. La bibliothèque n’est pas publiée sur le catalogue Elm à ce stade ; `elm.json` décrit la galerie de vérification.

Ne pas dépendre d’une branche mobile, ne pas charger un CSS commun modifiable à distance, et ne pas maintenir une copie manuelle des composants dans chaque application. Les JavaScript et ressources d’une version sont publiés ensemble. Voir `docs/INTEGRATION.md` et `docs/DEPLOIEMENT.md`.

## Identité graphique

La source de référence est `MrJ-am/Signature`, à la révision enregistrée dans `identite.json`. Le logo SVG et la feuille de composition de la signature sont reproduits ici avec leurs empreintes. Ils sont des copies vérifiées de distribution, pas des sources à modifier : une mise à jour commence dans `Signature` puis actualise la révision et les empreintes.

La signature reste le texte sélectionnable `MrJ.am` et le point ordinaire U+002E. Son rendu exact nécessite les ressources typographiques du dépôt d’origine, **non distribuées dans ce dépôt public**. Chaque application doit les intégrer depuis la même révision autorisée avec leurs empreintes ; Vision le fait dans son artefact privé ; Matheval vérifie aussi les blobs Git et SHA-256 de ses fontes autorisées avant construction. Le chargement et le texte sélectionnable sont contrôlés dans les deux applications. La galerie peut afficher une police de remplacement : ce remplacement ne valide pas la signature.

Le CSS technique de la signature et celui de KaTeX ne constituent pas une seconde bibliothèque de présentation : ils sont locaux, immuables pour une version et réservés à ces intégrations. Les interfaces ordinaires sont construites avec ElmUI.
