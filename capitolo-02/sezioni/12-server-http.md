## 2.12 Il server HTTP completo

Se il catalogo deve essere condiviso tra più utenti o macchine, il trasporto `stdio` non basta: serve HTTP. Come nel Capitolo 1, il passaggio è questione di pochi ritocchi.

### 2.12.1 Il pacchetto aggiuntivo

```bash
> dotnet add package ModelContextProtocol.AspNetCore --version 2.3.0
```

### 2.12.2 Le differenze rispetto a stdio

Tre modifiche al codice precedente:

1. `WebApplication.CreateBuilder` al posto di `Host.CreateApplicationBuilder`;
2. `WithHttpTransport()` al posto di `WithStdioServerTransport()`;
3. `app.MapMcp("/mcp")` per mappare l'endpoint sullo stesso percorso usato dai client.

Tutto il resto — entità, `DbContext`, tool — resta **identico** alla sezione 2.11: i metodi dei tool dichiarano esplicitamente il nome pubblico, per esempio `[McpServerTool(Name = "list_products")]`. È la riprova del valore del protocollo: il codice di dominio non dipende dal trasporto.

```csharp
using System.ComponentModel;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using ModelContextProtocol;
using ModelContextProtocol.Server;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContextFactory<CatalogDbContext>(options =>
    options.UseSqlite("Data Source=catalog.db"));

builder.Services.AddMcpServer()
    .WithHttpTransport()
    .WithTools<CatalogTool>();

var app = builder.Build();

// Inizializzazione dimostrativa, come nella versione stdio; non cancella il database.
{
    var options = new DbContextOptionsBuilder<CatalogDbContext>()
        .UseSqlite("Data Source=catalog.db").Options;
    await using var seedDb = new CatalogDbContext(options);
    await seedDb.Database.EnsureCreatedAsync();

    if (!await seedDb.Products.AnyAsync())
    {
        var books = await seedDb.Categories.SingleOrDefaultAsync(c => c.Name == "Books")
            ?? new Category { Name = "Books" };
        var electronics = await seedDb.Categories.SingleOrDefaultAsync(c => c.Name == "Electronics")
            ?? new Category { Name = "Electronics" };
        seedDb.Products.AddRange(
            new Product { Name = "The Lord of the Rings", Price = 29.90m, Category = books },
            new Product { Name = "MacBook Air", Price = 1199.00m, Category = electronics });
        await seedDb.SaveChangesAsync();
    }
}

app.MapMcp("/mcp");

await app.RunAsync();

// ... entità, DbContext e CatalogTool identici alla versione stdio ...
```

### 2.12.3 Avviare e collegare

Avviamo il server su una porta:

```bash
> dotnet run --urls http://localhost:5080
```

Il client (Claude Desktop, VS Code o l'Inspector) userà l'URL `http://localhost:5080/mcp`. La configurazione per Claude Desktop, per esempio:

```json
{
  "mcpServers": {
    "catalog": {
      "url": "http://localhost:5080/mcp"
    }
  }
}
```

### 2.12.4 Considerazioni per il database in HTTP

Come il listato `stdio`, anche questo è un esempio didattico, non una configurazione di produzione. `EnsureCreated` non sostituisce le migrazioni: per usare `dotnet ef`, rimuovi il blocco dimostrativo di inizializzazione e applica le migrazioni separatamente. Non aggiungere `EnsureDeleted` al codice eseguito all'avvio, perché può essere eseguito anche quando gli strumenti EF Core caricano l'app in fase di design.

Con un server HTTP condiviso, il database diventa una **risorsa concorrente**: più richieste possono arrivare contemporaneamente. Qui il pattern `IDbContextFactory` dà il meglio di sé: ogni richiesta crea il proprio contesto, e SQLite (o il provider scelto) gestisce la concorrenza a livello di file o di server. Due accortezze:

- per SQLite, in scenari ad alta concorrenza di scrittura, valuta di abilitare il **WAL** (Write-Ahead Logging) per ridurre i blocchi;
- per database server (SQL Server, PostgreSQL), la concorrenza è gestita dal motore, e il pooling delle connessioni rende tutto fluido.

### 2.12.5 Un consiglio di architettura

Se il catalogo deve servire sia un'applicazione tradizionale sia un agente AI, non duplicare la logica: costruisci le tue **REST API** per l'applicazione e un **MCP server** che usa lo stesso `DbContext` (o gli stessi servizi applicativi) per l'agente. Come discusso nel Capitolo 1, REST e MCP sono complementari, e condividere il livello dati è la scelta che massimizza la coerenza e minimizza la manutenzione.
