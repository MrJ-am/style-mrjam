const {test, expect} = require('@playwright/test');
const fs = require('node:fs');
const reference = JSON.parse(fs.readFileSync('dist/exports/palette.json'));
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
  await page.goto('/palette.html?L=0.7&C=0.1');
  await expect(roles(page)).toHaveCount(8);
  expect(await paire(page)).toEqual({l:0.7,c:0.1});
  await expect(page.locator('[data-tetrade]')).toHaveCount(2);
  const couleurs=await roles(page).evaluateAll(es=>es.map(e=>({...e.dataset})));
  for(const col of couleurs){expect(+col.l).toBe(0.7);expect(+col.c).toBe(0.1);}
  const teintes=Object.fromEntries(couleurs.map(e=>[e.rolePalette,+e.h]));
  expect(teintes['mode-audio']).toBeCloseTo(47.507764,6);
  expect(teintes['mode-visio']).toBeCloseTo(227.507764,6);
  expect(teintes['mode-kino']).toBeCloseTo(317.507764,6);
  for(const [cle,n] of [['logo',4],['mode-audio',2],['mode-visio',2],['mode-kino',2],['xiaoping',7],['ydris',8],['zoe',5],['licorne',19]]){
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
  await page.goto('/palette.html?L=0.7&C=0.1');
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
  await page.goto('/palette.html?autre=conserve&L=0.7&C=0.1');
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
  await page.getByRole('button',{name:'Palette de référence',exact:true}).click();
  expect((await paire(page)).l).toBeCloseTo(reference.L,12);expect((await paire(page)).c).toBeCloseTo(reference.C,12);
  await page.goto(url);expect(await paire(page)).toEqual(attendue);
  await valeurs(page,'1','0.2');expect(await paire(page)).toEqual({l:1,c:0});
  await valeurs(page,'0','0.2');expect(await paire(page)).toEqual({l:0,c:0});
});

for(const largeur of [320,375,768,1440]){
 test(`palette : navigation et cadrage à ${largeur}px`,async({page},info)=>{
  await page.setViewportSize({width:largeur,height:1000});
  await page.goto('/');await page.getByRole('link',{name:'Palette OKLCH',exact:true}).click();
  await expect(page.getByRole('heading',{name:'Une palette, deux paramètres.'})).toBeVisible();
  if(largeur===320) await page.addStyleTag({content:'.mrjam-ecran {font-family:"DejaVu Sans",sans-serif!important}'});
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

test('palette : huit frontières fixes, enveloppe et contraintes actives',async({page})=>{
 await page.goto('/palette.html?L=0.7&C=0.1');
 const courbes=page.locator('[data-frontiere-role]');
 await expect(courbes).toHaveCount(8);
 await expect(page.locator('[data-gamut-frontiere]')).toHaveCount(1);
 const traces=await courbes.evaluateAll(es=>Object.fromEntries(es.map(e=>[e.dataset.frontiereRole,{h:+e.dataset.h,d:e.getAttribute('d'),couleur:e.getAttribute('stroke'),motif:e.getAttribute('stroke-dasharray')}])));
 for(const col of await roles(page).evaluateAll(es=>es.map(e=>e.dataset))){
   expect(traces[col.rolePalette].h).toBe(+col.h);
   expect(traces[col.rolePalette].couleur).toMatch(/^oklch\(/);
   expect(traces[col.rolePalette].d.split(' L')).toHaveLength(513);
 }
 expect(new Set(Object.values(traces).map(t=>t.motif)).size).toBe(8);
 await page.getByRole('button',{name:'Licorne rose invisible',exact:true}).click();
 await expect(page.locator('[data-frontiere-role="licorne"]')).toHaveAttribute('stroke-width','4');
 expect(await paire(page)).toEqual({l:.7,c:.1});
 const limite=page.locator('[data-limite-commune]');
 for(const l of ['0','0.2','0.7','0.95','1']){
   await valeurs(page,l,'1');
   expect((await paire(page)).c).toBe(+(await limite.getAttribute('data-limite-commune')));
   const actives=(await limite.getAttribute('data-limitantes')).split(' ');
   expect(actives.length).toBeGreaterThan(0);
   if(l==='0'||l==='1') expect(actives.sort()).toEqual(Object.keys(traces).sort());
   else expect(actives).toEqual([l==='0.95'?'zoe':'ydris']);
   for(const cle of actives) expect(traces[cle]).toBeDefined();
   await plan(page).focus();await page.keyboard.press('Shift+ArrowRight');
   expect((await paire(page)).c).toBe(+(await limite.getAttribute('data-limite-commune')));
 }
 for(const [cle,trace] of Object.entries(traces)) await expect(page.locator(`[data-frontiere-role="${cle}"]`)).toHaveAttribute('d',trace.d);
 await expect(limite).toContainText('Licorne rose invisible');
});

test('licorne : contours du logo, similitudes, cadrage et export commun',async({page})=>{
 await page.goto('/palette.html?L=0.7&C=0.1');
 const svg=page.locator('[data-svg="palette-licorne"]');
 const contours=async source=>source.locator('defs path').evaluateAll(es=>es.map(e=>e.getAttribute('d')));
 expect(await contours(svg)).toEqual(await contours(page.locator('[data-svg="palette-logo"]')));
 const mesures=await svg.evaluate(svg=>[...svg.querySelectorAll('g[data-instance] use')].map(use=>{
   const m=use.transform.baseVal.getItem(0).matrix;
   const source=document.getElementById(use.getAttribute('href').slice(1));
   const chemin=source.querySelector('path');
   const origine=source.transform.baseVal.getItem(0).matrix;
   const longueur=chemin.getTotalLength();let rayon=0;
   for(let i=0;i<=128;i++){
     const p=chemin.getPointAtLength(longueur*i/128).matrixTransform(origine).matrixTransform(m);
     rayon=Math.max(rayon,Math.hypot(p.x-15,p.y-15));
   }
   return {source:source.id,matrice:[m.a,m.b,m.c,m.d,m.e,m.f],orthogonal:m.a*m.c+m.b*m.d,ecartEchelles:m.a*m.a+m.b*m.b-m.c*m.c-m.d*m.d,rayon};
 }));
 expect(mesures).toHaveLength(19);
 for(const mesure of mesures){
   expect(mesure.source).toMatch(/^palette-licorne-(auditif|visuel|kinesthesique)$/);
   expect(Math.abs(mesure.orthogonal)).toBeLessThan(1e-12);
   expect(Math.abs(mesure.ecartEchelles)).toBeLessThan(1e-12);
   expect(mesure.rayon).toBeLessThan(15);
 }
 await expect(svg.locator('[data-instance^="criniere-"]')).toHaveCount(6);
 await expect(svg.locator('[data-instance="encolure"]')).toHaveCount(0);
 await expect(svg.locator('[data-instance^="corne-"]')).toHaveCount(5);
 await expect(svg.locator('[data-trou]')).toHaveCount(0);
 const contenu=await (await page.request.get('/exports/Licorne-factorisee.svg')).text();
 const exporte=await page.evaluate(contenu=>{
   const d=new DOMParser().parseFromString(contenu,'image/svg+xml');
   return {contours:[...d.querySelectorAll('defs path')].map(e=>e.getAttribute('d')),matrices:[...d.querySelectorAll('use[data-instance]')].map(e=>{const m=e.transform.baseVal.getItem(0).matrix;return [m.a,m.b,m.c,m.d,m.e,m.f]})};
 },contenu);
 expect(exporte.contours).toEqual(await contours(svg));expect(exporte.matrices).toHaveLength(19);
 exporte.matrices.forEach((m,i)=>m.forEach((v,j)=>expect(v).toBeCloseTo(mesures[i].matrice[j],12)));
 await expect(svg.locator('linearGradient')).toHaveCount(1);
 await expect(svg.locator('mask [data-instance]')).toHaveCount(19);
 await expect(svg.locator('[data-degrade-global]')).toHaveCount(1);
 await expect(svg.locator('linearGradient stop').first()).toHaveAttribute('stop-color','#ffffff');
 await expect(svg.locator('linearGradient stop').last()).toHaveAttribute('stop-color',await svg.locator('[data-background]').getAttribute('fill'));

});

test('licorne : invisibilité, inspection au clavier et couleur synchronisée',async({page})=>{
 await page.goto('/palette.html?L=0.7&C=0.1');
 const svg=page.locator('[data-svg="palette-licorne"]');
 const fond=svg.locator('[data-background]');
 const initial=await fond.getAttribute('fill');const url=page.url();
 const masquer=page.getByRole('button',{name:'Rendre invisible',exact:true});
 await masquer.focus();await page.keyboard.press('Enter');
 await expect(svg.locator('[data-instance]')).toHaveCount(0);
 await expect(svg.locator('title')).toContainText('Licorne invisible');
 expect(page.url()).toBe(url);
 await valeurs(page,'0.65','0.08');
 await expect(svg.locator('[data-instance]')).toHaveCount(0);
 expect(await fond.getAttribute('fill')).not.toBe(initial);
 await page.getByRole('button',{name:'Révéler la licorne',exact:true}).click();
 await expect(svg.locator('[data-instance]')).toHaveCount(19);
 const inspecter=page.getByRole('button',{name:'Voir les pièces',exact:true});
 await inspecter.focus();await page.keyboard.press('Space');
 await expect(svg.locator('[data-instance="museau"] use')).toHaveAttribute('fill','#ffca91');
 await expect(svg.locator('[data-instance="machoire"] use')).toHaveAttribute('fill','#9ed8fa');
 await valeurs(page,'0.7','0.1');
 await expect(svg.locator('[data-instance="criniere-front"] use')).toHaveAttribute('fill','#9ed8fa');
 await page.getByRole('button',{name:'Voir la silhouette',exact:true}).click();
 expect(await svg.locator('[data-instance] use').evaluateAll(es=>es.every(e=>e.getAttribute('fill')==='#ffffff'))).toBe(true);
 await expect(fond).toHaveAttribute('fill',initial);
});


test('référence définitive : maximum, manifeste et téléchargements concordants',async({page})=>{
 await page.goto('/palette.html');
 expect((await paire(page)).l).toBeCloseTo(reference.L,12);
 expect((await paire(page)).c).toBeCloseTo(reference.C,12);
 await expect(page.locator('[data-limite-commune]')).toHaveAttribute('data-limitantes','ydris zoe');
 const manifeste=await (await page.request.get('/exports/palette.json')).json();
 expect(manifeste).toEqual(reference);
 for(const lien of await page.locator('a[href^="exports/"]').evaluateAll(es=>es.map(e=>e.getAttribute('href')))){
   expect((await page.request.get('/'+lien)).ok()).toBe(true);
 }
 await page.getByRole('link',{name:'Le sens de cette construction →',exact:true}).click();
 await expect(page.locator('#palette')).toContainText('deux harmonies tétradiques');
 await expect(page.getByRole('heading',{name:'Un quatre caché dans le trois.'})).toBeVisible();
 await expect(page.getByRole('link',{name:'La Licorne rose invisible sur Wikipédia'})).toHaveAttribute('href','https://fr.wikipedia.org/wiki/Licorne_rose_invisible');
 await expect(page.locator('[data-svg="philo-licorne"] [data-instance]')).toHaveCount(19);
});

test('licorne : le SVG garde le modèle approuvé et un seul champ de dégradé',async({page})=>{
 await page.goto('/palette.html');
 const exporte=await (await page.request.get('/exports/Licorne-factorisee.svg')).text();
 const source=fs.readFileSync('references/licorne/modele-valide.svg','utf8');
 const mesures=await page.evaluate(async({exporte,source})=>{
   const parser=new DOMParser();
   const officiel=parser.parseFromString(exporte,'image/svg+xml');
   const valide=parser.parseFromString(source,'image/svg+xml');
   const rose=officiel.querySelector('svg > circle').getAttribute('fill');
   valide.querySelector('circle').setAttribute('fill',rose);
   valide.querySelector('stop[offset="1"]').setAttribute('stop-color',rose);
   const raster=async(d)=>{
     // Même résolution intrinsèque : Firefox rastérise sinon le SVG sans taille en 300 × 150.
     d.documentElement.setAttribute('width','640');d.documentElement.setAttribute('height','640');
     const im=new Image();im.src='data:image/svg+xml;charset=utf-8,'+encodeURIComponent(new XMLSerializer().serializeToString(d));await im.decode();
     const canevas=document.createElement('canvas');canevas.width=canevas.height=640;
     const contexte=canevas.getContext('2d');contexte.drawImage(im,0,0,640,640);return contexte.getImageData(0,0,640,640).data;
   };
   const a=await raster(officiel),b=await raster(valide);
   let somme=0,grandsEcarts=0;
   for(let i=0;i<a.length;i++){const ecart=Math.abs(a[i]-b[i]);somme+=ecart;if(ecart>10) grandsEcarts++;}
   // La géométrie, le cadrage et la direction du dégradé doivent tous coïncider.
   return {moyenne:somme/a.length,grandsEcarts:grandsEcarts/a.length};
 },{exporte,source});
 expect(mesures.moyenne).toBeLessThan(.15);
 expect(mesures.grandsEcarts).toBeLessThan(.002);
});
