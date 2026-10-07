#!/usr/bin/env python3
"""Reconnaître les briques de X et vérifier leurs similitudes (Python 3.10+).

Bibliothèque standard uniquement. Analyseur volontairement limité aux commandes
M/m, L/l, A/a, Z/z et aux transformations matrix/translate/rotate/scale utilisées
par les références fournies. Ce n'est pas un lecteur SVG général : toute syntaxe
non prise en charge provoque une erreur explicite, jamais un tracé approximatif.

Le parcours inverse et les trois décalages cycliques sont essayés indépendamment
de la réflexion. Les points servent à l'ajustement ; les SVG exportés conservent
les arcs d'origine. Une borne continue conservative complète l'échantillonnage.
Référence des conversions d'arcs : https://www.w3.org/TR/SVG/implnote.html
"""
from __future__ import annotations

import argparse
import cmath
from dataclasses import dataclass
import hashlib
import json
import math
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
NS = '{http://www.w3.org/2000/svg}'
ORIGINE = complex(13.8, 9.0)
NUMBER = r'[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?'
TOKEN = re.compile(NUMBER + r'|[A-Za-z]')
Affine = tuple[float, float, float, float, float, float]
IDENTITE: Affine = (1., 0., 0., 1., 0., 0.)


def tokens(source: str) -> list[str]:
    """Lire nombres/exposants et commandes, en rejetant les caractères inconnus."""
    result: list[str] = []
    end = 0
    for match in TOKEN.finditer(source):
        if source[end:match.start()].strip(' \t\r\n,'):
            raise ValueError('Séparateur SVG non reconnu')
        result.append(match.group())
        end = match.end()
    if source[end:].strip(' \t\r\n,'):
        raise ValueError('Fin SVG non reconnue')
    return result


def appliquer(m: Affine, p: complex) -> complex:
    """Appliquer la matrice SVG (a,b,c,d,e,f) à un point."""
    a, b, c, d, e, f = m
    return complex(a*p.real + c*p.imag + e, b*p.real + d*p.imag + f)


def composer(outer: Affine, inner: Affine) -> Affine:
    """Composer outer ∘ inner, y compris les translations."""
    a,b,c,d,e,f = outer
    g,h,i,j,k,l = inner
    return (a*g+c*h, b*g+d*h, a*i+c*j, b*i+d*j,
            a*k+c*l+e, b*k+d*l+f)


def transformation(source: str) -> Affine:
    """Lire une liste SVG de transformations dans son ordre spécifié."""
    result = IDENTITE
    end = 0
    for match in re.finditer(r'([A-Za-z]+)\s*\(([^)]*)\)', source):
        if source[end:match.start()].strip(' \t\r\n,'):
            raise ValueError('Transformation non reconnue')
        name, args = match.groups()
        values = [float(x) for x in tokens(args)]
        if name == 'matrix' and len(values) == 6:
            m = tuple(values)
        elif name == 'translate' and len(values) in (1, 2):
            m = (1.,0.,0.,1.,values[0],values[1] if len(values)==2 else 0.)
        elif name == 'scale' and len(values) in (1, 2):
            m = (values[0],0.,0.,values[-1],0.,0.)
        elif name == 'rotate' and len(values) in (1, 3):
            angle = math.radians(values[0])
            c, s = math.cos(angle), math.sin(angle)
            m = (c,s,-s,c,0.,0.)
            if len(values) == 3:
                x,y = values[1:]
                m = composer((1.,0.,0.,1.,x,y), composer(m,(1.,0.,0.,1.,-x,-y)))
        else:
            raise ValueError(f'Transformation non prise en charge : {name} {values}')
        result = composer(result, m)  # liste SVG = produit dans l'ordre écrit
        end = match.end()
    if source[end:].strip(' \t\r\n,'):
        raise ValueError('Fin de transformation non reconnue')
    return result


@dataclass(frozen=True)
class Arc:
    """Un arc elliptique, conservant la paramétrisation et ses extrémités."""
    start: complex
    end: complex
    center: complex
    rx: float
    ry: float
    phi: float
    theta: float
    delta: float

    def point(self, t: float) -> complex:
        """Évaluer l'arc ; préserver les extrémités données exactement."""
        if t == 0.:
            return self.start
        if t == 1.:
            return self.end
        angle = self.theta + t*self.delta
        return self.center + cmath.exp(1j*self.phi)*complex(
            self.rx*math.cos(angle), self.ry*math.sin(angle))


def arc_endpoint(start: complex, values: list[float], relative: bool) -> Arc:
    """Conversion endpoint → centre conforme à l'algorithme SVG."""
    rx,ry,degrees,large,sweep,x,y = values
    if large not in (0,1) or sweep not in (0,1):
        raise ValueError('Les drapeaux d’arc doivent valoir 0 ou 1')
    rx,ry = abs(rx),abs(ry)
    end = complex(x,y) + (start if relative else 0j)
    if not rx or not ry or abs(start-end) == 0:
        raise ValueError('Arc dégénéré non attendu dans ces références')
    phi = math.radians(degrees)
    v = (start-end)/2 * cmath.exp(-1j*phi)
    lam = (v.real/rx)**2 + (v.imag/ry)**2
    if lam > 1:
        rx *= math.sqrt(lam)
        ry *= math.sqrt(lam)
    den = rx*rx*v.imag*v.imag + ry*ry*v.real*v.real
    num = max(0., rx*rx*ry*ry-den)
    factor = (-1 if large == sweep else 1)*math.sqrt(num/den)
    local = factor*complex(rx*v.imag/ry, -ry*v.real/rx)
    center = cmath.exp(1j*phi)*local + (start+end)/2
    u = complex((v.real-local.real)/rx, (v.imag-local.imag)/ry)
    w = complex((-v.real-local.real)/rx,(-v.imag-local.imag)/ry)
    theta = cmath.phase(u)
    delta = cmath.phase(w/u)
    if sweep == 0 and delta > 0:
        delta -= math.tau
    if sweep == 1 and delta < 0:
        delta += math.tau
    return Arc(start,end,center,rx,ry,phi,theta,delta)


def lire_chemin(source: str) -> list[Arc]:
    """Lire le sous-ensemble utile ; refuser les segments non négligeables."""
    ts = tokens(source)
    i = 0
    command = ''
    current = 0j
    first: complex | None = None
    arcs: list[Arc] = []
    while i < len(ts):
        if ts[i].isalpha():
            command = ts[i]
            i += 1
        kind = command.upper()
        if kind == 'Z':
            if first is None or abs(current-first) > 1e-3:
                raise ValueError('Fermeture non négligeable non prise en charge')
            current = first
            command = ''
            continue
        count = {'M':2,'L':2,'A':7}.get(kind)
        if count is None or i+count > len(ts):
            raise ValueError(f'Commande SVG non prise en charge : {command!r}')
        vals = [float(v) for v in ts[i:i+count]]
        i += count
        if kind in ('M','L'):
            end = complex(*vals) + (current if command.islower() else 0j)
            if kind == 'M':
                if first is not None:
                    raise ValueError('Plusieurs sous-chemins non prévus')
                first = end
            elif abs(end-current) > 1e-3:
                raise ValueError('Segment non négligeable non prévu')
            current = end
            command = 'l' if command.islower() else 'L'
        else:
            if first is None:
                raise ValueError('Arc avant moveto')
            arc = arc_endpoint(current,vals,command.islower())
            arcs.append(arc)
            current = arc.end
    if len(arcs) != 3:
        raise ValueError(f'Il faut trois arcs par brique, obtenu : {len(arcs)}')
    return arcs


@dataclass(frozen=True)
class Chemin:
    """Un chemin et sa transformation cumulée depuis la racine SVG."""
    id: str
    arcs: list[Arc]
    transform: Affine


def lire_svg(path: Path) -> list[Chemin]:
    """Extraire les paths et composer tous leurs groupes ancêtres."""
    result: list[Chemin] = []
    def walk(node: ET.Element, parent: Affine) -> None:
        local = transformation(node.get('transform',''))
        cumulative = composer(parent,local)
        if node.tag == NS+'path':
            result.append(Chemin(node.get('id',f'path-{len(result)}'),
                                  lire_chemin(node.attrib['d']),cumulative))
        for child in node:
            walk(child,cumulative)
    walk(ET.parse(path).getroot(),IDENTITE)
    return result


def correspondances(arcs: list[Arc], reverse: bool, shift: int) -> list[tuple[Arc,bool]]:
    """Changer départ/sens du contour sans changer sa géométrie."""
    seq = [(a,reverse) for a in (list(reversed(arcs)) if reverse else arcs)]
    return seq[shift:]+seq[:shift]


def echantillons(seq: list[tuple[Arc,bool]], count: int) -> list[complex]:
    """Échantillonnage uniforme de l'angle de chaque arc, extrémités comprises."""
    return [arc.point(1-j/(count-1) if rev else j/(count-1))
            for arc,rev in seq for j in range(count)]


def reflechir(p: complex, miroir: bool) -> complex:
    """Réflexion F(x,y)=(-x,y), ou identité."""
    return -p.conjugate() if miroir else p


def ajuster(source: list[complex], target: list[complex], miroir: bool) -> tuple[complex,complex]:
    """Moindres carrés : target ≈ translation + multiplicateur × F(source)."""
    xs = [reflechir(x,miroir) for x in source]
    mx = sum(xs)/len(xs)
    my = sum(target)/len(target)
    denom = sum(abs(x-mx)**2 for x in xs)
    if denom < 1e-20:
        raise ValueError('Points insuffisants pour ajuster une similitude')
    mult = sum((x-mx).conjugate()*(y-my) for x,y in zip(xs,target))/denom
    if abs(mult) < 1e-12:
        raise ValueError('Ajustement singulier')
    return mult,my-mult*mx


def facteur_similitude(m: Affine) -> float:
    """Vérifier une similitude et en renvoyer l'échelle positive."""
    a,b,c,d,_,_ = m
    sx,sy = math.hypot(a,b),math.hypot(c,d)
    if abs(sx-sy)>1e-9 or abs(a*c+b*d)>1e-9 or sx<1e-12:
        raise ValueError('La borne continue exige une similitude non dégénérée')
    return sx


def borne_continue(seq: list[tuple[Arc,bool]], target: Chemin,
                    mult: complex, translation: complex, miroir: bool) -> float:
    """Borner l'écart sur tous les t des arcs correspondants, non seulement des points.

    Pour deux arcs circulaires C+v exp(i delta t), on utilise
    |ΔC|+|Δv|+|v_cible| |Δdelta|, puisque |exp(ia)-exp(ib)|≤|a-b|.
    Ajout conservatif des très petits segments de fermeture numériques.
    """
    facteur_similitude(target.transform)
    a,b,c,d,_,_ = target.transform
    target_sign = 1 if a*d-b*c>0 else -1
    bounds = []
    for (source,rev), dest in zip(seq,target.arcs):
        if abs(source.rx-source.ry)>1e-9 or abs(dest.rx-dest.ry)>1e-9:
            raise ValueError('La borne continue est réservée aux arcs circulaires')
        cs = translation+mult*reflechir(source.center-ORIGINE,miroir)
        ct = appliquer(target.transform,dest.center)
        ps = source.end if rev else source.start
        vs = mult*reflechir(ps-source.center,miroir)
        vt = appliquer(target.transform,dest.start)-ct
        ds = source.delta*(-1 if rev else 1)*(-1 if miroir else 1)
        dt = dest.delta*target_sign
        bounds.append(abs(cs-ct)+abs(vs-vt)+abs(vt)*abs(ds-dt))
    # La seule fermeture implicite ajoute un petit segment aux contours fournis.
    source_gap = max(
        abs((arc.start if rev else arc.end)
            - (seq[(i+1)%3][0].end if seq[(i+1)%3][1]
               else seq[(i+1)%3][0].start))
        for i,(arc,rev) in enumerate(seq))
    target_gap = abs(appliquer(target.transform,target.arcs[-1].end)
                     - appliquer(target.transform,target.arcs[0].start))
    return max(bounds)+abs(mult)*source_gap+target_gap


def reconnaitre(source: Chemin, target: Chemin, count: int) -> list[dict]:
    """Essayer similitudes directes/indirectes et toutes les correspondances d'arcs."""
    ys = [appliquer(target.transform,p) for p in echantillons(
        [(arc,False) for arc in target.arcs],count)]
    result = []
    for reverse in (False,True):
        for shift in range(3):
            seq = correspondances(source.arcs,reverse,shift)
            xs = [p-ORIGINE for p in echantillons(seq,count)]
            for miroir in (False,True):
                mult,trans = ajuster(xs,ys,miroir)
                errors = [abs(trans+mult*reflechir(x,miroir)-y) for x,y in zip(xs,ys)]
                result.append(dict(translation=[trans.real,trans.imag],
                    angle_degres=math.degrees(cmath.phase(mult)),echelle=abs(mult),
                    miroir=miroir,parcours_inverse=reverse,decalage_arcs=shift,
                    erreur_max_echantillons=max(errors),
                    erreur_rms=math.sqrt(sum(e*e for e in errors)/len(errors)),
                    borne_continue=borne_continue(seq,target,mult,trans,miroir)))
    return result


def verifier(root: Path = ROOT, count: int = 129, tolerance: float = 1e-4) -> dict:
    """Reconnaître X et retourner mesures, données de production et signatures."""
    if count < 3 or not math.isfinite(tolerance) or tolerance <= 0:
        raise ValueError('Nombre de points ou tolérance invalide')
    logo = lire_svg(root/'sources/logo-original.svg')
    targets = lire_svg(root/'sources/X-original.svg')
    if len(logo)!=3 or len(targets)!=7:
        raise ValueError('Structure inattendue des références')
    noms = ['Auditif','Visuel','Kinesthesique']
    results = []
    for target in targets:
        choices = []
        for name,source in zip(noms,logo):
            for candidate in reconnaitre(source,target,count):
                candidate['brique'] = name
                choices.append(candidate)
        good = [c for c in choices if c['borne_continue'] <= tolerance]
        # Préférer une réalisation sans réflexion si la brique admet les deux.
        pool = [c for c in good if not c['miroir']] or good or choices
        best = min(pool,key=lambda c:c['erreur_rms']).copy()
        # Retenir les angles entiers du dessin et les deux échelles issues
        # des rayons si cela respecte encore la tolérance ; mesurer, pas supposer.
        libre = best.copy()
        source = logo[noms.index(best['brique'])]
        seq = correspondances(source.arcs,best['parcours_inverse'],best['decalage_arcs'])
        xs = [p-ORIGINE for p in echantillons(seq,count)]
        ys = [appliquer(target.transform,p) for p in echantillons(
            [(arc,False) for arc in target.arcs],count)]
        scale = facteur_similitude(target.transform)*min(a.rx for a in target.arcs)/3
        angle = round(best['angle_degres'])
        mult = scale*cmath.exp(1j*math.radians(angle))
        trans = sum(y-mult*reflechir(x,best['miroir']) for x,y in zip(xs,ys))/len(xs)
        errors = [abs(trans+mult*reflechir(x,best['miroir'])-y) for x,y in zip(xs,ys)]
        bound = borne_continue(seq,target,mult,trans,best['miroir'])
        if bound <= tolerance:
            best.update(translation=[trans.real,trans.imag],angle_degres=angle,
                        echelle=scale,erreur_max_echantillons=max(errors),
                        erreur_rms=math.sqrt(sum(e*e for e in errors)/len(errors)),
                        borne_continue=bound,parametres_normalises=True)
        else:
            best['parametres_normalises'] = False
        best['ajustement_libre'] = libre
        best['path_id'] = target.id
        best['determinant'] = (-1 if best['miroir'] else 1)*best['echelle']**2
        best['fermeture_cible'] = abs(appliquer(target.transform,target.arcs[-1].end)
                                      - appliquer(target.transform,target.arcs[0].start))
        best['transform_originale_cumulee'] = list(target.transform)
        best['valide'] = best['borne_continue']<=tolerance
        results.append(best)
    return dict(version=1,unites='viewBox SVG 30 × 30 ; y vers le bas',
        origine_locale=[ORIGINE.real,ORIGINE.imag],
        formule='T(p)=translation+echelle*R(angle)*F^miroir(p), F(x,y)=(-x,y)',
        nature='Ajustement numérique des arcs arrondis, pas égalité symbolique exacte',
        tolerance=tolerance,points_par_arc=count,
        methode='Toutes briques, deux sens, trois départs, deux chiralités ; moindres carrés complexes',
        critere='Borne continue conservative des arcs et fermetures ; voir le code',
        sources_sha256={name:hashlib.sha256((root/'sources'/name).read_bytes()).hexdigest()
                        for name in ['logo-original.svg','X-original.svg']},
        valide=all(c['valide'] for c in results),instances=results)


def main() -> int:
    """Produire le rapport JSON ; sortir en échec si la tolérance est dépassée."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--points',type=int,default=129)
    parser.add_argument('--tolerance',type=float,default=1e-4)
    parser.add_argument('--sortie',type=Path)
    args = parser.parse_args()
    try:
        report = verifier(args.root,args.points,args.tolerance)
    except (ValueError,OSError,ET.ParseError) as exc:
        print(f'Erreur : {exc}',file=sys.stderr)
        return 2
    text = json.dumps(report,ensure_ascii=False,indent=2,allow_nan=False)+'\n'
    if args.sortie:
        args.sortie.parent.mkdir(parents=True,exist_ok=True)
        args.sortie.write_text(text,encoding='utf-8')
    else:
        print(text,end='')
    return 0 if report['valide'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
