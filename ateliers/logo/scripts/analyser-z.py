"""Reconnaître l’ébauche retrouvée et aligner les raccords sans modifier les arcs."""
from pathlib import Path
import cmath
import hashlib
import json
import math
import sys
import xml.etree.ElementTree as ET

RACINE = Path(__file__).resolve().parents[1]
KIT = RACINE / 'references/kit_codex_logo_X'
sys.path.insert(0, str(KIT / 'outils'))
import verifier_geometrie as geometrie

original = RACINE / 'references/Z-original.svg'
logo = geometrie.lire_svg(KIT / 'sources/logo-original.svg')
cibles = {p.id: p for p in geometrie.lire_svg(original)}
traces = {p.attrib['id']: p for p in ET.parse(original).getroot().iter(geometrie.NS+'path')}
# Les cinq pièces visibles sur la photographie ; le disque et les deux essais
# isolés restent archivés dans l’original, sans rejoindre le personnage.
selection = [
    ('path6', 'auditif-0', 'tete', 'Auditif'),
    ('path8', 'visuel-0', 'bras-gauche', 'Visuel'),
    ('path10', 'kinesthesique-0', 'pied', 'Kinesthesique'),
    ('path10-2', 'kinesthesique-1', 'diagonale', 'Kinesthesique'),
    ('path8-2', 'visuel-1', 'bras-droit', 'Visuel'),
]
mesures = []
poses = []
reference = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" role="img" aria-labelledby="titre">',
             '<title id="titre">Zoé · ébauche originale recadrée</title>',
             '<circle cx="15" cy="15" r="15" fill="#087f71"/>',
             '<g transform="translate(15 15) scale(0.4) translate(-121.5 -99)">']
for path, identifiant, fonction, brique in selection:
    cible = cibles[path]
    source = logo[['Auditif', 'Visuel', 'Kinesthesique'].index(brique)]
    valides = [c for c in geometrie.reconnaitre(source, cible, 129) if c['borne_continue'] < 1e-4]
    assert valides, path
    choix = min([c for c in valides if not c['miroir']] or valides, key=lambda c: c['erreur_rms'])
    mesures.append(dict(choix, path_id=path, brique=brique))
    position = (complex(*choix['translation']) - complex(121.5, 99)) * .4 + complex(15, 15)
    poses.append(dict(id=identifiant, path_source=fonction, path_original=path, brique=brique,
                      translation=[position.real, position.imag], angle_degres=round(choix['angle_degres']),
                      echelle=.9455664, chiralite='Reflechie' if choix['miroir'] else 'Directe'))
    matrice = ' '.join(str(v) for v in cible.transform)
    reference.append(f'<path id="{path}" fill="#ffffff" d="{traces[path].attrib["d"]}" transform="matrix({matrice})"/>')
reference.extend(['</g>', '</svg>'])
(RACINE/'references/Z-reference.svg').write_text('\n'.join(reference)+'\n')

def placer(index, position, angle):
    poses[index].update(translation=[position.real, position.imag], angle_degres=angle)

def rotation(point, angle):
    return point * cmath.exp(1j * math.radians(angle)) * .9455664

# Les angles complémentaires partagent le même cercle de raccord au cou.
pivot = complex(*poses[3]['translation'])
placer(1, pivot, 163)
placer(3, pivot, 43)
placer(4, pivot + rotation(complex(2.598076, 1.5), 43) - rotation(complex(-3, 0), -107), -107)
# Aligner le départ du pied sur la pointe de la diagonale.
placer(2, pivot + rotation(complex(-1.5, 19.568639), 43) - rotation(complex(2.598076, 1.5), -86), -86)
# Rapprocher la tête en conservant un espace lisible avec les épaules.
placer(0, complex(*poses[0]['translation']) + complex(-.5, 1), -54)

rapport = dict(version=1, tolerance=1e-4, points_par_arc=129, valide=True,
               nature='Reconnaissance des cinq contours de l’ébauche, avant les retouches de placement.',
               sources_sha256={str(p.relative_to(RACINE)): hashlib.sha256(p.read_bytes()).hexdigest()
                               for p in [original, KIT/'sources/logo-original.svg']},
               elements_ecartes=['rect66', 'circle4', 'path10-2-9', 'path8-2-8'], instances=mesures)
donnees = dict(version=2, personnage='Zoé',
               nature='Reprise de Z-original.svg : tête rapprochée, raccords des épaules et du pied alignés ; arcs canoniques inchangés.',
               source='references/Z-original.svg', origine_locale=[13.8, 9], fond_logo='#64c29b', fond_Z='#087f71',
               formule='T(p)=translation+echelle*R(angle)*F^miroir(p), F(x,y)=(-x,y)',
               ordre_de_dessin='Tête, bras gauche, pied, diagonale, bras droit', instances=poses)
for nom, contenu in [('geometrie-Z-original.json', rapport), ('decomposition-Z.json', donnees)]:
    (RACINE/'donnees'/nom).write_text(json.dumps(contenu, ensure_ascii=False, indent=2)+'\n')
print('Ébauche Z : cinq contours reconnus, borne maximale', max(m['borne_continue'] for m in mesures))
