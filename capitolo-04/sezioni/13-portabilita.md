## 4.13 Portabilità: cosa è standard e cosa no

Se il tuo team usa motori diversi — o se semplicemente non vuoi riscrivere tutto quando cambi strumento — la domanda è: **che cosa posso scrivere una volta sola?**

### 4.13.1 La scala della portabilità

| Livello | Portabilità | Note |
| --- | --- | --- |
| `AGENTS.md` | Alta | Riconosciuto da Codex, Cursor, VS Code (harness Copilot e Local), Claude Code, Gemini CLI (configurabile) |
| Skill (`SKILL.md`) | Alta, per i client compatibili | Il formato Agent Skills è riusabile; i percorsi di scoperta variano da client a client |
| Server MCP | Alta | Standard MCP, indipendente dal motore (Capitolo 1) |
| Plugin (Agent Plugins 1.0) | Media | Le parti portabili sono skill e MCP; agenti e hook sono nel namespace del client |
| File di istruzioni mirate | Bassa | `applyTo` / `paths` / `globs` / sottocartelle: quattro approcci |
| Agenti | Bassa | Formati simili, campi e semantica diversi |
| Comandi | Bassa | `.prompt.md`, `.md`, `.toml`: tre formati |

La conseguenza strategica: **investi nello standard e automatizza le copie richieste**. Un `AGENTS.md` curato e skill ben fatte sono riutilizzabili dove il client li supporta; non presumere che ogni client li scopra automaticamente dallo stesso percorso. Il restante lavoro — regole mirate, agenti, comandi e distribuzione dei file — va scritto in modo che sia **facile da rigenerare**.

### 4.13.2 La strategia della fonte unica

Il modo meno doloroso di gestire più motori è avere una fonte unica e generare le copie. Tre approcci, in ordine crescente di automazione:

**1. Riferimento.** Il file specifico non contiene la regola, ma un rimando:

```markdown
<!-- .github/copilot-instructions.md -->
# Taskify

Le regole di progetto sono in [`AGENTS.md`](../AGENTS.md). Questo file esiste solo
per i client che non leggono `AGENTS.md`: non aggiungere regole qui.
```

Costo: zero. Limite: funziona solo se il motore risolve i link relativi (VS Code lo fa).

**2. Collegamento simbolico.** Un solo file reale, più collegamenti:

```powershell
# Windows: richiede privilegi di amministratore o Developer Mode
New-Item -ItemType SymbolicLink -Path "CLAUDE.md" -Target "AGENTS.md"
```

Costo: basso. Limite: i symlink su Windows sono fragili in Git e in CI; vanno valutati caso per caso.

**3. Generazione.** Un piccolo script che produce le copie da una fonte:

```powershell
# tools/sync-agent-config.ps1
$source = "AGENTS.md"
$targets = @(
    ".github/copilot-instructions.md",
    ".claude/CLAUDE.md"
)
foreach ($t in $targets) {
    $dir = Split-Path -Parent $t
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $banner = "<!-- GENERATO da $source con tools/sync-agent-config.ps1: non modificare a mano -->`n`n"
    Set-Content -Path $t -Value ($banner + (Get-Content $source -Raw)) -Encoding UTF8
}
```

Costo: medio. Vantaggio: funziona ovunque, è verificabile in CI e il banner impedisce le modifiche a mano.

### 4.13.3 Il formato delle skill è portabile, la scoperta no

Una skill conforme allo standard Agent Skills può essere riutilizzata dai client compatibili, ma il formato non impone un percorso universale né garantisce la scoperta automatica in ogni strumento. I percorsi documentati per i client trattati qui sono:

```text
VS Code con Copilot   .github/skills/<nome>/SKILL.md o .agents/skills/<nome>/SKILL.md
Claude Code           .claude/skills/<nome>/SKILL.md
Cursor                .cursor/skills/<nome>/SKILL.md o .agents/skills/<nome>/SKILL.md
Gemini CLI            .gemini/skills/<nome>/SKILL.md o .agents/skills/<nome>/SKILL.md
Codex                 .agents/skills/<nome>/SKILL.md
```

Questi percorsi e il supporto di Cursor, Gemini CLI e VS Code sono verificati nella documentazione ufficiale consultata il 30 ottobre 2026: [VS Code — Agent Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills), [Cursor — Agent Skills](https://cursor.com/docs/skills), [Gemini CLI — Agent Skills](https://geminicli.com/docs/cli/skills/). Mantieni una fonte canonica e, per i client che richiedono un altro percorso, crea copie, collegamenti simbolici dove funzionano nell'ambiente di sviluppo e nella CI, oppure genera i file con uno script. `.github/skills/` e `.agents/skills/` sono percorsi supportati in contesti compatibili, non destinazioni universali.

### 4.13.4 Un criterio di decisione

Per decidere dove investire, usa questa domanda: **quanto spesso cambierà?** Le convenzioni di progetto cambiano lentamente (una volta ogni qualche mese): vale la pena scriverle nello standard e rigenerare le copie. Gli agenti e i comandi cambiano spesso e sono legati al flusso di lavoro personale: tanto vale scriverli nel formato del motore che usi davvero, senza inseguire la portabilità.
