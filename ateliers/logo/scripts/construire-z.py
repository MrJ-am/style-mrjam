"""Construire le dessin Z explicite à partir des placements choisis pour Zoé."""
from pathlib import Path
import json
import xml.etree.ElementTree as ET

RACINE = Path(__file__).resolve().parents[1]
NS = '{http://www.w3.org/2000/svg}'
donnees = json.loads((RACINE/'donnees/decomposition-Z.json').read_text())
logo = ET.parse(RACINE/'references/kit_codex_logo_X/sources/logo-original.svg').getroot()
contours = dict(zip(['Auditif', 'Visuel', 'Kinesthesique'],
                    [p.attrib['d'] for p in logo.iter(NS+'path')]))
lignes = [
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" role="img" aria-labelledby="titre description">',
    '  <title id="titre">Zoé · axe Z</title>',
    '  <desc id="description">Une silhouette en Z composée des courbes audio, visio et kino du logo. Utilisation strictement réservée.</desc>',
    f'  <circle cx="15" cy="15" r="15" fill="{donnees["fond_Z"]}"/>',
]
for instance in donnees['instances']:
    x, y = instance['translation']
    echelle = instance['echelle']
    horizontal = -echelle if instance['chiralite'] == 'Reflechie' else echelle
    transformation = f'translate({x} {y}) rotate({instance["angle_degres"]}) scale({horizontal} {echelle}) translate(-13.8 -9)'
    lignes.append(f'  <path id="{instance["path_source"]}" fill="#ffffff" d="{contours[instance["brique"]]}" transform="{transformation}"/>')
lignes.append('</svg>')
(RACINE/'dessins').mkdir(exist_ok=True)
(RACINE/'dessins/Z.svg').write_text('\n'.join(lignes)+'\n')
print('Zoé : cinq contours canoniques placés dans dessins/Z.svg.')
