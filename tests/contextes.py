"""Palettes isolées et contrôle select natif, sur le JavaScript réellement compilé."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
from playwright.sync_api import expect, sync_playwright
from typographie import verifier_alignement, verifier_points


def charger_polices(page, signature):
    # Ressources originales locales, réservées : jamais copiées dans le bundle.
    css = (signature / 'web/signature.css').read_text()
    import re
    page.add_style_tag(content=re.sub(r'@font-face\{[^}]+\}', '', css))
    for famille, fichier, format in (('MrJamSignature', 'web/MrJamSignature.woff2', 'woff2'),
                                     ('EchoPoint', 'web/EchoPoint.woff2', 'woff2'),
                                     ('MrJamEcriture', 'fonts/Parisienne-Regular.ttf', 'truetype')):
        donnees = base64.b64encode((signature / fichier).read_bytes()).decode()
        page.evaluate('async ({famille,donnees,format}) => {const f=new FontFace(famille,`url(data:font/${format};base64,${donnees})`);document.fonts.add(await f.load());}', {'famille': famille, 'donnees': donnees, 'format': format})


def verifier(javascript, signature):
    code = javascript.read_text()
    resultats = []
    with sync_playwright() as pilote:
        executable = os.environ.get('CHROMIUM')
        navigateur = pilote.chromium.launch(**({'executable_path': executable} if executable else {}))
        try:
            for largeur in (320, 768, 1440):
                page = navigateur.new_page(viewport={'width': largeur, 'height': 1000})
                erreurs = []
                page.on('pageerror', lambda erreur: erreurs.append(str(erreur)))
                page.set_content('<!doctype html><html lang="fr"><head><meta name="viewport" content="width=device-width,initial-scale=1"></head><body><div id="application"></div></body></html>')
                page.add_script_tag(content=code)
                page.evaluate("window.contextes=Elm.Contextes.init({node:document.getElementById('application')})")
                page.add_script_tag(path=str(Path(__file__).resolve().parents[1] / 'public/assets/mrjam/fenetres.js'))
                page.add_script_tag(path=str(Path(__file__).resolve().parents[1] / 'public/assets/mrjam/animations.js'))
                # evaluate invoque une expression retournant une fonction : une
                # expression nue appellerait ici le disposer immédiatement.
                page.evaluate('() => { window.detacherAnimations=MrJamAnimations.relier(contextes.ports.reductionAnimations); }')
                charger_polices(page, signature)
                marque = page.locator('[data-mrjam-marque]')
                expect(marque).to_have_text('Vision.MrJ.am')
                assert marque.evaluate('e=>getComputedStyle(e).userSelect') == 'text'
                verifier_alignement(marque)
                if largeur == 1440:
                    marque.evaluate('e=>{e.style.zoom="4";}')
                    verifier_alignement(marque)
                    verifier_points(marque)
                    marque.evaluate('e=>{e.style.removeProperty("zoom");}')
                couleurs = {}
                for nom in ('MrJ.am', 'Vision', 'Zoé'):
                    bouton = page.get_by_role('button', name=nom, exact=True)
                    expect(bouton).to_be_visible()
                    couleurs[nom] = bouton.evaluate('e => getComputedStyle(e).backgroundColor')
                assert len(set(couleurs.values())) == 3, couleurs
                # Les coordonnées OKLCH originales converties par le navigateur.
                # L'oracle ne reconstruit pas l'algorithme de conversion du produit.
                teintes = {'MrJ.am': 137.50776405003785, 'Vision': 227.50776405003785, 'Zoé': 272.50776405003785}
                for nom, teinte in teintes.items():
                    rgb = page.evaluate('h => {const canvas=document.createElement("canvas"); const c=canvas.getContext("2d"); c.fillStyle=`oklch(0.46 0.08 ${h})`; c.fillRect(0,0,1,1); return [...c.getImageData(0,0,1,1).data].slice(0,3)}', teinte)
                    attendu = f'rgb({rgb[0]}, {rgb[1]}, {rgb[2]})'
                    assert couleurs[nom] == attendu, (nom, couleurs[nom], attendu)
                # Le changement d'ordre force un rerendu sans transmettre la
                # palette d'une carte à ses voisines ni modifier les champs.
                page.get_by_role('textbox', name='Champ Vision', exact=True).fill('réponse conservée')
                page.get_by_role('button', name='MrJ.am', exact=True).click()
                page.mouse.move(0, 0)
                expect(page.get_by_role('button', name='MrJ.am', exact=True)).to_be_focused()
                expect(page.get_by_role('textbox', name='Champ Vision', exact=True)).to_have_value('réponse conservée')
                for nom, couleur in couleurs.items():
                    assert page.get_by_role('button', name=nom, exact=True).evaluate('e => getComputedStyle(e).backgroundColor') == couleur
                selecteur = page.get_by_label('Leçon', exact=True)
                expect(selecteur).to_have_value('une')
                selecteur.select_option('deux')
                expect(selecteur).to_have_value('deux')
                selecteur.focus()
                selecteur.press('ArrowUp')
                expect(selecteur).to_have_value('une')
                expect(selecteur).to_be_focused()
                font = selecteur.evaluate('e => [getComputedStyle(e).fontSize, getComputedStyle(e).color, getComputedStyle(e.parentElement).color]')
                assert font[0] == '16px' and font[1] == font[2], font
                page.get_by_role('radio', name='Bêta', exact=True).click()
                expect(page.get_by_role('radio', name='Bêta', exact=True)).to_be_checked()
                expect(page.get_by_role('radio', name='Zéro', exact=True)).to_be_checked()
                tableau = page.get_by_role('table', name='Tableau Vision', exact=True)
                expect(tableau.get_by_role('row')).to_have_count(2)
                expect(tableau.get_by_role('columnheader', name='Réponse', exact=True)).to_be_visible()
                cellule = tableau.get_by_role('cell').get_by_role('textbox', name='Réponse dans le tableau', exact=True)
                expect(cellule).to_have_value('réponse conservée')
                bordure = tableau.get_by_role('row').first.evaluate('e => getComputedStyle(e).borderBottomColor')
                rgb = page.evaluate('() => {const c=document.createElement("canvas").getContext("2d");c.fillStyle="oklch(0.88 0.016 227.50776405003785)";c.fillRect(0,0,1,1);return [...c.getImageData(0,0,1,1).data].slice(0,3)}')
                assert bordure == f'rgb({rgb[0]}, {rgb[1]}, {rgb[2]})', bordure
                cadre = page.locator('#tableau-encadre')
                encadre = cadre.get_by_role('table', name='Actions encadrées', exact=True)
                expect(encadre.get_by_role('row')).to_have_count(4)
                for choix in ('premier', 'deuxième', 'troisième'):
                    encadre.get_by_role('button', name='Choisir ' + choix, exact=True).click()
                    expect(page.get_by_role('textbox', name='Champ Vision', exact=True)).to_have_value(choix)
                boite, lignes = cadre.bounding_box(), encadre.bounding_box()
                assert lignes['y'] >= boite['y'] and lignes['y'] + lignes['height'] <= boite['y'] + boite['height'], (boite, lignes)
                page.get_by_role('textbox', name='Champ Vision', exact=True).fill('réponse conservée')
                courte = page.get_by_role('textbox', name='Réponse courte', exact=True)
                expect(courte).to_have_attribute('id', 'reponse-courte')
                expect(courte).to_have_attribute('aria-describedby', 'aide-reponse')
                expect(courte).to_have_attribute('placeholder', 'Exemple')
                expect(courte).to_have_attribute('spellcheck', 'false')
                expect(courte).to_have_attribute('autocomplete', 'off')
                expect(courte).to_have_attribute('autocapitalize', 'off')
                courte.press_sequentially('abcdef')
                expect(courte).to_have_value('abcde')
                courte.press('ArrowLeft')
                expect(page.get_by_text('Validations : 0', exact=True)).to_be_visible()
                courte.press('Enter')
                expect(page.get_by_text('Validations : 1', exact=True)).to_be_visible()
                expect(courte).to_have_value('abcde')
                expect(courte).to_be_focused()
                nombre = page.get_by_role('spinbutton', name='Nombre natif', exact=True)
                expect(nombre).to_have_value('0')
                nombre.fill('')
                expect(page.get_by_text('Valeur native : «»', exact=True)).to_be_visible()
                nombre.fill('0')
                expect(page.get_by_text('Valeur native : «0»', exact=True)).to_be_visible()
                nombre.fill('-1.25')
                expect(nombre).to_have_value('-1.25')
                expect(nombre).to_have_attribute('step', 'any')
                date = page.get_by_label('Date native', exact=True)
                expect(date).to_have_attribute('type', 'date')
                expect(date).to_have_value('2026-10-11')
                date.fill('2026-12-31')
                expect(date).to_have_value('2026-12-31')
                date_heure = page.get_by_label('Date et heure natives', exact=True)
                expect(date_heure).to_have_attribute('type', 'datetime-local')
                expect(date_heure).to_have_value('2026-10-11T14:30')
                menu = page.get_by_role('button', name='Ouvrir le menu', exact=True)
                menu.click()
                expect(menu).to_have_attribute('aria-expanded', 'true')
                page.get_by_role('button', name='Action du menu', exact=True).press('Escape')
                expect(menu).to_have_attribute('aria-expanded', 'false')
                expect(page.get_by_role('button', name='Action du menu', exact=True)).to_have_count(0)
                expect(menu).to_be_focused()
                expect(page.get_by_text('Validations : 1', exact=True)).to_be_visible()
                litteral = page.locator('#texte-litteral')
                assert litteral.inner_text() == 'Deux  espaces\nUne autre ligne\n' + 'sans-espace' * 100
                rendu = litteral.locator('.s.p').first.evaluate('e => ({espace:getComputedStyle(e).whiteSpace,repli:getComputedStyle(e).overflowWrap,largeur:e.scrollWidth,visible:e.clientWidth})')
                assert rendu['espace'] == 'pre-wrap' and rendu['repli'] == 'anywhere', rendu
                assert rendu['largeur'] <= rendu['visible'], rendu
                picto = page.get_by_role('button', name='Loupe vectorielle', exact=True)
                expect(picto).to_have_attribute('title', 'Loupe vectorielle')
                assert picto.bounding_box()['width'] >= 44 and picto.bounding_box()['height'] >= 44
                svg = picto.locator('svg')
                expect(svg).to_have_attribute('viewBox', '0 0 24 24')
                expect(svg).to_have_attribute('aria-hidden', 'true')
                expect(svg).to_have_attribute('focusable', 'false')
                expect(svg).to_have_attribute('stroke', 'currentColor')
                expect(svg.locator('path')).to_have_count(1)
                expect(svg.locator('path')).to_have_attribute('d', 'M16 10a6 6 0 1 1-12 0 6 6 0 0 1 12 0m-1.5 4.5L21 21')
                for valeur, effective in ((-4, 0), (0, 0), (32.125, 32.125), (100, 100), (124, 100)):
                    barre = page.get_by_role('progressbar', name=f'Avancement {valeur}', exact=True)
                    expect(barre).to_have_attribute('aria-valuenow', str(effective))
                    expect(barre).to_have_attribute('aria-valuemin', '0')
                    expect(barre).to_have_attribute('aria-valuemax', '100')
                    mesures = barre.evaluate('e => ({largeur:e.getBoundingClientRect().width,segments:[...e.children].filter(x=>x.tagName!=="STYLE").map(x=>({largeur:x.getBoundingClientRect().width,fond:getComputedStyle(x).backgroundColor}))})')
                    assert len(mesures['segments']) == (2 if 0 < effective < 100 else 1), mesures
                    if effective > 0:
                        assert mesures['segments'][0]['fond'] == couleurs['Vision'], mesures
                        assert abs(mesures['segments'][0]['largeur'] / mesures['largeur'] - effective / 100) < .005, mesures
                # Transition réelle elm-animator -> dimensions/alpha elm-ui.
                # Le message et la saisie restent disponibles pendant le mouvement.
                aide = page.locator('#aide-animee')
                basculer = page.get_by_role('button', name='Basculer l’aide', exact=True)
                frames = page.locator('#compteur-frames')
                frames_repos = frames.inner_text()
                page.wait_for_timeout(120)
                assert frames.inner_text() == frames_repos == '0'
                basculer.focus()
                basculer.press('Space')
                expect(page.locator('#etat-aide')).to_have_text('Aide ouverte')
                page.wait_for_function('() => {let h=document.getElementById("aide-animee").getBoundingClientRect().height;return h>32 && h<80}')
                basculer.dispatch_event('click')
                expect(page.locator('#etat-aide')).to_have_text('Aide fermée')
                assert 0 < aide.bounding_box()['height'] < 96, 'inversion sans saut à la destination'
                expect(basculer).to_be_focused()
                page.wait_for_function('document.getElementById("aide-animee").getBoundingClientRect().height===0')
                for _ in range(5):
                    basculer.dispatch_event('click')
                expect(page.locator('#etat-aide')).to_have_text('Aide ouverte')
                page.get_by_role('textbox', name='Champ Vision', exact=True).fill('réponse pendant animation')
                expect(page.get_by_role('textbox', name='Champ Vision', exact=True)).to_have_value('réponse pendant animation')
                page.wait_for_function('document.getElementById("aide-animee").getBoundingClientRect().height===96')
                page.wait_for_timeout(80)
                stabilise = frames.inner_text()
                assert int(stabilise) > 0
                page.wait_for_timeout(120)
                assert frames.inner_text() == stabilise, 'abonnement RAF resté actif au repos'
                # Observer dès le clic : un aller-retour du pilote puis une
                # assertion de texte peut dépasser cette phase transitoire.
                # Aucun changement de durée ni de seuil du produit.
                hauteur_intermediaire = basculer.evaluate('''bouton => new Promise((resolve, reject) => {
                  const debut=performance.now(), aide=document.getElementById('aide-animee');
                  function observer(){
                    const hauteur=aide.getBoundingClientRect().height;
                    if(hauteur>20 && hauteur<64)return resolve(hauteur);
                    if(performance.now()-debut>2000)return reject(new Error('Phase de fermeture non observée'));
                    requestAnimationFrame(observer);
                  }
                  requestAnimationFrame(observer); bouton.click();
                })''')
                assert 20 < hauteur_intermediaire < 64
                expect(page.locator('#etat-aide')).to_have_text('Aide fermée')
                page.emulate_media(reduced_motion='reduce')
                try:
                    expect(page.locator('#preference-animation')).to_have_text('Animations réduites')
                except AssertionError as erreur:
                    raise AssertionError({'largeur': largeur, 'preference_native': page.evaluate('matchMedia("(prefers-reduced-motion: reduce)").matches'), 'raccord_present': page.evaluate('typeof detacherAnimations'), 'frames': frames.inner_text(), 'erreurs_js': erreurs}) from erreur
                assert aide.bounding_box()['height'] == 0
                stabilise = frames.inner_text()
                basculer.click()
                expect(page.locator('#etat-aide')).to_have_text('Aide ouverte')
                assert aide.bounding_box()['height'] == 96
                page.wait_for_timeout(120)
                assert frames.inner_text() == stabilise, 'frames malgré prefers-reduced-motion'
                ouvrir = page.get_by_role('button', name='Ouvrir le dialogue', exact=True)
                # La racine de complément garde l'état et le clavier natifs.
                # La présentation vient des deux sous-arbres elm-ui.
                titre = page.get_by_role('heading', name='Titre de découverte', exact=True)
                expect(titre).to_have_css('font-size', '30px' if largeur <= 600 else '42px')
                section = page.get_by_role('heading', name='Un titre de section', exact=True)
                expect(section).to_have_css('font-size', '30px' if largeur <= 600 else '36px')
                resume = page.locator('summary').filter(has_text='Complément natif')
                complement = resume.locator('..')
                reponse = complement.get_by_role('textbox', name='Réponse du complément', exact=True, include_hidden=True)
                expect(reponse).not_to_be_visible()
                resume.focus()
                expect(resume).to_be_focused()
                # focused d'elm-ui produit aussi :focus-within : aucune règle CSS
                # appliquée manuellement au summary ni classe de framework imitée.
                accent = couleurs['Vision']
                assert resume.evaluate('(e,c) => {for(let p=e;p;p=p.parentElement){const s=getComputedStyle(p).boxShadow;if(s.includes(c))return true;}return false;}', accent)
                resume.press('Space')
                expect(reponse).to_be_visible()
                expect(resume).to_be_focused()
                reponse.fill('état du complément conservé')
                resume.focus()
                resume.press('Enter')
                expect(reponse).not_to_be_visible()
                resume.press('Enter')
                expect(reponse).to_have_value('état du complément conservé')
                resume.press('Space')
                expect(reponse).not_to_be_visible()
                for nouvelle_largeur in (320, 768, 1440, largeur):
                    page.set_viewport_size({'width': nouvelle_largeur, 'height': 1000})
                    expect(titre).to_have_css('font-size', '30px' if nouvelle_largeur <= 600 else '42px')
                    expect(section).to_have_css('font-size', '30px' if nouvelle_largeur <= 600 else '36px')
                    expect(resume).to_be_focused()
                    expect(reponse).to_have_value('état du complément conservé')
                    assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), nouvelle_largeur
                ouvrir.click()
                dialogue = page.get_by_role('dialog', name='Dialogue Vision', exact=True)
                expect(dialogue).to_be_visible()
                assert dialogue.bounding_box()['width'] <= largeur - 24
                fermer = dialogue.get_by_role('button', name='Fermer', exact=True)
                assert fermer.evaluate('e => getComputedStyle(e).backgroundColor') == couleurs['Vision']
                champ = dialogue.get_by_role('textbox', name='Champ du dialogue', exact=True)
                police_page = page.get_by_role('main').evaluate('e => getComputedStyle(e).fontFamily')
                # Mesurer les contrôles réellement peints par ElmUI, plutôt que
                # la police sans texte du conteneur dialog natif.
                assert champ.evaluate('e => getComputedStyle(e).fontFamily') == police_page
                assert fermer.evaluate('e => getComputedStyle(e).fontFamily') == police_page
                champ.fill('réponse dans la modale')
                champ.focus()
                page.get_by_role('textbox', name='Champ Vision', exact=True, include_hidden=True).evaluate('e => e.focus()')
                expect(champ).to_be_focused()
                champ.press('Shift+Tab')
                expect(fermer).to_be_focused()
                fermer.press('Tab')
                expect(champ).to_be_focused()
                champ.press('Escape')
                expect(dialogue).to_have_count(0)
                expect(ouvrir).to_be_focused()
                expect(page.get_by_text('Fermetures : 1', exact=True)).to_be_visible()
                expect(page.get_by_role('textbox', name='Champ Vision', exact=True)).to_have_value('réponse dans la modale')
                ouvrir.click()
                expect(dialogue).to_be_visible()
                fermer.click()
                expect(dialogue).to_have_count(0)
                expect(ouvrir).to_be_focused()
                expect(page.get_by_text('Fermetures : 2', exact=True)).to_be_visible()
                etat_conserve = page.get_by_role('textbox', name='Champ Vision', exact=True).input_value()
                for commande, limite in (('Ouvrir une confirmation', 560), ('Comparer', 1160)):
                    declencheur = page.get_by_role('button', name=commande, exact=True)
                    declencheur.click()
                    confirmation = page.get_by_role('dialog', name='Confirmation explicite', exact=True)
                    expect(confirmation).to_be_visible()
                    racine = confirmation.locator(':scope > div')
                    expect(racine).to_have_css('max-width', f'{limite}px')
                    assert confirmation.bounding_box()['width'] <= largeur, largeur
                    valeur = confirmation.get_by_role('textbox', name='Valeur conservée', exact=True)
                    expect(valeur).to_have_value(etat_conserve)
                    rester = confirmation.get_by_role('button', name='Rester ici', exact=True)
                    # Premier contrôle, comme dans le dialogue historique : la
                    # fermeture précède le contenu. Le navigateur garde cet ordre.
                    expect(rester).to_be_focused()
                    page.keyboard.press('Tab')
                    expect(valeur).to_be_focused()
                    page.keyboard.press('Tab')
                    expect(rester).to_be_focused()
                    page.keyboard.press('Shift+Tab')
                    expect(valeur).to_be_focused()
                    page.keyboard.press('Escape')
                    expect(confirmation).to_have_count(0)
                    expect(declencheur).to_be_focused()
                assert not erreurs, erreurs
                assert page.evaluate('document.documentElement.scrollWidth <= innerWidth'), largeur
                resultats.append({'largeur': largeur, 'couleurs': couleurs, 'tableau_contexte_et_roles': True, 'tableau_encadre_lignes_et_actions': True, 'selecteur_clavier': True, 'polymorphisme_choix': True,
                                  'focus_apres_deplacement': True, 'modale_focus_inert_echap_reouverture': True, 'fermetures_exactes': 2,
                                  'saisie_identifiee_soumission_unique': True, 'zero_distinct_du_vide': True, 'dates_natives': True,
                                  'menu_echap': True, 'texte_litteral_replie': True, 'pictogramme_original': True,
                                  'vitrine_redimensionnements_complement_natif_focus_etat': True,
                                  'confirmation_comparaison_natives_dimensions_clavier': True,
                                  'progression_visuelle_et_aria': True, 'transition_interrompue_sans_saut': True,
                                  'metier_immediat_frames_arretees_reduction': True})
                page.close()
            # La préférence déjà présente à l'enrôlement du port est aussi appliquée.
            page = navigateur.new_page(viewport={'width': 320, 'height': 1000})
            page.emulate_media(reduced_motion='reduce')
            page.set_content('<div id="application"></div>')
            page.add_script_tag(content=code)
            page.evaluate('window.contextes=Elm.Contextes.init({node:document.getElementById("application")})')
            page.add_script_tag(path=str(Path(__file__).resolve().parents[1] / 'public/assets/mrjam/animations.js'))
            page.evaluate('() => { MrJamAnimations.relier(contextes.ports.reductionAnimations); }')
            expect(page.locator('#preference-animation')).to_have_text('Animations réduites')
            page.get_by_role('button', name='Basculer l’aide', exact=True).click()
            expect(page.locator('#etat-aide')).to_have_text('Aide ouverte')
            assert page.locator('#aide-animee').bounding_box()['height'] == 96
            page.wait_for_timeout(120)
            expect(page.locator('#compteur-frames')).to_have_text('0')
            page.close()
        finally:
            navigateur.close()
    print(json.dumps({'javascript_sha256': hashlib.sha256(javascript.read_bytes()).hexdigest(), 'parcours': resultats}, ensure_ascii=False))


if __name__ == '__main__':
    args = argparse.ArgumentParser()
    args.add_argument('--javascript', type=Path, default=Path(__file__).resolve().parents[1] / 'public/galerie.js')
    args.add_argument('--signature', type=Path, default=Path(__file__).resolve().parents[2] / 'Signature')
    options = args.parse_args()
    verifier(options.javascript, options.signature)
