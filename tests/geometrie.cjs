'use strict';
// Référence frontend historique, uniquement sur entrées synthétiques.
const assert = require('node:assert/strict');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { performance } = require('node:perf_hooks');

async function verifier(javascript, reference) {
  const { Elm } = require(path.resolve(javascript));
  const application = Elm.Geometrie.init();
  let attente;
  application.ports.geometrieSortie.subscribe(resultat => {
    assert.ok(attente, 'Un résultat doit correspondre à une demande active');
    const retour = attente; attente = null; retour(resultat);
  });
  const calculer = entree => new Promise(resolve => {
    assert.equal(attente, undefined === attente ? undefined : null, 'Appels sérialisés');
    attente = resolve;
    application.ports.geometrieEntree.send(entree);
  });
  const { placerBilles } = await import(pathToFileURL(path.resolve(reference, 'space-layout.js')));
  const { dragValue, layoutThumbs } = await import(pathToFileURL(path.resolve(reference, 'slider-layout.js')));
  function comparer(a, b, position = '') {
    if (typeof a === 'number') {
      assert.ok(Number.isFinite(a) && Number.isFinite(b), position);
      assert.ok(Math.abs(a - b) < 1e-9, `${position}: ${a} != ${b}`);
    } else if (Array.isArray(a)) {
      assert.equal(a.length, b.length, position);
      a.forEach((v, i) => comparer(v, b[i], `${position}[${i}]`));
    } else if (a && typeof a === 'object') {
      assert.deepEqual(Object.keys(a).sort(), Object.keys(b).sort(), position);
      Object.entries(a).forEach(([k, v]) => comparer(v, b[k], `${position}.${k}`));
    } else assert.equal(a, b, position);
  }
  let cas = 0, prisesLevees = 0;
  const debut = performance.now();
  for (const [largeur, hauteur] of [[264,350],[366,464],[820,650],[320,568]]) {
    for (const [x,y] of [[largeur/2,hauteur/2],[0,0],[largeur,hauteur]]) {
      const points = Array.from({length:6},(_,i)=>({id:String(i),x,y}));
      const copie = JSON.stringify(points);
      // cout n'est qu'un détail de tri historique, jamais consommé par la vue.
      // Toutes les positions visibles et leur ordre restent comparés.
      comparer(await calculer({calcul:'billes',largeur,hauteur,diametre:49,points}), placerBilles(points,largeur,hauteur,49).map(({id,x,y})=>({id,x,y})));
      assert.equal(JSON.stringify(points), copie); cas++;
    }
  }
  for (const largeur of [44,132,220,300,500]) {
    for (const valeurs of [[0,0,0,0,0,0],[-10,-10,-9.9,9.9,10,10],[-5,-4.9,0,.1,5,5.1]]) {
      const points = valeurs.map((valeur, numero)=>({id:String(numero),numero,valeur}));
      const historique = points.map(p=>({id:p.id,number:p.numero,value:p.valeur}));
      const traduire = p=>({id:p.id,numero:p.number,valeur:p.value,ancre:p.anchor,x:p.x,y:p.y});
      const normal = layoutThumbs(historique,largeur,'1');
      comparer(await calculer({calcul:'poignees',largeur,prioritaire:'1',prise:null,points}), normal.map(traduire)); cas++;
      const levee = normal.find(p=>p.y<0) || normal[0];
      if (levee.y < 0) prisesLevees++;
      const prise = {y:levee.y,decalage:levee.x-levee.anchor};
      comparer(await calculer({calcul:'poignees',largeur,prioritaire:levee.id,prise,points}), layoutThumbs(historique,largeur,levee.id,42,{y:prise.y,offset:prise.decalage}).map(traduire)); cas++;
    }
  }
  assert.ok(prisesLevees > 0, 'La campagne doit réellement exercer une poignée surélevée');
  for (const [minimum,maximum,pas] of [[-10,10,.1],[0,3,.25]]) {
    for (const largeur of [0,1,132,220,500]) for (const depart of [minimum,0,(minimum+maximum)/2,maximum]) {
      for (const dx of [-500,-100,-.05,0,.05,100,500]) {
        comparer(await calculer({calcul:'deplacement',depart,dx,largeur,minimum,maximum,pas}),dragValue(depart,dx,largeur,minimum,maximum,pas));cas++;
      }
    }
  }
  const vue = await calculer({calcul:'projection',largeur:400,hauteur:400,camera:{azimut:0,elevation:0},billes:[{x:0,y:0,z:0},{x:10,y:0,z:0},{x:0,y:10,z:0},{x:0,y:0,z:10}]});
  assert.equal(vue.diametre,50);
  comparer(vue.unite,(400-50*1.3-40)/20);
  comparer(vue.points,[{x:200,y:200,profondeur:0},{x:200+10*vue.unite,y:200,profondeur:0},{x:200,y:200-10*vue.unite,profondeur:0},{x:200,y:200,profondeur:10}]);cas++;
  const gestes=await calculer({calcul:'gestes'});
  assert.deepEqual(gestes.prise,{proposition:null,ouvrir:null});
  assert.deepEqual(gestes.hesitant,{proposition:null,ouvrir:null});
  assert.deepEqual(gestes.glisse,{proposition:{id:'a',valeur:4.5,validee:false},ouvrir:null});
  assert.deepEqual(gestes.annule,{proposition:{id:'a',valeur:0,validee:false},ouvrir:null});
  assert.deepEqual(gestes.valide,{proposition:{id:'a',valeur:4.5,validee:true},ouvrir:null});
  assert.deepEqual(gestes.clic,{proposition:null,ouvrir:'a'});
  assert.deepEqual(gestes.verticale,{proposition:null,ouvrir:null});
  assert.equal(gestes.home.proposition.valeur,-10);assert.equal(gestes.end.proposition.valeur,10);
  assert.equal(gestes.cameraClic.ouvrir,'a');assert.equal(gestes.cameraClic.tourne,false);
  assert.equal(gestes.cameraAnnule.ouvrir,null);assert.equal(gestes.cameraAnnule.tourne,false);
  assert.equal(gestes.cameraValide.ouvrir,null);assert.equal(gestes.cameraValide.tourne,true);
  comparer(gestes.cameraValide.azimut,.56);comparer(gestes.cameraValide.elevation,.52);
  assert.equal(gestes.cameraFinDouble.tourne,false);assert.equal(gestes.cameraFinDouble.ouvrir,null);
  cas+=13;
  console.log(JSON.stringify({cas,prisesLevees,reference:path.resolve(reference),coordonneesInchangees:true,dureeMs:Math.round((performance.now()-debut)*10)/10}));
}

const args = process.argv.slice(2);
const argument = nom => { const i=args.indexOf(nom);assert.ok(i>=0 && args[i+1], `Argument requis ${nom}`);return args[i+1]; };
verifier(argument('--javascript'),argument('--reference')).catch(erreur=>{console.error(erreur);process.exitCode=1;});
