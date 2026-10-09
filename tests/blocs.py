"""Géométrie générique, emboîtement, focus et petits écrans sans données métier."""
from pathlib import Path
import os
import subprocess
import tempfile
from playwright.sync_api import sync_playwright, expect

racine = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory() as temporaire:
    bundle = Path(temporaire) / 'blocs.js'
    subprocess.run(['node_modules/.bin/elm', 'make', 'exemples/Blocs.elm', '--output='+str(bundle)],cwd=racine,check=True)
    with sync_playwright() as p:
        navigateur = p.chromium.launch(**({'executable_path':os.environ['CHROMIUM']} if 'CHROMIUM' in os.environ else {}))
        page = navigateur.new_page()
        for largeur in [320,390,768,1280]:
            page.set_viewport_size({'width':largeur,'height':900})
            page.set_content('<div id="app"></div>')
            page.add_script_tag(content=bundle.read_text())
            page.evaluate('Elm.Blocs.init({node:document.getElementById("app")})')
            expect(page.locator('.mrjam-bloc')).to_have_count(2)
            expect(page.locator('.mrjam-cavite')).to_have_count(3)
            bouton=page.get_by_role('button',name='Placer dans la première cavité')
            bouton.focus()
            page.keyboard.press('Enter')
            expect(page.get_by_text('Actions : 1',exact=True)).to_be_visible()
            assert page.evaluate('document.documentElement.scrollWidth <= innerWidth + 2')
            for cavite in page.locator('.mrjam-cavite').all():
                boite=cavite.bounding_box()
                assert boite['width'] > 120 and boite['height'] >= 48
        navigateur.close()
print('Blocs communs : 4 formats, 3 cavités, clavier et imbrication vérifiés.')
