/* Cycle de vie du dialogue natif ; aucune donnée ni décision applicative. */
(() => {
  const ouverts = new Map();
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
      }
    }
  };
  new MutationObserver(synchroniser).observe(document.body, {childList: true, subtree: true});
  synchroniser();
})();
