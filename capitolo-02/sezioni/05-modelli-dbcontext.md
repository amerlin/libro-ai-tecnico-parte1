## 2.5 Entità e DbContext

Creiamo ora le entità e il contesto. Per semplicità in questo capitolo teniamo tutto in `Program.cs` (top-level statements + classi); in un progetto reale separeresti le classi in file dedicati, ma per un esempio didattico la vicinanza del codice aiuta la lettura.

### 2.5.1 Le entità

```csharp
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
```

### 2.5.2 Il DbContext

```csharp
using Microsoft.EntityFrameworkCore;

public sealed class CatalogDbContext(DbContextOptions<CatalogDbContext> options)
    : DbContext(options)
{
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Product> Products => Set<Product>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Product>()
            .Property(p => p.Price)
            .HasPrecision(18, 2);
    }
}
```

### 2.5.3 La configurazione del modello

Nel metodo `OnModelCreating` dichiariamo la **precisione** del prezzo: `HasPrecision(18, 2)` significa 18 cifre totali di cui 2 decimali. È una buona pratica per le colonne monetarie: evita che SQLite (che di default non applica vincoli di precisione ai `decimal`) tronchi o approssimi i valori in modo imprevisto.

Gran parte della configurazione non serve scriverla: EF Core riconosce per convenzione:

- la chiave primaria (`Id`);
- la chiave esterna (`CategoryId`);
- la relazione uno-a-molti tramite le navigation property.

### 2.5.4 Un vincolo utile: il nome categoria univoco

Per rendere il modello più robusto, aggiungiamo un **indice univoco** sul nome della categoria, così il database stesso rifiuterà i duplicati:

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Product>()
        .Property(p => p.Price)
        .HasPrecision(18, 2);

    modelBuilder.Entity<Category>()
        .HasIndex(c => c.Name)
        .IsUnique();
}
```

Con questo vincolo, se un tool tentasse di inserire due categorie con lo stesso nome, il database risponderebbe con un errore di vincolo, che noi tradurremo in un messaggio chiaro per il modello.

### 2.5.5 Perché `required` e nullable

Le proprietà `Name` sono `required string` (non nullable): dichiarano un vincolo a compile time che aiuta a evitare oggetti "mezzi vuoti". Le navigation `Category?` e la collection `Products` sono invece gestite da EF Core: la collection parte da una lista vuota, la navigation verso il "lato uno" può essere `null` finché non viene caricata. Con i **nullable reference types** abilitati (come nel template), questo codice comunica con precisione cosa può essere `null` e cosa no.

### 2.5.6 Il prossimo passo

Con entità e contesto pronti, dobbiamo decidere **come** creare il database fisico. Le opzioni sono due — `EnsureCreated` (rapido, per prototipi) e le **migrazioni** (per progetti reali) — e le vedremo nelle prossime due sezioni.
