/* Capture/mesure seulement : caméra, géométrie et présentation appartiennent
   au socle Elm. Pas de DOM construit, styles, animation ou boucle de polling. */
(() => {
  const actifs = new Map();
  const annulations = new Map();
  const envoyer = (node, nom, detail) => node.dispatchEvent(new CustomEvent(nom, { detail, bubbles: true }));
  function relier(node) {
    if (actifs.has(node)) return;
    let pointeur;
    const mesure = new ResizeObserver(() => {
      if (node.isConnected && node.clientWidth > 0) envoyer(node, 'mrjam-espace-mesure', { largeur: node.clientWidth, hauteur: node.clientHeight });
    });
    mesure.observe(node);
    const prendre = e => {
      if (e.button !== 0 || pointeur !== undefined || node.dataset.inactif === 'true') return;
      const bille = e.target.closest('[data-mrjam-bille]');
      pointeur = e.pointerId;
      node.setPointerCapture(pointeur);
      (bille || node).focus({ preventScroll: true });
      envoyer(node, 'mrjam-espace-prise', { x: e.clientX, y: e.clientY, id: bille?.dataset.mrjamBille ?? null });
    };
    const deplacer = e => {
      if (e.pointerId === pointeur) envoyer(node, 'mrjam-espace-mouvement', { x: e.clientX, y: e.clientY });
    };
    const terminer = e => {
      if (e.pointerId !== pointeur) return;
      const ancien = pointeur; pointeur = undefined;
      envoyer(node, 'mrjam-espace-fin', { annule: e.type !== 'pointerup' });
      if (node.hasPointerCapture(ancien)) node.releasePointerCapture(ancien);
    };
    // Le clic pointeur a déjà été traité par la séquence de capture ; le clic
    // clavier natif (detail=0) conserve l'action accessible du bouton elm-ui.
    const clic = e => { if (e.detail > 0) { e.preventDefault(); e.stopPropagation(); } };
    annulations.set(node, () => {
      if (pointeur !== undefined) terminer({ pointerId: pointeur, type: 'pointercancel' });
    });
    node.addEventListener('pointerdown', prendre);
    node.addEventListener('pointermove', deplacer);
    for (const nom of ['pointerup', 'pointercancel', 'lostpointercapture']) node.addEventListener(nom, terminer);
    node.addEventListener('click', clic, true);
    actifs.set(node, () => {
      mesure.disconnect();
      node.removeEventListener('pointerdown', prendre); node.removeEventListener('pointermove', deplacer);
      for (const nom of ['pointerup', 'pointercancel', 'lostpointercapture']) node.removeEventListener(nom, terminer);
      node.removeEventListener('click', clic, true);
    });
  }
  function parcourir() {
    for (const [n, annuler] of annulations) if (n.dataset.inactif === 'true') annuler();
    for (const [node, nettoyer] of actifs) if (!node.isConnected) { nettoyer(); actifs.delete(node); annulations.delete(node); }
    document.querySelectorAll('[data-mrjam-espace]').forEach(relier);
  }
  new MutationObserver(parcourir).observe(document.documentElement, { childList: true, subtree: true, attributes: true, attributeFilter: ['data-inactif'] });
  parcourir();
})();
