## 4.8 Dove vivono i file: Claude Code

Claude Code ha un modello di **memoria a strati**: i file `CLAUDE.md` si sommano lungo una gerarchia che va dalla policy aziendale fino alla cartella in cui stai lavorando.

### 4.8.1 La gerarchia di `CLAUDE.md`

I file sono elencati nell'ordine di caricamento, dal più ampio al più specifico:

```{=latex}
\footnotesize
```

| Ambito | Posizione | Condiviso con |
| --- | --- | --- |
| Policy gestita | Windows: \texttt{C:\textbackslash{}Program\ Files\allowbreak\textbackslash{}ClaudeCode\allowbreak\textbackslash{}CLAUDE.md}; Linux/WSL: \texttt{/etc/claude-code\allowbreak/CLAUDE.md}; macOS: \texttt{/Library\allowbreak/Application\ Support\allowbreak/ClaudeCode\allowbreak/CLAUDE.md} | Tutta l'organizzazione |
| Utente | `~/.claude/CLAUDE.md` | Solo te, tutti i progetti |
| Progetto | `./CLAUDE.md` oppure `./.claude/CLAUDE.md` | Il team, via source control |
| Locale | `./CLAUDE.local.md` | Solo te, questo progetto (da mettere in `.gitignore`) |

```{=latex}
\normalsize
```

Il caricamento non si ferma alla cartella corrente: i `CLAUDE.md` nelle cartelle superiori vengono letti all'avvio, quelli nelle sottocartelle **su richiesta**, quando un file di quella cartella viene toccato. Quindi un `CLAUDE.md` in `src/Data/` può contenere regole specifiche del data layer senza appesantire il resto.

Un dettaglio che cambia le abitudini: Claude Code legge anche **`AGENTS.md`**, e in quel caso lo usa in vece di `CLAUDE.md`. Se hai già un `AGENTS.md`, non devi duplicarlo.

### 4.8.2 Le regole per percorso

Il frontmatter di un file in `.claude/rules/` usa `paths` (non `applyTo`):

```markdown
---
paths: ["src/Data/**/*.cs", "src/Models/**/*.cs"]
---

- Le entità non hanno costruttori con parametri: usa le proprietà `required`.
- Nessuna query LINQ con `ToList()` prima di un filtro.
- Le configurazioni `IEntityTypeConfiguration<T>` stanno in `src/Data/Configurations`.
```

È l'equivalente dei file `.instructions.md` di VS Code, con un nome di campo diverso. Chi scrive per entrambi i motori deve ricordarsi solo questa differenza.

### 4.8.3 Skill, agenti, comandi

```{=latex}
\footnotesize
```

| Cosa | Progetto | Utente |
|:----|:--------|:-------|
| Skill | \url{.claude/skills/<nome>/SKILL.md} | \url{~/.claude/skills/<nome>/SKILL.md} |
| Subagenti | \url{.claude/agents/<nome>.md} | \url{~/.claude/agents/<nome>.md} |
| Comandi (legacy) | \url{.claude/commands/<nome>.md} | \url{~/.claude/commands/<nome>.md} |
| Regole | \url{.claude/rules/*.md} | \url{~/.claude/rules/*.md} |
| Impostazioni | \url{.claude/settings.json}, \url{.claude/settings.local.json} | \url{~/.claude/settings.json} |
| Server MCP | \url{.mcp.json} (radice del progetto) | configurazione utente |

```{=latex}
\normalsize
```

Due note pratiche:

- i vecchi **comandi** non sono morti: un file in `.claude/commands/deploy.md` continua a produrre `/deploy`, ma la skill equivalente in `.claude/skills/deploy/SKILL.md` offre in più le risorse di supporto e l'attivazione automatica. Se stai iniziando oggi, scrivi una skill;
- `.claude/settings.local.json` e `CLAUDE.local.md` sono **personali**: vanno in `.gitignore`, altrimenti il repository si riempie di URL di sandbox e percorsi che esistono solo sulla tua macchina.

### 4.8.4 L'albero completo

```text
taskify/
|-- CLAUDE.md
|-- CLAUDE.local.md                 # in .gitignore
|-- .mcp.json
|-- .claude/
|   |-- settings.json
|   |-- settings.local.json         # in .gitignore
|   |-- rules/
|   |   |-- api.md                  # paths: src/Api/**/*.cs
|   |   `-- tests.md                # paths: tests/**/*.cs
|   |-- agents/
|   |   `-- revisore.md
|   `-- skills/
|       `-- release-notes/
|           `-- SKILL.md
`-- src/
    `-- Data/
        `-- CLAUDE.md               # solo per questa cartella
```

### 4.8.5 Come verificare cosa è stato caricato

Claude Code offre due comandi che valgono più di qualsiasi documentazione:

- **`/context`** mostra i file di memoria effettivamente caricati nella sessione.

Se un'istruzione "non funziona", la prima cosa da fare non è riscriverla meglio: è **verificare che sia stata caricata**. Nella sezione 4.17 vedremo come farlo in modo sistematico.
