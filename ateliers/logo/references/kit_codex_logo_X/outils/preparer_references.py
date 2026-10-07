#!/usr/bin/env python3
"""Régénérer la table de X et les deux SVG factorisés depuis les références.

Aucune dépendance tierce. Aucune ressource réseau. Aucun chemin de X n'est recopié
comme nouvelle primitive : les trois paths de la définition sont ceux du logo.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import xml.etree.ElementTree as ET

from verifier_geometrie import ROOT, NS, verifier

IDS = {
    'path4':'kinesthesique-0','path6':'kinesthesique-1',
    'path8':'visuel-1','path10':'auditif-0','path12':'kinesthesique-2',
    'path16':'visuel-2','path18':'visuel-0',
}


def definition(root: Path, prefix: str) -> ET.Element:
    """Créer quatre définitions locales, en gardant les d sources inchangés."""
    defs = ET.Element(NS+'defs')
    ET.SubElement(defs,NS+'circle',id=prefix+'esprit',cx='0',cy='0',r='2')
    paths = ET.parse(root/'sources/logo-original.svg').getroot().findall('.//'+NS+'path')
    for name,path in zip(['auditif','visuel','kinesthesique'],paths):
        g = ET.SubElement(defs,NS+'g',id=prefix+name,transform='translate(-13.8 -9)')
        ET.SubElement(g,NS+'path',d=path.attrib['d'])
    return defs


def svg(root: Path, cible: str, instances: list[dict]) -> str:
    """Assembler un SVG autonome avec defs/use et le fond de référence."""
    ET.register_namespace('','http://www.w3.org/2000/svg')
    prefix = 'ref-'+cible.lower()+'-'
    node = ET.Element(NS+'svg',version='1.1',viewBox='0 0 30 30')
    node.append(definition(root,prefix))
    ET.SubElement(node,NS+'circle',cx='15',cy='15',r='15',
                  fill='#64c29b' if cible=='Logo' else '#9c3e65')
    group = ET.SubElement(node,NS+'g',fill='#fff',stroke='none')
    if cible=='Logo':
        for name in ['esprit','auditif','visuel','kinesthesique']:
            ET.SubElement(group,NS+'use',href='#'+prefix+name,
                          transform='translate(13.8 9)')
    else:
        for inst in instances:
            x,y = inst['translation']
            transform = (f'translate({x:.17g} {y:.17g}) '
                         f'rotate({inst["angle_degres"]:.17g}) '
                         f'scale({inst["echelle"]:.17g})')
            if inst['miroir']:
                transform += ' scale(-1 1)'
            ET.SubElement(group,NS+'use',id=IDS[inst['path_id']],
                          href='#'+prefix+inst['brique'].lower(),transform=transform)
    ET.indent(node,space='  ')
    return '<?xml version="1.0" encoding="UTF-8"?>\n'+ET.tostring(node,encoding='unicode')+'\n'


def preparer(root: Path = ROOT) -> dict:
    """Recalculer les données ; refuser d'exporter un résultat hors tolérance."""
    report = verifier(root)
    if not report['valide']:
        raise ValueError('La géométrie ne respecte pas le seuil : export refusé')
    for directory in ['donnees','exports','verification']:
        (root/directory).mkdir(parents=True,exist_ok=True)
    (root/'verification/geometrie.json').write_text(
        json.dumps(report,ensure_ascii=False,indent=2,allow_nan=False)+'\n',encoding='utf-8')
    entries = []
    for item in report['instances']:
        entries.append(dict(id=IDS[item['path_id']],path_source=item['path_id'],
            brique=item['brique'],translation=item['translation'],
            angle_degres=item['angle_degres'],echelle=item['echelle'],
            chiralite='Reflechie' if item['miroir'] else 'Directe'))
    data = dict(version=1,origine_locale=[13.8,9],repere='SVG : y vers le bas',
                formule=report['formule'],fond_logo='#64c29b',fond_X='#9c3e65',
                ordre_de_dessin='Ordre de la liste instances',instances=entries)
    (root/'donnees/decomposition-X.json').write_text(
        json.dumps(data,ensure_ascii=False,indent=2,allow_nan=False)+'\n',encoding='utf-8')
    for name in ['Logo','X']:
        (root/'exports'/f'{name}-factorise.svg').write_text(svg(root,name,report['instances']),encoding='utf-8')
    return report


def main() -> None:
    """Point d'entrée du régénérateur de références."""
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    args=parser.parse_args()
    report=preparer(args.root)
    print(f'Géométrie validée, {len(report["instances"])} occurrences exportées.')


if __name__=='__main__':
    main()
