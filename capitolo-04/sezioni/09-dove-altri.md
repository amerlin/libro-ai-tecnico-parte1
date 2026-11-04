## 4.9 Dove vivono i file: Cursor, Gemini CLI e Codex

Gli altri motori seguono lo stesso schema concettuale — un file di contesto principale, file mirati, comandi, talvolta skill — con nomi diversi. Vediamo i tre più diffusi.

### 4.9.1 Cursor

Cursor usa le **regole** in `.cursor/rules/`, file con estensione `.mdc`. Un file `.md` in quella cartella viene **ignorato**, perché privo del frontmatter che dichiara quando applicarlo.

```markdown
---
description: Convenzioni per i componenti React
globs: src/components/**/*.tsx
alwaysApply: false
---

- Export nominati, mai default.
- Stili in un file `.module.css` accanto al componente.
- Componenti sotto le 200 righe.
```

Le tre chiavi si combinano così:

| `alwaysApply` | `description` | `globs` | Comportamento |
| --- | --- | --- | --- |
| `true` | — | — | Sempre inclusa |
| `false` | — | presente | Allegata quando un file corrisponde al pattern |
| `false` | presente | assente | L'agente la legge se la ritiene pertinente |
| `false` | assente | assente | Solo su `@`-menzione in chat |

In aggiunta Cursor supporta **`AGENTS.md`**, che è l'alternativa semplice per chi non vuole usare `.mdc`. Anche le regole di team si configurano dalla dashboard, per i piani Team ed Enterprise.

### 4.9.2 Gemini CLI

Gemini CLI usa file di contesto chiamati **`GEMINI.md`**, caricati in modo gerarchico:

1. **globale**: `~/.gemini/GEMINI.md`;
2. **workspace**: i `GEMINI.md` trovati nelle cartelle di lavoro e nelle loro cartelle superiori;
3. **just-in-time**: quando uno strumento accede a una cartella, vengono letti i `GEMINI.md` di quella cartella e dei suoi antenati, fino a una radice considerata attendibile.

I file trovati vengono **concatenati**, non sovrascritti: è un modello additivo, diverso da quello a precedenza dei file di istruzioni singoli.

```text
~/.gemini/
|-- GEMINI.md                 # contesto globale
|-- settings.json             # impostazioni utente
`-- commands/
    `-- test.toml             # comando globale /test

taskify/
|-- GEMINI.md                 # contesto del progetto
|-- .gemini/
|   |-- settings.json         # impostazioni di progetto
|   `-- commands/
|       |-- changelog.toml    # /changelog
|       `-- git/
|           `-- commit.toml   # /git:commit (namespace da sottocartella)
`-- src/
    `-- Api/
        `-- GEMINI.md         # caricato quando si lavora qui
```

Due utilità da conoscere:

- il nome del file di contesto è configurabile (`context.fileName` in `settings.json`): puoi fargli leggere `AGENTS.md`, `CONTEXT.md` e `GEMINI.md` insieme;
- `@file.md` dentro un `GEMINI.md` importa un altro file, così il contesto resta modulare.

### 4.9.3 Codex

Codex legge `AGENTS.md` e configura se stesso con TOML:

```text
~/.codex/config.toml          # configurazione utente
taskify/
`-- .codex/
    `-- config.toml           # override di progetto (trusted)
```

La configurazione risolve i valori in un ordine preciso: flag da riga di comando, poi `config.toml` di progetto (dalla radice verso la cartella corrente, il più vicino vince), poi i profili, poi la configurazione utente, poi quella di sistema. Un dettaglio importante: se un progetto non è considerato attendibile, Codex **salta** il livello `.codex/` di progetto — configurazione, hook e regole compresi.

### 4.9.4 Gli altri

Lo stesso schema si ritrova ovunque. In forma sintetica:

- **GitHub Copilot (VS Code):** file `.github/copilot-instructions.md` e `AGENTS.md`; configurazione in `.github/` e `~/.copilot/`.
- **Claude Code:** file `CLAUDE.md` e `AGENTS.md`; configurazione in `.claude/` e `~/.claude/`.
- **Cursor:** `AGENTS.md` e `.cursor/rules/*.mdc`; configurazione in `.cursor/`.
- **Gemini CLI:** `GEMINI.md` e `AGENTS.md` (configurabile); configurazione in `.gemini/` e `~/.gemini/`.
- **Codex:** `AGENTS.md`; configurazione in `.codex/` e `~/.codex/`.
- **Windsurf, Cline e Continue:** file di regole proprietari; molti accettano anche `AGENTS.md`.

Il filo conduttore è evidente: **`AGENTS.md` sta diventando il denominatore comune**. Nella sezione 4.13 vedremo come sfruttarlo.
