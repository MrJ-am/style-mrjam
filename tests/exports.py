"""Les ressources de palette publiées restent les exports scientifiques Elm exacts."""
from pathlib import Path

racine=Path(__file__).resolve().parents[1]
for nom in ['palette.css','palette.json']:
    publie=racine/'public/assets/mrjam/palette'/nom
    genere=racine/'ateliers/logo/dist/exports'/nom
    assert publie.read_bytes()==genere.read_bytes(),f'Export de palette divergent : {nom}'
print('Exports CSS/JSON de palette reproduits depuis Elm, identiques aux ressources communes.')
