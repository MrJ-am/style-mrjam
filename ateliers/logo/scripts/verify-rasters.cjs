// Capture the original, Elm export and live Elm endpoint in both browser engines.
const { chromium, firefox } = require('@playwright/test');
const { readFileSync, mkdirSync, existsSync } = require('node:fs');
const { execFileSync, spawn } = require('node:child_process');

const serveur = spawn('python3', ['-m', 'http.server', '4188', '--bind', '127.0.0.1', '--directory', 'dist'], {stdio:'ignore'});
(async () => {
  for (let essai = 0; essai < 50; essai++) {
    try { const reponse = await fetch('http://127.0.0.1:4188'); if (reponse.ok) break; } catch {}
    if (essai === 49) throw new Error('Serveur raster indisponible');
    await new Promise(r => setTimeout(r, 100));
  }
  mkdirSync('verification/rasters', { recursive: true });
  for (const [engine, launcher, options] of [
    ['chromium', chromium, { executablePath: process.env.CHROMIUM_PATH || (existsSync('/usr/bin/chromium') ? '/usr/bin/chromium' : undefined), args: ['--no-sandbox'] }],
    ['firefox', firefox, {}]
  ]) {
    const browser = await launcher.launch(options);
    const page = await browser.newPage({ viewport: { width: 1200, height: 1200 } });
    const app = await browser.newPage();
    for (const [name, original, p] of [['logo', 'logo', 0], ['x', 'X', 1], ['y', 'Y', 1]]) {
      await app.goto(`http://127.0.0.1:4188/?p=${p}&cible=${original}`);
      const live = await app.locator('[data-svg="main-scene"]').evaluate(svg => {
        const copy = svg.cloneNode(true);
        copy.setAttribute('viewBox', '0 0 30 30');
        return new XMLSerializer().serializeToString(copy);
      });
      const samples = [
        ['source', readFileSync(original === 'Y' ? 'references/Y-original.svg' : `references/kit_codex_logo_X/sources/${original}-original.svg`)],
        ['export', readFileSync(`dist/exports/${name === 'logo' ? 'Logo' : original}-factorise.svg`)],
        ['scene', Buffer.from(live)]
      ];
      for (const [kind, svg] of samples) {
        await page.setContent(`<style>html,body{margin:0;background:white}img{display:block;width:1200px;height:1200px}</style><img alt="Comparaison" src="data:image/svg+xml;base64,${svg.toString('base64')}">`);
        await page.locator('img').evaluate(img => img.decode());
        await page.screenshot({ path: `verification/rasters/${engine}-${name}-${kind}.png` });
      }
    }
    await browser.close();
  }
  execFileSync('python3', ['scripts/compare-raster-output.py'], { stdio: 'inherit' });
})().catch(error => { console.error(error); process.exitCode = 1; }).finally(() => serveur.kill());
