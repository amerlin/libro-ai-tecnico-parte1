## 1.9 L'ecosistema .NET: pacchetti e namespaces

Il C# SDK ufficiale di MCP è distribuito su NuGet attraverso una famiglia di pacchetti. Conoscerla è importante per aggiungere al progetto solo ciò che serve, senza dipendenze inutili.

### 1.9.1 I pacchetti

| Pacchetto | Scopo |
|-----------|-------|
| `ModelContextProtocol.Core` | API di basso livello: client, server "nudo", trasporti, attributi. Dipendenze minime. |
| `ModelContextProtocol` | Pacchetto principale con le estensioni di *hosting* e *dependency injection*. Referenzia `Core`. È la scelta giusta per quasi tutti i progetti che non hanno bisogno di HTTP. |
| `ModelContextProtocol.AspNetCore` | Libreria per i server MCP basati su HTTP. Referenzia `ModelContextProtocol`. |
| `ModelContextProtocol.Extensions.Apps` | Estensione per costruire interfacce utente interattive renderizzate dentro gli host MCP. |
| `ModelContextProtocol.Extensions.Tasks` | Estensione per eseguire tool di lunga durata in modo asincrono, con polling dello stato. |

Per il nostro lavoro useremo due pacchetti: `ModelContextProtocol` (per il server `stdio`) e `ModelContextProtocol.AspNetCore` (per il server HTTP).

> **Versione.** Al momento in cui scriviamo, l'ultima versione stabile è la **2.3.0**, e targetizza .NET 8, .NET 9 e .NET 10. Le API sono in evoluzione: se usi una versione diversa, verifica sempre la documentazione di riferimento (`csharp.sdk.modelcontextprotocol.io`).

### 1.9.2 I namespaces principali

L'SDK organizza i tipi in namespaces chiari:

- `ModelContextProtocol.Server` — i tipi lato server: gli attributi `[McpServerTool]`, `[McpServerPrompt]`, `[McpServerResource]` e i rispettivi attributi di tipo, oltre a `McpServerOptions` e `McpServer`.
- `Microsoft.Extensions.DependencyInjection` — le estensioni di configurazione: `AddMcpServer()`, `WithTools<T>()`, `WithPrompts<T>()`, `WithResources<T>()`, `WithStdioServerTransport()` e (dal pacchetto ASP.NET Core) `WithHttpTransport()`.
- `Microsoft.AspNetCore.Builder` — l'estensione `MapMcp()` per mappare l'endpoint HTTP.
- `ModelContextProtocol.Client` — i tipi lato client (`McpClient`, i trasporti client), utili per scrivere test o client .NET.
- `ModelContextProtocol.Protocol` — i tipi del protocollo a basso livello (messaggi, risultati).

### 1.9.3 Gli attributi di registrazione

L'SDK adotta un approccio dichiarativo: si espongono le funzionalità marcando metodi e classi con attributi. La mappatura è:

| Attributo | Applicato a | Effetto |
|-----------|-------------|---------|
| `[McpServerToolType]` | Classe | Segnala che la classe contiene dei tool |
| `[McpServerTool]` | Metodo | Espone il metodo come tool |
| `[McpServerPromptType]` | Classe | Segnala che la classe contiene dei prompt |
| `[McpServerPrompt]` | Metodo | Espone il metodo come prompt |
| `[McpServerResourceType]` | Classe | Segnala che la classe contiene delle risorse |
| `[McpServerResource]` | Metodo | Espone il metodo come risorsa |

Le descrizioni (fondamentali, come abbiamo detto) si esprimono con l'attributo standard di .NET `[Description]`, sia sul metodo sia sui parametri. Vedremo subito esempi concreti.

### 1.9.4 Il modello di hosting

L'SDK si integra con il sistema di **dependency injection** di .NET: il server MCP viene registrato come servizio, i tool vengono istanziati dal container (quindi possono ricevere dipendenze nel costruttore, come un `HttpClient` o un `ILogger`), e il trasporto viene scelto con un metodo dedicato.

Questo significa che i nostri server avranno la stessa struttura di una qualunque applicazione .NET moderna: un *builder*, una configurazione dei servizi, e un `RunAsync()` finale. Non c'è nulla di esoterico: se conosci `Host.CreateApplicationBuilder` e `WebApplication.CreateBuilder`, sei già a casa.

### 1.9.5 Versioni e compatibilità con .NET 10

.NET 10 è la versione Long Term Support (LTS) corrente della piattaforma .NET. L'SDK MCP 2.3.0 la supporta ufficialmente (il pacchetto contiene una build per `net10.0`). Nel resto del capitolo assumeremo .NET 10, ma tutto il codice è identico su .NET 8 e .NET 9, a meno di indicazioni contrarie.
