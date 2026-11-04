## 1.5 JSON-RPC 2.0: il linguaggio del protocollo

Tutta la comunicazione MCP avviene tramite messaggi **JSON-RPC 2.0**. JSON-RPC è un protocollo remoto estremamente semplice: un messaggio JSON che descrive una chiamata di procedura remota, con un identificatore per correlare richieste e risposte. Se hai mai lavorato con RPC, gRPC o con le API JSON di Ethereum, il concetto ti sarà familiare.

MCP usa JSON-RPC 2.0 con alcune convenzioni specifiche. I tipi di messaggio sono tre: request, notification e response; l'errore è una variante della response.

### 1.5.1 La richiesta (request)

Una richiesta è un messaggio inviato da una parte per chiedere all'altra di eseguire un'operazione. Ha un campo `method` e, opzionalmente, un campo `params`:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "echo",
    "arguments": { "message": "ciao" }
  }
}
```

Il campo `id` può essere una stringa o un numero e serve a correlare la risposta. Quando l'operazione non richiede risposta, il messaggio diventa una *notifica* (vedi sotto) e l'`id` viene omesso.

### 1.5.2 La risposta (response)

La risposta a una richiesta riporta lo stesso `id` e il risultato nel campo `result`:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      { "type": "text", "text": "hello ciao" }
    ],
    "isError": false
  }
}
```

### 1.5.3 La variante di errore della risposta

In caso di errore a livello di protocollo, la risposta contiene un campo `error` al posto di `result`. Non è un quarto tipo di messaggio, ma una variante della response:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": -32602,
    "message": "Invalid params"
  }
}
```

I codici di errore standard di JSON-RPC, che MCP riusa, sono:

| Codice | Significato |
|--------|-------------|
| -32700 | Parse error |
| -32600 | Invalid request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |

A questi MCP aggiunge codici specifici, come `-32002` (resource not found) o `-32022` (unsupported protocol version). Nell'SDK .NET questi valori sono raccolti nell'enumerazione `McpErrorCode`, che useremo nella sezione sulla gestione degli errori.

Un errore durante l'esecuzione di un tool è diverso: `tools/call` restituisce comunque un `result`, il cui `CallToolResult` segnala `isError: true`.

### 1.5.4 La notifica (notification)

Una notifica è una richiesta *senza* `id`: il destinatario la esegue ma non deve rispondere. Si usa per eventi unidirezionali. L'esempio più importante è la notifica di inizializzazione completata:

```json
{
  "jsonrpc": "2.0",
  "method": "notifications/initialized",
  "params": {}
}
```

### 1.5.5 I metodi standard di MCP

Sopra JSON-RPC, MCP definisce una serie di metodi con nomi a barre (`risorsa/azione`). I più importanti, lato server:

| Metodo | Scopo |
|--------|-------|
| `initialize` | Avvia la sessione e negozia le capabilities |
| `notifications/initialized` | Notifica che l'inizializzazione è conclusa |
| `ping` | Verifica che la connessione sia viva |
| `tools/list` | Elenca i tool disponibili |
| `tools/call` | Invoca un tool |
| `resources/list` | Elenca le risorse |
| `resources/read` | Legge una risorsa |
| `resources/templates/list` | Elenca i template di risorsa |
| `prompts/list` | Elenca i prompt |
| `prompts/get` | Ottiene un prompt |
| `logging/setLevel` | Imposta il livello di log |
| `completion/complete` | Richiede completamenti |

Il bello di lavorare con l'SDK .NET è che **non dovremo mai scrivere questi messaggi a mano**: l'SDK li genera e li interpreta per noi. Conoscerli, però, è essenziale per il debugging, per leggere i log e per capire cosa succede "sotto il cofano". Inoltre, quando useremo l'MCP Inspector o un client generico, sarà naturale ragionare in termini di questi metodi.

### 1.5.6 Un esempio completo di scambio

Mettiamo insieme i pezzi per vedere una sessione minima. Il client apre la connessione e invia l'inizializzazione:

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{
  "protocolVersion":"2025-06-18",
  "capabilities":{},
  "clientInfo":{"name":"book-test","version":"1.0"}
}}
```

Il server risponde con le proprie informazioni e capacità:

```json
{"jsonrpc":"2.0","id":1,"result":{
  "protocolVersion":"2025-06-18",
  "capabilities":{"tools":{}},
  "serverInfo":{"name":"McpTest","version":"1.0.0.0"}
}}
```

Il client notifica che l'inizializzazione è completa e poi elenca i tool:

```json
{"jsonrpc":"2.0","method":"notifications/initialized","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
```

Il server risponde con l'elenco (nota il nome in minuscolo, un dettaglio dell'SDK che documenteremo):

```json
{"jsonrpc":"2.0","id":2,"result":{"tools":[
  {"name":"echo","description":"Echoes the message back to the client.",
   "inputSchema":{"type":"object","properties":{
      "message":{"type":"string","description":"The message to echo."}},
    "required":["message"]}}
]}}
```

Infine il client invoca il tool:

```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{
  "name":"echo","arguments":{"message":"mondo"}}}
```

E il server restituisce il risultato:

```json
{"jsonrpc":"2.0","id":3,"result":{
  "content":[{"type":"text","text":"hello mondo"}],
  "isError":false
}}
```

Questo scambio, pur minimale, contiene tutto il DNA di MCP. Lo rivedremo realizzato davvero, byte per byte, quando eseguiremo il nostro primo server.
