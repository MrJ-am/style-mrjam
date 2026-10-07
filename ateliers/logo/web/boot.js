(() => {
  const params = new URLSearchParams(location.search);
  const finite = (name, fallback) => {
    const value = Number(params.get(name));
    return params.has(name) && Number.isFinite(value) ? Math.max(0, Math.min(1, value)) : fallback;
  };
  const motion = matchMedia('(prefers-reduced-motion: reduce)');
  const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: {
      width: innerWidth,
      cible: params.get('cible') || 'X',
      reducedMotion: motion.matches,
      tab: params.get('vue') || 'recomposition',
      progress: finite('p', 0),
      mirror: finite('miroir', 0.5),
      strategy: params.get('strategie') || ''
    }
  });
  motion.addEventListener('change', event => app.ports.reducedMotionChanged.send(event.matches));
  app.ports.download.subscribe(({ name, mime, content }) => {
    const url = URL.createObjectURL(new Blob([content], { type: mime }));
    const link = document.createElement('a');
    link.href = url;
    link.download = name;
    link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  });
  app.ports.chooseSettings.subscribe(() => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = '.json,application/json';
    input.addEventListener('change', async () => {
      const file = input.files[0];
      if (!file) return;
      if (file.size > 65536) {
        app.ports.receivedSettings.send('invalid');
        return;
      }
      try { app.ports.receivedSettings.send(await file.text()); }
      catch { app.ports.receivedSettings.send('invalid'); }
    });
    input.click();
  });
})();
