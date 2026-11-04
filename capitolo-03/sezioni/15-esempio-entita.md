## 3.15 Esempio C#: entità, DbContext e DTO

È il momento di vedere il codice che `/speckit-implement` produce seguendo il piano. Partiamo dalle fondamenta: l'entità, il contesto EF Core e i DTO. Corrispondono ai task `T003`, `T004` e `T005` della fase "Foundational".

### 3.15.1 L'entità `TaskItem`

File `src/Models/TaskItem.cs`, come stabilito dal piano:

```csharp
namespace Taskify.Models;

public sealed class TaskItem
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public bool IsCompleted { get; set; }
    public DateTime? DueDate { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
}
```

È il riflesso diretto del modello dati definito in `data-model.md`: un identificativo, un titolo obbligatorio, lo stato, la scadenza opzionale e la data di creazione. Nessuna sorpresa: l'entità **è** il modello dati, tradotto in C#.

### 3.15.2 Il `DbContext`

File `src/Data/TaskDbContext.cs`:

```csharp
using Microsoft.EntityFrameworkCore;
using Taskify.Models;

namespace Taskify.Data;

public sealed class TaskDbContext(DbContextOptions<TaskDbContext> options)
    : DbContext(options)
{
    public DbSet<TaskItem> Tasks => Set<TaskItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<TaskItem>(entity =>
        {
            entity.Property(t => t.Title).HasMaxLength(200).IsRequired();
            entity.Property(t => t.IsCompleted).HasDefaultValue(false);
        });
    }
}
```

Due scelte qui derivano **direttamente dalla specifica**:

- `HasMaxLength(200)` — il vincolo "titolo massimo 200 caratteri" (FR-001) non vive solo nella validazione dell'endpoint, ma anche nello schema del database: difesa in profondità;
- `HasDefaultValue(false)` — un task nasce "aperto".

### 3.15.3 I DTO

File `src/Contracts/TaskDtos.cs`:

```csharp
using Taskify.Models;

namespace Taskify.Contracts;

public sealed record CreateTaskRequest(string? Title, DateTime? DueDate);

public sealed record TaskDto(
    int Id,
    string Title,
    bool IsCompleted,
    DateTime? DueDate,
    DateTimeOffset CreatedAt)
{
    public static TaskDto From(TaskItem task) => new(
        task.Id,
        task.Title,
        task.IsCompleted,
        task.DueDate,
        task.CreatedAt);
}
```

Il DTO separa il **contratto esterno** (ciò che l'API espone) dal **modello interno** (l'entità EF Core). È la pratica del Capitolo 2 applicata qui: mai esporre le entità grezze, controllare sempre ciò che viaggia sul filo.

### 3.15.4 La tracciabilità spec → codice

Nota come ogni decisione di codice sia riconducibile a un requisito:

| Codice | Requisito di origine |
|--------|----------------------|
| `Title` obbligatorio, max 200 | FR-001 |
| `IsCompleted` con default `false` | FR-003 (completamento) |
| `DueDate?` opzionale | FR-001 |
| `TaskDto.From` (proiezione) | Coerenza API (constitution) |

Questa tracciabilità non è un vezzo: è ciò che permette, durante la **convergenza**, di verificare che ogni requisito abbia una realizzazione nel codice.

### 3.15.5 La registrazione dei servizi

L'ultimo tassello "foundational" è la registrazione del `DbContext` nel container (task `T006`), che vedremo all'inizio di `Program.cs` nella prossima sezione. Con queste fondamenta pronte, il "Checkpoint" della fase Foundational è superato: le user story possono essere implementate.
