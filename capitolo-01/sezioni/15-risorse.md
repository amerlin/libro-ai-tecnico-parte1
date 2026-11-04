## 1.15 Le Risorse

Se i tool sono le "azioni" del server, le **risorse** sono i suoi "documenti": dati esposti con un URI e letti dal client (o dall'host) per arricchire il contesto del modello. Vediamo come esporle con l'SDK .NET.

### 1.15.1 Una risorsa semplice

Una risorsa è un metodo marcato con `[McpServerResource]`, all'interno di una classe marcata con `[McpServerResourceType]`. La proprietà `UriTemplate` definisce l'identificatore:

```csharp
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;

var builder = Host.CreateApplicationBuilder(args);
builder.Logging.ClearProviders();

builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithResources<AppResources>();

await builder.Build().RunAsync();

[McpServerResourceType]
public sealed class AppResources
{
    [McpServerResource(UriTemplate = "config://app", Name = "AppConfig")]
    [Description("Application configuration in JSON format.")]
    public static string GetConfig()
        => "{\"name\":\"demo\",\"version\":\"1.0.0\"}";
}
```

Il client può ora elencare le risorse (`resources/list`) e leggerle (`resources/read` con l'URI `config://app`). La risorsa restituisce una stringa; l'SDK la incapsula in un contenuto di testo con tipo MIME `text/plain` (personalizzabile tramite la proprietà `MimeType` dell'attributo).

### 1.15.2 I template di risorsa parametrizzati

Spesso una risorsa rappresenta un *insieme* di dati dello stesso tipo: un documento per ogni cliente, una pagina per ogni articolo. In questi casi si usa un **template**, in cui l'URI contiene dei segnaposto racchiusi tra graffe:

```csharp
[McpServerResource(UriTemplate = "docs://clients/{id}", Name = "ClientDocument")]
[Description("The document of a client, identified by id.")]
public static string GetClientDocument(string id)
    => $"Document content for client {id}";
```

I segnaposto del template corrispondono ai **parametri del metodo**: quando il client legge `docs://clients/42`, l'SDK invoca `GetClientDocument("42")`. La risorsa può dichiarare un `MimeType` specifico, per esempio `application/json` o `text/markdown`:

```csharp
[McpServerResource(UriTemplate = "docs://clients/{id}", Name = "ClientDocument", MimeType = "text/markdown")]
[Description("The document of a client, identified by id.")]
public static string GetClientDocument(string id)
    => $"# Client {id}\n\nContenuto del documento.";
```

### 1.15.3 Risorse e sottoscrizioni

MCP prevede che un client possa **sottoscriversi** ai cambiamenti di una risorsa (`resources/subscribe`), ricevendo una notifica quando il contenuto cambia (`notifications/resources/updated`). È la base per scenari in cui il modello deve essere aggiornato quando, per esempio, un file viene modificato o un record viene aggiornato. L'SDK .NET supporta queste operazioni tramite handler configurabili; per i nostri scopi introduttivi è sufficiente sapere che esistono.

### 1.15.4 Tool o risorsa?

La regola pratica per scegliere:

- se il dato deve essere **letto dal modello quando serve**, un **tool** di lettura va benissimo e spesso è più semplice;
- se il dato è **parte stabile del contesto** (configurazioni, documentazione, dati di riferimento) che il client può caricare in modo proattivo, una **risorsa** è più appropriata;
- se il dato cambia nel tempo e vuoi **notificare** i cambiamenti, le risorse con sottoscrizione sono la scelta naturale.

Nella pratica molti server espongono la stessa informazione in entrambi i modi: un tool per la lettura on-demand e una risorsa per l'accesso dichiarativo.

### 1.15.5 Il tipo MIME giusto

Il campo `MimeType` aiuta il client a interpretare il contenuto. Valori comuni:

| Tipo MIME | Uso |
|-----------|-----|
| `text/plain` | Testo semplice (default) |
| `text/markdown` | Documenti Markdown |
| `application/json` | Dati strutturati |
| `text/html` | Pagine HTML |
| `image/png`, `image/jpeg` | Immagini |

Le risorse binarie (come le immagini) richiedono di restituire byte; l'SDK supporta anche questo caso, ma per il nostro percorso introduttivo ci concentriamo sui contenuti testuali.
