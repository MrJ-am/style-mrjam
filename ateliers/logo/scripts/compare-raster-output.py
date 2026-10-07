"""Quantify browser raster differences; Pillow is a development-only dependency."""
from pathlib import Path
import json
from PIL import Image, ImageChops, ImageFilter

root = Path(__file__).resolve().parents[1]/'verification'
results = []
for engine in ['chromium','firefox']:
    for name in ['logo','x','y','z']:
        source = Image.open(root/'rasters'/f'{engine}-{name}-source.png').convert('RGBA')
        for kind in ['export','scene']:
            target = Image.open(root/'rasters'/f'{engine}-{name}-{kind}.png').convert('RGBA')
            diff = ImageChops.difference(source,target)
            total = sum(i*n for band in diff.split() for i,n in enumerate(band.histogram()))
            maximum = max(band.getextrema()[1] for band in diff.split())
            mean = total/(4*source.width*source.height)
            maximum_band = diff.split()[0]
            for band in diff.split()[1:]:
                maximum_band = ImageChops.lighter(maximum_band,band)
            mask = maximum_band.point(lambda v: 255 if v else 0)
            edges = source.convert('RGB').filter(ImageFilter.FIND_EDGES).convert('L').point(lambda v: 255 if v else 0).filter(ImageFilter.MaxFilter(7))
            outside = ImageChops.subtract(mask,edges).histogram()[255]
            count = mask.histogram()[255]
            result = dict(engine=engine,composition=name,comparison=kind,size=source.size,background='white',maximum_component_error=maximum,mean_component_error=mean,different_pixels=count,different_pixels_outside_3px_contours=outside,threshold_mean=0.02,passed=mean<=0.02 and outside==0)
            results.append(result)
            diff.save(root/'rasters'/f'{engine}-{name}-{kind}-difference.png')
(root/'comparaison-navigateurs.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
assert all(r['passed'] for r in results), 'Raster mismatch: inspect the report and differences.'
