## 4.23 Riepilogo

### 4.23.1 I quattro livelli

| Livello | Cosa contiene | Quando si carica | Costo in contesto |
| --- | --- | --- | --- |
| **Istruzioni** | Regole, convenzioni, comandi | Sempre, o per pattern di file | Fisso, a ogni turno |
| **Skill** | Procedure, con script e riferimenti | Su attivazione | Solo nome e descrizione, finché non serve |
| **Agenti** | Ruolo, strumenti, modello | Alla selezione o alla delega | Le istruzioni dell'agente attivo |
| **Plugin** | Confezione dei precedenti | All'installazione | Quello dei componenti che contiene |

La scelta dello strumento è una scelta sul **contesto**: quanto deve essere sempre presente, quanto deve essere disponibile, quanto deve essere isolato.

### 4.23.2 Dove mettere i file

Per i percorsi di dettaglio e i limiti di scoperta, vedi la mappa comparata nella sezione 4.11. In sintesi:

- **Copilot (VS Code):** `.github/copilot-instructions.md` o `AGENTS.md`; skill in `.github/skills/`, `.agents/skills/` o `~/.copilot/skills/`; agenti in `.github/agents/` o `~/.copilot/agents/`.
- **Claude Code:** `CLAUDE.md`, `.claude/rules/` o `AGENTS.md`; skill e agenti sotto `.claude/`; plugin con `.claude-plugin/plugin.json`.
- **Cursor:** `AGENTS.md` e `.cursor/rules/*.mdc`; skill e agenti dipendono dalle funzionalità e dai percorsi supportati dal client.
- **Gemini CLI:** `GEMINI.md` e, se configurato, `AGENTS.md`; le estensioni distribuiscono i componenti aggiuntivi.
- **Codex:** `AGENTS.md` e skill in `.agents/skills/`; plugin e marketplace per la distribuzione.
- **DeepSeek:** il formato è quello dell'host scelto; DeepSeek Harness usa moduli TypeScript e `cordis.yml`.

### 4.23.3 Le tre idee da portarsi a casa

**1. La portabilità è una scala, non un interruttore.** `AGENTS.md`, le skill standard e i server MCP viaggiano; le istruzioni mirate, gli agenti e i comandi no. Investi dove il contenuto è stabile, accetta il duplicato dove non lo è, e genera le copie con uno script.

**2. La configurazione è codice.** Va revisionata, versionata, validata in CI e trattata come codice eseguito con i tuoi privilegi. Un `SKILL.md` che chiama `curl` non è una nota: è un comando.

**3. I permessi battono le istruzioni.** Se una cosa non deve accadere, non scriverla in un file: togli lo strumento, limita i permessi, metti un hook. Le istruzioni orientano; i permessi vincolano.

### 4.23.4 Il filo con i capitoli precedenti

Questi tre capitoli formano una progressione coerente:

- il **Capitolo 1** ha dato all'agente degli **strumenti** (MCP: tool, risorse, prompt);
- il **Capitolo 2** gli ha dato dei **dati** (un database dietro un server MCP);
- il **Capitolo 3** gli ha dato un **processo** (dalla specifica al codice);
- il **Capitolo 4** gli dà la **memoria e il mestiere**: le regole del progetto, le procedure del team, i ruoli e i confini.

Senza il quarto, i primi tre funzionano ma vanno rispiegati ogni mattina. Con il quarto, l'agente arriva alla sessione sapendo già come si lavora qui — che è, in fondo, la definizione di un buon collaboratore.
