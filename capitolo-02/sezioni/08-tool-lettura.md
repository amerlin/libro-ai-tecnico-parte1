## 2.8 I tool di lettura

Veniamo al cuore del capitolo: i tool. Iniziamo dalle **letture**, che sono le operazioni più frequenti e quelle in cui LINQ dà il meglio.

### 2.8.1 La classe dei tool

La classe riceve la factory nel costruttore e la usa per creare un contesto per ogni invocazione:

```csharp
using Microsoft.EntityFrameworkCore;
using ModelContextProtocol.Server;
using System.ComponentModel;

[McpServerToolType]
public sealed class CatalogTool(IDbContextFactory<CatalogDbContext> factory)
{
    // I tool possono usare direttamente il parametro del costruttore primario.
}
```

Il costruttore primario riceve la factory; i parametri del costruttore primario sono accessibili direttamente nei metodi della classe (come abbiamo già visto con `HttpClient` nel Capitolo 1), quindi non serve dichiarare campi aggiuntivi.

### 2.8.2 Elencare i prodotti

```csharp
[McpServerTool(Name = "list_products"), Description("Lists all products, optionally filtered by category name.")]
public async Task<ProductDto[]> ListProducts(
    [Description("Optional category name filter.")] string? category = null,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    IQueryable<Product> query = db.Products;

    if (category is not null)
        query = query.Where(p => p.Category!.Name == category);

    return await query
        .OrderBy(p => p.Name)
        .Select(p => new ProductDto(p.Id, p.Name, p.Price, p.Category!.Name))
        .ToArrayAsync(cancellationToken);
}
```

Analizziamolo:

- **`CreateDbContextAsync`** crea un contesto nuovo; `await using` ne garantisce la corretta chiusura (rilascia la connessione) a fine metodo.
- Con la proiezione in **`Select`**, `Include(p => p.Category)` è superfluo: EF Core traduce l'accesso a `p.Category.Name` nella query SQL della proiezione. È la proiezione, non `Include`, a evitare query aggiuntive.
- **Filtro condizionale**: se `category` è `null`, la clausola `Where` non viene aggiunta; altrimenti filtriamo per nome. La query è composta prima, eseguita dopo.
- **Proiezione con `Select`**: invece delle entità restituiamo un `ProductDto` per riga, con il nome della categoria "appiattito".
- **`ToArrayAsync`** materializza la query (la esegue) e restituisce l'array; `cancellationToken` annulla sia la query sia la creazione del contesto.

### 2.8.3 Cercare per nome

```csharp
[McpServerTool(Name = "search_products"), Description("Searches products whose name contains the given text.")]
public async Task<ProductDto[]> SearchProducts(
    [Description("Text to search in product names.")] string term,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    return await db.Products
        .Where(p => p.Name.Contains(term))
        .OrderBy(p => p.Name)
        .Select(p => new ProductDto(p.Id, p.Name, p.Price, p.Category!.Name))
        .ToArrayAsync(cancellationToken);
}
```

`Contains` viene tradotto in un `LIKE '%term%'` (con SQLite è case-insensitive per i caratteri ASCII): utile per la ricerca "fuzzy" che un modello spesso richiede.

### 2.8.4 Ottenere un singolo prodotto

```csharp
[McpServerTool(Name = "get_product"), Description("Gets a single product by id.")]
public async Task<ProductDto?> GetProduct(
    [Description("Product id.")] int id,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    return await db.Products
        .Where(p => p.Id == id)
        .Select(p => new ProductDto(p.Id, p.Name, p.Price, p.Category!.Name))
        .FirstOrDefaultAsync(cancellationToken);
}
```

Restituiamo `ProductDto?`: se il prodotto non esiste, il risultato è `null`, e il modello potrà dire all'utente "non ho trovato il prodotto 42". In alternativa si può lanciare una `McpException` (come vedremo per le scritture); per le letture, un `null` è spesso la scelta più naturale.

### 2.8.5 Schema generato

Come visto nel Capitolo 1, l'SDK genera lo schema di input dai parametri. Per `ListProducts` produrrà, in sostanza:

```json
{
  "type": "object",
  "properties": {
    "category": {
      "description": "Optional category name filter.",
      "type": ["string", "null"],
      "default": null
    }
  }
}
```

Il parametro nullable con default diventa opzionale e può essere `null`: il modello potrà chiamare `list_products` senza argomenti oppure con `{"category": "Books"}`.

### 2.8.6 Un'osservazione sulle performance

Ogni invocazione crea un contesto e una connessione nuova. Per SQLite (file locale) il costo è irrisorio. Per database remoti (SQL Server, PostgreSQL) il **connection pooling** del provider rende comunque efficiente questa creazione: la connessione fisica viene riusata da un pool, e il contesto logico è leggero. Il pattern factory, quindi, non è un lusso da prototipo: è la soluzione di produzione.
