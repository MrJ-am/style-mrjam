# Lecture et notation facultative

`MrJam.Lectures.vue` compose un dialogue natif en elm-ui avec le contexte de
marque explicite. Le document défile ; entête et commandes sont distincts.
En paysage compact, les commandes occupent la colonne de droite. La référence
mesurée avec `mesurerReference` place le lecteur sous l'énoncé, au plus à32%
de la hauteur disponible. `reinitialiser` repart du début lors d'une sélection
différente et restitue le focus au lecteur. Les résultats DOM sont explicites.
Un seul lecteur et une seule note actifs par page : leurs identifiants sont fixes.

La transition d'entrée reçoit une timeline du socle Transitions. Les commandes
et la fermeture restent immédiatement disponibles ; la fermeture ne dépend
jamais de la fin d'une animation. L'appelant raccorde les préférences initiale
et live, conserve la timeline et borne son abonnement avec `Transitions.abonnement`.
Les aides appartiennent au même dialogue accessible, sans compagnon rendu inerte.

`MrJam.Curseurs.note` distingue la réponse `Maybe Float` et l'aperçu de geste.
Barème0..3, pas0,25 : zéro est une réponse, Nothing reste une absence. Le clavier
natif écrit la note ; le pont `notes.js` conserve la prise relative sans saut
initial du rail. Un aperçu ou un geste annulé ne valide aucune réponse. Le
consommateur conserve l'idempotence de ses opérations et événements métier.

Le pont manipule uniquement la saisie native, la capture de pointeur, le focus
et les événements d'aperçu/changement. Aucun nœud, style, HTML, animation ou
rafraîchissement de présentation n'est produit par JavaScript. L'adaptateur
Curseur.note a quatre constantes : width100%, height44px, opacity0 et pointer-events:none. Le proxy
natif invisible conserve l’accès clavier ; les pointeurs ciblent la surface elm-ui,
avec touch-action:none fixe. Cela évite qu’un input natif écrive avant un
pointercancel (observé sur Chromium tactile). Label,
barème, aide et noms d'événements sont fixes et contrôlés par l'AST central.

Le porteur natif dialog ne peut recevoir une marge depuis son contenu elm-ui.
Dialogue.margeLecture est donc une capacité unique : margin-top en pixels,
argument unique borné12..800. Aucun autre style configurable. Les attributs
communs restent dans attributsBase ; aucune copie de moteur de dialogue.
Les applications n'importent pas ces adaptateurs privés.

Qualification locale ciblée : notes.py (clavier/souris, trois largeurs,
aperçu sans écriture, annulation, zéro/absence ; tactile Chromium réel).
Firefox est une option explicite vers un binaire existant, sans installation
ou fallback. lecture.py vérifie quatre formats, mouvement normal/réduit,
défilement, changement de texte, focus et arrêt des frames. L'orchestrateur
central exécute ces tests ; les parcours réels des consommateurs restent requis.

Le lecteur reçoit aussi l’identifiant stable de la production affichée, exposé
par le seul attribut `production-id`. Ce repère ne fournit aucune autorisation.
Les tests des consommateurs peuvent ainsi vérifier le rattachement au contenu.

La marge est arrondie au plafond pour ne pas recouvrir le bord fractionnaire de
l’énoncé. fenetres.js restitue aussi le focus après disparition d’une aide, via
une vérification en fin de focusout ; aucun rafraîchissement permanent.
