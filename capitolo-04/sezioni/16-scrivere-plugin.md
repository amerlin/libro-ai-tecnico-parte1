## 4.16 Scrivere un plugin

Mettiamo insieme i pezzi: la skill `release-notes`, l'agente `Revisore` e — per completezza — un server MCP per il catalogo prodotti del Capitolo 2.

### 4.16.1 La struttura

```text
dotnet-delivery-plugin/
|-- plugin.json
|-- skills/
|   |-- release-notes/
|   |   |-- SKILL.md
|   |   |-- scripts/collect-commits.py
|   |   `-- references/CHANGELOG-FORMAT.md
|   `-- db-migration/
|       `-- SKILL.md
|-- mcp.json
`-- com.github.copilot/
    |-- agents/
    |   |-- planner.agent.md
    |   |-- implementer.agent.md
    |   `-- revisore.agent.md
    `-- hooks/
        `-- hooks.json
```

Tutto ciò che è nelle prime tre voci è **portabile**; solo `com.github.copilot/` è specifico del client.

### 4.16.2 Il manifest

```json
{
  "$schema": "https://agent-plugins.org/schemas/1.0.0/plugin.schema.json",
  "name": "dotnet-delivery",
  "description": "Skill, agenti e server MCP per il ciclo di rilascio di una Minimal API .NET",
  "version": "1.2.0",
  "license": "MIT",
  "author": { "name": "Team Taskify" },
  "keywords": ["dotnet", "release", "changelog", "ef-core"],
  "homepage": "https://github.com/esempio/dotnet-delivery"
}
```

Il campo `$schema` non è decorativo: è ciò che distingue un plugin Agent Plugins 1.0 dal formato Copilot. Se manca, il client ripiega sul formato predefinito.

Gli URL con owner `esempio` sono valori segnaposto, non repository reali: sostituiscili con l'organizzazione e il repository effettivi prima di pubblicare o installare il plugin.

### 4.16.3 I server MCP

`mcp.json` dichiara i server senza che serva elencarli nel manifest:

```json
{
  "servers": {
    "catalog": {
      "command": "dotnet",
      "args": ["run", "--project", "tools/CatalogMcpServer"],
      "env": {
        "CATALOG_DB": "${workspaceFolder}/catalog.db"
      }
    }
  }
}
```

Qui si vede il legame con il Capitolo 2: il server MCP del catalogo diventa un componente del plugin, e chi lo installa ottiene gli strumenti senza configurare nulla a mano. È il modo giusto di distribuire un server MCP a un team.

### 4.16.4 Gli hook

Gli hook sono comandi che il client esegue in punti del ciclo di vita. Un esempio utile: impedire il commit di file con segreti.

```json
{
  "hooks": {
    "preCommit": [
      {
        "command": "pwsh",
        "args": ["-NoProfile", "-File", "scripts/check-secrets.ps1"]
      }
    ]
  }
}
```

Attenzione: gli hook sono **specifici del client**, non portabili, e sono la parte più rischiosa di un plugin. Un plugin che installa un hook esegue codice a ogni evento. È esattamente il punto su cui si concentra la sezione sulla sicurezza.

### 4.16.5 La versione Claude

Se vuoi lo stesso pacchetto per Claude Code, il manifest cambia posizione e nome:

```text
dotnet-delivery-plugin/
|-- .claude-plugin/
|   `-- plugin.json
|-- skills/
|   `-- release-notes/SKILL.md
|-- agents/
|   `-- revisore.md
|-- hooks/
|   `-- hooks.json
`-- .mcp.json
```

Le skill vengono esposte con il namespace del plugin (`/dotnet-delivery:release-notes`), che evita collisioni con skill omonime di altri plugin.

### 4.16.6 Pubblicare

La distribuzione avviene tramite un **marketplace**, cioè un repository Git con un catalogo. Il flusso tipico:

```bash
# VS Code / Copilot: aggiungi il marketplace e installa
/plugin marketplace add https://github.com/esempio/agent-plugins
/plugin marketplace browse dotnet-tools
/plugin install dotnet-delivery@dotnet-tools

# Claude Code
/plugin
```

Per uso interno, la cosa più pragmatica è un repository privato dell'organizzazione con un marketplace e una policy che consente solo i marketplace approvati. Un plugin interno non è più complicato di un pacchetto NuGet interno, e offre lo stesso beneficio: una versione, un changelog, un punto di aggiornamento.
