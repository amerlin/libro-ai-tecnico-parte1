## 1.20 Errori, logging e best practice

Un server MCP robusto non si limita a "funzionare quando tutto va bene": deve saper **fallire bene**. In questa sezione raccogliamo le pratiche essenziali per la gestione degli errori, il logging e la progettazione.

### 1.20.1 Gestire gli errori nei tool

Quando un tool incontra un errore previsto (un file inesistente, un parametro fuori intervallo, un servizio esterno irraggiungibile), non deve lasciar propagare un'eccezione grezza: deve restituire al client un **errore strutturato e comprensibile**. L'SDK offre la classe `McpException` (namespace `ModelContextProtocol`):

```csharp
using ModelContextProtocol;

[McpServerTool, Description("Reads the text content of a file under the root.")]
public string ReadFile([Description("Relative file path.")] string relativePath)
{
    var file = Resolve(relativePath);
    if (!File.Exists(file))
        throw new McpException($"File not found: {relativePath}");
    return File.ReadAllText(file);
}
```

L'SDK intercetta la `McpException` e restituisce il risultato del tool come `CallToolResult` con `isError: true` e il messaggio fornito, che il modello può leggere e riferire all'utente. Anche un'eccezione non gestita produce un risultato di errore del tool, in genere con un messaggio generico. Questo non è un errore JSON-RPC: gli errori di protocollo (per esempio una richiesta malformata o un metodo inesistente) usano invece una risposta JSON-RPC con il campo `error`.

### 1.20.2 Gli errori JSON-RPC di protocollo

Gli errori JSON-RPC di protocollo hanno codici come questi, raccolti nell'enumerazione `McpErrorCode` dell'SDK:

```{=latex}
\footnotesize
```

| Membro | Valore | Significato |
|---------------------------|--------|------------------------------|
| `ParseError` | -32700 | JSON non valido |
| `InvalidRequest` | -32600 | Richiesta malformata |
| `MethodNotFound` | -32601 | Metodo inesistente |
| `InvalidParams` | -32602 | Parametri non validi |
| `InternalError` | -32603 | Errore interno |
| `ResourceNotFound` | -32002 | Risorsa inesistente |
| `UnsupportedProtocolVersion` | -32022 | Versione del protocollo non supportata |

```{=latex}
\normalsize
```

Questi codici riguardano errori a livello di protocollo e sono distinti dagli errori di esecuzione dei tool, che vengono restituiti in `CallToolResult` con `isError: true`. Non associare quindi automaticamente a un errore di tool un codice JSON-RPC.

### 1.20.3 Validare gli argomenti in ingresso

Gli argomenti arrivano dal modello, e il modello può sbagliare. Valida sempre gli input critici prima di usarli:

```csharp
[McpServerTool, Description("Divides two numbers.")]
public static double Divide(
    [Description("Dividend.")] double dividend,
    [Description("Divisor.")] double divisor)
{
    if (divisor == 0)
        throw new McpException("Cannot divide by zero.");
    return dividend / divisor;
}
```

Lo schema di input dichiara i *tipi*, ma non i *vincoli di dominio*: tocca a te verificare intervalli, formati, permessi e coerenza.

### 1.20.4 Il logging: dove e come

Abbiamo già visto che nei server `stdio` il logging su console va disattivato, perché lo stdout è il canale del protocollo. La chiamata che lo fa è una sola:

```csharp
builder.Logging.ClearProviders();
```

Ma allora come si osservano i log? Le opzioni:

- **log su file** — registra i log su un file, non sulla console;
- **log su stderr** — tecnicamente lo stderr non è usato dal protocollo `stdio`; alcuni preferiscono dirottarvi i log;
- **MCP logging** — il protocollo prevede un meccanismo per inviare messaggi di log al client (`logging/setLevel` e notifiche di log), supportato dall'SDK.

La regola d'oro, per `stdio`, è una sola: **mai scrivere sullo stdout** nulla che non sia un messaggio JSON-RPC.

### 1.20.5 Dipendenze e testabilità

Progettare i tool come classi con dipendenze iniettate (come `WeatherTool` con il suo `HttpClient`) ha un beneficio collaterale prezioso: la **testabilità**. In un test unitario puoi sostituire l'`HttpClient` con un handler fittizio, oppure iniettare un'interfaccia `IWeatherService` e testare il tool in isolamento, senza rete né processi esterni. I metodi tool sono, in fondo, normali metodi C#: si testano come qualsiasi altro metodo.

### 1.20.6 Naming e coerenza

- Usa nomi di tool **chiari e verbosi**: `search_flights` è meglio di `sf`.
- Ricorda che l'SDK **converte i nomi in minuscolo**: scegli nomi già in stile `snake_case` per evitare sorprese (oppure usa la proprietà `Name` per un controllo esplicito).
- Mantieni **coerenza terminologica** tra tool, descrizioni e parametri.
- Esponi **un concetto per tool**: un tool che fa troppe cose è difficile da descrivere e da usare correttamente.

### 1.20.7 Piccole cose che fanno la differenza

- Descrivi i **valori di ritorno** nelle descrizioni, non solo gli input.
- Segnala nelle descrizioni i **casi limite** ("se il file non esiste, restituisce un errore").
- Usa le **annotazioni** (`ReadOnly`, `Destructive`, `Idempotent`) per informare i client sulla natura del tool.
- Mantieni i tool **idempotenti** quando possibile: rende il comportamento del modello più prevedibile e sicuro.
- Versiona i tuoi server (`serverInfo.name` e `version`) per tracciare le distribuzioni.

Queste pratiche, sommate, trasformano un server "che funziona" in un server **affidabile**, che un modello può usare con fiducia e che un team può mantenere nel tempo.
