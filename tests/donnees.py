"""Contrôles des composants de données ; les fixtures ne quittent pas la galerie."""
import base64
import json
import os
import re
import threading
from functools import partial
from http.server import ThreadingHTTPServer
from pathlib import Path
from navigation import ServeurSilencieux
from playwright.sync_api import expect, sync_playwright


def verifier():
    racine = Path(__file__).resolve().parents[1]
    serveur = ThreadingHTTPServer(('127.0.0.1', 0), partial(ServeurSilencieux, directory=str(racine / 'public')))
    threading.Thread(target=serveur.serve_forever, daemon=True).start()
    resultats = []
    try:
        with sync_playwright() as pilote:
            executable = os.environ.get('CHROMIUM')
            navigateur = pilote.chromium.launch(**({'executable_path': executable} if executable else {}))
            for largeur in [320, 390, 768, 1440]:
                page = navigateur.new_page(viewport={'width': largeur, 'height': 1000})
                erreurs = []
                page.on('pageerror', lambda erreur: erreurs.append(str(erreur)))
                if os.environ.get('HORS_LIGNE') == '1':
                    css = (racine / 'public/assets/mrjam/signature.css').read_text()
                    css = re.sub(r'@font-face\{[^}]+\}', '', css)
                    page.set_content('<html lang="fr"><head><style>' + css + '</style></head><body><div id="application"></div></body></html>')
                    page.add_script_tag(content=(racine / 'public/donnees.js').read_text())
                    page.evaluate("Elm.Donnees.init({node:document.getElementById('application')})")
                    logo = base64.b64encode((racine / 'public/assets/mrjam/Echologo.svg').read_bytes()).decode()
                    page.get_by_role('img', name='Logo MrJ.am').evaluate("(image, contenu) => image.src = 'data:image/svg+xml;base64,' + contenu", logo)
                else:
                    page.goto(f'http://127.0.0.1:{serveur.server_port}/donnees.html', wait_until='networkidle')
                nombre = page.get_by_role('spinbutton', name='Valeur numérique')
                expect(nombre).to_have_attribute('step', 'any')
                nombre.fill('-12.75')
                expect(page.get_by_text('Nombre saisi : -12.75', exact=True)).to_be_visible()
                nombre.fill('')
                expect(nombre).to_have_value('')
                date = page.get_by_label('Date civile', exact=True)
                expect(date).to_have_attribute('type', 'date')
                date.fill('2028-02-29')
                expect(page.get_by_text('Date saisie : 2028-02-29', exact=True)).to_be_visible()
                instant = page.get_by_label('Date et heure locales', exact=True)
                expect(instant).to_have_attribute('type', 'datetime-local')
                instant.fill('2028-02-29T23:59:58.125')
                expect(page.get_by_text('Instant saisi : 2028-02-29T23:59:58.125', exact=True)).to_be_visible()
                texte = '  Deux espaces\n    Quatre espaces\n<script>window.intrusion = true</script>'
                lecteur = page.get_by_text(texte, exact=True)
                assert lecteur.text_content() == texte
                assert page.evaluate('window.intrusion === undefined')
                tableau = page.get_by_role('table', name='Exemple de données', exact=True)
                expect(tableau.get_by_role('row')).to_have_count(3)
                expect(tableau.get_by_role('columnheader')).to_have_count(3)
                expect(tableau.get_by_role('cell')).to_have_count(6)
                bouton = tableau.get_by_role('button', name='Ouvrir').first
                bouton.focus()
                bouton.press('Enter')
                expect(page.get_by_text('Ouvertures : 1', exact=True)).to_be_visible()
                bouton.press('Space')
                expect(page.get_by_text('Ouvertures : 2', exact=True)).to_be_visible()
                region = page.get_by_role('region', name='Exemple de données — défilement horizontal', exact=True)
                region.focus()
                expect(region).to_be_focused()
                if largeur < 480:
                    assert region.evaluate('element => element.scrollWidth > element.clientWidth')
                    region.press('Home')
                    region.press('ArrowRight')
                    page.wait_for_timeout(200)
                    assert region.evaluate('element => element.scrollLeft > 0')
                for controle in [nombre, date, instant, bouton]:
                    assert controle.bounding_box()['height'] >= 44, (controle.get_attribute('type'), controle.bounding_box())
                assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), largeur
                assert not erreurs, erreurs
                page.screenshot(path=str(racine / 'tests' / f'donnees-{largeur}.png'), full_page=True)
                resultats.append({'largeur': largeur, 'resultat': 'succès', 'mode': 'mémoire' if os.environ.get('HORS_LIGNE') == '1' else 'HTTP'})
                page.close()
            navigateur.close()
    finally:
        serveur.shutdown()
        serveur.server_close()
    (racine / 'tests/resultats-donnees.json').write_text(json.dumps(resultats, ensure_ascii=False, indent=2) + '\n')
    print(json.dumps(resultats, ensure_ascii=False))


if __name__ == '__main__':
    verifier()
