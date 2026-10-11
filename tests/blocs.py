"""Contours peints, palette originale, emboîtement et dimensions du vrai widget."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
from PIL import Image
from playwright.sync_api import expect, sync_playwright


def verifier(javascript):
    resultats = []
    with sync_playwright() as pilote:
        navigateur = pilote.chromium.launch(**({'executable_path': os.environ['CHROMIUM']} if 'CHROMIUM' in os.environ else {}))
        try:
            for largeur, hauteur in ((1440, 1000), (1280, 900), (768, 1024), (1024, 768), (390, 844), (844, 390), (320, 740)):
                page = navigateur.new_page(viewport={'width': largeur, 'height': hauteur})
                erreurs = []
                page.on('pageerror', lambda e: erreurs.append(str(e)))
                page.set_content('<!doctype html><html lang="fr"><body><div id="application"></div></body></html>')
                page.add_script_tag(content=javascript.read_text())
                page.evaluate('Elm.Blocs.init({node:document.getElementById("application")})')
                blocs = page.locator('[data-mrjam-construction="bloc"]')
                expect(blocs).to_have_count(2)
                bloc = blocs.first
                entete = bloc.locator(':scope > [data-mrjam-construction="entete"]')
                pied = bloc.locator(':scope > [data-mrjam-construction="pied"]')
                expect(entete).to_have_css('background-color', 'rgb(255, 203, 56)')
                assert entete.bounding_box()['height'] >= 48
                assert entete.evaluate('e=>getComputedStyle(e).clipPath').startswith('polygon(')
                expect(bloc.locator(':scope > [data-mrjam-construction="traverse"]')).to_have_count(1)
                epines = bloc.locator('[data-mrjam-construction="epine"]')
                for epine in epines.all():
                    assert epine.bounding_box()['width'] == 12
                    assert epine.bounding_box()['height'] >= 38, epine.bounding_box()
                # Pixels de l'encoche supérieure et de la languette inférieure.
                # L'oracle lit le fond réellement peint, pas une chaîne de CSS.
                image = Image.open(io.BytesIO(bloc.screenshot())).convert('RGB')
                tete = entete.bounding_box()
                bas = pied.bounding_box()
                origine = bloc.bounding_box()
                x_tete = round(tete['x'] - origine['x'])
                y_tete = round(tete['y'] - origine['y'])
                jaune = (255, 203, 56)
                assert image.getpixel((x_tete + 27, y_tete + 1)) != jaune
                assert image.getpixel((x_tete + 46, y_tete + 1)) == jaune
                x_pied = round(bas['x'] - origine['x'])
                y_pied = round(bas['y'] - origine['y'] + bas['height']) - 2
                assert image.getpixel((x_pied + 27, y_pied)) == jaune
                assert image.getpixel((x_pied + 60, y_pied)) != jaune
                premiere_epine = epines.first.bounding_box()
                x = round(premiere_epine['x'] - origine['x'])
                y = round(premiere_epine['y'] - origine['y'] + premiere_epine['height'] / 2)
                assert image.getpixel((x + 5, y)) == jaune
                assert image.getpixel((x + 15, y)) != jaune  # cavité ouverte
                cavites = page.locator('[data-mrjam-construction="cavite"]')
                expect(cavites).to_have_count(3)
                for cavite in cavites.all():
                    boite = cavite.bounding_box()
                    assert boite["width"] > 120 and boite["height"] >= 48, boite
                assert page.evaluate("document.documentElement.scrollWidth <= innerWidth + 2")
                bouton = page.get_by_role('button', name='Placer dans la première cavité', exact=True)
                bouton.click()
                expect(page.get_by_text('Actions : 1', exact=True)).to_be_visible()
                bouton.focus()
                bouton.press('Enter')
                expect(page.get_by_text('Actions : 2', exact=True)).to_be_visible()
                objets = page.locator('[data-mrjam-construction="objet"]')
                assert objets.count() == 4
                couleurs = objets.evaluate_all('es=>es.map(e=>getComputedStyle(e).backgroundColor)')
                assert couleurs[:2] == ['rgb(88, 182, 83)'] * 2, couleurs
                assert len(set(couleurs[1:])) == 3, couleurs
                page.get_by_role('button', name='Ouvrir l’atelier', exact=True).click()
                atelier = page.locator('[data-mrjam-construction="atelier"]')
                expect(atelier).to_be_visible()
                for w, h in ((largeur, hauteur), (320, 740), (844, 390), (1440, 1000)):
                    page.set_viewport_size({'width': w, 'height': h})
                    expect(atelier).to_have_css('height', f'{h}px')
                    palette = page.locator('[data-mrjam-construction="palette"]')
                    expect(palette).to_have_css('width', f'{140 if w <= 480 else 184 if w <= 900 else 258}px')
                    assert palette.bounding_box()['x'] == 0
                    assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), w
                    assert page.evaluate('document.documentElement.scrollHeight <= innerHeight + 2'), (w, h)
                    expect(page.get_by_role('button', name='Annuler', exact=True)).to_be_visible()
                    expect(page.get_by_text('Actions : 2', exact=True).last).to_be_visible()
                assert not erreurs, erreurs
                resultats.append({'dimensions': [largeur, hauteur], 'encoches_et_cavites_peintes': True, 'couleurs_originales_et_profondeur': True,
                                  'clavier_et_etat': True, 'palette_dimensions_defilements': True})
                page.close()
        finally:
            navigateur.close()
    print(json.dumps({'javascript_sha256': hashlib.sha256(javascript.read_bytes()).hexdigest(), 'parcours': resultats}, ensure_ascii=False))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--javascript', type=Path, default=Path(__file__).resolve().parents[1] / 'public/galerie.js')
    verifier(parser.parse_args().javascript)
