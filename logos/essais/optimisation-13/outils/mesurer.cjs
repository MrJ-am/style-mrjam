/* Banc local de comparaison SVG. Aucun code n’est ajouté au site. */
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const { createRequire } = require('node:module');
const requireOutils = createRequire(path.resolve(process.env.OUTILS_LOGO || 'ateliers/logo/package.json'));
const playwright = requireOutils('playwright');
const dossier = path.resolve(__dirname, '..');
const noms = ['G-uniforme-rgb', 'G-uniforme-oklch', 'G-adaptatif-rgb', 'G-adaptatif-oklch'];
const sources = noms.map(nom => fs.readFileSync(path.join(dossier, nom + '.svg'), 'utf8'));
const largeurs = (process.env.BENCH_TAILLES || '320,800,1600').split(',').map(Number);
const sortie = process.env.BENCH_SORTIE || 'mesures-brutes.json';
const moteurs = [
  ['chromium', { executablePath: process.env.CHROMIUM || '/usr/bin/chromium', args: ['--no-sandbox'] }],
  ['firefox', {}],
];

(async () => {
  const rapport = { date: new Date().toISOString(), machine: { plateForme: os.platform(), processeur: os.cpus()[0].model, coeurs: os.cpus().length }, noms, moteurs: [] };
  for (const [moteur, options] of moteurs) {
    const navigateur = await playwright[moteur].launch(options);
    const page = await navigateur.newPage({ viewport: { width: 1200, height: 900 }, deviceScaleFactor: 1 });
    const erreurs = [];
    page.on('pageerror', e => erreurs.push(e.message));
    await page.setContent('<!doctype html><title>Mesure locale SVG</title><canvas></canvas>');
    const resultat = await page.evaluate(async ({ sources, noms, largeurs }) => {
      if (!CSS.supports('color', 'oklch(0.7 0.1 10)')) throw Error('OKLCH non pris en charge');
      let graine = 20261013;
      const aleatoire = () => { graine = (1664525 * graine + 1013904223) >>> 0; return graine / 4294967296; };
      const ordre = () => { const a = [0, 1, 2, 3]; for (let i = 3; i > 0; i--) { const j = Math.floor(aleatoire() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; } return a; };
      const charger = async source => {
        const url = URL.createObjectURL(new Blob([source], { type: 'image/svg+xml' }));
        const img = new Image(); img.src = url; await img.decode(); return { img, url };
      };
      const canvas = document.querySelector('canvas');
      const ctx = canvas.getContext('2d', { willReadFrequently: true, colorSpace: 'srgb' });
      const peint = (img, w, h) => { ctx.clearRect(0, 0, w, h); ctx.drawImage(img, 0, 0, w, h); return ctx.getImageData(0, 0, w, h); };
      const froid = [], chaud = [], pixels = [];
      for (const largeur of largeurs) {
        const hauteur = Math.round(largeur * 1350 / 800);
        canvas.width = largeur; canvas.height = hauteur;
        const n = largeur === 800 ? 60 : 30;
        // Chaque mesure froide utilise un nouveau Blob : pas de cache URL partagé.
        for (let tour = -5; tour < n; tour++) {
          for (const index of ordre()) {
            const debut = performance.now(); const { img, url } = await charger(sources[index]);
            const decode = performance.now(); peint(img, largeur, hauteur); const fin = performance.now();
            URL.revokeObjectURL(url);
            if (tour >= 0) froid.push({ largeur, tour, nom: noms[index], decodage: decode - debut, renduLecture: fin - decode, total: fin - debut });
          }
        }
        // Repeindre la même image décodée. Lecture complète pour forcer le travail.
        const images = await Promise.all(sources.map(charger));
        for (let tour = -5; tour < n; tour++) {
          for (const index of ordre()) {
            const debut = performance.now(); peint(images[index].img, largeur, hauteur); const fin = performance.now();
            if (tour >= 0) chaud.push({ largeur, tour, nom: noms[index], total: fin - debut });
          }
        }
        const reference = peint(images[0].img, largeur, hauteur).data;
        for (let i = 1; i < 4; i++) {
          const valeurs = peint(images[i].img, largeur, hauteur).data;
          let max = 0, somme = 0, differents = 0, canaux = 0;
          for (let j = 0; j < valeurs.length; j += 4) {
            let diff = false;
            for (let c = 0; c < 3; c++) { const e = Math.abs(valeurs[j + c] - reference[j + c]); max = Math.max(max, e); somme += e; if (e) { diff = true; canaux++; } }
            if (diff) differents++;
          }
          pixels.push({ largeur, nom: noms[i], reference: noms[0], ecartCanalMax: max, ecartCanalMoyen: somme / (largeur * hauteur * 3), pixelsDifferents: differents, canauxDifferents: canaux });
        }
        for (const e of images) URL.revokeObjectURL(e.url);
      }
      return { froid, chaud, pixels, agent: navigator.userAgent, contexte: ctx.getContextAttributes() };
    }, { sources, noms, largeurs });
    rapport.moteurs.push({ moteur, version: navigateur.version(), erreurs, ...resultat });
    fs.writeFileSync(path.join(dossier, sortie), JSON.stringify(rapport, null, 2) + '\n');
    console.log(moteur, navigateur.version(), 'mesures terminées', resultat.pixels);
    await navigateur.close();
    if (erreurs.length) throw Error(erreurs.join('\n'));
  }
})().catch(e => { console.error(e); process.exit(1); });
