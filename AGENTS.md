# Règles du style MrJ.am

- Lire README.md, docs/INTEGRATION.md et docs/DEPLOIEMENT.md. L’état de la préparation est explicite : aucun site n’est encore migré.
- Écrire les noms, commentaires, tests et explications en français, sauf identifiants imposés par les outils, les bibliothèques et les contrats externes.
- Garder les appels compacts : `bouton "Valider" Valider`. La présentation usuelle doit être entièrement définie ici. Les variantes correspondent à des intentions distinctes, jamais à une suite d’options décoratives répétées dans les applications.
- Mutualiser ce qui est réellement commun ; ne pas importer les données, secrets, autorisations ou règles métier des applications dans cette bibliothèque publique.
- Préserver la palette existante et le logo original. Le logo et la signature sont d’utilisation strictement réservée ; aucune licence de code ne doit les englober.
- Signature est la source d’autorité. Utiliser une révision complète, vérifier les empreintes et conserver le texte sélectionnable `MrJ.am`.
- Ne pas redessiner le logo, transformer la signature en image ou distribuer les polices dans les archives de préparation.
- Compiler une référence avant un renommage de code existant. Renommer un seul symbole de façon cohérente, compiler tous ses consommateurs, puis tester les contrats non couverts par le typage avant le symbole suivant. Ne pas faire de remplacement textuel aveugle dans les chaînes, données ou API.
- Tester le clavier, les libellés accessibles, les états de contrôle, la taille tactile et les petits écrans. Les modales exigent gestion et restitution du focus, Échap et vérification du fond inerte avant publication.
- La compilation seule ne valide ni l’authentification, ni les données, ni un déploiement.
- Publier une version de style en reconstruisant tous les projets concernés, valider tous les artefacts avant activation et conserver les versions applicatives précédentes pour retour arrière. Ne pas toucher aux bases ni à NixOS pendant le portage d’interface.
