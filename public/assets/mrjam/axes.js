/* Mesure/capture/focus. Les valeurs et la disposition sont calculées en Elm. */
(() => {
  const actifs = new Map();
  const annulations = new Map();
  const envoyer = (n, nom, detail) => n.dispatchEvent(new CustomEvent(nom, { detail, bubbles: true }));
  function relier(node) {
    if (actifs.has(node)) return;
    let pointeur;
    const mesure = new ResizeObserver(() => {
      if (node.isConnected && node.clientWidth > 0) envoyer(node, 'mrjam-axe-mesure', node.clientWidth);
    }); mesure.observe(node);
    const prendre = e => {
      if (e.button !== 0 || pointeur !== undefined || node.dataset.inactif === 'true') return;
      const directe = e.target.closest('[data-mrjam-poignee]');
      const distance = element => { const r = element.getBoundingClientRect(); return Math.hypot(e.clientX-r.x-r.width/2, e.clientY-r.y-r.height/2); };
      const proche = directe || [...node.querySelectorAll('[data-mrjam-poignee]')].filter(n => !n.disabled).sort((a,b) => distance(a)-distance(b))[0];
      if (!proche || proche.disabled) return;
      const verrou = Boolean(directe || e.target.closest('[data-mrjam-rail]'));
      if (verrou) e.preventDefault();
      pointeur = e.pointerId; node.setPointerCapture(pointeur); proche.focus({ preventScroll: true });
      envoyer(node, 'mrjam-axe-prise', { id: proche.dataset.mrjamPoignee, x: e.clientX, y: e.clientY, direct: Boolean(directe), verrou });
    };
    const deplacer = e => {
      if (e.pointerId === pointeur) envoyer(node, 'mrjam-axe-mouvement', { x: e.clientX, y: e.clientY });
    };
    const terminer = e => {
      if (e.pointerId !== pointeur) return;
      const ancien = pointeur; pointeur = undefined;
      envoyer(node, 'mrjam-axe-fin', { annule: e.type !== 'pointerup' });
      if (node.hasPointerCapture(ancien)) node.releasePointerCapture(ancien);
    };
    const clic = e => { if (e.detail > 0) { e.preventDefault(); e.stopPropagation(); } };
    annulations.set(node, () => {
      if (pointeur !== undefined) terminer({ pointerId: pointeur, type: 'pointercancel' });
    });
    node.addEventListener('pointerdown', prendre); node.addEventListener('pointermove', deplacer);
    for (const nom of ['pointerup','pointercancel','lostpointercapture']) node.addEventListener(nom, terminer);
    node.addEventListener('click', clic, true);
    actifs.set(node, () => {
      mesure.disconnect(); node.removeEventListener('pointerdown', prendre); node.removeEventListener('pointermove', deplacer);
      for (const nom of ['pointerup','pointercancel','lostpointercapture']) node.removeEventListener(nom, terminer);
      node.removeEventListener('click', clic, true);
    });
  }
  function parcourir() {
    for (const [n, annuler] of annulations) if (n.dataset.inactif === 'true') annuler();
    for (const [n, nettoyer] of actifs) if (!n.isConnected) { nettoyer(); actifs.delete(n); annulations.delete(n); }
    document.querySelectorAll('[data-mrjam-axe]').forEach(relier);
  }
  new MutationObserver(parcourir).observe(document.documentElement, { childList:true, subtree:true, attributes:true, attributeFilter:['data-inactif'] }); parcourir();
})();
