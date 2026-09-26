"""Contrats visuels et clavier des composants documentaires partagés."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import threading
from playwright.sync_api import sync_playwright, expect

RACINE = Path(__file__).resolve().parents[1]


class Silencieux(SimpleHTTPRequestHandler):
    def log_message(self, *_): pass


def verifier_largeur(page):
    assert page.evaluate("document.documentElement.scrollWidth <= innerWidth + 1")


def verifier():
    serveur=ThreadingHTTPServer(('127.0.0.1',0),partial(Silencieux,directory=str(RACINE/'public')))
    threading.Thread(target=serveur.serve_forever,daemon=True).start()
    try:
        with sync_playwright() as pw:
            navigateur=pw.chromium.launch()
            for largeur in [320,390,768,1440]:
                page=navigateur.new_page(viewport=dict(width=largeur,height=900))
                # Même bundle optimisé ; le bootstrap reste un squelette technique.
                page.goto(f'http://127.0.0.1:{serveur.server_port}/?vue=bibliotheque',wait_until='networkidle')
                expect(page.get_by_role('heading',name='Bibliothèque',exact=True)).to_be_visible()
                tableau=page.get_by_role('table',name='Documents',exact=True)
                expect(tableau.get_by_role('row')).to_have_count(4)
                expect(tableau.get_by_role('columnheader')).to_have_count(3)
                expect(tableau.get_by_role('link')).to_have_count(3)
                action_ligne=tableau.get_by_role('button',name='Archiver : Guide de travail',exact=True)
                expect(action_ligne).to_have_text('Archiver')
                assert 32 <= action_ligne.bounding_box()['height'] <= 38
                hauteurs=tableau.get_by_role('row').evaluate_all('es=>es.map(e=>e.getBoundingClientRect().height)')
                assert all(32<=h<=48 for h in hauteurs[:3]),hauteurs
                assert hauteurs[3]<=130,hauteurs # titre long replié, sans hauteur fixe
                expect(page.get_by_text('Aucune donnée.',exact=True)).to_be_visible()
                verifier_largeur(page)
                declencheur=page.get_by_role('button',name='Nouveau document',exact=True)
                assert 32<=declencheur.bounding_box()['height']<=38
                police=page.locator('.mrjam-ecran').evaluate('e=>getComputedStyle(e).fontFamily')
                declencheur.focus();declencheur.press('Enter')
                dialogue=page.get_by_role('dialog',name='Confirmer',exact=True)
                expect(dialogue).to_be_visible()
                assert page.locator('.mrjam-ecran').evaluate('e=>getComputedStyle(e).fontFamily')==police
                verifier_largeur(page)
                dialogue.press('Escape');expect(dialogue).to_have_count(0);expect(declencheur).to_be_focused()
                page.screenshot(path=str(RACINE/'tests'/f'galerie-documentaire-{largeur}.png'),full_page=True)
                page.close()
            navigateur.close()
    finally:serveur.shutdown()
    print('Composants documentaires : 4 formats, densité, clavier, titres longs, état vide et dialogue vérifiés.')


if __name__=='__main__':verifier()
