const { test, expect } = require('@playwright/test');
const fs = require('node:fs');
const attendre = page => page.evaluate(() => new Promise(r => requestAnimationFrame(r)));
const scene = page => page.locator('[data-svg="main-scene"]');
const faces = page => scene(page).locator('g[data-instance] use').evaluateAll(elements => elements.filter(e => +e.getAttribute('opacity') > 0).map(e => [e.parentElement.dataset.instance, e.getAttribute('transform'), e.getAttribute('opacity')]));

for (const strategie of ['relief', 'fondu']) {
  test(`Y : extrémités, copies historiques et retour en ${strategie}`, async ({ page }, info) => {
    await page.goto(`/?cible=Y&strategie=${strategie}`);
    const logo = await faces(page);
    expect(logo).toHaveLength(4);
    await page.getByRole('button', {name:'Fixer Y', exact:true}).click(); await attendre(page);
    const y = await faces(page);
    expect(y).toHaveLength(8);
    expect(y[2][1]).toBe(y[4][1]); expect(y[3][1]).toBe(y[5][1]);
    await expect(scene(page).locator('[data-background]')).toHaveAttribute('fill', '#64c29b');
    await page.getByRole('button', {name:'Fixer le logo', exact:true}).click(); await attendre(page);
    expect(await faces(page)).toEqual(logo);
    await page.getByRole('button', {name:'Fixer Y', exact:true}).click(); await attendre(page);
    expect(await faces(page)).toEqual(y);
    fs.mkdirSync(`verification/captures/${info.project.name}`, {recursive:true});
    await scene(page).screenshot({path:`verification/captures/${info.project.name}/y-${strategie}.png`});
    const exportation = page.waitForEvent('download');
    await page.getByRole('button', {name:/Exporter la scène SVG/}).click();
    const fichier = await exportation;
    expect(fichier.suggestedFilename()).toBe('scene-logo-y.svg');
    const svg = fs.readFileSync(await fichier.path(),'utf8');
    expect(svg.match(/<use /g)).toHaveLength(8);
    expect(svg.match(/<path /g)).toHaveLength(3);
  });
}

test('Y : pause, reprise et inversion pendant la lecture', async ({page}) => {
  await page.clock.install({time:new Date('2026-10-07T12:00:00Z')});
  await page.clock.pauseAt(new Date('2026-10-07T12:00:01Z'));
  await page.goto('/?cible=Y');
  const progression = async () => +(await page.locator('[data-progress]').getAttribute('data-progress'));
  await page.getByRole('button',{name:'Logo → Y',exact:true}).click(); await page.clock.runFor(1300);
  expect(await progression()).toBeGreaterThan(.2);
  await page.getByRole('button',{name:/Pause/}).click(); await page.clock.runFor(20);
  const figees = await faces(page);
  await page.clock.runFor(8000); expect(await faces(page)).toEqual(figees);
  await page.getByRole('button',{name:'Y → Logo',exact:true}).click(); await page.clock.runFor(20);
  const avant = await progression(); await page.clock.runFor(300);
  expect(await progression()).toBeLessThan(avant);
  await page.getByRole('button',{name:'Personnage X',exact:true}).click(); await page.clock.runFor(20);
  expect(await progression()).toBe(0);
  await expect(page.locator('[data-running]')).toHaveAttribute('data-running','false');
  await expect(page.getByRole('button',{name:'Fixer X',exact:true})).toBeVisible();
});

test('Y : inspection des doublons et exports statiques', async ({page}) => {
  await page.goto('/?cible=Y&vue=geometrie');
  await expect(page.getByRole('heading',{name:'Les huit correspondances'})).toBeVisible();
  await expect(page.getByText(/path14 double path8/)).toBeVisible();
  await page.getByRole('button',{name:'path14',exact:true}).click(); await attendre(page);
  await expect(page.locator('[data-selected]')).toHaveAttribute('data-selected','kinesthesique-2');
  const ids = await page.locator('[id]').evaluateAll(es => es.map(e=>e.id));
  expect(new Set(ids).size).toBe(ids.length);
  const exportation = page.waitForEvent('download');
  await page.getByRole('button',{name:'↓ Y factorisé SVG',exact:true}).click();
  const fichier = await exportation;
  const recu = fs.readFileSync(await fichier.path(),'utf8');
  const attendu = fs.readFileSync('dist/exports/Y-factorise.svg','utf8');
  // Math.cos peut différer d’un dernier bit entre V8 et SpiderMonkey.
  const matrices = texte => [...texte.matchAll(/matrix\(([^)]+)\)/g)].map(m=>m[1].split(' ').map(Number));
  expect(recu.replace(/matrix\([^)]+\)/g,'MATRICE')).toBe(attendu.replace(/matrix\([^)]+\)/g,'MATRICE'));
  const cibles = matrices(attendu);
  matrices(recu).forEach((m,i)=>m.forEach((v,j)=>expect(Math.abs(v-cibles[i][j])).toBeLessThan(1e-12)));
});

for (const largeur of [320,375,768,1440]) {
  test(`Y et philosophie : navigation et cadrage à ${largeur}px`, async ({page},info) => {
    await page.setViewportSize({width:largeur,height:1000});
    const erreurs=[]; page.on('pageerror',e=>erreurs.push(e.message));
    for (const vue of ['recomposition','geometrie']) {
      await page.goto(`/?cible=Y&vue=${vue}&p=1`);
      if (largeur === 320) await page.addStyleTag({content:'.mrjam-ecran { font-family: "DejaVu Sans", sans-serif !important }'});
      await expect.poll(() => page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(largeur);
    }
    await page.getByRole('link',{name:'Philosophie du logo',exact:true}).click();
    await expect(page).toHaveURL(/philosophie.html$/);
    if (largeur === 320) await page.addStyleTag({content:'.mrjam-ecran { font-family: "DejaVu Sans", sans-serif !important }'});
    await expect(page.getByRole('heading',{name:'Un esprit ouvert à l’expérience.'})).toBeVisible();
    await expect(page.getByRole('heading',{name:'La croissance inscrite dans le dessin.'})).toBeVisible();
    await expect.poll(() => page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(largeur);
    expect(await page.getByRole('img').count()).toBe(7);
    await page.screenshot({path:`verification/captures/${info.project.name}/philosophie-${largeur}.png`,fullPage:true});
    await page.getByRole('link',{name:'Explorer les briques dans l’atelier →',exact:true}).click();
    await expect(page.getByRole('heading',{name:'Les huit correspondances'})).toBeVisible();
    expect(erreurs).toEqual([]);
  });
}

test('Y : cadrage de toutes les étapes et des deux stratégies',async ({page})=>{
  for(const strategie of ['relief','fondu']){
    await page.goto(`/?cible=Y&strategie=${strategie}`);
    for(let p=0;p<=100;p+=4){
      await page.getByRole('slider',{name:'Progression',exact:true}).evaluate((e,v)=>{e.value=v;e.dispatchEvent(new Event('input',{bubbles:true}));},String(p));
      await attendre(page);
      const boites=await scene(page).locator('g[data-instance]').evaluateAll(es=>es.filter(e=>+e.dataset.opacity>0).map(e=>{const b=e.getBBox();return [b.x,b.y,b.x+b.width,b.y+b.height];}));
      for(const [x,y,d,b] of boites){expect(x).toBeGreaterThanOrEqual(-9);expect(y).toBeGreaterThanOrEqual(-12);expect(d).toBeLessThanOrEqual(39);expect(b).toBeLessThanOrEqual(36);}
    }
  }
});
