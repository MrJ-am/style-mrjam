/* Pointeurs relatifs de la note commune. ElmUI dessine la surface ; ce pont
   ne crée aucun nœud, style, animation ni horloge de présentation. */
(() => {
  const raccords = new WeakSet();
  function raccorder(surface) {
    if (raccords.has(surface)) return;
    const input = surface.querySelector('input[type="range"]');
    if (!input) return;
    raccords.add(surface);
    let geste;
    const apercu = valeur => input.dispatchEvent(new CustomEvent('mrjam-note-apercu', { detail: valeur, bubbles: true }));
    surface.addEventListener('pointerdown', event => {
      if (event.button !== 0 || geste) return;
      const boite = surface.getBoundingClientRect(), poignee = surface.querySelector('[data-testid="grade-knob"]').getBoundingClientRect();
      const direct = Math.abs(event.clientX - poignee.x - poignee.width / 2) < 24 && Math.abs(event.clientY - poignee.y - poignee.height / 2) < 24;
      const rail = Math.abs(event.clientY - boite.y - boite.height / 2) < 10;
      geste = { pointer: event.pointerId, x: event.clientX, y: event.clientY, valeur: Number(input.value), courante: Number(input.value), largeur: Math.max(1, boite.width - 32), direct, intent: direct || rail ? 'horizontal' : null, bouge: false, horizontal: false };
      input.focus({ preventScroll: true });
      surface.setPointerCapture(event.pointerId);
      event.preventDefault();
    });
    surface.addEventListener('pointermove', event => {
      if (!geste || event.pointerId !== geste.pointer) return;
      const dx = event.clientX - geste.x, dy = event.clientY - geste.y;
      if (Math.hypot(dx, dy) > 4) geste.bouge = true;
      if (!geste.bouge) return;
      geste.intent ??= Math.abs(dx) >= Math.abs(dy) ? 'horizontal' : 'vertical';
      if (geste.intent === 'vertical' || Math.abs(dx) <= 4) return;
      geste.horizontal = true;
      event.preventDefault();
      const valeur = Number(Math.max(0, Math.min(3, Math.round((geste.valeur + dx / geste.largeur * 3) / .25) * .25)).toFixed(8));
      if (valeur !== geste.courante) { geste.courante = valeur; input.value = valeur; apercu(valeur); }
    });
    function terminer(event) {
      if (!geste || event.pointerId !== geste.pointer) return;
      const termine = geste; geste = null;
      const annule = event.type !== 'pointerup' || termine.intent === 'vertical';
      input.value = annule ? termine.valeur : termine.courante;
      if (!annule && (termine.horizontal || (!termine.bouge && termine.direct))) input.dispatchEvent(new Event('change', { bubbles: true }));
      apercu(null);
      if (surface.hasPointerCapture(termine.pointer)) surface.releasePointerCapture(termine.pointer);
    }
    for (const event of ['pointerup', 'pointercancel', 'lostpointercapture']) surface.addEventListener(event, terminer);
  }
  function synchroniser() {
    document.querySelectorAll('[data-mrjam-note-relative]').forEach(raccorder);
  }
  new MutationObserver(synchroniser).observe(document.documentElement, { childList: true, subtree: true });
  synchroniser();
})();
