## 2.11 Il server stdio completo

Mettiamo insieme tutti i pezzi. Il listato che segue è il `Program.cs` completo del nostro server: configurazione, creazione del database con semina, registrazione dei servizi, classe del tool. È il file che puoi compilare ed eseguire così com'è.

### 2.11.1 Il codice completo

```csharp
using System.ComponentModel;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol;
using ModelContextProtocol.Server;

var builder = Host.CreateApplicationBuilder(args);

// Su stdio lo stdout è del protocollo: niente log su console.
builder.Logging.ClearProviders();

// Registra la factory del DbContext (un contesto nuovo per ogni tool).
builder.Services.AddDbContextFactory<CatalogDbContext>(options =>
    options.UseSqlite("Data Source=catalog.db"));

// Registra il server MCP e il suo tool.
builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithTools<CatalogTool>();

// Crea il database e semina i dati di esempio (solo per l'esempio).
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

await builder.Build().RunAsync();

// ---- Entità ----
public sealed class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Product> Products { get; set; } = [];
}

public sealed class Product
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public Category? Category { get; set; }
}

// ---- DbContext ----
public sealed class CatalogDbContext(DbContextOptions<CatalogDbContext> options)
    : DbContext(options)
{
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>().Property(p => p.Price).HasPrecision(18, 2);
        modelBuilder.Entity<Category>().HasIndex(c => c.Name).IsUnique();
    }
}

// ---- Tool ----
[McpServerToolType]
public sealed class CatalogTool(IDbContextFactory<CatalogDbContext> factory)
{
    [McpServerTool(Name = "list_products"), Description("Lists all products, optionally filtered by category name.")]
    public async Task<ProductDto[]> ListProducts(
        [Description("Optional category name filter.")] string? category = null,
        CancellationToken cancellationToken = default)
    {
        await using var db = await factory.CreateDbContextAsync(cancellationToken);
        IQueryable<Product> query = db.Products;
        if (category is not null)
            query = query.Where(p => p.Category!.Name == category);
        return await query.OrderBy(p => p.Name)
            .Select(p => new ProductDto(p.Id, p.Name, p.Price, p.Category!.Name))
            .ToArrayAsync(cancellationToken);
    }

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

    [McpServerTool(Name = "create_product"), Description("Creates a new product in an existing category.")]
    public async Task<string> CreateProduct(
        [Description("Product name.")] string name,
        [Description("Product price.")] decimal price,
        [Description("Category name.")] string categoryName,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new McpException("Product name cannot be empty.");
        if (price < 0)
            throw new McpException("Price cannot be negative.");

        await using var db = await factory.CreateDbContextAsync(cancellationToken);
        var category = await db.Categories.FirstOrDefaultAsync(c => c.Name == categoryName, cancellationToken)
            ?? throw new McpException($"Category not found: {categoryName}");
        var product = new Product { Name = name, Price = price, CategoryId = category.Id };
        db.Products.Add(product);
        await db.SaveChangesAsync(cancellationToken);
        return $"created product '{name}' (id {product.Id})";
    }

    [McpServerTool(Name = "update_price"), Description("Updates the price of an existing product.")]
    public async Task<string> UpdatePrice(
        [Description("Product id.")] int id,
        [Description("New price.")] decimal newPrice,
        CancellationToken cancellationToken = default)
    {
        if (newPrice < 0)
            throw new McpException("Price cannot be negative.");

        await using var db = await factory.CreateDbContextAsync(cancellationToken);
        var product = await db.Products.FindAsync([id], cancellationToken)
            ?? throw new McpException($"Product not found: {id}");
        product.Price = newPrice;
        await db.SaveChangesAsync(cancellationToken);
        return $"updated price of product {id} to {newPrice}";
    }

    [McpServerTool(Name = "delete_product", Destructive = true),
     Description("Deletes a product by id. This operation cannot be undone.")]
    public async Task<string> DeleteProduct(
        [Description("Product id.")] int id,
        CancellationToken cancellationToken = default)
    {
        await using var db = await factory.CreateDbContextAsync(cancellationToken);
        var product = await db.Products.FindAsync([id], cancellationToken)
            ?? throw new McpException($"Product not found: {id}");
        db.Products.Remove(product);
        await db.SaveChangesAsync(cancellationToken);
        return $"deleted product {id}";
    }
}

public sealed record ProductDto(int Id, string Name, decimal Price, string Category);
```

### 2.11.2 Eseguire e provare

Avviamo il server:

```bash
> dotnet run
```

E collaudiamolo con una sessione JSON-RPC manuale oppure, meglio, con l'MCP Inspector. Un esempio di chiamata:

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{
  "name":"list_products",
  "arguments":{"category":"Books"}
}}
```

Il server risponderà con l'elenco dei prodotti della categoria "Books", proiettati nel DTO.

### 2.11.3 Osservazioni sul codice completo

- Questo listato è una **demo non destinata alla produzione**: `EnsureCreated` e la semina idempotente preparano il database se necessario, senza cancellarlo a ogni avvio. Per usare migrazioni, rimuovi l'inizializzazione dimostrativa e applicale con `dotnet ef`; non inserire `EnsureDeleted` nel codice di avvio, perché EF Core può eseguirlo anche in fase di design.
- La classe del tool espone sei strumenti: elenco, ricerca, lettura singola, creazione, aggiornamento del prezzo e cancellazione. Mantieni in `Name` lo stesso nome snake_case atteso dal client.
- Tutto il codice è stato compilato ed eseguito con .NET 10 e i pacchetti indicati: il round-trip completo (creazione database, semina, `list_products`, `create_product`, `delete_product`) è stato verificato.

### 2.11.4 Separare i file

In un progetto reale, `Program.cs` non dovrebbe contenere tutto. Una struttura pulita è:

![Struttura consigliata del progetto `CatalogMcpServer`](figure/struttura-progetto.pdf)

La logica non cambia: cambia solo l'organizzazione. Nel libro teniamo tutto insieme per leggibilità, ma nei tuoi progetti separa per responsabilità.
