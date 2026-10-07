"""Référence mathématique des effets à porter en Elm, sans moteur d'animation.

Ce module de test n'est pas destiné au navigateur. Le programme final doit utiliser
Elm Animator pour sa chronologie et SVG Elm pour son rendu. Les fonctions ci-dessous
isolent les conventions d'axes, le passage de tranche et la loi centrifuge.
"""
from __future__ import annotations

import math
from verifier_geometrie import Affine


def valider_finis(*values: float) -> None:
    """Refuser les valeurs non finies plutôt que produire un SVG invalide."""
    if not all(math.isfinite(x) for x in values):
        raise ValueError('Les paramètres doivent être finis')


def progression_douce(t: float) -> float:
    """Smoothstep quintique borné ; vitesse et accélération nulles aux extrémités."""
    valider_finis(t)
    t = max(0.,min(1.,t))
    return t*t*t*(10.+t*(-15.+6.*t))


def matrice_projection(x: float, y: float, angle: float, echelle: float,
                       basculement: float) -> Affine:
    """Translation + échelle uniforme + rotation plane + projection du retournement.

    Angles en radians. Repère SVG (y vers le bas).
    Basculement 0 → I, pi/2 → tranche, pi → F(x,y)=(-x,y).
    Le determinant nul à la tranche est intentionnel ; aucune inversion n'a lieu.
    """
    valider_finis(x,y,angle,echelle,basculement)
    if echelle <= 0 or not 0 <= basculement <= math.pi:
        raise ValueError('Échelle positive et basculement dans [0,pi] requis')
    c,z = math.cos(angle),math.sin(angle)
    if basculement == 0:
        k = 1.
    elif basculement == math.pi/2:
        k = 0.
    elif basculement == math.pi:
        k = -1.
    else:
        k = math.cos(basculement)
    return (echelle*c*k,echelle*z*k,-echelle*z,echelle*c,x,y)


def opacites_fondu(opacite: float, progression: float) -> tuple[float,float]:
    """Poids des deux faces ; ils ne s'additionnent pas en alpha source-over."""
    valider_finis(opacite,progression)
    if not 0 <= opacite <= 1 or not 0 <= progression <= 1:
        raise ValueError('Opacité et progression dans [0,1] requises')
    return opacite*(1-progression),opacite*progression


def ecartement(omega: float, maximum: float, reference: float) -> float:
    """Loi centrifuge bornée avec une référence fixe, pas le pic du cycle courant."""
    valider_finis(omega,maximum,reference)
    if maximum < 0 or reference <= 0:
        raise ValueError('Maximum non négatif et référence strictement positive requis')
    # Éviter aussi un débordement dans le carré pour des valeurs très grandes.
    rapport = min(1.,abs(omega)/reference)
    return maximum*rapport*rapport
