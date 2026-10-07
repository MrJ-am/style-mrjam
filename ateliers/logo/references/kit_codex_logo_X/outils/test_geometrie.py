"""Tests unitaires du vérificateur et des données de factorisation."""
import math
import unittest
import xml.etree.ElementTree as ET

from verifier_geometrie import (
    ROOT, NS, appliquer, arc_endpoint, composer, lire_svg,
    tokens, transformation, verifier,
)
from preparer_references import svg


class GeometrieTest(unittest.TestCase):
    """Contrôler la lecture, l'ordre des matrices et la correspondance des briques."""
    @classmethod
    def setUpClass(cls):
        cls.report = verifier()

    def test_tokens_exposants_et_signes(self):
        self.assertEqual(tokens('m1 -2a3 3 0 0 0 8.980264-5e-5')[-2:],
                         ['8.980264','-5e-5'])

    def test_transformations_composees(self):
        m=transformation('translate(3 4) rotate(90) scale(2)')
        self.assertAlmostEqual(abs(appliquer(m,1+0j)-(3+6j)),0.)

    def test_rotation_autour_point(self):
        m=transformation('rotate(180 58.304506 233.24971)')
        p=complex(58.304506,233.24971)
        self.assertLess(abs(appliquer(m,p)-p),1e-12)

    def test_arc_quart_cercle(self):
        arc=arc_endpoint(1+0j,[1,1,0,0,1,0,1],False)
        self.assertLess(abs(arc.center),1e-12)
        self.assertAlmostEqual(arc.delta,math.pi/2)
        self.assertLess(abs(arc.point(.5)-complex(2**-.5,2**-.5)),1e-12)

    def test_syntaxe_inconnue_refusee(self):
        with self.assertRaises(ValueError):
            transformation('skewX(45)')

    def test_structure_sources(self):
        self.assertEqual(len(lire_svg(ROOT/'sources/logo-original.svg')),3)
        self.assertEqual(len(lire_svg(ROOT/'sources/X-original.svg')),7)

    def test_tolerance_continue(self):
        self.assertTrue(self.report['valide'])
        for x in self.report['instances']:
            self.assertLess(x['erreur_max_echantillons'],x['borne_continue'])
            self.assertLess(x['borne_continue'],1e-4)

    def test_repartition_et_reflexions(self):
        rows=self.report['instances']
        self.assertEqual([sum(r['brique']==n for r in rows)
                          for n in ['Auditif','Visuel','Kinesthesique']],[1,3,3])
        self.assertEqual({r['path_id'] for r in rows if r['miroir']},
                         {'path6','path8','path12','path16'})

    def test_deux_echelles(self):
        scales=sorted(set(r['echelle'] for r in self.report['instances']))
        self.assertEqual(len(scales),2)
        self.assertAlmostEqual(scales[1]/scales[0],1.3122,places=12)

    def test_export_sans_paths_dupliques(self):
        text=svg(ROOT,'X',self.report['instances'])
        node=ET.fromstring(text)
        self.assertEqual(len(node.findall('.//'+NS+'path')),3)
        self.assertEqual(len(node.findall('.//'+NS+'use')),7)
        self.assertEqual(len(node.findall('.//'+NS+'defs/'+NS+'circle')),1)
        self.assertEqual(len(node.findall('./'+NS+'circle')),1)  # fond, pas tête

    def test_matrice_cumulee_groupes(self):
        paths={p.id:p for p in lire_svg(ROOT/'sources/X-original.svg')}
        g=.26574803
        self.assertAlmostEqual(paths['path8'].transform[0],g*.5)
        self.assertAlmostEqual(paths['path16'].transform[0],-g)


if __name__=='__main__':
    unittest.main()
