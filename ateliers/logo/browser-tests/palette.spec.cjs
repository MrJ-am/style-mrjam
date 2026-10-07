const {test, expect} = require('@playwright/test');
const fs = require('node:fs');
const roles = page => page.locator('[data-role-palette]');
const paire = page => roles(page).first().evaluate(e=>({l:Number(e.dataset.l),c:Number(e.dataset.c)}));
const plan = page => page.getByRole('group',{name:'Plan L × C',exact:true});
const valeurs = async (page,l,c) => {
  await page.getByRole('textbox',{name:'L · clarté',exact:true}).fill(l);
  await page.getByRole('textbox',{name:'C · chroma',exact:true}).fill(c);
  await page.getByRole('button',{name:'Appliquer L et C',exact:true}).click();
};

test('palette : rôles, géométrie et véritables SVG paramétrés',async({page})=>{
  const erreurs=[];page.on('pageerror',e=>erreurs.push(e.message));
  await page.goto('/palette.html');
  await expect(roles(page)).toHaveCount(8);
  expect(await paire(page)).toEqual({l:0.7,c:0.1});
  await expect(page.locator('[data-tetrade]')).toHaveCount(2);
  const couleurs=await roles(page).evaluateAll(es=>es.map(e=>({...e.dataset})));
  for(const col of couleurs){expect(+col.l).toBe(0.7);expect(+col.c).toBe(0.1);}
  const teintes=Object.fromEntries(couleurs.map(e=>[e.rolePalette,+e.h]));
  expect(teintes['mode-audio']).toBeCloseTo(47.507764,6);
  expect(teintes['mode-visio']).toBeCloseTo(227.507764,6);
  expect(teintes['mode-kino']).toBeCloseTo(317.507764,6);
  for(const [cle,n] of [['logo',4],['mode-audio',2],['mode-visio',2],['mode-kino',2],['xiaoping',7],['ydris',8],['zoe',5]]){
    const svg=page.locator(`[data-svg="palette-${cle}"]`);
    expect(await svg.locator('g[data-instance]').count()).toBe(n);
    await expect(svg.locator('[data-background]')).toHaveAttribute('fill',/^oklch\(/);
  }
  await expect(page.locator('[data-role-palette="licorne"]')).toContainText('Non retenu parmi les sept');
  await expect(page.locator('[data-svg="palette-logo-actuel"] [data-background]')).toHaveAttribute('fill','#64c29b');
  const ids=await page.locator('[id]').evaluateAll(es=>es.map(e=>e.id));expect(new Set(ids).size).toBe(ids.length);
  expect(erreurs).toEqual([]);
});

test('palette : souris continue, projection et relâchement hors du plan',async({page})=>{
  await page.goto('/palette.html');
  const b=await plan(page).boundingBox();
  await page.mouse.move(b.x+b.width*.2,b.y+b.height*.4);await page.mouse.down();
  const avant=await paire(page);
  await page.mouse.move(b.x+b.width*.4,b.y+b.height*.3,{steps:5});
  await expect.poll(()=>paire(page)).not.toEqual(avant);
  const durant=await paire(page);
  for(const col of await roles(page).evaluateAll(es=>es.map(e=>[+e.dataset.l,+e.dataset.c]))) expect(col).toEqual([durant.l,durant.c]);expect(durant.l).toBeCloseTo(.7,2);expect(durant.c).toBeGreaterThan(avant.c);
  await page.mouse.move(b.x+b.width+80,b.y+b.height*.3,{steps:5});await page.mouse.up();
  const frontiere=await paire(page);expect(frontiere.c).toBeLessThan(.2);
  await page.mouse.move(b.x+b.width*.1,b.y+b.height*.9);expect(await paire(page)).toEqual(frontiere);
  await valeurs(page,'0.7','10');expect((await paire(page)).c).toBeCloseTo(frontiere.c,2);
  await expect(page.getByRole('status')).toContainText('ramenée');
});

test('palette : clavier, saisies françaises, erreurs et URL exacte',async({page})=>{
  await page.goto('/palette.html?autre=conserve');
  await plan(page).focus();await expect(plan(page)).toBeFocused();await page.keyboard.press('ArrowUp');
  await expect.poll(async()=> (await paire(page)).l).toBe(.701);
  await page.keyboard.press('Shift+ArrowLeft');
  expect((await paire(page)).c).toBeCloseTo(.09,12);
  await expect(page.getByRole('status')).toContainText('L =');
  await page.getByRole('textbox',{name:'L · clarté',exact:true}).fill('0,712345678912345');
  await page.getByRole('textbox',{name:'C · chroma',exact:true}).fill('0,0912345678912345');
  await page.getByRole('textbox',{name:'C · chroma',exact:true}).press('Enter');
  const attendue={l:.712345678912345,c:.0912345678912345};
  await expect.poll(()=>paire(page)).toEqual(attendue);
  await expect.poll(()=>new URL(page.url()).searchParams.get('L')).toBe(String(attendue.l));
  expect(new URL(page.url()).searchParams.get('autre')).toBe('conserve');
  const url=page.url();await page.reload();expect(await paire(page)).toEqual(attendue);
  await valeurs(page,'invalide','0.1');await expect(page.getByRole('status')).toContainText('Saisissez');expect(await paire(page)).toEqual(attendue);
  await page.getByRole('button',{name:'État initial',exact:true}).click();expect(await paire(page)).toEqual({l:.7,c:.1});
  await page.goto(url);expect(await paire(page)).toEqual(attendue);
  await valeurs(page,'1','0.2');expect(await paire(page)).toEqual({l:1,c:0});
  await valeurs(page,'0','0.2');expect(await paire(page)).toEqual({l:0,c:0});
});

for(const largeur of [320,375,768,1440]){
 test(`palette : navigation et cadrage à ${largeur}px`,async({page},info)=>{
  await page.setViewportSize({width:largeur,height:1000});
  await page.goto('/');await page.getByRole('link',{name:'Palette OKLCH',exact:true}).click();
  await expect(page.getByRole('heading',{name:'Une palette, deux paramètres.'})).toBeVisible();
  await expect.poll(()=>page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(largeur);
  const b=await plan(page).boundingBox();expect(b.height).toBeGreaterThanOrEqual(280);expect(b.width).toBeGreaterThan(200);
  await valeurs(page,'.712345678912345','.0912345678912345');
  await expect.poll(()=>page.evaluate(()=>document.documentElement.scrollWidth)).toBeLessThanOrEqual(largeur);
  fs.mkdirSync(`verification/captures/${info.project.name}`,{recursive:true});
  await page.screenshot({path:`verification/captures/${info.project.name}/palette-${largeur}.png`,fullPage:true});
  await page.getByRole('link',{name:'Philosophie du logo',exact:true}).click();
  await page.getByRole('link',{name:'Palette OKLCH',exact:true}).click();
  await expect(page).toHaveURL(/palette.html/);
 });
}

test('palette : glissement tactile réel et absence de défilement du plan',async({browser},info)=>{
 test.skip(info.project.name!=='chromium','Injection tactile native via CDP dans Chromium ; souris et clavier couverts dans les deux moteurs.');
 const context=await browser.newContext({hasTouch:true,viewport:{width:375,height:900}});
 const page=await context.newPage();await page.goto('http://127.0.0.1:4187/palette.html');
 await plan(page).scrollIntoViewIfNeeded();const b=await plan(page).boundingBox();const scroll=await page.evaluate(()=>scrollY);
 const cdp=await context.newCDPSession(page);
 const point=(x,y)=>({x:b.x+b.width*x,y:b.y+b.height*y,id:1});
 await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[point(.2,.5)]});
 await cdp.send('Input.dispatchTouchEvent',{type:'touchMove',touchPoints:[point(.4,.3)]});
 await expect.poll(async()=> (await paire(page)).l).toBeCloseTo(.7,2);
 await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
 expect(await page.evaluate(()=>scrollY)).toBe(scroll);
 expect((await paire(page)).c).toBeGreaterThan(.02);
 await context.close();
});
