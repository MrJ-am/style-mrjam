"""Lecteur commun : document défilant, commandes disponibles, focus et repos."""
import argparse
import os
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import tempfile
import threading
from playwright.sync_api import expect, sync_playwright


class Silencieux(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def verifier(javascript):
    racine = Path(__file__).resolve().parents[1]
    resultats = []
    with tempfile.TemporaryDirectory(prefix='lecture-mrjam-') as temporaire:
        dossier = Path(temporaire)
        (dossier / 'app.js').write_bytes(javascript.read_bytes())
        for nom in ('fenetres.js', 'notes.js'):
            (dossier / nom).write_bytes((racine / 'public/assets/mrjam' / nom).read_bytes())
        (dossier / 'index.html').write_text('''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><script src="app.js"></script></head><body><div id="app"></div><script src="fenetres.js"></script><script src="notes.js"></script></body></html>''')
        serveur = ThreadingHTTPServer(('127.0.0.1', 0), partial(Silencieux, directory=temporaire))
        threading.Thread(target=serveur.serve_forever, daemon=True).start()
        try:
            with sync_playwright() as pilote:
                navigateur = pilote.chromium.launch(**({"executable_path": os.environ["CHROMIUM"]} if os.environ.get("CHROMIUM") else {}))
                try:
                    for largeur, hauteur in ((320, 568), (390, 844), (1363, 936), (844, 390)):
                        for reduite in (False, True):
                            page = navigateur.new_page(viewport={'width': largeur, 'height': hauteur}, reduced_motion='reduce' if reduite else 'no-preference')
                            page.add_init_script('''window.framesLecture=0; const original=requestAnimationFrame; window.requestAnimationFrame=f=>{framesLecture++;return original(f);};''')
                            page.goto(f'http://127.0.0.1:{serveur.server_port}/')
                            page.evaluate('reduite=>Elm.Lecture.init({node:document.getElementById("app"),flags:reduite})', reduite)
                            ouvrir = page.get_by_role('button', name='Lire', exact=True)
                            ouvrir.click()
                            dialogue = page.get_by_role('dialog', name='Rédaction de contrôle', exact=True)
                            expect(dialogue).to_be_visible()
                            # Une commande métier est disponible immédiatement.
                            page.locator('#grade').focus()
                            page.locator('#grade').press('Home')
                            expect(page.locator('#lecture-note')).to_have_text('0')
                            page.wait_for_timeout(350)
                            boite = dialogue.bounding_box()
                            assert boite['x'] >= 0 and boite['y'] >= 0, (largeur, hauteur, boite)
                            assert abs(boite['y'] - 114) < 1, (largeur, hauteur, boite)
                            assert boite['x'] + boite['width'] <= largeur + 1 and boite['y'] + boite['height'] <= hauteur + 1, (largeur, hauteur, boite)
                            contenu = page.locator('[data-testid="reader-content"]')
                            assert contenu.evaluate('e=>e.scrollHeight>e.clientHeight'), (largeur, hauteur)
                            contenu.evaluate('e=>e.scrollTop=200')
                            assert contenu.evaluate('e=>e.scrollTop>0')
                            page.get_by_role('button', name='Autre texte', exact=True).click()
                            expect(contenu).to_contain_text('Étape 1')
                            expect(contenu).to_have_js_property('scrollTop', 0)
                            assert dialogue.evaluate('e=>e.contains(document.activeElement)')
                            for _ in range(8):
                                page.keyboard.press('Tab')
                                assert dialogue.evaluate('e=>e.contains(document.activeElement)')
                            nombre = page.evaluate('framesLecture')
                            page.wait_for_timeout(200)
                            assert page.evaluate('framesLecture') == nombre
                            page.keyboard.press('Escape')
                            expect(dialogue).to_have_count(0)
                            expect(ouvrir).to_be_focused()
                            ouvrir.click()
                            expect(dialogue).to_be_visible()
                            page.get_by_role('button', name='Fermer', exact=True).click()
                            expect(dialogue).to_have_count(0)
                            expect(ouvrir).to_be_focused()
                            assert page.evaluate('document.documentElement.scrollWidth<=innerWidth')
                            resultats.append({'largeur': largeur, 'hauteur': hauteur, 'reduite': reduite, 'commandesImmediates': True, 'focus': True, 'defilement': True, 'framesArretees': True})
                            page.close()
                finally:
                    navigateur.close()
        finally:
            serveur.shutdown()
            serveur.server_close()
    return resultats


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--javascript', type=Path, default=Path(__file__).resolve().parents[1] / 'public/galerie.js')
    args = parser.parse_args()
    print(json.dumps(verifier(args.javascript), ensure_ascii=False))
