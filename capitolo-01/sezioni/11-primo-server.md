## 1.11 Il tuo primo MCP server (stdio)

È arrivato il momento di scrivere codice. Costruiremo il server più piccolo possibile: un server `stdio` che espone un solo tool, `echo`, capace di rispondere a un messaggio. È il classico "Hello, World!" di MCP, ma contiene già tutti gli elementi che ritroveremo, invariati, nei server più complessi.

### 1.11.1 Il codice completo

Sostituisci il contenuto di `Program.cs` con questo:

```csharp
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;

// 1. Crea l'host generico dell'applicazione.
var builder = Host.CreateApplicationBuilder(args);

// 2. Su stdio, lo stdout è riservato al protocollo: disattiva i log su console.
builder.Logging.ClearProviders();

// 3. Registra il server MCP, sceglie il trasporto stdio e aggancia i tool.
builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<EchoTool>();

// 4. Avvia il server e resta in ascolto sullo standard input.
await builder.Build().RunAsync();

// 5. La classe che contiene i nostri tool.
[McpServerToolType]
public sealed class EchoTool
{
    [McpServerTool, Description("Echoes the message back to the client.")]
    public static string Echo(
        [Description("The message to echo.")] string message)
        => $"hello {message}";
}
```

### 1.11.2 Lettura riga per riga

Vediamo ogni blocco nel dettaglio.

**L'host.** `Host.CreateApplicationBuilder(args)` crea un *generic host*: un contenitore leggero con dependency injection, configurazione e logging. Per un server `stdio` è tutto ciò che serve; non vogliamo un web server.

**Il logging.** `builder.Logging.ClearProviders()` rimuove i provider di logging predefiniti, che altrimenti scriverebbero sulla console. Come abbiamo spiegato, in un server `stdio` lo stdout è il canale del protocollo: qualsiasi byte estraneo lo corromperebbe. È una delle trappole più comuni, e una riga la disinnesca.

**La registrazione.** La catena di metodi fa tre cose:

- `AddMcpServer()` registra il server MCP nel container di dependency injection;
- `WithStdioServerTransport()` seleziona il trasporto su standard input/output;
- `WithTools<EchoTool>()` registra la classe `EchoTool` come fornitrice di tool.

**L'avvio.** `await builder.Build().RunAsync()` costruisce l'host e lo avvia. Il server entra in ascolto sullo stdin, esegue l'handshake e risponde alle richieste finché lo stdin non viene chiuso.

**Il tool.** `[McpServerToolType]` marca la classe come contenitore di tool; `[McpServerTool]` espone il metodo `Echo` come tool; `[Description]` fornisce la descrizione che il modello leggerà. Il parametro `message` ha a sua volta una `[Description]`, e il metodo restituisce una stringa che l'SDK convertirà in contenuto testuale.

### 1.11.3 Eseguire e provare il server

Compiliamo e avviamo:

```bash
> dotnet run
```

Il server si mette in attesa sullo standard input e non stampa nulla (i log sono disattivati). Possiamo collaudarlo inviandogli a mano i messaggi JSON-RPC. Su una shell che supporta l'ereditarietà dello stdin possiamo incollare, una per riga, questi quattro messaggi (nel trasporto `stdio` ogni messaggio è una singola riga; qui li mostriamo su più righe solo per leggibilità — se li incolli, rimetti ciascuno su una riga):

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{
  "protocolVersion":"2025-06-18",
  "capabilities":{},
  "clientInfo":{"name":"book-test","version":"1.0"}
}}

{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}

{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}

{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{
  "name":"echo",
  "arguments":{"message":"mondo"}
}}
```

Il server risponde (sullo stdout) con la sequenza di risposte JSON-RPC, tra cui l'elenco dei tool e il risultato dell'invocazione:

```json
{"jsonrpc":"2.0","id":2,"result":{"tools":[{
  "name":"echo",
  "description":"Echoes the message back to the client.",
  "inputSchema":{
    "type":"object",
    "properties":{
      "message":{"type":"string","description":"The message to echo."}
    },
    "required":["message"]
  }
}]}}
```

```json
{"jsonrpc":"2.0","id":3,"result":{
  "content":[{"type":"text","text":"hello mondo"}],
  "isError":false
}}
```

### 1.11.4 Un dettaglio importante: il nome in minuscolo

Nota che il nome del tool è `echo`, con la iniziale minuscola, anche se il metodo C# si chiama `Echo`. L'SDK .NET, per uniformarsi alle convenzioni del protocollo, **converte i nomi dei tool in minuscolo**. È un dettaglio che conviene ricordare quando si invocano i tool a mano, in un test o in un client: si cerca `echo`, non `Echo`.

Se desideri un nome esplicito, puoi sovrascriverlo con la proprietà `Name` dell'attributo:

```csharp
[McpServerTool(Name = "echo_message")]
[Description("Echoes the message back to the client.")]
public static string Echo([Description("The message to echo.")] string message)
    => $"hello {message}";
```

### 1.11.5 Cosa abbiamo ottenuto

Con un listato compatto abbiamo un server MCP pienamente funzionante: risponde all'handshake, si fa scoprire e invoca il tool. Tutto il resto — serializzazione, schema degli argomenti, gestione del trasporto — è opera dell'SDK. È il pattern che useremo d'ora in poi: *descrivi la funzione, lascia che l'SDK faccia il resto*.
