const { test, expect } = require('@playwright/test');
const fs = require('node:fs');
const path = require('node:path');

const virtualClocks = new WeakSet();
const settle = async page => {
  if (virtualClocks.has(page)) await page.clock.runFor(20);
  else await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => resolve())));
};
const setChecked = async (page, name, checked) => {
  const checkbox = page.getByRole('checkbox', { name, exact: typeof name === 'string' });
  if ((await checkbox.isChecked()) !== checked) await checkbox.click();
  await settle(page);
  if (checked) await expect(checkbox).toBeChecked(); else await expect(checkbox).not.toBeChecked();
};
const scene = page => page.locator('[data-svg="main-scene"]');
const progress = page => page.locator('[data-progress]').getAttribute('data-progress').then(Number);
const setSlider = async (page, name, value) => {
  const slider = page.getByRole('slider', { name, exact: true });
  await slider.evaluate((input, v) => { input.value = String(v); input.dispatchEvent(new Event('input', { bubbles: true })); }, value);
  await settle(page);
};
const visibleFaces = page => scene(page).locator('g[data-instance]').evaluateAll(groups => groups.flatMap(group => [...group.querySelectorAll('use')].filter(use => Number(use.getAttribute('opacity')) > 0).map(use => ({ id: group.dataset.instance, transform: use.getAttribute('transform'), opacity: use.getAttribute('opacity') }))));
const capture = async (page, info, name, locator) => {
  const file = path.join('verification/captures', info.project.name, `${name}.png`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  if (locator) await locator.screenshot({ path: file });
  else await page.screenshot({ path: file, fullPage: true });
};
const clock = async page => {
  const time = new Date('2026-10-07T12:00:00Z');
  await page.clock.install({ time });
  await page.clock.pauseAt(new Date(time.getTime() + 1000));
  virtualClocks.add(page);
};

test('page autonome, ressources locales et console sans erreur', async ({ page }, info) => {
  const errors = [];
  const requests = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => { if (message.type() === 'error') errors.push(message.text()); });
  page.on('response', response => { if (response.status() >= 400) errors.push(`${response.status()} ${response.url()}`); });
  page.on('request', request => requests.push(request.url()));
  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Du logo au mouvement.' })).toBeVisible();
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  expect(await scene(page).locator('defs > *').count()).toBe(4);
  expect(await scene(page).locator('defs path').count()).toBe(3);
  expect(errors).toEqual([]);
  expect(requests.filter(url => !url.startsWith('http://127.0.0.1:4187') && !url.startsWith('data:'))).toEqual([]);
  await capture(page, info, '01-logo-desktop');
});

test('captures déterministes : logo, milieu, X et dispersion', async ({ page }, info) => {
  for (const [name, url] of [
    ['02-logo', '/?p=0'], ['03-recomposition-milieu', '/?p=0.5'],
    ['04-x-final', '/?p=1'], ['05-fondu-local-milieu', '/?p=0.5&strategie=fondu'],
    ['06-dispersion', '/?vue=rotation&p=0.5']
  ]) {
    await page.goto(url);
    await capture(page, info, name, scene(page));
    const faces = await visibleFaces(page);
    expect(JSON.stringify(faces)).not.toMatch(/NaN|Infinity/);
    if (name === '02-logo') expect(faces).toHaveLength(4);
    if (name === '04-x-final') {
      expect(faces).toHaveLength(7);
      await expect(scene(page).locator('[data-background]')).toHaveAttribute('fill', '#9c3e65');
    }
  }
});

test('pause, reprise, inversion, scrub et clics rapides', async ({ page }) => {
  await clock(page);
  await page.goto('/');
  const definitions = await scene(page).locator('defs').innerHTML();
  await page.getByRole('button', { name: /Lire/, exact: false }).click(); await settle(page);
  await page.clock.runFor(1200);
  const moving = await progress(page);
  expect(moving).toBeGreaterThan(0.2);
  expect(moving).toBeLessThan(0.4);
  await page.getByRole('button', { name: /Pause/ }).click(); await settle(page);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  const frozen = await visibleFaces(page);
  const frozenBackground = await scene(page).locator('[data-background]').getAttribute('fill');
  await page.clock.runFor(10000);
  expect(await visibleFaces(page)).toEqual(frozen);
  expect(await scene(page).locator('[data-background]').getAttribute('fill')).toBe(frozenBackground);
  await page.getByRole('button', { name: /Lire/ }).click(); await settle(page);
  await page.clock.runFor(400);
  expect(await progress(page)).toBeGreaterThan(moving);
  await page.getByRole('button', { name: 'X → Logo', exact: true }).click(); await settle(page);
  const turn = await progress(page);
  await page.clock.runFor(300);
  expect(await progress(page)).toBeLessThan(turn);
  await setSlider(page, 'Progression', 63.2);
  await page.clock.runFor(16);
  expect(await progress(page)).toBeCloseTo(0.632, 8);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  for (let i = 0; i < 8; i++) await page.getByRole('button', { name: i % 2 ? 'Logo → X' : 'X → Logo', exact: true }).click(); await settle(page);
  await page.getByRole('button', { name: /Recommencer/ }).click(); await settle(page);
  await page.clock.runFor(6000);
  expect(await progress(page)).toBe(0);
  expect(await scene(page).locator('defs').innerHTML()).toEqual(definitions);
});

test('lecture et inspection manuelle produisent la même scène', async ({ page, context }) => {
  await clock(page);
  await page.goto('/');
  await page.getByRole('button', { name: /Lire/ }).click(); await settle(page);
  await page.clock.runFor(1780);
  await page.getByRole('button', { name: /Pause/ }).click(); await settle(page);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  const p = await progress(page);
  const playing = await visibleFaces(page);
  const manual = await context.newPage();
  await manual.goto(`/?p=${p}`);
  expect(await visibleFaces(manual)).toEqual(playing);
  await manual.close();
});

test('stratégies : remise au logo, cible commune sans fantôme', async ({ page }) => {
  await page.goto('/?p=1');
  const relief = await visibleFaces(page);
  await setSlider(page, 'Progression', 54);
  await page.getByRole('button', { name: 'Fondu local', exact: true }).click(); await settle(page);
  expect(await progress(page)).toBe(0);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  expect(await visibleFaces(page)).toHaveLength(4);
  await page.getByRole('button', { name: 'Fixer X', exact: true }).click(); await settle(page);
  expect(await visibleFaces(page)).toEqual(relief);
  await setChecked(page, 'Fondu du fond', false);
  await page.getByRole('button', { name: 'Fixer X', exact: true }).click(); await settle(page);
  await expect(scene(page).locator('[data-background]')).toHaveAttribute('fill', '#64c29b');
});

test('boucles déterministes et arrêt par le curseur', async ({ page }) => {
  await clock(page);
  await page.goto('/');
  await setSlider(page, 'Durée de l’aller', 0.2);
  await setChecked(page, /Boucle aller-retour/, true);
  await page.getByRole('button', { name: /Lire/ }).click(); await settle(page);
  await page.clock.runFor(7300);
  expect(await progress(page)).toBeGreaterThanOrEqual(0);
  expect(await progress(page)).toBeLessThanOrEqual(1);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'true');
  await page.getByRole('button', { name: 'Fixer le logo', exact: true }).click(); await settle(page);
  await page.clock.runFor(2000);
  expect(await progress(page)).toBe(0);
  expect(await visibleFaces(page)).toHaveLength(4);
});

test('onglet masqué : suspension sans rattrapage au retour', async ({ page }) => {
  await clock(page);
  await page.goto('/');
  await page.getByRole('button', { name: /Lire/ }).click(); await settle(page);
  await page.clock.runFor(600);
  await page.evaluate(() => {
    Object.defineProperty(document, 'hidden', { configurable: true, value: true });
    document.dispatchEvent(new Event('visibilitychange'));
  });
  await page.clock.runFor(20);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  const p = await progress(page);
  await page.clock.runFor(180000);
  await page.evaluate(() => {
    Object.defineProperty(document, 'hidden', { configurable: true, value: false });
    document.dispatchEvent(new Event('visibilitychange'));
  });
  expect(await progress(page)).toBe(p);
});

test('réduction du mouvement, clavier et lecture volontaire', async ({ page }) => {
  await page.emulateMedia({ reducedMotion: 'reduce' });
  await page.goto('/');
  await expect(page.getByRole('button', { name: 'Fondu local', exact: true })).toHaveAttribute('aria-pressed', 'true');
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  await expect(page.getByRole('checkbox', { name: /Boucle aller-retour/ })).not.toBeChecked();
  await page.getByRole('slider', { name: 'Progression', exact: true }).focus();
  await page.keyboard.press('ArrowRight');
  await expect.poll(() => progress(page)).toBeGreaterThan(0);
  await page.getByRole('button', { name: /Lire/ }).click(); await settle(page);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'true');
  expect(await page.locator('svg [aria-live]').count()).toBe(0);
  expect(await page.getByRole('slider').evaluateAll(nodes => nodes.every(n => !n.closest('[aria-live]')))).toBe(true);
});

test('inspecteur : avant, pendant et après la tranche ; fondu local', async ({ page }, info) => {
  await page.goto('/?vue=geometrie');
  const inspector = page.locator('[data-svg="mirror-inspector"]');
  for (const [name, percentage] of [['avant-tranche', 49], ['tranche', 50], ['apres-tranche', 51]]) {
    await setSlider(page, 'Progression locale du miroir', percentage);
    await expect(inspector.locator('g[data-instance]')).toHaveAttribute('data-mirror', String(percentage / 100));
    await capture(page, info, `07-${name}`, inspector);
    const matrix = await inspector.locator('use').getAttribute('transform');
    const values = matrix.match(/matrix\((.*)\)/)[1].split(' ').map(Number);
    expect(values.every(Number.isFinite)).toBe(true);
    if (percentage === 50) expect(values[0]).toBe(0);
    if (percentage < 50) expect(values[0]).toBeGreaterThan(0);
    if (percentage > 50) expect(values[0]).toBeLessThan(0);
  }
  await page.getByRole('button', { name: '90°', exact: true }).click(); await settle(page);
  await page.getByRole('button', { name: 'Fondu local', exact: true }).click(); await settle(page);
  expect(await inspector.locator('use').count()).toBe(2);
  expect(await inspector.locator('use').evaluateAll(nodes => nodes.map(n => n.getAttribute('opacity')))).toEqual(['0.5', '0.5']);
  await capture(page, info, '08-fondu-local-inspecteur', inspector);
});

test('géométrie : comparaison, sélection, isolation et identifiants uniques', async ({ page }, info) => {
  await page.goto('/?vue=geometrie');
  const ids = await page.locator('[id]').evaluateAll(elements => elements.map(element => element.id));
  expect(new Set(ids).size).toBe(ids.length);
  await page.getByRole('button', { name: 'path8', exact: true }).click(); await settle(page);
  await expect(page.locator('[data-selected]')).toHaveAttribute('data-selected', 'visuel-1');
  await setChecked(page, 'Isoler la sélection', true);
  expect(await page.locator('[data-svg="comparison"] g[data-instance]').count()).toBe(1);
  await setChecked(page, 'Masquer cette occurrence', true);
  expect(await page.locator('[data-svg="comparison"] g[data-instance]').count()).toBe(0);
  await setChecked(page, 'Masquer cette occurrence', false);
  await setChecked(page, 'Isoler la sélection', false);
  await page.getByRole('button', { name: 'Écart visuel', exact: true }).click(); await settle(page);
  await expect(page.locator('[data-svg="comparison"] image')).toHaveAttribute('style', /mix-blend-mode:difference/);
  await capture(page, info, '09-ecart-x', page.locator('[data-svg="comparison"]'));
});

test('export SVG et import/export des réglages', async ({ page }) => {
  await page.goto('/?p=1');
  const exportPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: /Exporter la scène SVG/ }).click(); await settle(page);
  const exported = await exportPromise;
  const svg = fs.readFileSync(await exported.path(), 'utf8');
  expect(svg.match(/<use /g)).toHaveLength(7);
  expect(svg.match(/<path /g)).toHaveLength(3);
  expect(svg).toContain('#9c3e65');
  const jsonPromise = page.waitForEvent('download');
  await page.getByRole('button', { name: /Enregistrer les réglages/ }).click(); await settle(page);
  const json = await jsonPromise;
  const settings = JSON.parse(fs.readFileSync(await json.path(), 'utf8'));
  expect(settings.version).toBe(1);
  settings.duration = 6.3;
  settings.strategy = 'fondu';
  const chooserPromise = page.waitForEvent('filechooser');
  await page.getByRole('button', { name: /Charger des réglages/ }).click(); await settle(page);
  const chooser = await chooserPromise;
  await chooser.setFiles({ name: 'reglages.json', mimeType: 'application/json', buffer: Buffer.from(JSON.stringify(settings)) });
  await expect(page.getByRole('slider', { name: 'Durée de l’aller', exact: true })).toHaveValue('6.3');
  await expect(page.getByRole('button', { name: 'Fondu local', exact: true })).toHaveAttribute('aria-pressed', 'true');
  expect(await progress(page)).toBe(0);
});

test('centrifugation : réglages extrêmes et cadrage fixe sans clipping', async ({ page }) => {
  await page.goto('/?vue=rotation');
  await setSlider(page, 'Durée du mouvement', 0.2);
  await setSlider(page, 'Repos à chaque extrémité', 0);
  await setSlider(page, 'Nombre de tours', 8);
  await setSlider(page, 'Écartement maximal', 6);
  const box = await scene(page).getAttribute('viewBox');
  for (let p = 0; p <= 100; p += 2) {
    await setSlider(page, 'Progression', p);
    await expect.poll(() => progress(page)).toBeCloseTo(p / 100, 6);
    const bounds = await scene(page).locator('g[data-instance]').evaluateAll(nodes => nodes.map(node => {
      const b = node.getBBox(); return { id: node.dataset.instance, x: b.x, y: b.y, right: b.x + b.width, bottom: b.y + b.height };
    }));
    for (const b of bounds) {
      expect(b.x, b.id).toBeGreaterThanOrEqual(-15);
      expect(b.y, b.id).toBeGreaterThanOrEqual(-20);
      expect(b.right, b.id).toBeLessThanOrEqual(45);
      expect(b.bottom, b.id).toBeLessThanOrEqual(40);
    }
    expect(await scene(page).getAttribute('viewBox')).toBe(box);
  }
  await setSlider(page, 'Nombre de tours', 0);
  const initial = await visibleFaces(page);
  await setSlider(page, 'Progression', 50);
  expect(await visibleFaces(page)).toEqual(initial);
});

for (const viewport of [{ width: 320, height: 800 }, { width: 375, height: 850 }, { width: 768, height: 1024 }, { width: 1440, height: 1000 }]) {
  test(`trois vues sans débordement à ${viewport.width}px`, async ({ page }, info) => {
    await page.setViewportSize(viewport);
    for (const tab of ['recomposition', 'rotation', 'geometrie']) {
      await page.goto(`/?vue=${tab}&p=1`);
      if (viewport.width === 320) await page.addStyleTag({ content: '.app-root { font-family: "DejaVu Sans", sans-serif !important }' });
      // Attendre la mise en page après le redimensionnement et l’injection des styles ElmUI.
      await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth)).toBeLessThanOrEqual(viewport.width);
      expect(await page.getByRole('slider').evaluateAll(inputs => inputs.every(input => {
        const box = input.getBoundingClientRect(); return box.left >= 0 && box.right <= innerWidth && box.width > 100;
      }))).toBe(true);
      if (viewport.width !== 1440 || tab === 'geometrie') await capture(page, info, `10-${tab}-${viewport.width}`);
    }
  });
}

test('recomposition : cadrage aux bornes des réglages, deux stratégies', async ({ page }) => {
  for (const strategy of ['relief', 'fondu']) {
    await page.goto(`/?strategie=${strategy}`);
    await setSlider(page, 'Durée de l’aller', 0.2);
    await setSlider(page, 'Décalage des départs', 0.25);
    await setSlider(page, 'Fenêtre du retournement', 90);
    for (let p = 0; p <= 100; p += 4) {
      await setSlider(page, 'Progression', p);
      const bounds = await scene(page).locator('g[data-instance]').evaluateAll(nodes => nodes.filter(node => Number(node.dataset.opacity) > 0).map(node => {
        const b = node.getBBox(); return { id: node.dataset.instance, x: b.x, y: b.y, right: b.x + b.width, bottom: b.y + b.height };
      }));
      for (const b of bounds) {
        expect(b.x, b.id).toBeGreaterThanOrEqual(-9);
        expect(b.y, b.id).toBeGreaterThanOrEqual(-12);
        expect(b.right, b.id).toBeLessThanOrEqual(39);
        expect(b.bottom, b.id).toBeLessThanOrEqual(36);
      }
    }
  }
});

test('interaction tactile avec le curseur', async ({ browser }) => {
  const context = await browser.newContext({ viewport: { width: 375, height: 850 }, hasTouch: true });
  const page = await context.newPage();
  await page.goto('http://127.0.0.1:4187/');
  const slider = page.getByRole('slider', { name: 'Progression', exact: true });
  await slider.scrollIntoViewIfNeeded();
  const box = await slider.boundingBox();
  await page.touchscreen.tap(box.x + box.width * 0.7, box.y + box.height / 2);
  await expect.poll(() => progress(page)).toBeGreaterThan(0.5);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running', 'false');
  await context.close();
});

test('fichier HTML autonome ouvert directement', async ({ page }, info) => {
  test.skip(info.project.name === 'chromium', 'Le Chromium géré interdit les URL file: ; ouverture directe vérifiée avec Firefox.');
  await page.goto('file://' + path.resolve('dist/atelier-logo-x.html'));
  await expect(page.getByRole('heading', { name: 'Du logo au mouvement.' })).toBeVisible();
  await page.getByRole('button', { name: 'Fixer X', exact: true }).click(); await settle(page);
  expect(await visibleFaces(page)).toHaveLength(7);
});
