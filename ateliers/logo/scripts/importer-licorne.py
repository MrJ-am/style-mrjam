#!/usr/bin/env python3
"""Normalise le modèle approuvé sans modifier ses contours ni ses proportions."""
import math
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

RACINE = Path(__file__).resolve().parents[1]
SOURCE = RACINE / 'references/licorne/modele-valide.svg'
CIBLE = RACINE / 'src/Echo/Licorne.elm'
NS = {'s': 'http://www.w3.org/2000/svg'}
racine = ET.parse(SOURCE).getroot()
x, y, largeur, hauteur = map(float, racine.attrib['viewBox'].split())
assert largeur == hauteur
k = 30 / largeur
formes = {'audio': 'Auditif', 'visio': 'Visuel', 'kino': 'Kinesthesique'}
noms = {
    '11': 'criniere-front', '13': 'criniere-tempe', '14': 'criniere-joue',
    '20': 'criniere-arriere', 'meche-basse-1': 'criniere-basse-1',
    'meche-basse-2': 'criniere-basse-2', '5': 'oreille-arriere',
    '7': 'oreille-avant', '8': 'corne-base', '6': 'corne-2',
    '4': 'corne-3', '2': 'corne-4', '1': 'corne-pointe', '16': 'oeil',
}
lignes = []
for piece in racine.findall('.//s:use', NS):
    a, b, c, d, e, f = map(float, re.findall(r'[-+\d.eE]+', piece.attrib['transform'][7:-1]))
    assert abs(a*c+b*d) < 1e-10 and abs(a*a+b*b-c*c-d*d) < 1e-10
    identifiant = piece.attrib['id'].removeprefix('piece-')
    nom = noms.get(identifiant, identifiant)
    forme = formes[piece.attrib['{http://www.w3.org/1999/xlink}href'].removeprefix('#forme-')]
    # Les définitions Elm ont leur origine en (13,8 ; 9), le SVG source non.
    xx, yy = k*(a*13.8+c*9+e-x), k*(b*13.8+d*9+f-y)
    echelle, angle = k*math.hypot(c,d), math.degrees(math.atan2(-c,d))
    miroir = 'True' if a*d-b*c < 0 else 'False'
    lignes.append(f'{{ id = "{nom}", brick = {forme}, x = {xx!r}, y = {yy!r}, angle = {angle!r}, scale = {echelle!r}, reflected = {miroir} }}')
gradient = racine.find('.//s:linearGradient', NS).attrib
coord = {n: k*(float(gradient[n])-(x if n.startswith('x') else y)) for n in ['x1','y1','x2','y2']}
contenu = '''module Echo.Licorne exposing (degrade, placements)

{-| Données du modèle approuvé : museau très long, sans poitrail.
Généré par scripts/importer-licorne.py. Les trois contours restent dans Primitives.
Le dégradé global va du blanc de la corne au rose du disque dans la crinière.
-}

import Echo.Primitives exposing (Brick(..))


type alias Placement =
    { id : String, brick : Brick, x : Float, y : Float, angle : Float, scale : Float, reflected : Bool }



degrade : { x1 : Float, y1 : Float, x2 : Float, y2 : Float }
degrade =
    { ''' + ', '.join(f'{n} = {v!r}' for n,v in coord.items()) + ''' }


placements : List Placement
placements =
    [ ''' + '\n    , '.join(lignes) + '\n    ]\n'
with tempfile.TemporaryDirectory() as dossier:
    temporaire = Path(dossier) / 'Licorne.elm'
    temporaire.write_text(contenu)
    subprocess.run([str(RACINE/'node_modules/.bin/elm-format'), str(temporaire), '--yes'], check=True, stdout=subprocess.DEVNULL)
    resultat = temporaire.read_text()
if '--check' in sys.argv:
    assert CIBLE.read_text() == resultat, 'Placements différents du modèle approuvé : relancer importer-licorne.py'
    print('Licorne : 19 similitudes et dégradé conformes au modèle approuvé.')
else:
    CIBLE.write_text(resultat)
