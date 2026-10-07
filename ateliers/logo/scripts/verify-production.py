"""Mesurer les SVG réellement exportés par Elm face aux références immuables."""
from pathlib import Path
import json
import math
import sys
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
# Le logo du kit correspond aux contours de Signature distribués par le dépôt.
autorite = ET.parse(RACINE/'../../public/assets/mrjam/Echologo.svg').getroot()
assert ET.tostring(autorite) == ET.tostring(ET.parse(KIT/'sources/logo-original.svg').getroot())
sortie = dict(source='SVG produits par Echo.Render, compilation Elm optimisée', tolerance=1e-4,
              valide=True, logo='4 occurrences canoniques, translation exacte, fond exact ; source Signature vérifiée', compositions=resultats)
(RACINE/'verification').mkdir(exist_ok=True)
texte = json.dumps(sortie, ensure_ascii=False, indent=2)+'\n'
(RACINE/'verification/production-geometrie.json').write_text(texte)
(RACINE/'dist/exports/production-geometrie.json').write_text(texte)
