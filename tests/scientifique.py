"""Portées scientifiques, TeX réel, Markdown littéral et soumission clavier.

La référence historique est une entrée différentielle facultative, jamais un
renderer du produit. Le pilote et KaTeX sont ceux déjà verrouillés centralement.
"""
import argparse
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import tempfile
import threading
from playwright.sync_api import expect, sync_playwright

PORTEES = "Première ligne\n  Hypothèse $P$\n  Conséquence **importante**\n    Sous-portée $Q$\n    Conséquence\n  Fin de sous-portée\nRetour\nConclusion"
CAS = [
    PORTEES,
    PORTEES.replace("  ", ""),
    "# Titre\n\nParagraphe **fort** et `code $ignoré$`.\nUne autre ligne.\n\n- Premier $x^2$\n- Second\n\n## Autre titre\n\n$$\\frac{1}{2}$$",
    '<img src=x onerror="alert(1)"> & <script>hostile</script>\n\n**Texte sûr**',
    "Une formule $\\href{javascript:alert(1)}{refusée}$ et un dollar non fermé $.",
    "", "  \r\n\r\n# Titre\rListe\r\n- Élément", "Littéral **non fermé et `isolé et $$a",
]


class Silencieux(SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def verifier(javascript, katex, reference=None):
    racine = Path(__file__).resolve().parents[1]
    resultats = []
    with tempfile.TemporaryDirectory(prefix='scientifique-mrjam-') as temporaire:
        dossier = Path(temporaire)
        (dossier / 'app.js').write_bytes(javascript.read_bytes())
        (dossier / 'mathematiques.js').write_bytes((racine / 'public/assets/mrjam/mathematiques.js').read_bytes())
        (dossier / 'index.html').write_text('''<!doctype html><html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="stylesheet" href="/katex/katex.min.css"><script defer src="/katex/katex.min.js"></script><script defer src="/app.js"></script><script defer src="/mathematiques.js"></script></head><body><div id="app"></div></body></html>''')
        if reference:
            (dossier / 'reference.js').write_bytes(reference.read_bytes())
            (dossier / 'reference.html').write_text('''<!doctype html><html lang="fr"><head><meta charset="utf-8"><link rel="stylesheet" href="/katex/katex.min.css"><script src="/katex/katex.min.js"></script><script src="/katex/contrib/auto-render.min.js"></script><script src="/reference.js"></script></head><body><rich-text></rich-text></body></html>''')
        serveur = ThreadingHTTPServer(('127.0.0.1', 0), partial(Silencieux, directory=temporaire))
        threading.Thread(target=serveur.serve_forever, daemon=True).start()
        try:
            with sync_playwright() as pilote:
                options = {'executable_path': os.environ['CHROMIUM']} if os.environ.get('CHROMIUM') else {}
                navigateur = pilote.chromium.launch(**options)
                try:
                    for largeur in (320, 390, 1363):
                        page = navigateur.new_page(viewport={'width': largeur, 'height': 1000})
                        page.set_default_timeout(3000)
                        erreurs = []
                        page.on('pageerror', lambda erreur: erreurs.append(str(erreur)))
                        page.route('**/katex/**', lambda route: route.fulfill(path=katex / route.request.url.split('/katex/', 1)[1]))
                        for indice, source in enumerate(CAS):
                            page.goto(f'http://127.0.0.1:{serveur.server_port}/', wait_until='networkidle')
                            page.evaluate('(source)=>window.fixture=Elm.Scientifique.init({node:document.getElementById("app"),flags:source})', source)
                            doc = page.locator('[data-mrjam-document]')
                            expect(doc).to_have_attribute('data-mrjam-document', source)
                            assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), (largeur, indice)
                            if indice == 0:
                                portees = doc.locator('[data-mrjam-portee]')
                                expect(portees).to_have_count(8)
                                geometrie = portees.evaluate_all('xs=>xs.map(x=>({retrait:parseFloat(getComputedStyle(x).paddingLeft),largeur:x.clientWidth,contenu:x.scrollWidth}))')
                                retraits = [x['retrait'] for x in geometrie]
                                assert retraits[0] == 0 and retraits[1] > 0
                                assert abs(retraits[3] - retraits[1] * 2) < .1
                                assert retraits[5] == retraits[1] and retraits[6] == 0
                                assert all(x['contenu'] <= x['largeur'] + 1 for x in geometrie), geometrie
                                expect(doc.locator('math')).to_have_count(2)
                                expect(doc.locator('.katex-error')).to_have_count(0)
                                if reference:
                                    ancienne = navigateur.new_page()
                                    ancienne.route('**/katex/**', lambda route: route.fulfill(path=katex / route.request.url.split('/katex/', 1)[1]))
                                    ancienne.goto(f'http://127.0.0.1:{serveur.server_port}/reference.html', wait_until='networkidle')
                                    ancienne.locator('rich-text').evaluate('(e,s)=>e.setAttribute("content",s)', source)
                                    anciennes = ancienne.locator('.proof-line').evaluate_all('xs=>xs.map(x=>({texte:x.textContent,retrait:parseFloat(getComputedStyle(x).paddingLeft)}))')
                                    assert len(anciennes) == 8
                                    assert [x['retrait'] / anciennes[1]['retrait'] for x in anciennes] == [r / retraits[1] for r in retraits]
                                    expect(ancienne.locator('.katex-error')).to_have_count(0)
                                    ancienne.close()
                            elif indice == 1:
                                expect(doc.locator('[data-mrjam-portee]')).to_have_count(0)
                            elif indice == 2:
                                expect(doc.get_by_role('heading', level=1)).to_have_text('Titre')
                                expect(doc.get_by_role('heading', level=2)).to_have_text('Autre titre')
                                expect(doc.get_by_role('listitem')).to_have_count(2)
                                expect(doc.locator('math')).to_have_count(2)
                                expect(doc).to_contain_text('code $ignoré$')
                            elif indice == 3:
                                expect(doc.locator('img,script')).to_have_count(0)
                                expect(doc).to_contain_text('<script>hostile</script>')
                            elif indice == 4:
                                expect(doc.locator('a')).to_have_count(0)
                                assert doc.inner_text()
                        champ = page.get_by_role('textbox', name='Saisie', exact=True)
                        champ.fill('Contenu conservé')
                        champ.press('Enter')
                        expect(page.locator('#validations')).to_have_text('1')
                        bouton = page.get_by_role('button', name='Action indépendante', exact=True)
                        bouton.focus()
                        bouton.press('Enter')
                        expect(page.locator('#actions')).to_have_text('1')
                        expect(page.locator('#validations')).to_have_text('1')
                        expect(champ).to_have_value('Contenu conservé')
                        assert erreurs == [], erreurs
                        resultats.append({'largeur': largeur, 'cas': len(CAS), 'porteesEtTexReels': True, 'soumissionBornee': True, 'referenceHistorique': bool(reference)})
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
    parser.add_argument('--reference', type=Path)
    args = parser.parse_args()
    print(json.dumps(verifier(args.javascript, args.katex, args.reference), ensure_ascii=False))
