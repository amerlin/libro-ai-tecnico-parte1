## 1.14 Esempio pratico: un server meteo con HTTP

Il secondo esempio mostra come un MCP server possa **integrare un'API esterna**: il tool esporrà al modello le previsioni meteo, ottenute chiamando un servizio HTTP pubblico. È il pattern "MCP sopra una REST API" che abbiamo descritto nella sezione di confronto, e introduce due concetti nuovi: l'iniezione di un `HttpClient` tipizzato e la gestione di una risposta JSON.

### 1.14.1 La scelta dell'API

Per l'esempio useremo **Open-Meteo** (`https://api.open-meteo.com/`), un servizio meteo gratuito che non richiede chiave API. L'endpoint che useremo è:

```text
GET https://api.open-meteo.com/v1/forecast
    ?latitude=41.89&longitude=12.49&current=temperature_2m
```

La risposta è un JSON che contiene, tra le altre cose, la temperatura corrente:

```json
{
  "current": {
    "temperature_2m": 18.4
  }
}
```

### 1.14.2 Il codice completo

Creiamo un nuovo progetto console e aggiungiamo il pacchetto, come già visto. Il server espone un unico tool, `get_temperature`, che accetta latitudine e longitudine:

```csharp
using System.ComponentModel;
using System.Text.Json;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol;
using ModelContextProtocol.Server;

var builder = Host.CreateApplicationBuilder(args);

// Su stdio lo stdout è del protocollo.
builder.Logging.ClearProviders();

// Registra un HttpClient tipizzato per il servizio meteo.
builder.Services.AddHttpClient<WeatherTool>(client =>
    client.BaseAddress = new Uri("https://api.open-meteo.com/"));

builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<WeatherTool>();

await builder.Build().RunAsync();

[McpServerToolType]
public sealed class WeatherTool(HttpClient http)
{
    [McpServerTool, Description("Gets the current temperature for a location.")]
    public async Task<string> GetTemperature(
        [Description("Latitude of the location.")] double latitude,
        [Description("Longitude of the location.")] double longitude,
        CancellationToken cancellationToken = default)
    {
        var url = $"v1/forecast?latitude={latitude}" +
                  $"&longitude={longitude}&current=temperature_2m";
        var json = await http.GetStringAsync(url, cancellationToken);

        using var doc = JsonDocument.Parse(json);
        var temperature = doc.RootElement
            .GetProperty("current")
            .GetProperty("temperature_2m")
            .GetDouble();

        return $"Current temperature: {temperature:F1} °C";
    }
}
```

### 1.14.3 Lettura guidata

**L'`HttpClient` tipizzato.** `AddHttpClient<WeatherTool>(...)` registra nel container un `HttpClient` configurato con il base address del servizio, e lo associa alla classe `WeatherTool`. Grazie al **costruttore primario** (`WeatherTool(HttpClient http)`), l'istanza riceve automaticamente il client quando viene creata. Questo è il modo idiomatico .NET per gestire le chiamate HTTP: l'`HttpClient` è riusato, gestito e disposto correttamente dal container.

**Il tool asincrono.** `GetTemperature` è `async` e accetta un `CancellationToken`: come spiegato, l'SDK lo inietta automaticamente e lo esclude dallo schema di input. I veri argomenti esposti al modello sono solo `latitude` e `longitude`.

**La lettura del JSON.** Usiamo `System.Text.Json` (già incluso nel runtime) per estrarre la temperatura. In un'applicazione reale useresti classi fortemente tipizzate e `GetFromJsonAsync<T>`, ma la lettura manuale con `JsonDocument` rende esplicito il formato della risposta, utile a scopo didattico.

**Il risultato.** Il tool restituisce una stringa leggibile, che il modello potrà citare direttamente nella risposta all'utente: "La temperatura corrente è 18.4 °C".

### 1.14.4 Gestire gli errori dell'API esterna

Nel codice sopra, se il servizio meteo non risponde, l'eccezione di rete si propaga e l'SDK restituisce un errore generico del tool. È più elegante intercettare gli errori e restituire un messaggio chiaro. Lo faremo in modo sistematico nella sezione sulla gestione degli errori; per ora anticipiamo il concetto con un frammento:

```csharp
try
{
    var json = await http.GetStringAsync(url, cancellationToken);
    // ... parsing ...
    return $"Current temperature: {temperature:F1} °C";
}
catch (HttpRequestException ex)
{
    throw new McpException($"Weather service unavailable: {ex.Message}");
}
```

Qui `McpException` (namespace `ModelContextProtocol`) segnala un errore del tool: l'SDK lo restituisce al client nel `CallToolResult` con `isError: true` e un messaggio comprensibile. Non è un errore JSON-RPC di protocollo, che viene rappresentato separatamente dal campo `error`.

### 1.14.5 Provare il server

Avviamo il server e invochiamo il tool per Roma (latitudine 41.89, longitudine 12.49):

```json
{"jsonrpc":"2.0","id":9,"method":"tools/call","params":{
  "name":"get_temperature",
  "arguments":{"latitude":41.89,"longitude":12.49}
}}
```

Il server chiama Open-Meteo e risponde con la temperatura corrente. Il modello, da parte sua, sa quando usare questo tool perché la descrizione dichiara chiaramente cosa fa e quali parametri richiede: è l'autodescrizione di MCP in azione.
