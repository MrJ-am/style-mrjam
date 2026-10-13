"""Génère quatre SVG comparables à partir des calculs Elm, sans modifier la forme."""
import copy
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

DOSSIER = Path(__file__).resolve().parent.parent
NS = 'http://www.w3.org/2000/svg'
ET.register_namespace('', NS)
ET.register_namespace('xlink', 'http://www.w3.org/1999/xlink')
def balise(nom):
    return '{' + NS + '}' + nom

calcul = json.loads(Path(sys.argv[1]).read_text())
assert calcul['gamutValide']
choix = next(e for e in calcul['experiences'] if e['tolerance'] == 0.0001)
assert choix['validation']['erreurOKLabMax'] <= choix['tolerance']
assert choix['validation']['erreurCanal8bitsMax'] <= 0.25
original = ET.parse(DOSSIER.parent / 'chemins-12/G-blanc-quadratique.svg').getroot()
formes = ET.tostring(original.find('.//' + balise('mask')))
rapport = {'toleranceOKLab': choix['tolerance'], 'experiences': calcul['experiences'], 'gamutValide': True, 'variantes': []}
for nom, points in [('uniforme', calcul['uniforme']), ('adaptatif', choix['etapes'])]:
    assert points[0]['t'] == 0 and points[-1]['t'] == 1
    assert all(p['gamut'] for p in points)
    assert all(a['t'] < b['t'] for a, b in zip(points, points[1:]))
    for encodage in ['rgb', 'oklch']:
        svg = copy.deepcopy(original)
        g = svg.find('.//' + balise('linearGradient'))
        for ancien in list(g):
            g.remove(ancien)
        for p in points:
            couleur = ('rgb(' + ','.join(f'{v*100:.10f}%' for v in p['rgb']) + ')' if encodage == 'rgb'
                       else f'oklch({p["L"]:.12f} {p["C"]:.12f} {p["h"]:.12f})')
            ET.SubElement(g, balise('stop'), {'offset': f'{p["t"]:.12f}', 'stop-color': couleur})
        # Même titre et même description : seule la liste des stops varie.
        svg.find(balise('title')).text = 'Licorne G — essai d’optimisation du dégradé'
        svg.find(balise('desc')).text = 'Silhouette factorisée inchangée. Chemin F parcouru selon t². Interpolation SVG sRGB entre les étapes.'
        assert ET.tostring(svg.find('.//' + balise('mask'))) == formes
        assert g.attrib == original.find('.//' + balise('linearGradient')).attrib
        ET.indent(svg, space='  ')
        fichier = DOSSIER / f'G-{nom}-{encodage}.svg'
        ET.ElementTree(svg).write(fichier, encoding='utf-8', xml_declaration=True)
        rapport['variantes'].append({'nom': fichier.stem, 'etapes': len(points), 'octets': fichier.stat().st_size})
(DOSSIER / 'precision.json').write_text(json.dumps(rapport, ensure_ascii=False, indent=2) + '\n')
print(json.dumps(rapport['variantes'], ensure_ascii=False, indent=2))
