#!/usr/bin/env python3
"""Rassembler les SVG distribués par le site sans modifier leurs sources."""

import argparse
from pathlib import Path
import shutil


def main():
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("--check", action="store_true", help="Vérifier sans écrire")
    options = arguments.parse_args()
    racine = Path(__file__).resolve().parents[1]
    source = racine / "public/assets/mrjam"
    destination = racine / "logos"
    fichiers = sorted(source.rglob("*.svg"))
    if not fichiers:
        raise SystemExit("Aucun SVG trouvé dans les ressources du site.")
    erreurs = []
    attendus = {fichier.relative_to(source) for fichier in fichiers}
    presents = {
        fichier.relative_to(destination)
        for fichier in destination.rglob("*.svg")
        if fichier.relative_to(destination).parts[0] != "essais"
    }
    for chemin in sorted(presents - attendus):
        erreurs.append(f"Copie sans source : logos/{chemin}")
    for fichier in fichiers:
        relatif = fichier.relative_to(source)
        copie = destination / relatif
        if options.check:
            if not copie.is_file() or copie.read_bytes() != fichier.read_bytes():
                erreurs.append(f"Copie absente ou différente : logos/{relatif}")
        else:
            copie.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(fichier, copie)
    if erreurs:
        raise SystemExit("\n".join(erreurs))
    action = "vérifiés" if options.check else "recopiés"
    print(f"{len(fichiers)} SVG du site {action} dans logos/. Essais conservés séparément.")


if __name__ == "__main__":
    main()
