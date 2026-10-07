// Assembler les seules ressources publiques après compilation et validation.
import { cpSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { join, relative } from 'node:path';

const destination = '.pages';
rmSync(destination, { recursive: true, force: true });
mkdirSync(destination);
for (const nom of ['index.html', 'philosophie.html', 'atelier-logo.html', '.nojekyll', 'exports']) {
  cpSync(`ateliers/logo/dist/${nom}`, `${destination}/${nom}`, { recursive: true });
}
// Les variantes distribuées sont générées par le même rendu que l’atelier.
for (const nom of ['Logo-factorise.svg', 'X-factorise.svg', 'Y-factorise.svg', 'decomposition-X.json', 'decomposition-Y.json']) {
  if (!readFileSync(`public/assets/mrjam/factorises/${nom}`).equals(readFileSync(`ateliers/logo/dist/exports/${nom}`))) {
    throw new Error(`Variante à régénérer : ${nom}`);
  }
}
const fichiers = {};
function inventorier(repertoire) {
  for (const entree of readdirSync(repertoire, { withFileTypes: true })) {
    const chemin = join(repertoire, entree.name);
    if (entree.isDirectory()) inventorier(chemin);
    else fichiers[relative(destination, chemin)] = createHash('sha256').update(readFileSync(chemin)).digest('hex');
  }
}
inventorier(destination);
const revision = execFileSync('git', ['rev-parse', 'HEAD'], { encoding: 'utf8' }).trim();
writeFileSync(`${destination}/revision.json`, JSON.stringify({ depot: 'MrJ-am/style-mrjam', revision, fichiers }, null, 2) + '\n');
console.log(`GitHub Pages : ${Object.keys(fichiers).length} fichiers publics, révision ${revision}.`);
