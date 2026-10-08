import { mkdirSync, readFileSync, writeFileSync, copyFileSync, rmSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
mkdirSync('dist/exports', { recursive: true });
execFileSync('node_modules/.bin/elm', ['make', 'src/Main.elm', 'src/Philosophie.elm', 'src/Palette.elm', '--optimize', '--output=dist/elm.js'], { stdio: 'inherit' });
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
for (const nom of ['Z-original.svg', 'Z-reference.svg']) copyFileSync(`references/${nom}`, `dist/exports/${nom}`);
copyFileSync('donnees/geometrie-Z-original.json', 'dist/exports/geometrie-Z-original.json');
const template = readFileSync('web/index.html', 'utf8');
const script = readFileSync('dist/elm.js', 'utf8').replaceAll('</script', '<\\/script');
const boot = readFileSync('web/boot.js', 'utf8');
const style = readFileSync('web/style.css', 'utf8');
const licenses = JSON.stringify(JSON.parse(readFileSync('docs/third-party-licenses.json', 'utf8'))).replaceAll('<', '\\u003c');
const html = template.replace('/* STYLES */', () => style).replace('/* ELM */', () => script).replace('/* BOOT */', () => boot).replace('/* LICENSES */', () => licenses);
writeFileSync('dist/index.html', html);
writeFileSync('dist/atelier-logo.html', html);
writeFileSync('dist/atelier-logo-x.html', html); // Nom historique de la première livraison.
const philosophie = html.replace('<title>ÉcoLogo — Atelier du mouvement</title>', '<title>ÉcoLogo — Philosophie du logo · MrJ.am</title>').replace('Atelier vectoriel interactif : rotation centrifuge du logo et recomposition en Xiaoping (X), Ydris (Y) et Zoé (Z).', 'ÉcoLogo : correspondances, analogies, palette OKLCH et Licorne rose invisible ; expérimenter, apprendre et conceptualiser.').replace(/<script>\(\(\) => \{[\s\S]*?<\/script>/, '<script>Elm.Philosophie.init({node:document.getElementById("app"),flags:{width:innerWidth}});</script>');
writeFileSync('dist/philosophie.html', philosophie);
const palette = template.replace('/* STYLES */', () => style).replace('/* ELM */', () => script).replace('/* BOOT */', () => readFileSync('web/palette.js', 'utf8')).replace('/* LICENSES */', () => licenses).replace('<title>ÉcoLogo — Atelier du mouvement</title>', '<title>Palette OKLCH — Mister Jam</title>').replace(/<meta name="description"[^>]*>/, '<meta name="description" content="Explorer la palette OKLCH Mister Jam : deux paramètres communs, huit sommets et sept couleurs principales dans le gamut sRGB.">');
writeFileSync('dist/palette.html', palette);
writeFileSync('dist/.nojekyll', '');
console.log('Atelier et philosophie : dist/ ; exports : dist/exports/');
