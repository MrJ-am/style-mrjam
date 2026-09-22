"""Contrôles de la galerie : interactions, clavier et absence de débordement."""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import json
import base64
import re
import os
import threading
from playwright.sync_api import expect, sync_playwright
from controles import verifier_controles


class ServeurSilencieux(SimpleHTTPRequestHandler):
    def log_message(self, *arguments):
        pass


def verifier():
    racine = Path(__file__).resolve().parents[1]
    serveur = ThreadingHTTPServer(("127.0.0.1", 0), partial(ServeurSilencieux, directory=str(racine / "public")))
    fil = threading.Thread(target=serveur.serve_forever, daemon=True)
    fil.start()
    resultats = []
    try:
        with sync_playwright() as pilote:
            executable = os.environ.get("CHROMIUM")
            navigateur = pilote.chromium.launch(**({"executable_path": executable} if executable else {}))
            for largeur in [320, 390, 768, 1440]:
                page = navigateur.new_page(viewport={"width": largeur, "height": 1000})
                page.set_default_timeout(3000)
                erreurs = []
                page.on("pageerror", lambda erreur: erreurs.append(str(erreur)))
                if os.environ.get("HORS_LIGNE") == "1":
                    # Même JavaScript compilé, chargé en mémoire sans accès réseau.
                    javascript = (racine / "public/galerie.js").read_text()
                    css = (racine / "public/assets/mrjam/signature.css").read_text()
                    css = re.sub(r"@font-face\{[^}]+\}", "", css)
                    page.set_content('<html lang="fr"><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>' + css + '</style></head><body><div id="application"></div></body></html>')
                    page.add_script_tag(content=javascript)
                    page.evaluate("Elm.Galerie.init({node:document.getElementById('application')})")
                    page.add_script_tag(content=(racine / "public/assets/mrjam/fenetres.js").read_text())
                    logo = base64.b64encode((racine / "public/assets/mrjam/Echologo.svg").read_bytes()).decode()
                    page.get_by_role("img", name="Logo MrJ.am").evaluate("(image, contenu) => image.src = 'data:image/svg+xml;base64,' + contenu", logo)
                else:
                    page.goto(f"http://127.0.0.1:{serveur.server_port}/", wait_until="networkidle")
                expect(page.get_by_role("heading", name="Style MrJ.am")).to_be_visible()
                enregistrer = page.get_by_role("button", name="Enregistrer", exact=True)
                enregistrer.click()
                expect(page.get_by_text("Nombre d’enregistrements : 1", exact=True)).to_be_visible()
                enregistrer.focus()
                enregistrer.press("Enter")
                expect(page.get_by_text("Nombre d’enregistrements : 2", exact=True)).to_be_visible()
                enregistrer.press("Space")
                expect(page.get_by_text("Nombre d’enregistrements : 3", exact=True)).to_be_visible()
                expect(page.get_by_role("button", name="Indisponible", exact=True)).to_be_disabled()
                expect(page.get_by_role("button", name="Indisponible", exact=True)).to_have_attribute("tabindex", "-1")
                expect(page.get_by_role("button", name="Enregistrement en cours…", exact=True)).to_have_attribute("aria-busy", "true")
                champ = page.get_by_role("textbox", name="Titre", exact=True)
                champ.fill("Un titre avec des accents : éèàœ")
                expect(champ).to_have_value("Un titre avec des accents : éèàœ")
                contenu = "  Indentation conservée\n    Seconde ligne\n<script>ne pas exécuter</script>"
                page.get_by_role("textbox", name="Contenu", exact=True).fill(contenu)
                expect(page.get_by_role("textbox", name="Contenu", exact=True)).to_have_value(contenu)
                expect(page.get_by_label("Mot de passe", exact=True)).to_have_attribute("type", "password")
                case = page.get_by_role("checkbox", name="Inclure les fiches archivées")
                case.click()
                expect(case).to_be_checked()
                case.focus()
                case.press("Space")
                expect(case).not_to_be_checked()
                page.get_by_role("radio", name="Au moins une étiquette", exact=True).click()
                expect(page.get_by_role("radio", name="Au moins une étiquette", exact=True)).to_be_checked()
                page.get_by_role("button", name="Annuler", exact=True).click()
                expect(page.get_by_text("Confirmation : Annulation demandée.", exact=True)).to_be_visible()
                page.get_by_role("button", name="Archiver", exact=True).click()
                expect(page.get_by_text("Confirmation : Archivage demandé, aucune donnée réelle n’est modifiée.", exact=True)).to_be_visible()
                verifier_controles(page)
                identifiant = page.get_by_label("Identifiant de connexion", exact=True)
                expect(identifiant).to_have_attribute("autocomplete", "username")
                identifiant.fill("compte-de-demonstration")
                expect(identifiant).to_have_value("compte-de-demonstration")
                nouveau = page.get_by_label("Nouveau mot de passe", exact=True)
                expect(nouveau).to_have_attribute("autocomplete", "new-password")
                expect(nouveau).to_have_attribute("type", "password")
                nouveau.fill("Ceci-n-est-pas-un-secret")
                expect(nouveau).to_have_value("Ceci-n-est-pas-un-secret")
                tableau = page.get_by_role("table", name="Valeurs de démonstration", exact=True)
                expect(tableau.get_by_role("row")).to_have_count(3)
                expect(tableau.get_by_role("columnheader")).to_have_count(3)
                expect(tableau.get_by_role("cell")).to_have_count(6)
                expect(tableau.get_by_role("cell", name="0", exact=True)).to_have_count(2)
                assert tableau.bounding_box()["height"] >= 150
                tableau.get_by_role("button", name="Consulter", exact=True).first.click()
                tableau.get_by_role("button", name="Consulter", exact=True).first.focus()
                tableau.get_by_role("button", name="Consulter", exact=True).first.press("Enter")
                expect(page.get_by_text("Confirmation : Annulation demandée.", exact=True)).to_be_visible()
                expect(page.get_by_role("table", name="Résultats vides", exact=True).get_by_role("cell")).to_have_count(0)
                expect(page.get_by_text("Aucune donnée.", exact=True)).to_be_visible()
                defilement = page.get_by_role("region", name="Valeurs de démonstration — défilement horizontal", exact=True)
                if largeur < 600:
                    defilement.focus()
                    defilement.evaluate("element => element.scrollLeft = 0")
                    defilement.press("ArrowRight")
                    page.wait_for_function("element => element.scrollLeft > 0", arg=defilement.element_handle())
                assert not page.evaluate('Boolean(window.INJECTION)')
                expect(page.get_by_text('Du gras', exact=True)).to_be_visible()
                expect(page.get_by_role('table', name='Données de contrôle')).to_be_visible()
                declencheur = page.get_by_role('button', name='Ouvrir le dialogue', exact=True)
                declencheur.click()
                dialogue = page.get_by_role('dialog', name='Confirmer', exact=True)
                expect(dialogue).to_be_visible()
                for dimensions in ({"width": 320, "height": 460}, {"width": 844, "height": 390}, {"width": largeur, "height": 1000}):
                    page.set_viewport_size(dimensions)
                    boite = dialogue.bounding_box()
                    assert boite["x"] >= 0 and boite["y"] >= 0, boite
                    assert boite["x"] + boite["width"] <= dimensions["width"] + 1, boite
                    assert boite["y"] + boite["height"] <= dimensions["height"] + 1, boite
                    assert page.evaluate("document.documentElement.scrollWidth <= innerWidth + 1")
                expect(page.get_by_label('Valeur du dialogue', exact=True)).to_be_focused()
                page.get_by_role('button', name='Fermer le dialogue').focus()
                page.keyboard.press('Tab')
                expect(page.get_by_label('Valeur du dialogue', exact=True)).to_be_focused()
                enregistrer.evaluate('(e) => e.focus()')
                assert page.evaluate("document.activeElement.closest('dialog') !== null")
                page.keyboard.press('Escape')
                expect(dialogue).to_have_count(0)
                expect(declencheur).to_be_focused()
                assert page.locator(".mrjam").inner_text() == "MrJ.am"
                assert page.locator(".mrjam").evaluate("element => getComputedStyle(element).fontSize") == "28px"
                assert page.get_by_role("img", name="Logo MrJ.am").evaluate("image => image.complete && image.naturalWidth > 0")
                for bouton in page.get_by_role("button").all():
                    boite = bouton.bounding_box()
                    assert boite and boite["height"] >= 44, boite
                assert page.evaluate("document.documentElement.scrollWidth <= window.innerWidth"), f"Débordement à {largeur}px"
                assert not erreurs, erreurs
                page.screenshot(path=str(racine / "tests" / f"galerie-{largeur}.png"), full_page=True)
                resultats.append({"largeur": largeur, "resultat": "succès", "mode": "mémoire" if os.environ.get("HORS_LIGNE") == "1" else "HTTP"})
                page.close()
            navigateur.close()
    finally:
        serveur.shutdown()
        serveur.server_close()
    (racine / "tests" / "resultats.json").write_text(json.dumps(resultats, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(resultats, ensure_ascii=False))


if __name__ == "__main__":
    verifier()
