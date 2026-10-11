"""Notation facultative : saisie relative, zéro/absence, annulation et clavier."""
import argparse
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


def verifier(javascript, firefox=None):
    racine = Path(__file__).resolve().parents[1]
    resultats = []
    with tempfile.TemporaryDirectory(prefix='notes-mrjam-') as temporaire:
        dossier = Path(temporaire)
        (dossier / 'app.js').write_bytes(javascript.read_bytes())
        (dossier / 'notes.js').write_bytes((racine / 'public/assets/mrjam/notes.js').read_bytes())
        (dossier / 'index.html').write_text('''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><script src="app.js"></script></head><body><div id="app"></div><script>Elm.Scientifique.init({node:document.getElementById('app'),flags:''});</script><script src="notes.js"></script></body></html>''')
        serveur = ThreadingHTTPServer(('127.0.0.1', 0), partial(Silencieux, directory=temporaire))
        threading.Thread(target=serveur.serve_forever, daemon=True).start()
        try:
            with sync_playwright() as pilote:
                for moteur in ('chromium', 'firefox') if firefox else ('chromium',):
                    navigateur = getattr(pilote, moteur).launch(**({'executable_path': str(firefox)} if moteur == 'firefox' else {}))
                    try:
                        for largeur in (320, 390, 1363):
                            page = navigateur.new_page(viewport={'width': largeur, 'height': 1000})
                            page.goto(f'http://127.0.0.1:{serveur.server_port}/')
                            reponse = page.locator('#note-reponse')
                            evenements = page.locator('#note-evenements')
                            input_ = page.locator('#grade')
                            surface = page.locator('[data-mrjam-note-relative]')
                            surface.evaluate("e=>e.addEventListener('pointerdown', event=>window.pointerNote=event.pointerId)")
                            expect(reponse).to_have_text('absente')
                            expect(evenements).to_have_text('0')
                            expect(input_).to_have_attribute('aria-valuetext', 'Non noté')
                            boite = surface.bounding_box()
                            # Le rail éloigné de la poignée ne produit aucun saut.
                            page.mouse.click(boite['x'] + 5, boite['y'] + 22)
                            expect(reponse).to_have_text('absente')
                            expect(evenements).to_have_text('0')
                            poignee = page.locator('[data-testid="grade-knob"]').bounding_box()
                            x, y = poignee['x'] + 16, poignee['y'] + 16
                            page.mouse.move(x, y)
                            page.mouse.down()
                            page.mouse.move(x + (boite['width'] - 32) / 4, y, steps=5)
                            expect(input_).to_have_value('2.25')
                            expect(reponse).to_have_text('absente')
                            expect(evenements).to_have_text('0')
                            page.mouse.up()
                            expect(reponse).to_have_text('2.25')
                            expect(evenements).to_have_text('1')
                            # Une annulation conserve la réponse déjà validée.
                            poignee = page.locator('[data-testid="grade-knob"]').bounding_box()
                            x, y = poignee['x'] + 16, poignee['y'] + 16
                            page.mouse.move(x, y)
                            page.mouse.down()
                            page.mouse.move(x - (boite['width'] - 32) / 5, y, steps=3)
                            expect(input_).not_to_have_value('2.25')
                            surface.dispatch_event('pointercancel', {'pointerId': page.evaluate('window.pointerNote')})
                            page.mouse.up()
                            expect(input_).to_have_value('2.25')
                            expect(reponse).to_have_text('2.25')
                            expect(evenements).to_have_text('1')
                            input_.focus()
                            input_.press('Home')
                            expect(reponse).to_have_text('0')
                            expect(evenements).to_have_text('2')
                            expect(input_).to_have_attribute('aria-valuetext', '0 sur 3')
                            input_.press('ArrowRight')
                            expect(reponse).to_have_text('0.25')
                            expect(evenements).to_have_text('3')
                            assert page.evaluate('document.documentElement.scrollWidth <= innerWidth')
                            resultats.append({'moteur': moteur, 'version': navigateur.version, 'largeur': largeur, 'relatif': True, 'previewSansEcriture': True, 'annulation': True, 'zeroAbsent': True, 'clavier': True})
                            page.close()
                        if moteur == 'chromium':
                            page = navigateur.new_page(viewport={'width': 390, 'height': 844}, is_mobile=True, has_touch=True)
                            page.goto(f'http://127.0.0.1:{serveur.server_port}/')
                            session = page.context.new_cdp_session(page)
                            boite = page.locator('[data-mrjam-note-relative]').bounding_box()
                            poignee = page.locator('[data-testid="grade-knob"]').bounding_box()
                            x, y = poignee['x'] + 16, poignee['y'] + 16
                            def toucher(type_, x=None, y=None):
                                session.send('Input.dispatchTouchEvent', {'type': type_, 'touchPoints': [] if x is None else [{'id': 1, 'x': x, 'y': y}]})
                            toucher('touchStart', x, y)
                            for i in range(1, 9):
                                toucher('touchMove', x + (boite['width'] - 32) / 4 * i / 8, y + 35 * i / 8)
                                page.wait_for_timeout(18)
                            toucher('touchEnd')
                            expect(page.locator('#note-reponse')).to_have_text('2.25')
                            expect(page.locator('#note-evenements')).to_have_text('1')
                            poignee = page.locator('[data-testid="grade-knob"]').bounding_box()
                            x, y = poignee['x'] + 16, poignee['y'] + 16
                            toucher('touchStart', x, y)
                            for i in range(1, 9):
                                toucher('touchMove', x - (boite['width'] - 32) / 5 * i / 8, y)
                                page.wait_for_timeout(18)
                            expect(page.locator('#grade')).not_to_have_value('2.25')
                            toucher('touchCancel')
                            expect(page.locator('#note-reponse')).to_have_text('2.25')
                            expect(page.locator('#grade')).to_have_value('2.25')
                            expect(page.locator('#note-evenements')).to_have_text('1')
                            resultats.append({'moteur': moteur, 'version': navigateur.version, 'tactileReel': True, 'diagonale': True, 'annulation': True})
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
    parser.add_argument('--firefox', type=Path, help='Binaire existant explicitement choisi ; aucune installation ou substitution implicite')
    args = parser.parse_args()
    print(json.dumps(verifier(args.javascript, args.firefox), ensure_ascii=False))
