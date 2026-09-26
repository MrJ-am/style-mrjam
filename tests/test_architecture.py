"""Les composants applicatifs ne doivent pas redéfinir la présentation."""
from pathlib import Path
import unittest

RACINE = Path(__file__).resolve().parents[1]


class Architecture(unittest.TestCase):
    def test_un_seul_moteur_de_tableau(self):
        source = (RACINE / 'src/MrJam/Donnees.elm').read_text()
        self.assertNotIn('role "table"', source)
        self.assertIn('Tableaux.tableau', source)

    def test_un_seul_moteur_de_bouton(self):
        moteurs = [p.name for p in (RACINE / "src").rglob("*.elm") if "Saisie.button" in p.read_text()]
        self.assertEqual(moteurs, ["Controles.elm"])

    def test_lecture_et_identite_en_elm_ui(self):
        for nom in ['Donnees', 'Identite']:
            source = (RACINE / f'src/MrJam/{nom}.elm').read_text()
            self.assertNotIn('import Html\n', source, nom)
            self.assertNotIn('Html.text', source, nom)


if __name__ == '__main__':
    unittest.main()
