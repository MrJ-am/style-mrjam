# Compléments de données — préparation sans adoption implicite

Ces composants sont ajoutés dans la bibliothèque, et non sous forme de variantes
locales dans Vision. Ils étendent la référence
`52ad33f881b50feef91d60915d17bae90abfc592` sans renommer ni modifier ses modules
existants. La référence a été compilée avant l'ajout. Vision reste compilé avec
cette référence exacte ; l'adoption des compléments nécessite une nouvelle
révision approuvée pour les consommateurs et leur validation collective.

```elm
import MrJam.Donnees exposing (date, dateHeure, lecture, nombre, tableau)

nombre "Stabilité" modele.stabilite ModifierStabilite
date "Depuis le" modele.date ModifierDate
dateHeure "Date de référence locale" modele.instant ModifierInstant
lecture modele.contenu

tableau "Fiches"
    [ ( "Titre", \fiche -> lecture fiche.titre )
    , ( "Action", \fiche -> bouton "Ouvrir" (Ouvrir fiche.id) )
    ]
    modele.fiches
```

Les champs gardent une API à libellé, valeur et action. Ce sont des contrôles
natifs numériques ou calendaires sous ElmUI, avec libellés accessibles et
surface de saisie de 44 pixels minimum. Ils conservent les valeurs vides ; les
bornes métier, permissions, valeurs nulles, dates UTC, fuseaux et précision
transportée restent des responsabilités de l'application. Le navigateur peut
normaliser ou refuser les saisies qui ne correspondent pas au type natif.
Une date/heure locale n'est pas directement une chaîne de version serveur.

`lecture` est un lecteur de texte brut : les espaces, retours et chaînes HTML
restent littéraux et sélectionnables. Il ne remplace pas un lecteur Markdown.
`tableau` reçoit ses colonnes et lignes ; il expose des rôles de tableau de
lecture, pas de grille interactive. Les actions utilisent les boutons communs.
Sur petit écran, le défilement reste dans une région libellée, accessible au
clavier. Ni tri, ni pagination, ni filtrage ne sont cachés dans le composant.

La galerie `exemples/Donnees.elm` et `tests/donnees.py` contrôlent la saisie,
les dates bissextiles et fractions de seconde, la lecture littérale, les rôles,
les boutons au clavier, le défilement, les surfaces tactiles et quatre largeurs.
Le workflow `donnees.yml` compile puis teste cette galerie par HTTP. Le mode
`HORS_LIGNE=1` est distinct et ne prouve aucune interaction réseau.

Les modales avec focus/fond inerte, les choix déroulants et le lecteur Markdown
restent à préparer et à tester dans la bibliothèque avant leur adoption. Les
ressources d'identité ne sont pas modifiées, les droits restent réservés et
aucune police n'est ajoutée ni jointe aux contrôles. Aucun déploiement n'est
attaché à ces workflows.
