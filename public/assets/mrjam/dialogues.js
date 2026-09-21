/* Focus et fond inerte pour les dialogues ElmUI, y compris les superpositions.
 * Ce pont ne lit ni les données métier ni les ports applicatifs. */
(() => {
  let actif = null, precedents = [], neutralises = [], programme = false;
  const controles = noeud => [...noeud.querySelectorAll('button:not(:disabled),input:not(:disabled),select:not(:disabled),a[href],[tabindex="0"]')].filter(n => !n.closest('[inert]') && n.getClientRects().length);
  function retablir() { for (const [noeud, valeur] of neutralises) noeud.inert = valeur; neutralises = []; }
  function actualiser() {
    programme = false;
    const dialogues = [...document.querySelectorAll('[data-mrjam-dialogue]')];
    const suivant = dialogues.at(-1) || null;
    if (suivant === actif) return;
    retablir();
    if (suivant && !precedents.some(p => p.dialogue === suivant)) precedents.push({ dialogue: suivant, retour: document.activeElement });
    const fermes = precedents.filter(p => !p.dialogue.isConnected);
    precedents = precedents.filter(p => p.dialogue.isConnected);
    actif = suivant;
    if (actif) {
      const compagnons = [...document.querySelectorAll('[data-mrjam-compagnon]')];
      function isoler(parent) {
        for (const noeud of parent.children) {
          if (['STYLE','SCRIPT','LINK'].includes(noeud.tagName) || noeud === actif || compagnons.includes(noeud)) continue;
          if (noeud.contains(actif) || compagnons.some(c => noeud.contains(c))) isoler(noeud);
          else { neutralises.push([noeud, noeud.inert]); noeud.inert = true; }
        }
      }
      isoler(document.body);
      (fermes.at(-1)?.retour?.isConnected && actif.contains(fermes.at(-1).retour) ? fermes.at(-1).retour : actif).focus({ preventScroll: true });
    } else if (fermes.at(-1)?.retour?.isConnected) fermes.at(-1).retour.focus({ preventScroll: true });
  }
  new MutationObserver(() => { if (!programme) { programme = true; requestAnimationFrame(actualiser); } }).observe(document.body, { childList: true, subtree: true });
  document.addEventListener('keydown', evenement => {
    if (!actif) return;
    if (evenement.key === 'Escape') {
      const fermer = actif.querySelector('[data-mrjam-fermer] button,[data-mrjam-fermer] [role="button"],[data-mrjam-fermer][role="button"]');
      if (fermer) { evenement.preventDefault(); evenement.stopImmediatePropagation(); fermer.click(); }
    }
    if (evenement.key === 'Tab') {
      const liste = controles(actif), premier = liste[0], dernier = liste.at(-1);
      if (!premier) { evenement.preventDefault(); actif.focus(); }
      else if (evenement.shiftKey && (document.activeElement === premier || !liste.includes(document.activeElement))) { evenement.preventDefault(); dernier.focus(); }
      else if (!evenement.shiftKey && (document.activeElement === dernier || !actif.contains(document.activeElement))) { evenement.preventDefault(); premier.focus(); }
    }
  }, true);
  actualiser();
})();
