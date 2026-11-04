## 4.4 Le skill

Una skill è una **cartella con un file `SKILL.md`**: il frontmatter dichiara nome e descrizione, il corpo contiene le istruzioni. Attorno al file possono stare script, esempi e materiali di riferimento.

L'aspetto importante è che la skill è uno **standard aperto**: [Agent Skills](https://agentskills.io) è supportato da VS Code con Copilot, da Copilot CLI e dall'agente cloud, da Claude Code, da Codex e da altri strumenti che si stanno allineando. È il formato più portabile di tutto il capitolo.

![Anatomia di una skill: un file obbligatorio e tre cartelle opzionali, con caricamento progressivo](figure/anatomia-skill.pdf)

### 4.4.1 Il formato minimo

```markdown
---
name: release-notes
description: Genera le note di rilascio dai commit convenzionali dal tag precedente. Usa quando si prepara una release o si chiede il changelog.
---

# Note di rilascio

1. Trova il tag precedente con `git describe --tags --abbrev=0`.
2. Elenca i commit con `git log <tag>..HEAD --pretty=format:"%s"`.
3. Raggruppa per tipo: `feat`, `fix`, `perf`, `docs`, `chore`.
4. Scrivi in `CHANGELOG.md` una sezione `## [<versione>] - <data>` con
   sottosezioni `### Aggiunto`, `### Corretto`, `### Altro`.
5. Non inventare voci: se un commit non è classificabile, mettilo in `### Altro`.
```

Due soli campi obbligatori: `name` e `description`. Il `name` deve essere in minuscolo, con trattini, senza trattini iniziali o finali, e **deve coincidere con il nome della cartella**. La `description` è il campo più importante di tutti, perché è l'unico che l'agente legge *sempre*: deve dire **cosa** fa la skill e **quando** usarla, con le parole che useresti tu.

Confronta:

- «Aiuta con le release.» — inutile: nessun modello capirà quando attivarla;
- «Genera le note di rilascio dai commit convenzionali dal tag precedente. Usa quando si prepara una release, si aggiorna il changelog o si chiede "cosa è cambiato dall'ultima versione".» — attivabile.

### 4.4.2 La struttura consigliata

Lo standard raccomanda tre cartelle opzionali, che diventano utili appena la skill cresce:

| Cartella | Contenuto | Quando usarla |
| --- | --- | --- |
| `scripts/` | Codice eseguibile (Python, Bash, JavaScript) | La procedura richiede un'operazione deterministica che il modello non deve improvvisare |
| `references/` | Documentazione di dettaglio, specifiche, formati | Il corpo di `SKILL.md` diventerebbe troppo lungo |
| `assets/` | Template, file di esempio, risorse binarie | La skill produce output a partire da un modello |

Il criterio è sempre lo stesso: **`SKILL.md` deve contenere solo ciò che serve a decidere e a eseguire i passi**. Tutto ciò che è consultazione va nelle reference; tutto ciò che è esecuzione va negli script.

### 4.4.3 Perché gli script cambiano le regole del gioco

C'è una differenza sostanziale tra «spiega al modello come fare X» e «dai al modello uno script che fa X». La prima è probabilistica, la seconda è deterministica.

Se la skill deve aggiornare un file di versione, non serve che il modello ricostruisca il formato: serve uno script che lo faccia, con il modello che decide *quando* chiamarlo e *con quali argomenti*. Questo riduce le allucinazioni ed è il motivo per cui le skill migliori contengono pochi passi in prosa e qualche script affidabile.

```text
release-notes/
|-- SKILL.md
|-- scripts/
|   `-- collect-commits.py     # estrae i commit e li classifica
`-- references/
    `-- CHANGELOG-FORMAT.md    # il formato atteso, con esempi reali
```

### 4.4.4 Skill, comandi e prompt

Molti motori hanno più modi per invocare un contenuto salvato, e la distinzione storica si sta sfumando:

- in **Claude Code** i vecchi *custom commands* (`.claude/commands/*.md`) sono stati unificati nelle skill: un file in `.claude/commands/deploy.md` e una skill in `.claude/skills/deploy/SKILL.md` producono entrambi `/deploy`;
- in **Gemini CLI** i comandi personalizzati sono file `.toml` in `.gemini/commands/`;
- in **VS Code** i *prompt file* (`.github/prompts/*.prompt.md`) sono comandi che invochi tu, e restano distinti dalle skill.

La regola pratica: se vuoi che **l'agente** decida quando usarlo, scrivi una skill; se vuoi deciderlo **tu**, va bene un comando o un prompt file. Le skill moderne fanno entrambe le cose, perché hanno anche un nome invocabile.

