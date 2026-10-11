/* Cycle de vie du dialogue natif ; aucune donnée ni décision applicative. */
(() => {
  const ouverts = new Map();
  const controles = dialogue => [...dialogue.querySelectorAll('button, input, textarea, select, a[href], [tabindex]')]
    .filter(cible => cible.tabIndex >= 0 && !cible.disabled && !cible.matches('[aria-disabled="true"]') && !cible.closest('[inert]') && cible.getClientRects().length);
  const restituer = () => {
    const sommet = [...ouverts.keys()].filter(d => d.isConnected && d.matches(':modal')).at(-1);
    if (sommet && !sommet.contains(document.activeElement)) {
      (controles(sommet)[0] || sommet).focus({ preventScroll: true });
    }
  };
  const synchroniser = () => {
    for (const [dialogue, cible] of ouverts) {
      if (!dialogue.isConnected) {
        ouverts.delete(dialogue);
        if (cible?.isConnected && !cible.closest('[inert]')) cible.focus();
      }
    }
    for (const dialogue of document.querySelectorAll('dialog[data-mrjam-modale]')) {
      if (!dialogue.open) {
        ouverts.set(dialogue, document.activeElement);
        dialogue.showModal();
        dialogue.addEventListener('keydown', evenement => {
          if (evenement.key !== 'Tab') return;
          const cibles = controles(dialogue);
          const premiere = cibles[0], derniere = cibles.at(-1);
          if (evenement.shiftKey && document.activeElement === premiere) {
            evenement.preventDefault(); derniere?.focus();
          } else if (!evenement.shiftKey && document.activeElement === derniere) {
            evenement.preventDefault(); premiere?.focus();
          }
        });
      }
    }
    // Fermer une aide au-dessus d'un lecteur peut laisser le focus sur body
    // quand son ancienne cible a disparu. Le fond reste nativement inerte :
    // restituer alors un contrôle du dialogue encore au sommet, sans déplacer
    // un focus qui y est déjà valide, et sans déclencher d'action applicative.
    restituer();
  };
  // Firefox peut retirer le focus après la notification des mutations, lorsque
  // le contrôle d'aide disparaît. Vérifier à la fin de cet événement natif ;
  // aucun polling et aucun déplacement entre deux contrôles encore valides.
  document.addEventListener('focusout', () => queueMicrotask(restituer));
  new MutationObserver(synchroniser).observe(document.body, {childList: true, subtree: true});
  synchroniser();
})();
