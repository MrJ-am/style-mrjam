"""Tests des équations proposées pour l'animation des réflexions."""
import math
import unittest

from verifier_geometrie import appliquer, reflechir
from reference_miroir import (
    ecartement, matrice_projection, opacites_fondu, progression_douce,
)


class MiroirTest(unittest.TestCase):
    """Valider les endpoints, la tranche et la loi de dispersion."""
    def test_depart_identite(self):
        self.assertEqual(matrice_projection(0,0,0,1,0),(1,0,0,1,0,0))

    def test_arrivee_reflexion(self):
        matrix=matrice_projection(0,0,0,1,math.pi)
        for point in [0j,1+2j,-3+4j]:
            self.assertEqual(appliquer(matrix,point),reflechir(point,True))

    def test_composition_terminale(self):
        theta=math.radians(45)
        scale=.5624999968333334
        matrix=matrice_projection(14.6,11.73,theta,scale,math.pi)
        c,s=math.cos(theta),math.sin(theta)
        for p in [2+4j,-1+7j,0j]:
            f=reflechir(p,True)
            expected=complex(14.6,11.73)+scale*complex(c,s)*f
            self.assertLess(abs(appliquer(matrix,p)-expected),1e-12)

    def test_tranche_singuliere_sans_nan(self):
        m=matrice_projection(2,5,.7,.5625,math.pi/2)
        self.assertEqual(m[0]*m[3]-m[1]*m[2],0.)
        self.assertTrue(all(math.isfinite(v) for v in m))
        self.assertEqual(appliquer(m,1+3j),appliquer(m,-8+3j))

    def test_determinant_au_cours_du_retournement(self):
        for beta in [0,math.pi/4,math.pi/2,3*math.pi/4,math.pi]:
            m=matrice_projection(1,2,.7,.6,beta)
            self.assertAlmostEqual(m[0]*m[3]-m[1]*m[2],.6**2*math.cos(beta))

    def test_continuite_de_la_projection(self):
        left=matrice_projection(0,0,.4,1,math.pi/2-1e-7)
        right=matrice_projection(0,0,.4,1,math.pi/2+1e-7)
        self.assertLess(abs(appliquer(left,2+3j)-appliquer(right,2+3j)),1e-6)

    def test_fondu_endpoints(self):
        self.assertEqual(opacites_fondu(1,0),(1,0))
        self.assertEqual(opacites_fondu(1,1),(0,1))
        self.assertEqual(opacites_fondu(.8,.5),(.4,.4))

    def test_progression_reversible(self):
        for p in [0,.1,.25,.5,.9,1]:
            self.assertAlmostEqual(progression_douce(1-p),1-progression_douce(p))

    def test_dispersion_vitesse_et_saturation(self):
        self.assertEqual(ecartement(0,3,6),0)
        self.assertAlmostEqual(ecartement(4,3,6),4*ecartement(2,3,6))
        self.assertEqual(ecartement(-4,3,6),ecartement(4,3,6))
        self.assertEqual(ecartement(100,3,6),3)

    def test_parametres_invalides(self):
        with self.assertRaises(ValueError):
            matrice_projection(0,0,0,0,0)
        with self.assertRaises(ValueError):
            matrice_projection(0,0,math.nan,1,0)
        with self.assertRaises(ValueError):
            ecartement(1,3,0)


if __name__=='__main__':
    unittest.main()
