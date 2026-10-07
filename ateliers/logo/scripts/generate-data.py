"""Générer les données Elm mesurées et embarquer les références sans appel réseau."""
from pathlib import Path
import base64
import json

RACINE = Path(__file__).resolve().parents[1]
KIT = RACINE / 'references/kit_codex_logo_X'
entete = '''module Echo.ReferenceData exposing (Target, targets, ciblesY, ciblesZ, logoSource, xSource, sourceY, sourceZ)

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
    ('ciblesY', RACINE/'donnees/decomposition-Y.json', RACINE/'donnees/geometrie-Y.json'),
    ('ciblesZ', RACINE/'donnees/decomposition-Z.json', None)
]:
    donnees = json.loads(decomposition.read_text())
    erreurs = {r['path_id']: r for r in json.loads(rapport.read_text())['instances']} if rapport else {}
    lignes = []
    for inst in donnees['instances']:
        # Z est une création à poses définies, sans ajustement sur un dessin ancien.
        e = erreurs.get(inst['path_source'], {'erreur_max_echantillons': 0, 'borne_continue': 0})
        lignes.append('    { id = %s, path = %s, brick = %s, x = %r, y = %r, angle = %s, scale = %r, reflected = %s, error = %r, bound = %r }' % (
            json.dumps(inst['id']), json.dumps(inst['path_source']), inst['brique'], *inst['translation'],
            inst['angle_degres'], inst['echelle'], 'True' if inst['chiralite'] == 'Reflechie' else 'False',
            e['erreur_max_echantillons'], e['borne_continue']))
    sortie += f'\n{nom} : List Target\n{nom} =\n    [\n' + '\n    ,\n'.join(lignes) + '\n    ]\n'
for cle, chemin in [('logoSource', KIT/'sources/logo-original.svg'), ('xSource', KIT/'sources/X-original.svg'), ('sourceY', RACINE/'references/Y-original.svg'), ('sourceZ', RACINE/'dessins/Z.svg')]:
    url = 'data:image/svg+xml;base64,' + base64.b64encode(chemin.read_bytes()).decode()
    sortie += f'\n{cle} : String\n{cle} =\n    "{url}"\n'
(RACINE/'src/Echo/ReferenceData.elm').write_text(sortie)
