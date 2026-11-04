## 4.14 Scrivere una skill: esempio completo

Costruiamo una skill reale, con script e riferimento, seguendo lo standard. L'obiettivo: generare le note di rilascio di un progetto .NET a partire dai commit convenzionali.

### 4.14.1 La cartella

```text
.github/skills/release-notes/
|-- SKILL.md
|-- scripts/
|   `-- collect-commits.py
`-- references/
    `-- CHANGELOG-FORMAT.md
```

### 4.14.2 Il file `SKILL.md`

```markdown
---
name: release-notes
description: Genera le note di rilascio dai commit convenzionali dell'ultimo tag. Usa quando si prepara una release, si aggiorna CHANGELOG.md o si chiede cosa è cambiato dall'ultima versione.
license: MIT
metadata:
  version: "1.1"
---

# Note di rilascio

## Quando usarla

Quando la richiesta riguarda una release, un changelog o un diff rispetto all'ultimo tag.

## Procedura

1. Verifica che l'albero sia pulito:
   `git status --porcelain` deve restituire stringa vuota.
2. Esegui lo script che raccoglie e classifica i commit:
   `python scripts/collect-commits.py --format json`
3. Se lo script segnala commit non classificabili, **non inventare**: inseriscili
   nella sezione `### Altro` con il messaggio originale.
4. Scrivi l'aggiornamento in cima a `CHANGELOG.md`, seguendo
   `references/CHANGELOG-FORMAT.md`.
5. Non eseguire `git tag` né `git push`: la skill produce il testo, la release
   la decide una persona.

## Cosa non fare

- Non dedurre funzionalità dal codice: usa solo i messaggi di commit.
- Non riordinare i commit per importanza: mantieni l'ordine cronologico.
```

Osserva tre scelte:

- la `description` contiene **le parole con cui un utente farebbe la domanda** ("cosa è cambiato dall'ultima versione"), non solo la descrizione tecnica;
- la procedura rimanda a uno **script** per la parte deterministica e a un **riferimento** per il formato;
- c'è una sezione **"Cosa non fare"**, che è la parte più utile: gli errori ricorrenti si prevengono elencandoli.

### 4.14.3 Lo script

```python
#!/usr/bin/env python3
"""Raccoglie i commit dall'ultimo tag e li classifica per tipo."""
import argparse, json, re, subprocess, sys

CONVENTIONAL = re.compile(r"^(?P<type>[a-z]+)(?:\((?P<scope>[^)]+)\))?!?:\s*(?P<desc>.+)$")
SECTIONS = {"feat": "Aggiunto", "fix": "Corretto", "perf": "Prestazioni", "docs": "Documentazione"}

def run(*args: str) -> str:
    return subprocess.run(args, capture_output=True, text=True, check=True).stdout.strip()

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--format", choices=["json", "md"], default="md")
    args = parser.parse_args()

    try:
        last_tag = run("git", "describe", "--tags", "--abbrev=0")
        log = run("git", "log", f"{last_tag}..HEAD", "--pretty=format:%h%x09%s")
    except subprocess.CalledProcessError:
        print("Nessun tag trovato: specificare il commit di partenza.", file=sys.stderr)
        return 2

    grouped: dict[str, list[dict[str, str]]] = {}
    for line in log.splitlines():
        if not line.strip():
            continue
        sha, _, subject = line.partition("\t")
        match = CONVENTIONAL.match(subject)
        kind = match.group("type") if match else "altro"
        entry = {"sha": sha, "text": (match.group("desc") if match else subject).strip()}
        grouped.setdefault(SECTIONS.get(kind, "Altro"), []).append(entry)

    if args.format == "json":
        print(json.dumps(grouped, ensure_ascii=False, indent=2))
        return 0

    for section, items in grouped.items():
        print(f"### {section}\n")
        for item in items:
            print(f"- {item['text']} ({item['sha']})")
        print()
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
```

Lo script è volutamente piccolo e senza dipendenze: uno script di skill deve poter girare su qualsiasi macchina, senza `pip install`.

### 4.14.4 Perché questa skill funziona

Tre proprietà che la distinguono da un prompt salvato:

1. **È attivabile.** La descrizione contiene i termini d'uso, quindi l'agente la sceglie quando serve e la ignora quando non serve.
2. **È deterministica dove conta.** La raccolta dei commit non è affidata all'improvvisazione del modello.
3. **Ha un confine esplicito.** La skill produce testo; non tagga, non pubblica, non fa push. Un confine chiaro è ciò che rende una skill sicura da lasciare attiva.

### 4.14.5 Dove metterla

A seconda del motore, la stessa cartella va in:

```text
.github/skills/release-notes/     # VS Code con Copilot
.claude/skills/release-notes/     # Claude Code
.agents/skills/release-notes/     # Codex e harness neutri
```

Il contenuto non cambia. È l'unico componente di questo capitolo per cui questo è vero senza eccezioni.

