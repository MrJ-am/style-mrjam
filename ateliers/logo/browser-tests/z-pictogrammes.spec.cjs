const { test, expect } = require('@playwright/test');
const fs = require('node:fs');
const attendre = page => page.evaluate(() => new Promise(r => requestAnimationFrame(r)));
const scene = page => page.locator('[data-svg="main-scene"]');
const poses = page => scene(page).locator('g[data-instance] use').evaluateAll(es => es.filter(e => +e.getAttribute('opacity') > 0).map(e => [e.parentElement.dataset.instance, e.getAttribute('transform')]));

for (const strategie of ['relief', 'fondu']) {
  test(`Zoé : aller, export et retour en ${strategie}`, async ({page}, info) => {
    await page.goto(`/?cible=Z&strategie=${strategie}`);
    await expect(page.getByRole('button', {name:'Z · Zoé', exact:true})).toBeVisible();
    const logo = await poses(page);
    expect(logo).toHaveLength(4);
    await page.getByRole('button', {name:'Fixer Z', exact:true}).click(); await attendre(page);
    const zoe = await poses(page);
    expect(zoe).toHaveLength(5);
    await expect(scene(page).locator('[data-background]')).toHaveAttribute('fill', '#087f71');
    await page.getByRole('button', {name:'Fixer le logo', exact:true}).click(); await attendre(page);
    expect(await poses(page)).toEqual(logo);
    await page.getByRole('button', {name:'Fixer Z', exact:true}).click(); await attendre(page);
    expect(await poses(page)).toEqual(zoe);
    const prochain = page.waitForEvent('download');
    await page.getByRole('button', {name:/Exporter la scène SVG/}).click();
    const fichier = await prochain;
    expect(fichier.suggestedFilename()).toBe('scene-logo-z.svg');
    expect(fs.readFileSync(await fichier.path(),'utf8').match(/<use /g)).toHaveLength(5);
    fs.mkdirSync(`verification/captures/${info.project.name}`, {recursive:true});
    await scene(page).screenshot({path:`verification/captures/${info.project.name}/zoe-${strategie}.png`});
    await page.getByRole('button', {name:'Y · Idriss', exact:true}).click(); await attendre(page);
    expect(await poses(page)).toHaveLength(4);
    await expect(page.locator('[data-running]')).toHaveAttribute('data-running','false');
  });
}

test('les pictogrammes affichés et téléchargés contiennent la connaissance', async ({page}) => {
  await page.goto('/?cible=Z&vue=geometrie');
  for (const [nom, cle] of [['Audio','auditif'],['Visio','visuel'],['Kino','kinesthesique']]) {
    const icone = page.locator(`[data-svg="brick-${cle}"]`);
    expect(await icone.locator('g[data-instance] use').count()).toBe(2);
    await expect(icone.locator('g[data-instance="connaissance-0"] use')).toHaveAttribute('href', `#brick-${cle}-connaissance`);
    const prochain = page.waitForEvent('download');
    await page.getByRole('button',{name:`↓ ${nom} SVG`,exact:true}).click();
    const fichier = await prochain;
    expect(fichier.suggestedFilename()).toBe(`${nom}.svg`);
    const svg = fs.readFileSync(await fichier.path(),'utf8');
    expect(svg).toBe(fs.readFileSync(`dist/exports/${nom}.svg`,'utf8'));
    expect(svg.match(/<use /g)).toHaveLength(2);
    expect(svg).toContain(`href="#${cle}-connaissance"`);
  }
  await page.getByRole('link',{name:'Philosophie du logo',exact:true}).click();
  for (const cle of ['auditif','visuel','kinesthesique']) {
    expect(await page.locator(`[data-svg="sens-${cle}"] g[data-instance] use`).count()).toBe(2);
  }
  expect(await page.locator('body').innerText()).not.toMatch(/esprit|vidéo|mystique|présence intérieure/i);
  await page.getByRole('link',{name:'Explorer Zoé →',exact:true}).click();
  await expect(page).toHaveURL(/cible=Z/);
  expect(await poses(page)).toHaveLength(5);
});

test('Zoé : placements inspectables et deux formes du fichier SVG', async ({page}) => {
  await page.goto('/?cible=Z&vue=geometrie');
  await expect(page.getByRole('heading',{name:'Les cinq placements de Zoé'})).toBeVisible();
  await page.getByRole('button',{name:'diagonale',exact:true}).click(); await attendre(page);
  await expect(page.locator('[data-selected]')).toHaveAttribute('data-selected','kinesthesique-1');
  const prochain = page.waitForEvent('download');
  await page.getByRole('button',{name:'↓ Z factorisé SVG',exact:true}).click();
  const fichier = await prochain;
  expect(fichier.suggestedFilename()).toBe('Z-factorise.svg');
  expect(fs.readFileSync(await fichier.path(),'utf8').match(/<use /g)).toHaveLength(5);
  const source = await page.request.get(await page.getByRole('link',{name:'↓ Z.svg',exact:true}).getAttribute('href'));
  expect(source.ok()).toBe(true);
  expect(await source.text()).toBe(fs.readFileSync('dessins/Z.svg','utf8'));
  const ids = await page.locator('[id]').evaluateAll(es => es.map(e => e.id));
  expect(new Set(ids).size).toBe(ids.length);
});

for (const largeur of [320, 1440]) {
  test(`Zoé : contrôles et cadrage à ${largeur}px`, async ({page}) => {
    await page.setViewportSize({width:largeur,height:1000});
    for (const vue of ['recomposition','geometrie']) {
      await page.goto(`/?cible=Z&vue=${vue}&p=1`);
      if (largeur === 320) await page.addStyleTag({content:'.mrjam-ecran {font-family:"DejaVu Sans",sans-serif!important}'});
      await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth)).toBeLessThanOrEqual(largeur);
      for (const bouton of await page.getByRole('button').all()) {
        const boite = await bouton.boundingBox();
        // Contrat commun : actions compactes de 32 à 38 px, nominal 34 px.
        // Voir docs/INTERFACE-DOCUMENTAIRE.md à la racine du dépôt.
        expect(boite.height).toBeGreaterThanOrEqual(32);
        expect(boite.width).toBeGreaterThanOrEqual(24);
        expect(boite.x).toBeGreaterThanOrEqual(0);
        expect(boite.x + boite.width).toBeLessThanOrEqual(largeur);
      }
    }
  });
}

test('Zoé : toutes les étapes restent dans le cadrage', async ({page}) => {
  for (const strategie of ['relief','fondu']) {
    await page.goto(`/?cible=Z&strategie=${strategie}`);
    for (let p = 0; p <= 100; p += 4) {
      await page.getByRole('slider',{name:'Progression',exact:true}).evaluate((e,v) => {e.value=v;e.dispatchEvent(new Event('input',{bubbles:true}));}, String(p));
      await attendre(page);
      const boites = await scene(page).locator('g[data-instance]').evaluateAll(es => es.filter(e => +e.dataset.opacity>0).map(e => {const b=e.getBBox();return [b.x,b.y,b.x+b.width,b.y+b.height];}));
      for (const [x,y,d,b] of boites) {expect(x).toBeGreaterThanOrEqual(-9);expect(y).toBeGreaterThanOrEqual(-12);expect(d).toBeLessThanOrEqual(39);expect(b).toBeLessThanOrEqual(36);}
    }
  }
});
