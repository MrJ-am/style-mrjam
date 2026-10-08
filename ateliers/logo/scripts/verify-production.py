"""Mesurer les SVG réellement exportés par Elm face aux références immuables."""
from pathlib import Path
import json
import hashlib
import math
import sys
import subprocess
import xml.etree.ElementTree as ET

RACINE = Path(__file__).resolve().parents[1]
KIT = RACINE/'references/kit_codex_logo_X'
sys.path.insert(0, str(KIT/'outils'))
import verifier_geometrie as geometrie

NS = geometrie.NS
logo_original = geometrie.lire_svg(KIT/'sources/logo-original.svg')
canoniques = dict(zip(['Auditif', 'Visuel', 'Kinesthesique'], logo_original))
contours = dict(zip(canoniques, [p.attrib['d'] for p in ET.parse(KIT/'sources/logo-original.svg').getroot().iter(NS+'path')]))
resultats = {}
for nom, fichier, decomposition, mesures, nombre, couleur in [
    ('X', KIT/'sources/X-original.svg', KIT/'donnees/decomposition-X.json', KIT/'verification/geometrie.json', 7, '#9c3e65'),
    ('Y', RACINE/'references/Y-original.svg', RACINE/'donnees/decomposition-Y.json', RACINE/'donnees/geometrie-Y.json', 8, '#64c29b')
]:
    donnees = json.loads(decomposition.read_text())
    correspondances = {r['path_id']: r for r in json.loads(mesures.read_text())['instances']}
    cibles = {p.id: p for p in geometrie.lire_svg(fichier)}
    svg = ET.parse(RACINE/f'dist/exports/{nom}-factorise.svg').getroot()
    definitions = {n.attrib['id']: n for n in svg.find(NS+'defs')}
    occurrences = list(svg.iter(NS+'use'))
    assert len(definitions) == 4 and len(list(svg.iter(NS+'path'))) == 3 and len(occurrences) == nombre
    assert svg.find(NS+'circle').attrib['fill'] == couleur
    lignes = []
    for occurrence, inst in zip(occurrences, donnees['instances']):
        assert occurrence.attrib['data-instance'] == inst['id']
        definition = definitions[occurrence.attrib['href'][1:]]
        assert definition.find(NS+'path').attrib['d'] == contours[inst['brique']]
        assert definition.attrib['transform'] == 'translate(-13.8 -9)'
        matrice = geometrie.transformation(occurrence.attrib['transform'])
        echelle = geometrie.facteur_similitude(matrice)
        miroir = matrice[0]*matrice[3]-matrice[1]*matrice[2] < 0
        assert miroir == (inst['chiralite'] == 'Reflechie')
        assert math.isclose(echelle, inst['echelle'], abs_tol=1e-14)
        source = canoniques[inst['brique']]
        cible = cibles[inst['path_source']]
        detail = correspondances[inst['path_source']]
        seq = geometrie.correspondances(source.arcs, detail['parcours_inverse'], detail['decalage_arcs'])
        src = [geometrie.appliquer(matrice, p-geometrie.ORIGINE) for p in geometrie.echantillons(seq, 129)]
        dst = [geometrie.appliquer(cible.transform, p) for p in geometrie.echantillons([(a, False) for a in cible.arcs], 129)]
        maximum = max(abs(a-b) for a, b in zip(src, dst))
        mult = complex(matrice[0], matrice[1]) * (-1 if miroir else 1)
        borne = geometrie.borne_continue(seq, cible, mult, complex(matrice[4], matrice[5]), miroir)
        assert maximum < 1e-4 and borne < 1e-4, (nom, inst['id'], maximum, borne)
        lignes.append(dict(id=inst['id'], path=inst['path_source'], echelle=echelle, miroir=miroir,
                           matrice=matrice, erreur_max_echantillons=maximum, borne_continue=borne))
    if nom == 'Y':
        assert lignes[2]['matrice'] == lignes[4]['matrice']
        assert lignes[3]['matrice'] == lignes[5]['matrice']
    resultats[nom] = lignes
    print(f"{nom} : {nombre} occurrences ; erreur maximale {max(r['erreur_max_echantillons'] for r in lignes):.10g} ; borne {max(r['borne_continue'] for r in lignes):.10g}.")

logo = ET.parse(RACINE/'dist/exports/Logo-factorise.svg').getroot()
assert len(logo.find(NS+'defs')) == 4 and len(list(logo.iter(NS+'use'))) == 4
assert logo.find(NS+'circle').attrib['fill'] == '#64c29b'
for occurrence in logo.iter(NS+'use'):
    assert geometrie.transformation(occurrence.attrib['transform']) == (1, 0, 0, 1, 13.8, 9)

# Les trois pictogrammes doivent réellement rendre le centre ET leur contour.
pictogrammes = {}
for nom, brique in [('Audio', 'Auditif'), ('Visio', 'Visuel'), ('Kino', 'Kinesthesique')]:
    svg = ET.parse(RACINE/f'dist/exports/{nom}.svg').getroot()
    definitions = {n.attrib['id']: n for n in svg.find(NS+'defs')}
    occurrences = list(svg.iter(NS+'use'))
    assert len(occurrences) == 2, (nom, 'disque central manquant ou dupliqué')
    centre, contour = [definitions[u.attrib['href'][1:]] for u in occurrences]
    assert centre.tag == NS+'circle' and centre.attrib['r'] == '2'
    assert centre.attrib['cx'] == '0' and centre.attrib['cy'] == '0'
    assert contour.find(NS+'path').attrib['d'] == contours[brique]
    assert contour.attrib['transform'] == 'translate(-13.8 -9)'
    assert svg.find(NS+'circle').attrib['fill'] == '#64c29b'
    for occurrence in occurrences:
        assert geometrie.transformation(occurrence.attrib['transform']) == (1, 0, 0, 1, 13.8, 9)
        assert occurrence.attrib['opacity'] == '1'
    pictogrammes[nom] = 'Disque de rayon 2 et contour canonique, au même placement'

# Z : distinguer la reconnaissance de l’ébauche des placements retravaillés.
# Les exports doivent reproduire la reprise ; les retouches diffèrent de l’original.
z = ET.parse(RACINE/'dist/exports/Z-factorise.svg').getroot()
definitions = {n.attrib['id']: n for n in z.find(NS+'defs')}
occurrences = list(z.iter(NS+'use'))
donnees_z = json.loads((RACINE/'donnees/decomposition-Z.json').read_text())
source_z = ET.parse(RACINE/'dist/exports/Z.svg').getroot()
dessins_z = list(source_z.iter(NS+'path'))
assert len(occurrences) == len(dessins_z) == len(donnees_z['instances']) == 5
assert z.find(NS+'circle').attrib['fill'] == source_z.find(NS+'circle').attrib['fill'] == '#087f71'
lignes_z = []
for occurrence, dessin, instance in zip(occurrences, dessins_z, donnees_z['instances']):
    definition = definitions[occurrence.attrib['href'][1:]]
    assert definition.find(NS+'path').attrib['d'] == dessin.attrib['d'] == contours[instance['brique']]
    assert occurrence.attrib['data-instance'] == instance['id']
    matrice = geometrie.transformation(occurrence.attrib['transform'])
    angle = math.radians(instance['angle_degres'])
    echelle = instance['echelle']
    a, b = echelle * math.cos(angle), echelle * math.sin(angle)
    signe = -1 if instance['chiralite'] == 'Reflechie' else 1
    attendue = (signe*a, signe*b, -b, a, *instance['translation'])
    assert all(abs(v-w) < 1e-12 for v, w in zip(matrice, attendue))
    matrice_dessin = geometrie.transformation(dessin.attrib['transform'])
    for point in geometrie.echantillons([(arc, False) for arc in canoniques[instance['brique']].arcs], 129):
        rendu = geometrie.appliquer(matrice, point-geometrie.ORIGINE)
        reference = geometrie.appliquer(matrice_dessin, point)
        assert abs(rendu-reference) < 1e-12
        assert abs(rendu-complex(15, 15)) < 15, ('Z hors du disque', instance['id'], rendu)
    lignes_z.append(dict(id=instance['id'], path=instance['path_source'], matrice=matrice))
resultats['Z'] = lignes_z
rapport_z = json.loads((RACINE/'donnees/geometrie-Z-original.json').read_text())
for chemin, empreinte in rapport_z['sources_sha256'].items():
    assert hashlib.sha256((RACINE/chemin).read_bytes()).hexdigest() == empreinte
assert [i['path_original'] for i in donnees_z['instances']] == [i['path_id'] for i in rapport_z['instances']]
assert all(i['borne_continue'] < 1e-4 for i in rapport_z['instances'])
assert [i['brique'] for i in donnees_z['instances']] == ['Auditif', 'Visuel', 'Kinesthesique', 'Kinesthesique', 'Visuel']
assert [i['id'] for i in donnees_z['instances'] if i['chiralite'] == 'Reflechie'] == ['visuel-1']
matrices_z = {i['path']: i['matrice'] for i in lignes_z}
def point_z(nom, x, y):
    return geometrie.appliquer(matrices_z[nom], complex(x, y))
# Tolérance liée aux six décimales des points canoniques, sans retoucher leurs arcs.
assert abs(point_z('bras-gauche', 3, 0) - point_z('diagonale', -1.5, 2.598076)) < 1e-6
assert abs(point_z('bras-droit', 3, 0) - point_z('diagonale', 2.598076, 1.5)) < 1e-6
assert abs(point_z('pied', 2.598076, 1.5) - point_z('diagonale', -1.5, 19.568639)) < 1e-6
print('Z : 5 placements définis ; dessin explicite et export concordants à 1e-12 ; pictogrammes complets.')

# Licorne : vérifier la normalisation exacte du dessin approuvé, pas seulement son import.
subprocess.run([sys.executable, str(RACINE/'scripts/importer-licorne.py'), '--check'], check=True)
modele = ET.parse(RACINE/'references/licorne/modele-valide.svg').getroot()
licorne = ET.parse(RACINE/'dist/exports/Licorne-factorisee.svg').getroot()
x0, y0, largeur, hauteur = map(float, modele.attrib['viewBox'].split())
k = 30 / largeur
assert largeur == hauteur
assert len(list(licorne.iter(NS+'path'))) == 3
originaux = list(modele.iter(NS+'use'))
copies = list(licorne.iter(NS+'use'))
assert len(originaux) == len(copies) == 19
identifiants = {'auditif': 'Auditif', 'visuel': 'Visuel', 'kinesthesique': 'Kinesthesique'}
definitions = {n.attrib['id']: n for n in licorne.find(NS+'defs')}
erreur = 0
for original, copie in zip(originaux, copies):
    nom = identifiants[copie.attrib['href'].removeprefix('#licorne-')]
    definition = definitions[copie.attrib['href'][1:]]
    assert definition.find(NS+'path').attrib['d'] == contours[nom]
    ancienne = geometrie.transformation(original.attrib['transform'])
    nouvelle = geometrie.transformation(copie.attrib['transform'])
    geometrie.facteur_similitude(nouvelle)
    for point in geometrie.echantillons([(arc, False) for arc in canoniques[nom].arcs], 129):
        attendu = k * (geometrie.appliquer(ancienne, point) - complex(x0, y0))
        obtenu = geometrie.appliquer(nouvelle, point - geometrie.ORIGINE)
        erreur = max(erreur, abs(obtenu - attendu))
        assert abs(obtenu-complex(15, 15)) < 15
assert erreur < 1e-12, erreur
masque = licorne.find('.//'+NS+'mask')
assert len(list(masque.iter(NS+'use'))) == 19
assert len(list(licorne.iter(NS+'linearGradient'))) == 1
champ = licorne.find(NS+'rect')
assert champ.attrib['mask'] == 'url(#licorne-silhouette)'
gradient = licorne.find('.//'+NS+'linearGradient')
reference_gradient = modele.find('.//'+NS+'linearGradient')
assert gradient.attrib['gradientUnits'] == 'userSpaceOnUse'
assert gradient.attrib['color-interpolation'] == 'sRGB'
for coord in ['x1', 'y1', 'x2', 'y2']:
    attendu = k*(float(reference_gradient.attrib[coord])-(x0 if coord.startswith('x') else y0))
    assert abs(float(gradient.attrib[coord])-attendu) < 1e-12
assert gradient[0].attrib['stop-color'] == '#ffffff'
assert gradient[1].attrib['stop-color'] == licorne.find(NS+'circle').attrib['fill']
resultats['Licorne'] = dict(occurrences=19, contours=3, erreur_max=erreur,
    source_sha256=hashlib.sha256((RACINE/'references/licorne/modele-valide.svg').read_bytes()).hexdigest())
print(f'Licorne : 19 occurrences de 3 contours ; dégradé global ; écart au modèle {erreur:.3g}.')

# Le logo du kit correspond aux contours de Signature distribués par le dépôt.
autorite = ET.parse(RACINE/'../../public/assets/mrjam/Echologo.svg').getroot()
assert ET.tostring(autorite) == ET.tostring(ET.parse(KIT/'sources/logo-original.svg').getroot())
sortie = dict(source='SVG produits par Echo.Render, compilation Elm optimisée', tolerance=1e-4,
              valide=True, logo='4 occurrences canoniques, translation exacte, fond exact ; source Signature vérifiée', compositions=resultats,
              pictogrammes=pictogrammes, nature_Z='Reprise de l’ébauche reconnue à 1e-4 ; comparaison dessin retravaillé/export à 1e-12')
(RACINE/'verification').mkdir(exist_ok=True)
texte = json.dumps(sortie, ensure_ascii=False, indent=2)+'\n'
(RACINE/'verification/production-geometrie.json').write_text(texte)
(RACINE/'dist/exports/production-geometrie.json').write_text(texte)
