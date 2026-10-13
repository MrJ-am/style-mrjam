"""Variante oreille : sources d'identité conservées, aucune géométrie nouvelle."""
import os
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


class Audio(unittest.TestCase):
    def test_contour_et_instances(self):
        root = Path(__file__).resolve().parents[1]
        signature = Path(os.environ.get('SIGNATURE_SOURCE', root.parent / 'Signature'))
        officiel = ET.parse(signature / 'artwork/Echologo.svg').getroot()
        audio = ET.parse(root / 'public/assets/mrjam/palette/Palette-Audio.svg').getroot()
        chemins = lambda svg: [n.attrib['d'] for n in svg.iter() if n.tag.endswith('path')]
        self.assertEqual(chemins(officiel), chemins(audio))
        instances = [n.attrib['href'] for n in audio.iter() if n.tag.endswith('use')]
        self.assertEqual(['#mode-audio-connaissance', '#mode-audio-auditif'], instances)
        self.assertIn('description = "Logo Audition"', (root / 'src/MrJam/Identite.elm').read_text())


if __name__ == '__main__': unittest.main()
