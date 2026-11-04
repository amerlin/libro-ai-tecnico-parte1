## 2.9 I tool di scrittura

Le scritture sono il punto in cui un server MCP diventa potente — e pericoloso. Creazione e cancellazione vanno implementate con cura: validazione, gestione degli errori e annotazioni che informino il client della loro natura.

### 2.9.1 Creare un prodotto

```csharp
[McpServerTool(Name = "create_product"), Description("Creates a new product in an existing category.")]
public async Task<string> CreateProduct(
    [Description("Product name.")] string name,
    [Description("Product price.")] decimal price,
    [Description("Category name.")] string categoryName,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    if (string.IsNullOrWhiteSpace(name))
        throw new McpException("Product name cannot be empty.");

    if (price < 0)
        throw new McpException("Price cannot be negative.");

    var category = await db.Categories
        .FirstOrDefaultAsync(c => c.Name == categoryName, cancellationToken)
        ?? throw new McpException($"Category not found: {categoryName}");

    var product = new Product { Name = name, Price = price, CategoryId = category.Id };
    db.Products.Add(product);
    await db.SaveChangesAsync(cancellationToken);

    return $"created product '{name}' (id {product.Id})";
}
```

Punti chiave:

- cerchiamo la categoria per nome; se non esiste, lanciamo una `McpException` con un messaggio chiaro — il modello potrà riferirlo all'utente e, eventualmente, riprovare con un'altra categoria;
- creiamo il prodotto con `CategoryId` (la chiave esterna, già nota) invece di navigare la relazione: è la strada più diretta quando abbiamo già caricato la categoria;
- dopo `SaveChangesAsync`, `product.Id` contiene l'identificativo generato dal database: lo restituiamo nel messaggio.

### 2.9.2 Cancellare un prodotto

```csharp
[McpServerTool(Name = "delete_product", Destructive = true),
 Description("Deletes a product by id. This operation cannot be undone.")]
public async Task<string> DeleteProduct(
    [Description("Product id.")] int id,
    CancellationToken cancellationToken = default)
{
    if (newPrice < 0)
        throw new McpException("Price cannot be negative.");

    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    var product = await db.Products.FindAsync([id], cancellationToken)
        ?? throw new McpException($"Product not found: {id}");

    db.Products.Remove(product);
    await db.SaveChangesAsync(cancellationToken);

    return $"deleted product {id}";
}
```

Qui usiamo due accortezze:

1. **`FindAsync`** cerca per chiave primaria: è più idiomatica di `FirstOrDefaultAsync(p => p.Id == id)` e, con il tracking attivo, può evitare una query se l'entità è già in memoria.
2. **`Destructive = true`** dichiara che l'operazione è distruttiva: i client possono usare questa annotazione per chiedere conferma all'utente o applicare politiche più prudenti. È un piccolo dettaglio che fa una grande differenza in termini di sicurezza.

### 2.9.3 Gestire i vincoli del database

Il database ha l'ultima parola. Se, per esempio, tentassimo di creare un prodotto con una categoria inesistente e non avessimo il controllo esplicito, SQLite risponderebbe con un errore di vincolo di chiave esterna. Le eccezioni di EF Core (`DbUpdateException`) incapsulano questi errori: in un server robusto conviene intercettarle e tradurle in messaggi comprensibili.

Un esempio di traduzione:

```csharp
try
{
    await db.SaveChangesAsync(cancellationToken);
}
catch (DbUpdateException)
{
    throw new McpException("Could not save the product: a database constraint was violated.");
}
```

Nella pratica, i controlli espliciti (come la ricerca della categoria prima dell'inserimento) sono preferibili: prevengono l'errore invece di gestirlo.

### 2.9.4 Un tool di aggiornamento

Per completezza, ecco un aggiornamento del prezzo:

```csharp
[McpServerTool(Name = "update_price"), Description("Updates the price of an existing product.")]
public async Task<string> UpdatePrice(
    [Description("Product id.")] int id,
    [Description("New price.")] decimal newPrice,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    var product = await db.Products.FindAsync([id], cancellationToken)
        ?? throw new McpException($"Product not found: {id}");

    product.Price = newPrice;
    await db.SaveChangesAsync(cancellationToken);

    return $"updated price of product {id} to {newPrice}";
}
```

Qui il **change tracker** fa il lavoro: carichiamo l'entità (che viene tracciata), modifichiamo la proprietà e chiamiamo `SaveChangesAsync`; EF Core genera l'`UPDATE` con le sole colonne cambiate.

### 2.9.5 Validazione degli input

Gli argomenti arrivano dal modello, che può sbagliare. Oltre ai controlli di esistenza, valida i **vincoli di dominio**:

I controlli vanno applicati nel corpo del tool prima di accedere al database, come negli esempi di `CreateProduct` e `UpdatePrice`.

La regola d'oro è la stessa del Capitolo 1: lo schema dichiara i *tipi*, ma i *vincoli di business* li applichi tu. Un tool che restituisce errori chiari è un tool che il modello impara a usare bene.
