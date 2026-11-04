## 2.2 Entity Framework Core in sintesi

Prima di scrivere codice, ripassiamo i concetti essenziali di Entity Framework Core. Se lo conosci già, puoi scorrere velocemente: serve solo ad allineare il vocabolario.

### 2.2.1 Cos'è un ORM

Entity Framework Core è un **Object-Relational Mapper** (ORM): una libreria che mappa le **entità** C# (classi) sulle **tabelle** del database e le **proprietà** sulle **colonne**. Il programmatore lavora con oggetti e LINQ; l'ORM traduce il tutto in SQL e materializza i risultati in oggetti.

Il punto di ingresso è il **`DbContext`**: una classe che rappresenta una sessione di lavoro con il database. Contiene un `DbSet<T>` per ogni entità e permette di eseguire query, inserimenti, aggiornamenti e cancellazioni, coordinati dal metodo `SaveChanges()`.

### 2.2.2 Le entità

Un'entità è una semplice classe C# con proprietà pubbliche. Per convenzione, la proprietà `Id` (o `<NomeClasse>Id`) viene riconosciuta come **chiave primaria**:

```csharp
public sealed class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Product> Products { get; set; } = [];
}
```

La proprietà `Products` è una **navigation property**: rappresenta la relazione "una categoria ha molti prodotti". EF Core la userà per eseguire le join quando serve.

### 2.2.3 Il DbContext

La classe `DbContext` dichiara quali entità fanno parte del modello:

```csharp
public sealed class CatalogDbContext(DbContextOptions<CatalogDbContext> options)
    : DbContext(options)
{
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();
}
```

Il costruttore primario riceve `DbContextOptions<T>`, che contiene la configurazione (provider, stringa di connessione) e che verrà fornita dal sistema di dependency injection.

### 2.2.4 Le query LINQ

EF Core traduce le query LINQ in SQL. Un esempio:

```csharp
var books = await db.Products
    .Where(p => p.Category!.Name == "Books")
    .OrderBy(p => p.Name)
    .ToListAsync();
```

L'esecuzione avviene **solo quando si materializza la query** (con `ToListAsync`, `ToArrayAsync`, `FirstOrDefaultAsync`, ecc.): fino a quel momento si compone un albero di espressioni che il provider traduce. Questo dettaglio è importante perché ci permette di costruire query **condizionali**, aggiungendo filtri solo se necessari.

### 2.2.5 Le operazioni di scrittura

Le scritture passano dal *change tracker* di EF Core:

```csharp
db.Products.Add(new Product { Name = "Headphones", Price = 199.99m, CategoryId = 1 });
await db.SaveChangesAsync(); // genera INSERT
```

`SaveChanges()` rileva le modifiche (aggiunte, modifiche, cancellazioni) e le applica al database in una **transazione implicita**.

### 2.2.6 I provider

EF Core separa il nucleo dai **provider**, uno per database. I più usati:

- **SQLite:** `Microsoft.EntityFrameworkCore.Sqlite`, adatto allo sviluppo locale e a database su file.
- **SQL Server:** `Microsoft.EntityFrameworkCore.SqlServer`, usato spesso in ambienti Windows e Azure.
- **PostgreSQL:** `Npgsql.EntityFrameworkCore.PostgreSQL`, provider open source.
- **InMemory:** `Microsoft.EntityFrameworkCore.InMemory`, utile per alcuni test ma non equivalente a un vero database relazionale.

In questo capitolo useremo **SQLite** per la sua semplicità operativa: zero installazioni, un solo file. Alla fine del capitolo vedremo come passare a un altro provider cambiando poco più di una riga.

### 2.2.7 La configurazione tramite DI

In un'applicazione .NET moderna, il `DbContext` si registra nel container di dependency injection. EF Core offre due modalità:

- `AddDbContext<T>` — registra un contesto **scoped** (condiviso nell'ambito di una richiesta);
- `AddDbContextFactory<T>` — registra una **factory** che crea un contesto nuovo a richiesta.

Come anticipato, per i tool MCP useremo `AddDbContextFactory<T>`: ogni invocazione di tool avrà il suo contesto fresco, senza conflitti e senza tracking accumulato. Ne vedremo i dettagli operativi nella sezione dedicata.
