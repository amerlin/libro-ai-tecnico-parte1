## 3.17 Esempio C#: i test (test-first)

La constitution impone il **Test-First**, e i task lo riflettono: prima i test, poi l'implementazione. Il listato mostra il file completo a lavoro terminato; durante il lavoro si aggiungono i test di ciascuna user story e li si esegue in RED prima di implementare la story corrispondente.

### 3.17.1 Il progetto di test

```bash
> dotnet new xunit -o tests/Taskify.Tests -n Taskify.Tests
> dotnet add tests/Taskify.Tests/Taskify.Tests.csproj reference src/Taskify.csproj
> dotnet add tests/Taskify.Tests/Taskify.Tests.csproj package Microsoft.AspNetCore.Mvc.Testing
```

Il pacchetto `Microsoft.AspNetCore.Mvc.Testing` fornisce `WebApplicationFactory<T>`, che avvia l'applicazione **in-memory** per i test di integrazione, senza bisogno di un server reale.

### 3.17.2 I test

File `tests/Taskify.Tests/TaskEndpointsTests.cs`:

```csharp
using System.Net;
using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc.Testing;
using Taskify.Contracts;

namespace Taskify.Tests;

public class TaskEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public TaskEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task CreateTask_WithValidTitle_ReturnsCreated()
    {
        var response = await _client.PostAsJsonAsync(
            "/tasks", new { title = "Write the tests", dueDate = (DateTime?)null });

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var task = await response.Content.ReadFromJsonAsync<TaskDto>();
        Assert.NotNull(task);
        Assert.Equal("Write the tests", task.Title);
        Assert.False(task.IsCompleted);
    }

    [Fact]
    public async Task CreateTask_WithoutTitle_ReturnsBadRequest()
    {
        var response = await _client.PostAsJsonAsync(
            "/tasks", new { title = "", dueDate = (DateTime?)null });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task ListTasks_FilterByStatus_ReturnsOnlyOpenTasks()
    {
        await _client.PostAsJsonAsync("/tasks", new { title = "Open task" });
        await _client.PostAsJsonAsync("/tasks", new { title = "Done task" });

        var open = await _client.GetFromJsonAsync<List<TaskDto>>("/tasks?status=open");

        Assert.NotNull(open);
        Assert.All(open, t => Assert.False(t.IsCompleted));
    }

    [Fact]
    public async Task CompleteTask_ExistingId_ReturnsCompleted()
    {
        var created = await _client.PostAsJsonAsync("/tasks", new { title = "To complete" });
        var task = await created.Content.ReadFromJsonAsync<TaskDto>();

        var response = await _client.PostAsync($"/tasks/{task!.Id}/complete", null);

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        var completed = await response.Content.ReadFromJsonAsync<TaskDto>();
        Assert.True(completed!.IsCompleted);
    }

    [Fact]
    public async Task DeleteTask_ExistingId_ReturnsNoContent()
    {
        var created = await _client.PostAsJsonAsync("/tasks", new { title = "To delete" });
        var task = await created.Content.ReadFromJsonAsync<TaskDto>();

        var response = await _client.DeleteAsync($"/tasks/{task!.Id}");

        Assert.Equal(HttpStatusCode.NoContent, response.StatusCode);
    }
}
```

### 3.17.3 La corrispondenza con gli scenari di accettazione

Ogni test mappa uno scenario della specifica:

```{=latex}
\small
```

| Test | Scenario di accettazione |
|------|--------------------------|
| `CreateTask_WithValidTitle_ReturnsCreated` | US1, scenario 1 |
| `CreateTask_WithoutTitle_ReturnsBadRequest` | US1, scenario 2 |
| `ListTasks_FilterByStatus_...` | US2, scenario 1 |
| `CompleteTask_ExistingId_...` | US3, scenario 1 |
| `DeleteTask_ExistingId_...` | US3, scenario 2 |

```{=latex}
\normalsize
```

È la tracciabilità che la convergenza verificherà: ogni requisito testabile ha il suo test.

### 3.17.4 Il ciclo Red-Green-Refactor

Il principio Test-First impone l'ordine: scrivi il test, **verifica che fallisca** (perché l'implementazione non c'è ancora), poi implementa, poi verifica che passi. In un flusso con agente AI, questo ordine è importante: evita il "test scritto a posteriori" che verrebbe tarato sull'implementazione invece che sul requisito.

### 3.17.5 Eseguire i test

```bash
> dotnet test tests/Taskify.Tests/Taskify.Tests.csproj
```

Se tutto è in ordine, l'output riporterà i test verdi. È la conferma di **correttezza**; la conferma di **completezza** arriverà con `/speckit-converge`.
