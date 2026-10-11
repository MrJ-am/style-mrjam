# Intégration centrale

Les règles actives sont le [contrat frontend central](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/FRONTENDS.md),
les [commandes locales](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/DEVELOPPEMENT.md) et le
[manifeste d’assemblage](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/manifest.json). Les décisions et preuves
antérieures restent dans `coordination/historique/` ; elles ne qualifient pas
l’amendement du 11 octobre 2026.

Présentation en elm-ui, transitions avec elm-animator dans le socle style-mrjam.
Les applications expriment état métier et intentions puis composent ce socle.
Pas de présentation Html/Html.Styled/elm-css, CSS applicatif, styles inline, HTML
injecté ni moteur d’animation local. Bootstrap minimal et adaptateurs techniques
étroits seulement : périmètre nommé, justification de la capacité manquante,
contrôle et tests. Element.html/htmlAttribute sont réservés à ces adaptateurs.
Les références de type nécessaires au navigateur restent autorisées.

elm-review central bloque la qualification des sources assemblées, y compris le
style à sa révision verrouillée. Les règles résolvent les symboles (alias/exposing),
vérifient frontières et échappatoires ; tests positifs/négatifs et fixture rejetée.
Aucun contournement par exclusions générales ou suppressions régénérées.

Qualifiés localement : interruptions/inversions rapides, état/focus/clavier,
reduced-motion et arrêt du rafraîchissement inutile. Une action métier n’attend
pas une décoration. Préserver fonctionnalités, accessibilité et identité visuelle.
Une analyse statique ne prouve pas ces parcours navigateur.

Sources de style à révision Git exacte, récupérées pour la construction sans
copie divergente entretenue dans l’application ; artefact complet/empreintes.
Composants publiés avant manifeste. CI/CD uniquement dans l’infrastructure,
réservée à la promotion du candidat qualifié et à ses sondes/préconditions ;
aucune campagne de développement distante, aucun workflow composant ou acquittement.

La bibliothèque porte composants, politique de transitions et raccordement Elm.
Aucun métier, credential ou contenu personnel. Les consommateurs expriment leur
état ; un import elm-animator direct par écran n’est pas requis si le socle
l’encapsule. Signature garde ses droits et ressources à empreintes exactes.
Domaines/préfixes publics et ateliers existants sont à préserver ; une ancienne
publication Pages ne justifie ni workflow satellite ni réactivation d’un ancien
traitement suspendu. La commande centrale sélectionne les consommateurs affectés,
construit une fois leurs ressources puis promeut cet artefact. Le retour conserve
les données actuelles, sans restauration SQL pour annuler du code.

Le socle `MrJam.Transitions` porte la chronologie elm-animator2.0.0 et le lecteur
commun auparavant interne à l’atelier logo. Les applications gardent leurs états
et géométrie ; elles appellent `initialiser`, `aller`, `mettreAJour`, `reduire`,
`nombre` et `abonnement`. La cible métier est immédiate, les valeurs visuelles
passent dans les attributs elm-ui ; aucun renderer HTML/CSS local. Réduction des
animations et repos arrêtent les frames. Le lecteur artistique existant utilise
`abonnementLecteur` ; ses calculs de pause/reprise/inversion/boucles sont conservés.
La migration des autres vues et le passage des contrôles centraux restent requis.

`MrJam.Mathematiques.ligne/texte/formule` compose du texte et le raccord TeX
sans HTML interprété. Charger `assets/mrjam/mathematiques.js` après le KaTeX
existant : ce pont commun conserve `trust=false`, MathML et le repli textuel.
`MrJam.Documents.repereFocusable/navigation` et `MrJam.Accessibilite` donnent
les sémantiques nécessaires ; `MrJam.pageAccessible cible titre contenu` porte
le lien d’évitement révélé par le focus elm-ui, testé au clavier.

`MrJam.Videos` reçoit la `Source` du cours et conserve un `Modele` par instance.
Raccorder `mettreAJour` et `Cmd.map` dans update ; appeler `quitter` lorsque la
vue quitte le lecteur, pour invalider ses promesses sans perdre ses positions.
Charger `assets/mrjam/videos.js` et le SDK Vimeo local déjà présent. Seul
l’iframe apparaît au clic ; commandes, messages et affiche sont en elm-ui.
L’adaptateur natif borne la surface16/9 et les attributs de l’iframe. Le pont
n’écrit aucun style et ne crée aucun DOM ordinaire. Ses tests isolés exercent
KaTeX0.18.7 réel et un SDK simulé ; ils ne prouvent pas la disponibilité de Vimeo.
Ces capacités n’ajoutent aucun backend ni service.
