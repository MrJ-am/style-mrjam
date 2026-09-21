"""Vérifie les copies d’identité sans télécharger ni modifier leurs sources."""
import hashlib
import json
from pathlib import Path

racine = Path(__file__).resolve().parents[1]
identite = json.loads((racine / "identite.json").read_text())
for nom, reference in identite["fichiers"].items():
    contenu = (racine / "public/assets/mrjam" / nom).read_bytes()
    empreinte_git = hashlib.sha1(b"blob " + str(len(contenu)).encode() + b"\0" + contenu).hexdigest()
    if empreinte_git != reference["git_blob"] or hashlib.sha256(contenu).hexdigest() != reference["sha256"]:
        raise SystemExit(f"La ressource {nom} ne correspond plus à la référence autorisée.")
print("Copies du logo et de la composition de signature conformes à la référence.")
