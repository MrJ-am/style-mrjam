#!/usr/bin/env python3
"""Comparer les références statiques et leurs SVG factorisés à 1200 × 1200.

Contrôle facultatif : nécessite CairoSVG et Pillow, contrairement aux tests de
base qui n'utilisent que Python. Aucune installation automatique ni réseau.
Ce test n'est pas une validation de navigateur ou de l'application Elm.
"""
from __future__ import annotations
import argparse
import io
import json
from pathlib import Path
import sys

ROOT=Path(__file__).resolve().parents[1]


def main() -> int:
    """Calculer les écarts RGBA et enregistrer un rapport explicite."""
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--taille',type=int,default=1200)
    args=parser.parse_args()
    if not 30 <= args.taille <= 4096:
        parser.error('La taille doit être comprise entre 30 et 4096')
    try:
        import cairosvg
        from PIL import Image, ImageChops
    except ImportError:
        print('Contrôle facultatif : installer CairoSVG et Pillow pour le lancer.',file=sys.stderr)
        return 2
    summary={}
    for name,source in [('Logo','logo'),('X','X')]:
        images=[]
        for path in [args.root/'sources'/f'{source}-original.svg',
                     args.root/'exports'/f'{name}-factorise.svg']:
            data=cairosvg.svg2png(bytestring=path.read_bytes(),output_width=args.taille,
                                 output_height=args.taille)
            images.append(Image.open(io.BytesIO(data)).convert('RGBA'))
        diff=ImageChops.difference(*images)
        bands=diff.split()
        max_band=bands[0]
        for band in bands[1:]:
            max_band=ImageChops.lighter(max_band,band)
        count=args.taille*args.taille-max_band.histogram()[0]
        total=sum(sum(i*n for i,n in enumerate(band.histogram())) for band in bands)
        summary[name]=dict(moteur='CairoSVG '+cairosvg.__version__,
            taille_px=[args.taille,args.taille],
            difference_max_sur_255=max(band.getextrema()[1] for band in bands),
            nombre_pixels_differents=count,
            ecart_absolu_moyen_par_composante=total/(4*args.taille*args.taille),
            statut='Comparaison raster de références statiques, pas test navigateur de l’application Elm')
    dest=args.root/'verification/comparaison-raster.json'
    dest.parent.mkdir(parents=True,exist_ok=True)
    dest.write_text(json.dumps(summary,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(summary,ensure_ascii=False,indent=2))
    return 0


if __name__=='__main__':
    raise SystemExit(main())
