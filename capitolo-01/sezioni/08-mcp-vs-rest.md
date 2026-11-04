## 1.8 MCP vs REST API: un confronto approfondito

"Ma io ho già le mie API REST: perché dovrei usare MCP?" È la domanda più frequente, e la risposta merita una sezione intera. La chiave è capire che **non sono concorrenti**: risolvono problemi diversi e, nella maggior parte dei progetti reali, convivono.

### 1.8.1 Cos'è una REST API

Una REST API (Representational State Transfer) è uno stile architettonico per esporre risorse su HTTP. Un servizio definisce una serie di **endpoint** (URL) e di **verbi HTTP** (GET, POST, PUT, DELETE), con formati di richiesta e risposta (tipicamente JSON) documentati a mano o con specifiche come OpenAPI.

Esempio:

```text
GET    /api/customers/123
POST   /api/customers
PUT    /api/customers/123
DELETE /api/customers/123
```

Le REST API sono ottime per la comunicazione **tra software**: un'applicazione chiama un'altra applicazione in modo deterministico, tipizzato e prevedibile. Il chiamante sa *esattamente* quale endpoint invocare e quali parametri passare.

### 1.8.2 Cos'è un MCP server

Un MCP server, come abbiamo visto, espone **tool, risorse e prompt** descritti in modo autodescrittivo e *scopribili*. Il chiamante non conosce a priori gli endpoint: all'avvio chiede al server "che cosa sai fare?" e riceve un elenco di funzionalità con relative descrizioni e schemi. La decisione su *cosa* invocare spetta al **modello**, non a un programmatore che ha scritto il codice di integrazione.

### 1.8.3 La differenza fondamentale: chi decide cosa chiamare

```{=latex}
\small
```

| | REST API | MCP server |
|-------|----------|------------|
| **Consumatore** | Un'applicazione (codice scritto da un umano) | Un modello linguistico (o un client che lo assiste) |
| **Scoperta** | Documentazione, OpenAPI, a mano | Automatica (`tools/list`, `resources/list`, ...) |
| **Decisione di chiamata** | Il programmatore, a compile time | Il modello, a runtime, in base al contesto |
| **Contratto** | Endpoint + verbi + schemi specifici per servizio | Un unico protocollo per tutti i servizi |
| **Semantica** | Legata al dominio (`/customers`, `/orders`) | Generica (tool, risorse, prompt) |
| **Stato** | Stateless (di norma) | Sessione con capabilities negoziate |
| **Trasporto tipico** | HTTP | `stdio`, Streamable HTTP |

```{=latex}
\normalsize
```

In una REST API il **programmatore** decide: scrive `GET /api/weather?city=Roma` e conosce la risposta. In un MCP server il **modello** decide: gli vengono presentati i tool disponibili ("c'è un tool `get_weather` che accetta `city`") e, quando l'utente chiede "che tempo fa a Roma?", il modello capisce da solo di dover chiamare `get_weather` con `city = "Roma"`.

### 1.8.4 L'autodescrizione è il vero valore

La differenza pratica più profonda è l'**autodescrizione**. Un MCP server non espone solo funzioni: espone *descrizioni* di quelle funzioni, pensate per essere lette da un modello. Il nome, la descrizione del tool e la descrizione di ogni parametro diventano parte del "prompt di sistema" che l'host costruisce per il modello. La qualità di queste descrizioni determina la probabilità che il modello usi lo strumento correttamente.

Una REST API, per contro, è descritta da una documentazione pensata per **umani** (o, nel migliore dei casi, da una specifica OpenAPI pensata per generatori di codice). Un LLM può, in teoria, imparare a usare un'API REST leggendone la documentazione, ma questo processo è fragile e va ripetuto per ogni API.

### 1.8.5 Il problema M×N, di nuovo

Torniamo al problema M×N. Con le REST API, ogni applicazione AI deve essere integrata a mano con ogni servizio. Con MCP, ogni servizio espone una volta la propria interfaccia standard, e *tutte* le applicazioni AI che parlano MCP possono usarla senza ulteriore lavoro. È il passaggio da una complessità moltiplicativa a una complessità additiva: *M* applicazioni + *N* server, invece di *M × N* integrazioni.

### 1.8.6 Quando usare cosa

**Usa una REST API quando:**

- il consumatore è un'applicazione o un servizio, non un LLM;
- hai bisogno di controllo tipizzato, prestazioni prevedibili e semantica di dominio esplicita;
- la logica di business richiede transazioni, versioning degli endpoint, contratti stabili;
- devi esporre funzionalità a terze parti con un contratto pubblico ben definito.

**Usa un MCP server quando:**

- il consumatore è un'applicazione basata su LLM (assistenti, agenti, copiloti);
- vuoi che il modello scopra e usi i tuoi strumenti e dati senza integrazioni ad hoc;
- vuoi scrivere l'integrazione **una volta** e riusarla con qualsiasi host (Claude, VS Code, Copilot, un tuo agente);
- vuoi esporre non solo dati, ma anche azioni e template di prompt in modo uniforme.

**La combinazione vincente** è, molto spesso, **entrambi**: mantieni le tue REST API come strato applicativo, e costruisci un MCP server che vi si appoggia sopra per renderle consumabili dai modelli. È esattamente ciò che faremo nell'esempio meteo: il nostro MCP server chiamerà un'API HTTP esterna e ne esporrà il risultato come tool.

### 1.8.7 Un esempio concreto di differenza

Consideriamo il caso "cerca un volo". Con una REST API:

```text
GET /api/flights/search?from=FCO&to=JFK&date=2026-11-01
Authorization: Bearer <token>
```

Il chiamante deve conoscere l'endpoint, i parametri, l'autenticazione e il formato della risposta. Con un MCP server, il client vede invece:

```json
{
  "name": "search_flights",
  "description": "Search available flights between two airports on a given date.",
  "inputSchema": {
    "type": "object",
    "properties": {
      "from": { "type": "string", "description": "Departure airport IATA code." },
      "to":   { "type": "string", "description": "Arrival airport IATA code." },
      "date": { "type": "string", "description": "Travel date in YYYY-MM-DD." }
    },
    "required": ["from", "to", "date"]
  }
}
```

Il modello, leggendo questa descrizione, sa *da solo* come procedere quando l'utente dice "trovami un volo da Roma a New York per il primo novembre". Non c'è codice di integrazione da scrivere: c'è solo una descrizione da leggere.

### 1.8.8 Tabella di sintesi operativa

| Criterio | REST API | MCP server |
|----------|----------|------------|
| Scopo | Comunicazione tra servizi | Fornire contesto e strumenti agli LLM |
| Scoperta | Manuale/OpenAPI | Automatica via protocollo |
| Chiamante tipico | Codice applicativo | Modello linguistico |
| Flessibilità d'uso | Bassa (contratto fisso) | Alta (il modello adatta gli argomenti) |
| Riuso tra host AI | Richiede integrazione per ciascuno | Nativamente riusabile |
| Autenticazione | API key, OAuth, ecc. | OAuth 2.1 (HTTP), trust locale (stdio) |
| Ecosistema .NET | ASP.NET Core, Minimal API, ecc. | `ModelContextProtocol` + `ModelContextProtocol.AspNetCore` |

In sintesi: REST è il linguaggio dei **servizi**, MCP è il linguaggio dei **modelli**. Padroneggiare entrambi — e saperli comporre — è una delle competenze più richieste nello sviluppo di applicazioni AI moderne.
