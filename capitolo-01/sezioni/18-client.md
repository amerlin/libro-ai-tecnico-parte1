## 1.18 Configurare i client: Claude Desktop e VS Code

Un server MCP senza client è come un telefono senza interlocutore. Vediamo come collegare i nostri server ai due host più comuni: **Claude Desktop** e **Visual Studio Code** (con GitHub Copilot). Il principio è identico per qualunque altro host: si dichiara il server con un nome, un comando (per `stdio`) o un URL (per HTTP).

### 1.18.1 Claude Desktop con un server stdio

Claude Desktop legge la configurazione dei server da un file JSON. Su Windows si trova in:

```text
%APPDATA%\Claude\claude_desktop_config.json
```

Apri il file e aggiungi il nostro server meteo nella sezione `mcpServers`:

```json
{
  "mcpServers": {
    "meteo": {
      "command": "dotnet",
      "args": [
        "run",
        "--project",
        "C:\\percorso\\del\\progetto\\MeteoServer"
      ]
    }
  }
}
```

Spiegazione dei campi:

- `"meteo"` è il **nome logico** che l'host userà per riferirsi al server;
- `"command"` è l'eseguibile da lanciare (`dotnet`);
- `"args"` sono gli argomenti: `run --project <percorso>` compila ed esegue il progetto.

Dopo aver salvato, riavvia Claude Desktop: nella sua interfaccia comparirà il server (con i relativi tool) tra le integrazioni disponibili.

> **Consiglio.** In produzione è preferibile pubblicare il server (`dotnet publish`) e puntare direttamente all'eseguibile, invece di usare `dotnet run`, che compila a ogni avvio:

```json
{
  "mcpServers": {
    "meteo": {
      "command": "C:\\percorso\\publish\\MeteoServer.exe",
      "args": []
    }
  }
}
```

### 1.18.2 Claude Desktop con un server HTTP

Se hai realizzato il server HTTP della sezione precedente, la configurazione usa l'URL invece del comando:

```json
{
  "mcpServers": {
    "meteo-http": {
      "url": "http://localhost:5080/mcp"
    }
  }
}
```

### 1.18.3 Visual Studio Code (GitHub Copilot)

VS Code supporta i server MCP tramite il file `.vscode/mcp.json` nella root del progetto (o tramite le impostazioni). Il formato è simile:

```json
{
  "servers": {
    "meteo": {
      "type": "stdio",
      "command": "dotnet",
      "args": [
        "run",
        "--project",
        "C:\\percorso\\del\\progetto\\MeteoServer"
      ]
    },
    "meteo-http": {
      "type": "http",
      "url": "http://localhost:5080/mcp"
    }
  }
}
```

Dopo aver salvato il file, VS Code/Copilot rileva il server e ne espone i tool all'agente. Potrai chiedere, per esempio: "Che tempo fa a Roma?" e osservare Copilot usare il tool `get_temperature` del tuo server.

### 1.18.4 Il formato comune

Come vedi, al di là di piccole differenze sintattiche, tutti gli host condividono la stessa logica:

- per `stdio`: un **comando** (e i relativi argomenti) da eseguire;
- per HTTP: un **URL** da contattare;
- opzionalmente: variabili d'ambiente, intestazioni HTTP o token di autenticazione.

È la promessa di riusabilità di MCP resa concreta: lo stesso server si collega a Claude Desktop, a VS Code e a qualunque altro host con una configurazione di poche righe, senza modificare una sola riga di codice del server.

### 1.18.5 Variabili d'ambiente e segreti

Molti server hanno bisogno di configurazione (chiavi API, percorsi, livelli di log). Gli host consentono di passare **variabili d'ambiente**:

```json
{
  "mcpServers": {
    "meteo": {
      "command": "dotnet",
      "args": ["run", "--project", "C:\\percorso\\MeteoServer"],
      "env": {
        "API_KEY": "la-tua-chiave"
      }
    }
  }
}
```

> **Attenzione.** Non commettere mai segreti nei file di configurazione condivisi (né tantomeno nel codice sorgente). Usa variabili d'ambiente locali, un gestore di segreti o, per i server HTTP, l'autenticazione OAuth prevista dalla specifica. Torneremo sulla sicurezza tra poco.
