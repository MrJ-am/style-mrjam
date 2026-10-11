# Bibliothèque de style MrJ.am

L’assemblage, les commandes locales et toute la CI/CD appartiennent à
[MrJ-am/vps-infrastructure](https://github.com/MrJ-am/vps-infrastructure).
Lire le [contrat central](https://github.com/MrJ-am/vps-infrastructure/blob/main/coordination/CONTRATS.org),
le [manifeste](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/manifest.json)
et les [commandes de développement](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/DEVELOPPEMENT.md).
Interfaces Elm : elm-ui pour la présentation et elm-animator pour les transitions,
mutualisés ici ; les applications portent intentions et état métier. Pas de Html/Html.Styled/elm-css, CSS/HTML applicatif ou
animation ad hoc. Adaptateurs techniques étroits, documentés/testés ; Element.html
et htmlAttribute bornés. elm-review central obligatoire, sans suppressions/exclusions
générales ; tests des règles et parcours Continuous UI (interruptions/inversions,
focus/clavier/reduced-motion, rafraîchissement arrêté). Lire le
[contrat frontend](https://github.com/MrJ-am/vps-infrastructure/blob/main/assemblage/FRONTENDS.md).

Ce dépôt conserve ses sources, contrats et tests ; publier son commit avant
référencement central. Aucun workflow satellite, publication autonome, échange
obligatoire entre conversations ou acquittement. L’intégration centrale et les
tests pertinents valident un changement.

Préserver les modifications concurrentes, les données et les secrets. Commits
français, push sans force ; aucune PR ni modification de visibilité ou licence.
Une compilation ou un test local ne prouve pas une publication : citer les
révisions et les contrôles de la version réellement servie. Les anciennes règles
sont conservées dans `coordination/historique/AGENTS-avant-composants-20261011.md`.

Bibliothèque ElmUI et composants communs : aucun métier, backend, secret,
permission ou donnée personnelle. Lire `README.md`, `docs/INTEGRATION.md` et
`docs/DEPLOIEMENT.md` pour les usages ; les règles de publication sont centrales.
Les consommateurs verrouillent une révision exacte. Une adoption qualifie et
reconstruit uniquement les consommateurs affectés dans l’atelier central avant
activation ; aucune validation collective entre agents ni chaîne autonome.

Garder les appels compacts, par exemple `bouton "Valider" Valider`. Les variantes
expriment une intention ; éviter des réglages décoratifs répétés chez les
consommateurs. Préserver palette et logo original, texte sélectionnable `MrJ.am`.
Signature est la source d’autorité à révision complète/empreintes vérifiées.
Logo, signature et polices réservés ne sont pas couverts par la licence de code ;
ne pas les redistribuer dans les archives publiques de préparation.

Tester les parcours affectés : clavier, libellés accessibles, états, tactile et
petits écrans ; modales avec focus restitué, Échap et fond inerte. Garder le code
compact et français sous notre contrôle. Renommer un symbole avec ses usages et
contrats, sans remplacement aveugle des chaînes/API. Ne modifier aucune base
métier pour une évolution de présentation ; le retour conserve les données.
