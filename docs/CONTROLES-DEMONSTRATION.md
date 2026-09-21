# Compléments communs pour le portage de Démonstration

Cette branche est une proposition additive issue de
`52ad33f881b50feef91d60915d17bae90abfc592`. Elle n'est ni une publication ni
une autorisation de déplacer les verrous des applications.

- `choixRiches` accepte des libellés ElmUI structurés, y compris un élément
  de rendu mathématique, sans importer KaTeX ni un correcteur. Les libellés ne
  doivent pas contenir de contrôle interactif. `choix` réutilise le même rendu.
- `champIdentifie` reçoit un contrat de saisie (identifiant, libellé, aide,
  exemple facultatif, limite facultative), puis la valeur et le message.
  Les espaces sont préservés. L'exemple utilise le placeholder natif pour ne
  pas polluer le nom accessible ; les identifiants permettent de rendre le focus.
- `lienActif` pose `aria-current="page"` ; `lienExterne` annonce le nouvel onglet
  et pose `noopener noreferrer`.
- `boutonDevoiler` associe le bouton au contenu et expose `aria-expanded`.
  L'application reste responsable de la présence et du contenu de l'aide.

Aucun symbole existant n'est renommé. Une référence a été compilée et la
nouvelle galerie a été compilée en mode optimisé, avec contrôles des empreintes,
du clavier, des libellés, de la limite de saisie et de quatre largeurs d'écran.
La CI exécute les mêmes interactions en HTTP, en complément du contrôle en
mémoire de l'atelier. Les ressources d'identité restent inchangées ; aucun
fichier de police n'est ajouté et la typographie exacte n'est pas validée.

Le sélecteur compact de navigation reste à mutualiser. L'application
`apprendre-a-demontrer` continue de compiler la révision **52ad33f…** : elle ne
consomme pas ces ajouts avant validation d'une nouvelle révision collective.
Les contrôles de galerie ne remplacent pas les tests d'intégration applicatifs.
