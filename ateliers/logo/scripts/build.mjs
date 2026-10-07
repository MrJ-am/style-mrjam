import { mkdirSync, readFileSync, writeFileSync, copyFileSync, rmSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
mkdirSync('dist/exports', { recursive: true });
execFileSync('node_modules/.bin/elm', ['make', 'src/Main.elm', 'src/Philosophie.elm', '--optimize', '--output=dist/elm.js'], { stdio: 'inherit' });
execFileSync('node_modules/.bin/elm', ['make', 'src/Exporter.elm', '--optimize', '--output=dist/exporter.js'], { stdio: 'inherit' });
await new Promise((resolve) => {
  require('../dist/exporter.js').Elm.Exporter.init().ports.files.subscribe(files => {
    for (const file of files) writeFileSync(`dist/exports/${file.name}`, file.content);
    resolve();
  });
});
rmSync('dist/exporter.js');
for (const [source, target] of [
  ['donnees/decomposition-X.json', 'decomposition-X.json'],
  ['verification/geometrie.json', 'geometrie.json'],
]) copyFileSync(`references/kit_codex_logo_X/${source}`, `dist/exports/${target}`);
for (const name of ['decomposition-Y.json', 'geometrie-Y.json', 'decomposition-Z.json']) copyFileSync(`donnees/${name}`, `dist/exports/${name}`);
copyFileSync('dessins/Z.svg', 'dist/exports/Z.svg');
const template = readFileSync('web/index.html', 'utf8');
const script = readFileSync('dist/elm.js', 'utf8').replaceAll('</script', '<\\/script');
const boot = readFileSync('web/boot.js', 'utf8');
const style = readFileSync('web/style.css', 'utf8');
const licenses = JSON.stringify(JSON.parse(readFileSync('docs/third-party-licenses.json', 'utf8'))).replaceAll('<', '\\u003c');
const html = template.replace('/* STYLES */', () => style).replace('/* ELM */', () => script).replace('/* BOOT */', () => boot).replace('/* LICENSES */', () => licenses);
writeFileSync('dist/index.html', html);
writeFileSync('dist/atelier-logo.html', html);
writeFileSync('dist/atelier-logo-x.html', html); // Nom historique de la première livraison.
const philosophie = html.replace('<title>Écho — Atelier du mouvement</title>', '<title>Philosophie du logo — Écho · MrJ.am</title>').replace('Atelier vectoriel interactif : rotation centrifuge du logo et recomposition en Xiaoyu (X), Idriss (Y) et Zoé (Z).', 'La philosophie du logo Écho : connaissance, audio, visio, kino et les tuteurs Xiaoyu, Idriss et Zoé.').replace(/<script>\(\(\) => \{[\s\S]*?<\/script>/, '<script>Elm.Philosophie.init({node:document.getElementById("app"),flags:{width:innerWidth}});</script>');
writeFileSync('dist/philosophie.html', philosophie);
writeFileSync('dist/.nojekyll', '');
console.log('Atelier et philosophie : dist/ ; exports : dist/exports/');
