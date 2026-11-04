## 1.17 Server HTTP con ASP.NET Core

Finora abbiamo usato il trasporto `stdio`, ideale per un server locale lanciato dal client. Quando il server deve essere **condiviso**, raggiungibile via rete o eseguito dietro un proxy, si usa il trasporto **Streamable HTTP**, che l'SDK .NET integra direttamente con ASP.NET Core.

### 1.17.1 Il pacchetto aggiuntivo

Per il trasporto HTTP serve il pacchetto dedicato:

```bash
> dotnet add package ModelContextProtocol.AspNetCore --version 2.3.0
```

Questo pacchetto referenzia già `ModelContextProtocol`, quindi non serve aggiungerlo separatamente.

### 1.17.2 Il codice completo

Partiamo da un progetto ASP.NET Core *empty* (o *minimal API*), e trasformiamolo in un MCP server HTTP:

```csharp
using System.ComponentModel;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithTools<EchoTool>()
    .WithResources<AppResources>()
    .WithPrompts<AppPrompts>();

var app = builder.Build();

// Mappa l'endpoint MCP (Streamable HTTP) su /mcp.
app.MapMcp("/mcp");

await app.RunAsync();

[McpServerToolType]
public sealed class EchoTool
{
    [McpServerTool, Description("Echoes the message back to the client.")]
    public static string Echo([Description("The message to echo.")] string message)
        => $"hello {message}";
}

[McpServerResourceType]
public sealed class AppResources
{
    [McpServerResource(UriTemplate = "config://app", Name = "AppConfig")]
    [Description("Application configuration.")]
    public static string GetConfig() => "{\"name\":\"http-demo\"}";
}

[McpServerPromptType]
public sealed class AppPrompts
{
    [McpServerPrompt, Description("Creates a code review prompt.")]
    public static string ReviewCode([Description("The code to review.")] string code)
        => $"Please review the following code:\n\n{code}";
}
```

### 1.17.3 Le differenze rispetto a stdio

Tre sole differenze rispetto al server `stdio`:

1. usiamo `WebApplication.CreateBuilder` invece di `Host.CreateApplicationBuilder`, perché vogliamo un web server;
2. selezioniamo il trasporto con `WithHttpTransport()` invece di `WithStdioServerTransport()`;
3. mappiamo l'endpoint con `app.MapMcp("/mcp")`.

Non serve `builder.Logging.ClearProviders()`: su HTTP i log non interferiscono con il canale di comunicazione, e vederli in console è anzi utile.

### 1.17.4 Il percorso dell'endpoint

Il percorso passato a `MapMcp` deve corrispondere a quello usato nell'URL del client e dell'Inspector. In questo esempio l'endpoint è `/mcp`, quindi l'URL è `http://localhost:5080/mcp`:

```csharp
app.MapMcp("/mcp");
```

Se vuoi mappare l'endpoint alla radice dell'applicazione, puoi usare `app.MapMcp()` come variante; in quel caso il client dovrà puntare a `http://localhost:5080/`.

### 1.17.5 Eseguire e provare

Avviamo il server specificando una porta:

```bash
> dotnet run --urls http://localhost:5080
```

Il server è ora un normale endpoint HTTP. Un client MCP configurato con l'URL `http://localhost:5080/mcp` potrà connettersi, eseguire l'handshake e usare tool, risorse e prompt. Nella sezione sulla configurazione dei client vedremo esattamente come indicare l'URL.

### 1.17.6 Streamable HTTP e modalità stateless

Come accennato, Streamable HTTP supporta una **modalità stateless**, in cui ogni richiesta è indipendente e il server non mantiene sessioni persistenti. È utile per scenari ad alta scalabilità orizzontale. L'SDK la espone tramite le opzioni del trasporto:

```csharp
builder.Services.AddMcpServer()
    .WithHttpTransport(options => options.SessionMode = HttpServerSessionMode.Stateless)
    .WithTools<EchoTool>();
```

Nella modalità stateless, ogni richiesta crea un contesto server "fresco": va usata solo se i tuoi tool sono effettivamente privi di stato (nessuna sessione, nessun dato in memoria tra una chiamata e l'altra). La modalità predefinita è invece *stateful*, adatta alla maggior parte dei casi.

### 1.17.7 Coesistere con altre API

`MapMcp` convive senza problemi con gli altri endpoint dell'applicazione. Puoi quindi avere, nello stesso processo, sia le tue Minimal API REST sia l'endpoint MCP:

```csharp
app.MapGet("/health", () => Results.Ok("healthy"));
app.MapMcp("/mcp");
```

È la materializzazione del principio espresso nella sezione di confronto: **REST e MCP non si escludono**, anzi spesso vivono nella stessa applicazione, ognuno con il proprio ruolo.
