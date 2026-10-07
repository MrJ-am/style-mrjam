(() => {
  const app = Elm.Palette.init({node: document.getElementById('app'), flags: {width: innerWidth, query: location.search}});
  app.ports.remplacerQuery.subscribe(query => {
    const url = new URL(location.href);
    // Conserver les autres paramètres et le fragment sans arrondir les valeurs Elm.
    const paire = new URLSearchParams(query);
    for (const cle of ['L', 'C']) url.searchParams.set(cle, paire.get(cle));
    if (url.href !== location.href) history.replaceState(null, '', url);
  });
  addEventListener('popstate', () => app.ports.navigationQuery.send(location.search));
  let actif = null, attente = null, frame = null;
  const envoyer = () => {
    frame = null;
    if (!actif || !attente) return;
    const rect = actif.element.getBoundingClientRect();
    app.ports.selectionPlan.send({x: (attente.clientX - rect.left) / rect.width, y: (attente.clientY - rect.top) / rect.height});
    attente = null;
  };
  const terminer = event => {
    if (!actif || event.pointerId !== actif.id) return;
    if (event.type === 'pointerup') attente = event;
    if (frame !== null) cancelAnimationFrame(frame);
    envoyer();
    if (actif.element.hasPointerCapture(actif.id)) actif.element.releasePointerCapture(actif.id);
    actif = attente = null;
  };
  document.addEventListener('pointerdown', event => {
    const element = event.target.closest('[data-palette-plan]');
    if (!element || actif || !event.isPrimary || event.button !== 0) return;
    event.preventDefault();
    element.focus({preventScroll:true});
    actif = {element, id:event.pointerId};
    element.setPointerCapture(event.pointerId);
    attente = event;
    envoyer();
  });
  document.addEventListener('pointermove', event => {
    if (!actif || event.pointerId !== actif.id) return;
    attente = event;
    if (frame === null) frame = requestAnimationFrame(envoyer);
  });
  for (const nom of ['pointerup', 'pointercancel', 'lostpointercapture']) document.addEventListener(nom, terminer);
})();
