## 4.6 I plugin

Un plugin è una **cartella con un manifest** che raggruppa componenti correlati: skill, agenti, server MCP, hook, comandi. Si installa da un marketplace o da un repository Git e si aggiorna come una dipendenza.

![Struttura di un plugin: componenti portabili e componenti specifici del client](figure/plugin-pacchetto.pdf)

### 4.6.1 Perché servono

Il caso più frequente è banale: hai messo a punto tre skill e un agente che funzionano bene insieme, e vuoi usarli su cinque repository. Le alternative senza plugin sono copiare le cartelle (e poi dimenticarti di aggiornarne una) oppure duplicare il contenuto (e poi averne tre versioni divergenti).

Il plugin risolve il problema di **distribuzione**: una versione, un manifest, un comando di aggiornamento.

### 4.6.2 Lo standard e le estensioni

Il formato **Agent Plugins 1.0** definisce due componenti portabili — le **skill** e i **server MCP** — e lascia gli altri (agenti, hook, comandi, automazioni) come estensioni specifiche del client, in namespace con dominio inverso.

Un plugin conforme ha questa forma:

```text
my-testing-plugin/
|-- plugin.json                  # manifest: $schema, name, version...
|-- skills/                      # PORTABILE
|   `-- test-runner/
|       |-- SKILL.md
|       `-- run-tests.sh
|-- mcp.json                     # PORTABILE: server MCP
|-- automations/
|   `-- review.automation.md
`-- com.github.copilot/          # SPECIFICO del client
    |-- agents/
    |   `-- test-reviewer.agent.md
    `-- hooks/
        `-- hooks.json
```

Il dettaglio da capire: la cartella `com.github.copilot/` è **ignorata** dagli altri client. Questo permette a un unico pacchetto di essere portabile (skill e MCP) e, allo stesso tempo, di offrire funzionalità extra dove il client le supporta.

Il manifest minimo:

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "my-dev-tools",
  "description": "Utility per lo sviluppo .NET",
  "version": "1.2.0",
  "license": "MIT"
}
```

Nota cosa **non** c'è: i percorsi di skill e MCP. Non si dichiarano, si scoprono per convenzione — `skills/` e `mcp.json`. Meno configurazione, meno errori.

### 4.6.3 Il formato Claude

Claude Code usa un formato proprio, riconosciuto dai client che lo supportano: il manifest è `.claude-plugin/plugin.json` e i componenti stanno nelle cartelle `skills/`, `agents/`, `hooks/` e `.mcp.json` alla radice del plugin. I client che leggono entrambi i formati lo rilevano dal manifest presente.

```text
my-plugin/
|-- .claude-plugin/
|   `-- plugin.json
|-- skills/
|   `-- review/
|       `-- SKILL.md          # invocabile come /my-plugin:review
|-- agents/
|   `-- reviewer.md
|-- hooks/
|   `-- hooks.json
`-- .mcp.json
```

Le skill di un plugin sono **namespaced** (`/my-plugin:review`): è ciò che permette a due plugin di avere entrambi una skill chiamata `review` senza collidere.

### 4.6.4 Marketplace e fiducia

Un **marketplace** è un catalogo che elenca plugin e da dove scaricarli. In VS Code si aggiunge un marketplace da un repository Git e si installano i plugin con `/plugin install <plugin>@<marketplace>`; in Claude Code si usa `/plugin` e la scheda *Discover*.

Qui va detto con chiarezza: **un plugin può eseguire codice sulla tua macchina**. Gli hook sono comandi di shell, i server MCP sono processi, gli script delle skill vengono eseguiti. Installare un plugin da una fonte non verificata è come eseguire uno script scaricato da internet. La contromisura non è tecnica ma procedurale: leggi il contenuto, controlla l'autore, preferisci marketplace interni o verificati. Ne riparliamo nella sezione 4.18.

