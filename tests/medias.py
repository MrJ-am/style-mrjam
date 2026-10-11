"""TeX réel et lecteur elm-ui, SDK/serveurs vidéo synthétiques et isolés."""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import tempfile
import threading
from playwright.sync_api import expect, sync_playwright

AMORCE = """
window.lecteurs = []; window.attendre = false;
window.Vimeo = { Player: class {
  constructor(iframe) {
    this.iframe = iframe; this.evenements = {}; this.detruit = false;
    this.attente = window.attendre;
    this.pret = this.attente ? new Promise(resolve => this.resoudre = resolve) : Promise.resolve();
    window.lecteurs.push(this);
  }
  on(nom, action) { this.evenements[nom] = action; }
  ready() { return this.pret; }
  destroy() { this.detruit = true; return Promise.resolve(); }
}};
"""


class Silencieux(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def verifier(javascript, katex):
    racine = Path(__file__).resolve().parents[1]
    resultats = []
    with tempfile.TemporaryDirectory(prefix='medias-mrjam-') as temporaire:
        dossier = Path(temporaire)
        (dossier / 'app.js').write_bytes(javascript.read_bytes())
        (dossier / 'videos.js').write_bytes((racine / 'public/assets/mrjam/videos.js').read_bytes())
        (dossier / 'mathematiques.js').write_bytes((racine / 'public/assets/mrjam/mathematiques.js').read_bytes())
        (dossier / 'affiche.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 160 90"><rect width="160" height="90" fill="#dcebe1"/></svg>')
        # Rendu par la bibliothèque déjà consommée par Logique, trust=false.
        # Ce petit amorçage de test ne définit aucune interface du produit.
        (dossier / 'index.html').write_text('''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/katex/katex.min.css"><script defer src="/katex/katex.min.js"></script><script defer src="/app.js"></script><script defer src="/videos.js"></script><script defer src="/mathematiques.js"></script></head><body><div id="app"></div></body></html>''')
        serveur = ThreadingHTTPServer(('127.0.0.1', 0), partial(Silencieux, directory=temporaire))
        threading.Thread(target=serveur.serve_forever, daemon=True).start()
        try:
            with sync_playwright() as pilote:
                options = {'executable_path': os.environ['CHROMIUM']} if os.environ.get('CHROMIUM') else {}
                navigateur = pilote.chromium.launch(**options)
                try:
                    for largeur in (320, 768, 1440):
                        page = navigateur.new_page(viewport={'width': largeur, 'height': 1100})
                        page.set_default_timeout(4000)
                        erreurs, contacts = [], []
                        page.on('pageerror', lambda erreur: erreurs.append(str(erreur)))
                        page.add_init_script(AMORCE)

                        def externe(route):
                            contacts.append(route.request.url)
                            route.fulfill(status=200, content_type='text/html', body='<!doctype html><title>Lecteur synthétique</title>')

                        page.route('https://**/*', externe)
                        page.route('**/katex/**', lambda route: route.fulfill(path=katex / route.request.url.split('/katex/', 1)[1]))
                        page.goto(f'http://127.0.0.1:{serveur.server_port}/', wait_until='networkidle')
                        page.evaluate("window.medias=Elm.Medias.init({node:document.getElementById('app')})")
                        eviter = page.get_by_role('link', name='Aller au contenu', exact=True)
                        assert eviter.evaluate('e=>getComputedStyle(e).opacity') == '0'
                        eviter.focus()
                        expect(eviter).to_be_visible()
                        assert eviter.evaluate('e=>getComputedStyle(e).opacity') == '1'
                        assert eviter.bounding_box()['y'] >= 0
                        eviter.press('Enter')
                        expect(page.locator('#repere-medias')).to_be_focused()
                        region = page.locator('#lecteur-video')
                        bouton = page.get_by_role('button', name='Lire Démonstration à 0:37', exact=True)
                        try:
                            expect(bouton).to_be_visible()
                        except AssertionError:
                            print({'erreurs': erreurs, 'boutons': page.get_by_role('button').evaluate_all("xs=>xs.map(x=>({texte:x.textContent,nom:x.getAttribute('aria-label'),id:x.id,hidden:x.closest('[aria-hidden]')?.outerHTML.slice(0,100)}))"), 'cible': page.locator('#video-activer').count()}, flush=True)
                            raise
                        expect(page.locator('#information-video')).to_be_visible()
                        expect(page.locator('iframe')).to_have_count(0)
                        assert contacts == [], contacts
                        expect(page.locator('#texte-mathematique')).to_contain_text('<b>échappé</b>')
                        expect(page.locator('#texte-mathematique b')).to_have_count(0)
                        expect(page.locator('#texte-mathematique math')).to_have_count(1)
                        expect(page.locator('#formule-mathematique .katex-display')).to_have_count(1)
                        expect(page.locator('#formule-hostile a')).to_have_count(0)
                        assert page.locator('#formule-hostile').inner_text(), 'Une formule refusée reste intelligible'
                        assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), largeur
                        assert bouton.bounding_box()['height'] >= 44
                        bouton.focus()
                        nombre = page.evaluate('lecteurs.length')
                        bouton.press('Enter')
                        iframe = page.locator('iframe')
                        expect(iframe).to_have_count(1)
                        expect(iframe).to_have_attribute('title', 'Démonstration')
                        assert 'dnt=1' in iframe.get_attribute('src') and iframe.get_attribute('src').endswith('#t=37s')
                        expect(iframe).to_have_attribute('referrerpolicy', 'strict-origin-when-cross-origin')
                        cadre = iframe.bounding_box()
                        assert abs(cadre['width'] / cadre['height'] - 16 / 9) < .02, cadre
                        expect(page.get_by_text('Ouverture de la vidéo…', exact=True)).to_have_count(0)
                        assert page.evaluate('lecteurs.length') == nombre + 1, 'Le passage prêt ne recrée pas le SDK'
                        page.evaluate("lecteurs.at(-1).evenements.timeupdate({seconds:125})")
                        page.get_by_role('button', name='Arrêter la vidéo', exact=True).click()
                        expect(iframe).to_have_count(0)
                        reprendre = page.get_by_role('button', name='Reprendre Démonstration à 2:05', exact=True)
                        expect(reprendre).to_be_focused()
                        assert page.evaluate('lecteurs.at(-1).detruit')
                        reprendre.click()
                        expect(iframe).to_have_attribute('src', __import__('re').compile(r'#t=125s$'))
                        page.evaluate("lecteurs.at(-1).evenements.error({name:'PrivacyError'})")
                        expect(iframe).to_have_count(0)
                        secours = page.get_by_role('link', name='Regarder sur Vimeo — nouvel onglet', exact=True)
                        expect(secours).to_have_attribute('target', '_blank')
                        expect(secours).to_be_focused()
                        page.get_by_role('button', name='Réessayer ici', exact=True).click()
                        expect(reprendre).to_be_focused()
                        page.get_by_role('button', name='Depuis le début', exact=True).click()
                        expect(iframe).to_have_attribute('src', __import__('re').compile(r'#t=0s$'))
                        page.evaluate("lecteurs.at(-1).evenements.ended({})")
                        page.get_by_role('button', name='Arrêter la vidéo', exact=True).click()
                        expect(bouton).to_be_focused()
                        # Promesse ancienne résolue après destruction et changement de vue.
                        page.evaluate('window.attendre=true')
                        bouton.click()
                        expect(page.get_by_text('Ouverture de la vidéo…', exact=True)).to_be_visible()
                        page.get_by_role('button', name='YouTube', exact=True).click()
                        expect(iframe).to_have_count(0)
                        assert page.evaluate('lecteurs.at(-1).detruit')
                        page.evaluate('lecteurs.at(-1).resoudre()')
                        expect(bouton).to_be_visible()
                        bouton.click()
                        expect(iframe).to_have_attribute('src', __import__('re').compile(r'^https://www\.youtube-nocookie\.com/'))
                        expect(page.get_by_text('Ouverture de la vidéo…', exact=True)).to_have_count(0)
                        page.get_by_role('button', name='Arrêter la vidéo', exact=True).click()
                        # Mauvais hôte refusé avant toute création d'iframe.
                        page.get_by_role('button', name='Source invalide', exact=True).click()
                        avant = len(contacts)
                        bouton.click()
                        expect(secours).to_be_visible()
                        expect(iframe).to_have_count(0)
                        assert len(contacts) == avant
                        if largeur == 320:
                            # Délai réel du SDK bloqué, sans altérer les horloges du produit.
                            page.get_by_role('button', name='Vimeo', exact=True).click()
                            page.evaluate('window.attendre=true')
                            bouton.click()
                            expect(page.get_by_text('Ouverture de la vidéo…', exact=True)).to_be_visible()
                            expect(secours).to_be_focused(timeout=17000)
                            expect(iframe).to_have_count(0)
                            assert page.evaluate('lecteurs.at(-1).detruit')
                        # SDK manquant : échec explicite, aucune vue figée en chargement.
                        page.get_by_role('button', name='Vimeo', exact=True).click()
                        page.evaluate('window.Vimeo=undefined')
                        bouton.click()
                        expect(secours).to_be_focused()
                        expect(iframe).to_have_count(0)
                        assert erreurs == [], erreurs
                        resultats.append({'largeur': largeur, 'texReel': True, 'sdkSynthetique': True, 'clavierFocusReprise': True, 'promesseObsoleteIgnoree': True, 'sourcesRefusees': True})
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
    parser.add_argument('--katex', type=Path, required=True)
    args = parser.parse_args()
    print(json.dumps(verifier(args.javascript, args.katex), ensure_ascii=False))
