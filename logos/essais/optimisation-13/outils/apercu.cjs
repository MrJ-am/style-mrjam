const fs = require('node:fs'), path = require('node:path');
const { createRequire } = require('node:module');
const outils = createRequire(path.resolve(process.env.OUTILS_LOGO || 'ateliers/logo/package.json'));
const { chromium } = outils('playwright');
const dossier = path.resolve(__dirname, '..');
(async () => {
  const b = await chromium.launch({ executablePath: process.env.CHROMIUM || '/usr/bin/chromium', args: ['--no-sandbox'] });
  const p = await b.newPage({ viewport: { width: 1260, height: 785 } });
  const variantes = [['uniforme-rgb', 'G · 501 étapes RGB'], ['adaptatif-rgb', 'G · 29 étapes RGB'], ['adaptatif-oklch', 'G · 29 étapes OKLCH']];
  const uri = nom => 'data:image/svg+xml;base64,' + fs.readFileSync(path.join(dossier, 'G-' + nom + '.svg')).toString('base64');
  await p.setContent('<style>body{margin:0;background:#f4f2f2;color:#49333a;font-family:system-ui}main{display:flex;gap:12px;padding:12px}figure{margin:0;background:white;width:404px}h2{font-size:18px;text-align:center;margin:20px 0 8px}p{text-align:center;font-size:13px;margin:0 0 8px}img{display:block;width:404px}</style><main>' + variantes.map(([nom, titre]) => `<figure><h2>${titre}</h2><p>Même silhouette · même progression t²</p><img src="${uri(nom)}"></figure>`).join('') + '</main>');
  await p.locator('img').evaluateAll(xs => Promise.all(xs.map(x => x.decode())));
  await p.screenshot({ path: path.join(dossier, 'comparaison.png') });
  await b.close();
})().catch(e => { console.error(e); process.exit(1); });
