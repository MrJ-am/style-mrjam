"""Contrôles peints de Signature, partagés par le socle et ses consommateurs."""
from io import BytesIO
from PIL import Image
from playwright.sync_api import expect


def verifier_alignement(marque):
    """Comparer l'encre des deux fontes, pas seulement leurs boîtes CSS.

    Les capitales V et M de la source ont presque la même hauteur. Un centrage
    de blocs les décale de plusieurs pixels malgré une taille CSS identique.
    """
    image=Image.open(BytesIO(marque.screenshot())).convert('RGB')
    separation=marque.locator('.mrjam').bounding_box()['x']-marque.bounding_box()['x']
    zones=[[],[]]
    for y in range(image.height):
        for x in range(image.width):
            r,g,b=image.getpixel((x,y))
            if r<100 and g<150 and b<150:
                zones[int(x>=separation)].append(y)
    assert all(zones), 'Les deux fontes doivent être visibles'
    assert abs(min(zones[0])-min(zones[1]))<=1, 'Capitales décalées verticalement'
    assert min(zones[0]+zones[1])>0 and max(zones[0]+zones[1])<image.height-1, 'Signature rognée'

def verifier_points(marque):
    """Comparer les dessins peints, agrandis quatre fois, avec leur motif blanc.

    La position interne vient de mrjam.sty (1.8 em, marge .04 em). Les
    composantes isolent le disque des lettres voisines. Un contrôle du seul
    nom de la fonte ne détecterait pas un dessin différent ou un rognage.
    """
    point=marque.locator('.echo-point')
    expect(point).to_have_text('.')
    assert 'EchoPoint' in point.evaluate('(e)=>getComputedStyle(e).fontFamily')
    image=Image.open(BytesIO(marque.screenshot())).convert('RGB')
    boite=marque.bounding_box();capture=image.width/boite['width']
    zoom=float(marque.evaluate('(e)=>getComputedStyle(e).zoom'))
    facteur=zoom*capture
    assert 3.9<=facteur<=4.1
    prefixe=point.bounding_box();signature=marque.locator('.mrjam').bounding_box()
    taille=float(marque.locator('.mrjam').evaluate('(e)=>getComputedStyle(e).fontSize').replace('px',''))*zoom
    debut=signature['x']-boite['x']+1.84*taille
    regions=[(prefixe['x']-boite['x'],prefixe['x']-boite['x']+prefixe['width']),
             (debut,debut+.18*taille)]
    dessins=[]
    for gauche,droite in regions:
        pixels={(x,y) for x in range(int(gauche*capture),min(image.width,int(droite*capture)+1))
                for y in range(image.height) if max(image.getpixel((x,y)))<128}
        candidats=[]
        while pixels:
            depart=pixels.pop();composante={depart};pile=[depart]
            while pile:
                x,y=pile.pop()
                for dx in (-1,0,1):
                    for dy in (-1,0,1):
                        voisin=(x+dx,y+dy)
                        if voisin in pixels:
                            pixels.remove(voisin);composante.add(voisin);pile.append(voisin)
            limites=(min(x for x,y in composante),min(y for x,y in composante),
                     max(x for x,y in composante)+1,max(y for x,y in composante)+1)
            largeur=limites[2]-limites[0];hauteur=limites[3]-limites[1]
            if 3*facteur<=largeur<=5*facteur and 3*facteur<=hauteur<=5*facteur:
                candidats.append((limites,composante))
        assert len(candidats)==1, 'Un disque Echo entier doit apparaître dans chaque point'
        limites,composante=candidats[0]
        masque=Image.new('1',(limites[2]-limites[0],limites[3]-limites[1]))
        for x,y in composante:masque.putpixel((x-limites[0],y-limites[1]),1)
        dessins.append((limites,masque.resize((32,32),Image.Resampling.NEAREST)))
    assert abs(dessins[0][0][1]-dessins[1][0][1])<=facteur, 'Points décalés verticalement'
    ecart=sum(dessins[0][1].getpixel((x,y))!=dessins[1][1].getpixel((x,y))
              for x in range(32) for y in range(32))/1024
    assert ecart<.08, 'Les deux motifs doivent être identiques, à l’anticrénelage près'
    assert boite['height']*capture<=42*facteur, {'erreur':'Le point ne doit pas agrandir l’interligne', 'boite':boite, 'capture':capture, 'facteur':facteur, 'zoom':zoom}

