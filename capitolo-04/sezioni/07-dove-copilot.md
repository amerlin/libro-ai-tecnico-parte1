\newpage

## 4.7 Dove vivono i file: GitHub Copilot in VS Code

VS Code ha un'architettura che vale la pena capire prima di guardare le cartelle: la chat può girare su **harness** diversi (il termine usato dalla documentazione per indicare il "motore" che esegue la sessione: Copilot, Claude, Codex, o la modalità locale). Ogni harness ha le sue regole di scoperta dei file, e questo spiega perché in un unico progetto possono convivere `.github/` e `.claude/` senza che si pestino i piedi.

### 4.7.1 I file di progetto

- **Istruzioni di progetto:** `.github/copilot-instructions.md` (il file principale, sempre caricato).
- **Istruzioni in formato condiviso:** `AGENTS.md` (utilizzabile anche da altri agenti compatibili).
- **Istruzioni mirate:** `.github/instructions/**/*.instructions.md` (frontmatter `applyTo` e `description`).
- **Prompt riutilizzabili:** `.github/prompts/**/*.prompt.md` (invocati come `/nome`).
- **Agenti:** `.github/agents/*.agent.md` (frontmatter `name`, `description`, `tools`, `model`).
- **Skill:** `.github/skills/<nome>/SKILL.md` (standard Agent Skills).
- **Skill in percorso condiviso:** `.agents/skills/<nome>/SKILL.md` (scoperta da VS Code nei contesti supportati e da Codex).

L'albero di un progetto che usa tutto:

```text
taskify/
|-- .github/
|   |-- copilot-instructions.md
|   |-- instructions/
|   |   |-- tests.instructions.md
|   |   `-- api.instructions.md
|   |-- prompts/
|   |   `-- nuova-feature.prompt.md
|   |-- agents/
|   |   |-- planner.agent.md
|   |   `-- revisore.agent.md
|   `-- skills/
|       `-- release-notes/
|           |-- SKILL.md
|           `-- scripts/
|               `-- collect-commits.py
|-- .agents/
|   `-- skills/
|       `-- db-migration/
|           `-- SKILL.md
`-- AGENTS.md
```

### 4.7.2 I file utente

A livello utente, Copilot usa `~/.copilot/`:

- **Istruzioni personali sempre attive:** `~/.copilot/copilot-instructions.md`.
- **Istruzioni mirate:** `~/.copilot/instructions/*.instructions.md`.
- **Agenti personali:** `~/.copilot/agents/*.agent.md`.
- **Skill personali:** `~/.copilot/skills/<nome>/SKILL.md`.

Attenzione a un dettaglio che sorprende molti: le istruzioni utente nelle cartelle dell'harness **non** si sincronizzano con Settings Sync. Se cambi computer, quelle cartelle non ti seguono. I prompt file a livello utente, invece, stanno nello storage del profilo VS Code e seguono il profilo.

### 4.7.3 Il formato Claude dentro VS Code

VS Code riconosce anche le cartelle in stile Claude quando l'harness è quello di Anthropic:

| Cosa | Percorso |
| --- | --- |
| Istruzioni mirate | `.claude/rules/*.md` (frontmatter `paths`) |
| Agenti | `.claude/agents/*.md` |
| Skill | `.claude/skills/<nome>/SKILL.md` |

Il formato condiviso riduce il lavoro, ma non rende universale la scoperta automatica. `AGENTS.md` e il formato standard delle skill sono riutilizzabili solo dai client che li supportano; `.github/skills/` è un percorso di scoperta di VS Code con Copilot, non un percorso universale. Per un setup multi-harness, mantieni una fonte e pubblica le skill nei percorsi supportati da ciascun client tramite copie, collegamenti simbolici o generazione (vedi la sezione 4.13). Se invece scrivi tutto in `.copilot/` o in `.claude/`, stai scegliendo un harness specifico — il che va benissimo, purché sia una scelta e non un caso.

### 4.7.4 Un esempio completo e verificabile

```text
.github/copilot-instructions.md      → sempre caricato
.github/instructions/tests.instructions.md → quando tocchi tests/**
.github/skills/release-notes/        → solo nome e descrizione
.github/agents/revisore.agent.md     → strumenti in sola lettura
```

Per verificare che sia tutto visibile, in VS Code si apre l'**Agent Customizations editor** dalla Command Palette (`Chat: Open Customizations`): mostra istruzioni, skill, agenti e plugin per l'harness selezionato. È il modo più rapido per capire se un file è stato scoperto o se è nel posto sbagliato.
