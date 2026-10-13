"""Reproduit les couleurs avec les dépendances Elm déjà installées, hors du produit."""
import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('--outils', type=Path, help='Dossier de l’atelier logo contenant node_modules')
a = p.parse_args()
dossier = Path(__file__).resolve().parent
racine = dossier.parents[3]
outils = (a.outils or racine / 'ateliers/logo').resolve()
with tempfile.TemporaryDirectory(prefix='licorne-optimisation-') as tmp:
    travail = Path(tmp)
    manifeste = json.loads((racine / 'ateliers/logo/elm.json').read_text())
    manifeste['source-directories'] = [str(dossier), str(racine / 'ateliers/logo/src'), str(racine / 'src')]
    (travail / 'elm.json').write_text(json.dumps(manifeste, indent=2))
    environnement = dict(os.environ, GHCRTS='-N2')
    subprocess.run([str(outils / 'node_modules/.bin/elm'), 'make', str(dossier / 'Optimisation.elm'), '--optimize', '--output=optimisation.js'], cwd=travail, env=environnement, check=True)
    subprocess.run(['node', '-e', "require('./optimisation.js').Elm.Optimisation.init().ports.resultat.subscribe(d=>require('fs').writeFileSync('calcul.json',JSON.stringify(d)))"], cwd=travail, check=True)
    subprocess.run(['python3', str(dossier / 'composer.py'), str(travail / 'calcul.json')], check=True)
