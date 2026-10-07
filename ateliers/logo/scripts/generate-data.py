"""Générer les données Elm mesurées et embarquer les références sans appel réseau."""
from pathlib import Path
import base64
import json

RACINE = Path(__file__).resolve().parents[1]
KIT = RACINE / 'references/kit_codex_logo_X'
entete = '''module Echo.ReferenceData exposing (Target, targets, ciblesY, logoSource, xSource, sourceY)

{-| Généré par scripts/generate-data.py. Contours uniques dans Echo.Primitives. -}
import Echo.Primitives exposing (Brick(..))

type alias Target =
    { id : String, path : String, brick : Brick
    , x : Float, y : Float, angle : Float, scale : Float, reflected : Bool
    , error : Float, bound : Float
    }
'''
sortie = entete
for nom, decomposition, rapport in [
    ('targets', KIT/'donnees/decomposition-X.json', KIT/'verification/geometrie.json'),
    ('ciblesY', RACINE/'donnees/decomposition-Y.json', RACINE/'donnees/geometrie-Y.json')
]:
    donnees = json.loads(decomposition.read_text())
    erreurs = {r['path_id']: r for r in json.loads(rapport.read_text())['instances']}
    lignes = []
    for inst in donnees['instances']:
        e = erreurs[inst['path_source']]
        lignes.append('    { id = %s, path = %s, brick = %s, x = %r, y = %r, angle = %s, scale = %r, reflected = %s, error = %r, bound = %r }' % (
            json.dumps(inst['id']), json.dumps(inst['path_source']), inst['brique'], *inst['translation'],
            inst['angle_degres'], inst['echelle'], 'True' if inst['chiralite'] == 'Reflechie' else 'False',
            e['erreur_max_echantillons'], e['borne_continue']))
    sortie += f'\n{nom} : List Target\n{nom} =\n    [\n' + '\n    ,\n'.join(lignes) + '\n    ]\n'
for cle, chemin in [('logoSource', KIT/'sources/logo-original.svg'), ('xSource', KIT/'sources/X-original.svg'), ('sourceY', RACINE/'references/Y-original.svg')]:
    url = 'data:image/svg+xml;base64,' + base64.b64encode(chemin.read_bytes()).decode()
    sortie += f'\n{cle} : String\n{cle} =\n    "{url}"\n'
(RACINE/'src/Echo/ReferenceData.elm').write_text(sortie)
