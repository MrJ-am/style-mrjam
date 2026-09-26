# Style MrJ.am

Bibliothèque de composants **ElmUI**, avec une API française, destinée aux applications MrJ.am. Les projets fournissent les textes, les états et les actions ; la bibliothèque porte leur présentation commune.

> **Logo et signature : toute utilisation est strictement réservée.** La présence publique du logo, de la signature MrJ.am, de leurs fichiers et de leurs déclinaisons ne vaut aucune autorisation de reproduction, de modification, d’intégration, de redistribution ou d’exploitation. Toute utilisation exige l’autorisation préalable expresse de leur titulaire. Les éventuelles licences du code et les licences des dépendances ne s’étendent pas à ces éléments d’identité.

## État de cette publication

Le noyau et les compléments disposent d’une galerie et de tests d’interaction. **Vision utilise la révision `c7b4d6e00cd0014a0a05e5a4e77627357498faa9` en production depuis le 21 septembre 2026 à 22:32 UTC**, sur [vision.mrj.am](https://vision.mrj.am/). Les tableaux, valeurs spécialisées, lecteur Markdown et dialogues sont intégrés et vérifiés. Cette publication de Vision ne prouve pas la migration des autres applications ni l’installation de l’orchestrateur collectif. Consulter les exécutions de vérification de chaque révision et les preuves propres à chaque déploiement.

**Matheval est publié depuis le 21 septembre 2026 à 23:11 UTC**, sur
[principiipetit.io/matheval](https://principiipetit.io/matheval/), avec la révision
`553e5a85fc28d09ab2d034401c6cb912ef97320d`. Le questionnaire, le prototype et
l’administration utilisent les composants communs ; 50 parcours navigateur
et les contrôles de collecte ont réussi. Les 104 fichiers HTTPS servis ont
été comparés à l’artefact testé. Voir le
[bilan de publication](https://github.com/MrJ-am/M-moire/blob/master/docs/PORTAGE-ELMUI.md).

La licence de réutilisation du code n’a pas été choisie. Le caractère public du dépôt ne remplace pas cette décision. Les dépendances conservent leurs licences propres.

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

`MrJam.Theme` est interne. Ajouter des couleurs, arrondis ou bordures au point d’appel d’un composant usuel recréerait précisément la duplication à supprimer.

## Vérifier la bibliothèque

Prérequis : Node.js 22, Python 3, Elm 0.19.1 fourni par les dépendances de développement.

```sh
npm ci
npm run verifier
python3 -m pip install -r tests/requirements.txt
python3 -m playwright install chromium
python3 tests/navigation.py
python3 tests/documentaire.py
```

`npm run compiler` produit `public/galerie.js`. La galerie se sert depuis `public/`. Les tests vérifient clic, Entrée, Espace, champs libellés, saisie multiligne, états inactifs, cases, choix, taille tactile et absence de débordement à quatre largeurs.

Dans un atelier sans réseau navigateur, `HORS_LIGNE=1` charge le même JavaScript compilé en mémoire. Le logo est alors injecté comme ressource locale, sans requête HTTP ; les polices ne sont pas chargées. Ce contrôle ne remplace ni les tests HTTP des applications ni une vérification du rendu typographique de la signature.

## Partager une version

Les applications récupèrent **une révision Git complète et exacte**, puis ajoutent `src/` de cette révision aux répertoires source Elm. La bibliothèque n’est pas publiée sur le catalogue Elm à ce stade ; `elm.json` décrit la galerie de vérification.

Ne pas dépendre d’une branche mobile, ne pas charger un CSS commun modifiable à distance, et ne pas maintenir une copie manuelle des composants dans chaque application. Les JavaScript et ressources d’une version sont publiés ensemble. Voir `docs/INTEGRATION.md` et `docs/DEPLOIEMENT.md`.

## Identité graphique

La source de référence est `MrJ-am/Signature`, à la révision enregistrée dans `identite.json`. Le logo SVG et la feuille de composition de la signature sont reproduits ici avec leurs empreintes. Ils sont des copies vérifiées de distribution, pas des sources à modifier : une mise à jour commence dans `Signature` puis actualise la révision et les empreintes.

La signature reste le texte sélectionnable `MrJ.am` et le point ordinaire U+002E. Son rendu exact nécessite les ressources typographiques du dépôt d’origine, **non distribuées dans ce dépôt public**. Chaque application doit les intégrer depuis la même révision autorisée avec leurs empreintes ; Vision le fait dans son artefact privé ; Matheval vérifie aussi les blobs Git et SHA-256 de ses fontes autorisées avant construction. Le chargement et le texte sélectionnable sont contrôlés dans les deux applications. La galerie peut afficher une police de remplacement : ce remplacement ne valide pas la signature.

Le CSS technique de la signature et celui de KaTeX ne constituent pas une seconde bibliothèque de présentation : ils sont locaux, immuables pour une version et réservés à ces intégrations. Les interfaces ordinaires sont construites avec ElmUI.
