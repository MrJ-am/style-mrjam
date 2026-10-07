"""Reconnaître Y avec les arcs canoniques du logo et mesurer les arrondis SVG."""
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

logo = geometrie.lire_svg(KIT / 'sources/logo-original.svg')
cibles = geometrie.lire_svg(RACINE / 'references/Y-original.svg')
noms = ['Auditif', 'Visuel', 'Kinesthesique']
identifiants = ['visuel-1', 'visuel-0', 'kinesthesique-1', 'kinesthesique-0',
                'kinesthesique-2', 'kinesthesique-3', 'auditif-1', 'auditif-0']
assert len(cibles) == len(identifiants)
resultats = []
for cible in cibles:
    candidats = [dict(c, brique=nom) for nom, source in zip(noms, logo)
                 for c in geometrie.reconnaitre(source, cible, 129)]
    valides = [c for c in candidats if c['borne_continue'] <= 1e-4]
    assert valides, cible.id
    # Comme pour X, préférer une similitude directe quand la brique admet les deux.
    choix = [c for c in valides if not c['miroir']] or valides
    meilleur = min(choix, key=lambda c: c['erreur_rms']).copy()
    libre = meilleur.copy()
    source = logo[noms.index(meilleur['brique'])]
    seq = geometrie.correspondances(source.arcs, meilleur['parcours_inverse'], meilleur['decalage_arcs'])
    xs = [p-geometrie.ORIGINE for p in geometrie.echantillons(seq, 129)]
    ys = [geometrie.appliquer(cible.transform, p) for p in geometrie.echantillons([(a, False) for a in cible.arcs], 129)]
    echelle = geometrie.facteur_similitude(cible.transform)*min(a.rx for a in cible.arcs)/3
    angle = round(meilleur['angle_degres'])
    mult = echelle*cmath.exp(1j*math.radians(angle))
    translation = sum(y-mult*geometrie.reflechir(x, meilleur['miroir']) for x, y in zip(xs, ys))/len(xs)
    erreurs = [abs(translation+mult*geometrie.reflechir(x, meilleur['miroir'])-y) for x, y in zip(xs, ys)]
    borne = geometrie.borne_continue(seq, cible, mult, translation, meilleur['miroir'])
    if borne <= 1e-4:
        meilleur.update(translation=[translation.real, translation.imag], angle_degres=angle,
                        echelle=echelle, erreur_max_echantillons=max(erreurs),
                        erreur_rms=math.sqrt(sum(e*e for e in erreurs)/len(erreurs)), borne_continue=borne)
    meilleur.update(parametres_normalises=borne <= 1e-4, ajustement_libre=libre,
                    path_id=cible.id, transform_originale_cumulee=list(cible.transform), valide=True)
    resultats.append(meilleur)

# Vérifier les doublons sur les arcs ET leurs transformations cumulées.
assert cibles[2].arcs == cibles[4].arcs and cibles[2].transform == cibles[4].transform
assert cibles[3].arcs == cibles[5].arcs and cibles[3].transform == cibles[5].transform
rapport = dict(version=1, tolerance=1e-4, points_par_arc=129, valide=True,
               nature='Similitudes des arcs arrondis ; borne continue conservative, calcul flottant.',
               doublons={'path14': 'path8', 'path16': 'path10'},
               sources_sha256={str(p.relative_to(RACINE)): hashlib.sha256(p.read_bytes()).hexdigest()
                               for p in [KIT/'sources/logo-original.svg', RACINE/'references/Y-original.svg']},
               instances=resultats)
donnees = dict(version=1, origine_locale=[13.8, 9], fond_logo='#64c29b', fond_Y='#64c29b',
               formule='T(p)=translation+echelle*R(angle)*F^miroir(p), F(x,y)=(-x,y)',
               ordre_de_dessin='Ordre de la liste instances ; doublons historiques conservés',
               doublons=rapport['doublons'], instances=[
                   dict(id=identifiant, path_source=r['path_id'], brique=r['brique'],
                        translation=r['translation'], angle_degres=r['angle_degres'],
                        echelle=r['echelle'], chiralite='Reflechie' if r['miroir'] else 'Directe')
                   for identifiant, r in zip(identifiants, resultats)])
(RACINE/'donnees').mkdir(exist_ok=True)
for nom, contenu in [('decomposition-Y.json', donnees), ('geometrie-Y.json', rapport)]:
    (RACINE/'donnees'/nom).write_text(json.dumps(contenu, ensure_ascii=False, indent=2)+'\n')
for r in resultats:
    print(r['path_id'], r['brique'], r['angle_degres'], r['echelle'], r['miroir'], r['borne_continue'])
