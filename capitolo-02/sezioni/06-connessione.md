## 2.6 Connessione e creazione del database

Colleghiamo il `DbContext` all'applicazione e creiamo il database. Useremo due approcci: `EnsureCreated` per partire subito, e le **migrazioni** (sezione successiva) per il flusso di lavoro professionale.

### 2.6.1 La stringa di connessione

Per SQLite la stringa di connessione è semplicissima: un percorso di file.

```csharp
builder.Services.AddDbContextFactory<CatalogDbContext>(options =>
    options.UseSqlite("Data Source=catalog.db"));
```

`Data Source=catalog.db` indica il file del database, relativo alla cartella di lavoro del processo. Per un server `stdio` lanciato dal client, la cartella di lavoro è quella dichiarata nella configurazione del client; per uno lanciato a mano, la cartella corrente.

### 2.6.2 AddDbContextFactory

Nota che usiamo **`AddDbContextFactory`**, non `AddDbContext`. La differenza:

- `AddDbContext<CatalogDbContext>` registra un contesto **scoped**: pensato per essere condiviso durante una singola richiesta web, con un solo `SaveChanges` finale.
- `AddDbContextFactory<CatalogDbContext>` registra una **`IDbContextFactory<CatalogDbContext>`**: una factory che crea un contesto nuovo, indipendente, ogni volta che serve.

Come vedremo nella sezione dedicata, il factory è la scelta giusta per i tool MCP, perché ogni invocazione di tool è un'unità di lavoro isolata.

### 2.6.3 Creare lo schema con EnsureCreated

Per i prototipi, il modo più rapido per avere un database funzionante è `EnsureCreated`:

```csharp
var options = new DbContextOptionsBuilder<CatalogDbContext>()
    .UseSqlite("Data Source=catalog.db")
    .Options;
await using var db = new CatalogDbContext(options);
await db.Database.EnsureCreatedAsync();
```

`EnsureCreated` crea il database e lo schema **se non esistono**. Non usare `EnsureDeleted` all'avvio: elimina anche i dati e i comandi EF Core possono eseguire il codice di avvio in fase di design. Attenzione: `EnsureCreated` non si integra con le migrazioni — se il modello cambia, non aggiorna lo schema esistente. È uno strumento da prototipo.

### 2.6.4 Seed dei dati di esempio

Il blocco seguente è una **continuazione** del precedente: va eseguito nello stesso scope, mentre `db` è ancora aperto. Per avere qualcosa da interrogare, inseriamo due categorie e due prodotti:

```csharp
if (!await db.Products.AnyAsync())
{
    var books = await db.Categories.SingleOrDefaultAsync(c => c.Name == "Books")
        ?? new Category { Name = "Books" };
    var electronics = await db.Categories.SingleOrDefaultAsync(c => c.Name == "Electronics")
        ?? new Category { Name = "Electronics" };

    db.Products.AddRange(
        new Product { Name = "The Lord of the Rings", Price = 29.90m, Category = books },
        new Product { Name = "MacBook Air", Price = 1199.00m, Category = electronics });

    await db.SaveChangesAsync();
}
```

Nota l'uso delle **navigation property** (`Category = books`) invece della chiave esterna: EF Core risolve da solo il valore di `CategoryId` quando salva.

### 2.6.5 Dove mettere questa inizializzazione

Per un server `stdio`, conviene eseguire l'inizializzazione **prima** di avviare il server, così il database è pronto quando arrivano le prime richieste. Nel codice completo del server (sezione 2.11) vedremo il blocco di inizializzazione piazzato tra la configurazione dei servizi e `RunAsync()`.

Per creare il `DbContext` in quel punto abbiamo bisogno delle opzioni: le costruiamo a mano con `DbContextOptionsBuilder`, oppure risolviamo la factory dal container. Entrambe le strade sono valide; per l'esempio useremo la prima, più esplicita.
