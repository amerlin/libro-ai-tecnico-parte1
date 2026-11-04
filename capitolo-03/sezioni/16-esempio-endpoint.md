## 3.16 Esempio C#: gli endpoint della Minimal API

Ecco il cuore dell'implementazione: `src/Program.cs`, che realizza i quattro endpoint definiti nei contratti. Il listato mostra lo stato finale del file dopo il ciclo test-first; corrisponde ai task di implementazione `T009`, `T013` e `T017`. L'ordine espositivo del capitolo non è l'ordine di lavoro: i test vanno scritti ed eseguiti in RED prima di implementare gli endpoint.

### 3.16.1 Il codice completo

```csharp
using Microsoft.EntityFrameworkCore;
using Taskify.Contracts;
using Taskify.Data;
using Taskify.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<TaskDbContext>(options =>
    options.UseSqlite("Data Source=tasks.db"));

var app = builder.Build();

// Crea lo schema all'avvio (solo per l'esempio; in produzione: migrazioni).
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<TaskDbContext>();
    db.Database.EnsureCreated();
}

// ---- US1: creare un task ----
app.MapPost("/tasks", async (CreateTaskRequest request, TaskDbContext db) =>
{
    if (string.IsNullOrWhiteSpace(request.Title))
        return Results.BadRequest(new { error = "Title is required." });

    if (request.Title.Length > 200)
        return Results.BadRequest(new { error = "Title must be at most 200 characters." });

    var task = new TaskItem
    {
        Title = request.Title,
        DueDate = request.DueDate,
        IsCompleted = false,
        CreatedAt = DateTimeOffset.UtcNow
    };

    db.Tasks.Add(task);
    await db.SaveChangesAsync();

    return Results.Created($"/tasks/{task.Id}", TaskDto.From(task));
});

// ---- US2: elencare e filtrare ----
app.MapGet("/tasks", async (string? status, TaskDbContext db) =>
{
    IQueryable<TaskItem> query = db.Tasks;

    if (status is not null)
    {
        var completed = status switch
        {
            "open" => false,
            "completed" => true,
            _ => (bool?)null
        };

        if (completed is null)
            return Results.BadRequest(new { error = "status must be 'open' or 'completed'." });

        query = query.Where(t => t.IsCompleted == completed);
    }

    var tasks = await query
        .OrderBy(t => t.Id)
        .Select(t => new TaskDto(
            t.Id,
            t.Title,
            t.IsCompleted,
            t.DueDate,
            t.CreatedAt))
        .ToListAsync();

    return Results.Ok(tasks);
});

// ---- US3: completare ----
app.MapPost("/tasks/{id:int}/complete", async (int id, TaskDbContext db) =>
{
    var task = await db.Tasks.FindAsync(id);
    if (task is null)
        return Results.NotFound(new { error = "Task not found." });

    task.IsCompleted = true;
    await db.SaveChangesAsync();

    return Results.Ok(TaskDto.From(task));
});

// ---- US3: eliminare ----
app.MapDelete("/tasks/{id:int}", async (int id, TaskDbContext db) =>
{
    var task = await db.Tasks.FindAsync(id);
    if (task is null)
        return Results.NotFound(new { error = "Task not found." });

    db.Tasks.Remove(task);
    await db.SaveChangesAsync();

    return Results.NoContent();
});

app.Run();

// Rende Program accessibile ai test di integrazione (WebApplicationFactory).
public partial class Program { }
```

### 3.16.2 Lettura guidata

**La Minimal API.** Abbiamo scelto il pattern *Minimal API* di ASP.NET Core: endpoint dichiarati con `MapPost`, `MapGet`, `MapDelete`, handler come lambda. È la scelta più **semplice** per una feature di questo calibro — coerente con il principio di Semplicità della constitution. Se la feature crescesse, il piano potrebbe evolvere verso i controller; per ora, minimal è la scelta giusta.

**La validazione.** I due controlli su `Title` (obbligatorietà e lunghezza) realizzano FR-001 e il principio di Validazione della constitution. Errori chiari (`Title is required.`) permettono al chiamante di correggersi.

**I codici di stato.** Ogni risposta usa un codice semantico: `201 Created` con l'URI della risorsa, `400 Bad Request` per input non validi, `404 Not Found` per risorse inesistenti, `204 No Content` per l'eliminazione. È la coerenza REST richiesta dalla constitution.

**Il binding dei parametri.** ASP.NET Core associa automaticamente il corpo JSON a `CreateTaskRequest`, i segmenti di route a `id`, la query string a `status`, e inietta il `TaskDbContext` dall'DI. Nessun codice di colla.

**`public partial class Program`.** L'ultima riga rende la classe `Program` (generata dai top-level statements) accessibile al progetto di test, che userà `WebApplicationFactory<Program>`. È un dettaglio indispensabile per i test di integrazione.

### 3.16.3 Il progetto

Il progetto web si crea con:

```bash
> dotnet new web -o src -n Taskify
> cd src
> dotnet add package Microsoft.EntityFrameworkCore.Sqlite
```

Il file di progetto usa `Microsoft.NET.Sdk.Web`, che include implicitamente i namespaces di ASP.NET Core (per questo nel listato non servono molti `using` espliciti).
