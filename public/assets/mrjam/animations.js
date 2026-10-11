/* Préférence du navigateur vers un port Elm ; aucune animation JavaScript. */
window.MrJamAnimations = {
  relier(port, {initiale = true} = {}) {
    if (!port || typeof port.send !== 'function') throw new Error('Port de réduction des animations absent');
    const preference = matchMedia('(prefers-reduced-motion: reduce)');
    const envoyer = evenement => port.send(evenement.matches);
    preference.addEventListener('change', envoyer);
    if (initiale) envoyer(preference);
    return () => preference.removeEventListener('change', envoyer);
  }
};
