"""Résumés et différences appariées ; temps en millisecondes, pas de FPS extrapolés."""
import json
import random
import statistics
from pathlib import Path

DOSSIER = Path(__file__).resolve().parent.parent
d = json.loads((DOSSIER / 'mesures-brutes.json').read_text())

def quantile(valeurs, p):
    a = sorted(valeurs)
    t = (len(a)-1)*p
    i = int(t)
    return a[i] + (a[min(i+1,len(a)-1)]-a[i])*(t-i)

def intervalle(differences):
    r = random.Random(20261013)
    med = [statistics.median(r.choices(differences, k=len(differences))) for _ in range(4000)]
    return [quantile(med,.025),quantile(med,.975)]

resume = []
comparaisons = []
for moteur in d['moteurs']:
    for regime in ['froid', 'chaud']:
        for largeur in [320,800,1600]:
            lignes = [x for x in moteur[regime] if x['largeur']==largeur]
            for nom in d['noms']:
                e = [x for x in lignes if x['nom']==nom]
                totaux = [x['total'] for x in e]
                resume.append({'moteur':moteur['moteur'],'regime':regime,'largeur':largeur,'nom':nom,'nombre':len(e),'medianeMs':statistics.median(totaux),'p10Ms':quantile(totaux,.1),'p90Ms':quantile(totaux,.9),**({'decodageMedianMs':statistics.median(x['decodage'] for x in e),'renduLectureMedianMs':statistics.median(x['renduLecture'] for x in e)} if regime=='froid' else {})})
            for a,b in [(d['noms'][0],d['noms'][1]),(d['noms'][2],d['noms'][3]),(d['noms'][0],d['noms'][2]),(d['noms'][1],d['noms'][3])]:
                aa={x['tour']:x['total'] for x in lignes if x['nom']==a}
                bb={x['tour']:x['total'] for x in lignes if x['nom']==b}
                differences=[bb[t]-aa[t] for t in aa]
                comparaisons.append({'moteur':moteur['moteur'],'regime':regime,'largeur':largeur,'a':a,'b':b,'differenceMedianeMs_bMoinsA':statistics.median(differences),'intervalleBootstrap95':intervalle(differences)})
(DOSSIER/'resultats.json').write_text(json.dumps({'mesures':resume,'comparaisons':comparaisons},ensure_ascii=False,indent=2)+'\n')
for r in resume:
    if r['largeur']==800: print(r)
print('Comparaisons à 800 px :')
for r in comparaisons:
    if r['largeur']==800: print(r)
