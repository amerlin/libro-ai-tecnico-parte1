## 4.11 La mappa comparata: sei ambienti

Mettiamo tutto insieme in una vista unica. La figura confronta sei ambienti trattati nel capitolo: cinque client e DeepSeek come backend, allineati per tipo di contenuto.

![Mappa delle cartelle di personalizzazione nei sei ambienti del capitolo](figure/mappa-cartelle.pdf)

### 4.11.1 Tabella di orientamento

Primo elenco: dove stanno i contenuti operativi.

- **Copilot (VS Code):** istruzioni in `.github/` o `AGENTS.md`; skill in `.github/skills/` o `.agents/skills/`; agenti in `.github/agents/`; prompt in `.github/prompts/`.
- **Claude Code:** istruzioni in `CLAUDE.md` e `.claude/rules/`; skill, agenti e comandi in `.claude/skills/`, `.claude/agents/` e `.claude/commands/`.
- **Cursor:** regole in `.cursor/rules/` e `AGENTS.md`; skill e agenti in `.cursor/skills/`, `.agents/skills/` e `.cursor/agents/`; le skill possono essere invocate per nome o con `@`.
- **Gemini CLI:** contesto in `GEMINI.md` o `AGENTS.md` configurabile; skill e agenti in `.gemini/` e `.agents/`; comandi in `.gemini/commands/*.toml`.
- **Codex:** istruzioni in `AGENTS.md` e skill in `.agents/skills/`.
- **DeepSeek (API/backend):** percorsi, agenti e strumenti dipendono dall'host; DeepSeek Harness usa moduli propri (4.10.2).

Secondo elenco: ambito utente e distribuzione.

- **Copilot (VS Code):** `~/.copilot/`; plugin Agent Plugins con `plugin.json`.
- **Claude Code:** `~/.claude/`; plugin con `.claude-plugin/plugin.json`.
- **Cursor:** profilo dell'app.
- **Gemini CLI:** `~/.gemini/`; estensioni.
- **Codex:** `~/.codex/`; plugin e marketplace.
- **DeepSeek (API/backend):** non ha un livello utente proprio; dipende dall'host.

I trattini indicano che la tabella non riporta un percorso dedicato; per DeepSeek, in quanto backend, la scoperta dipende dal client host. Il supporto alle skill Agent Skills nei cinque client e i percorsi/subagenti di Cursor e Gemini CLI sono verificati nella documentazione ufficiale consultata il 30 ottobre 2026: [VS Code — Agent Skills](https://code.visualstudio.com/docs/agent-customization/agent-skills), [Claude Code — skills](https://code.claude.com/docs/en/skills), [Cursor — Agent Skills](https://cursor.com/docs/skills), [Cursor — Subagents](https://cursor.com/docs/subagents), [Gemini CLI — Agent Skills](https://geminicli.com/docs/cli/skills/), [Gemini CLI — comandi](https://geminicli.com/docs/reference/commands/) e [Codex — skills](https://developers.openai.com/codex/skills/). I percorsi completi dei singoli file sono nelle sezioni 4.7–4.10 e nella figura della mappa.

### 4.11.2 Tre letture utili

**Lettura 1 — il file di contesto è il contenuto più riutilizzabile.** Ogni client ha il suo file principale; diversi accettano `AGENTS.md` o possono essere configurati per leggerlo, ma non è una garanzia universale. Se dovessi scegliere **un solo** file condiviso, partirei da quello e verificherei il supporto dei client usati.

**Lettura 2 — cinque client documentano skill Agent Skills.** Copilot in VS Code, Claude Code, Cursor, Gemini CLI e Codex supportano il formato `skills/<nome>/SKILL.md`, con percorsi di scoperta che variano da client a client. DeepSeek, usato come API/backend, non definisce da solo un percorso di scoperta: dipende dall'host.

**Lettura 3 — i nomi cambiano, i concetti sono simili.** `applyTo`, `paths` e `globs` associano regole a percorsi, ma hanno sintassi e semantiche specifiche del client: selezionano quando applicare una regola e non implicano di per sé la sostituzione delle istruzioni generali. `alwaysApply` controlla l'applicazione di una regola in Cursor. Una volta riconosciute le differenze, cambiare motore costa meno.

### 4.11.3 Il rischio della mappa

Il rischio di una tabella come questa è di essere letta come una classifica. Non lo è: ogni motore ha fatto scelte diverse, e alcune sono migliori in certi contesti. La tabella serve a rispondere a una domanda operativa — «dove metto questo file?» — e a una domanda di manutenzione — «se domani cambio motore, quanto mi costa?».

La seconda domanda è quella che conta davvero, e la affrontiamo tra due sezioni.
