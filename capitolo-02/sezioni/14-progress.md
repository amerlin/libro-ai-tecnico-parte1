## 2.14 Primitivi avanzati: il Progress

Finora i nostri tool sono "tutto o niente": partono, lavorano e restituiscono un risultato. Ma un'operazione lunga — per esempio una query pesante, un'importazione o un calcolo — trae beneficio dal **reporting del progresso**: il server informa il client di quanto manca al completamento, e il client può mostrarlo all'utente.

### 2.14.1 Il meccanismo

MCP prevede che il client, quando invoca un tool, possa allegare un **progress token**. Il server, durante l'esecuzione, invia notifiche `notifications/progress` con quel token, comunicando una frazione di avanzamento (0..1), un totale opzionale e un messaggio.

L'SDK .NET rende tutto questo trasparente: basta dichiarare nel tool un parametro di tipo **`IProgress<ProgressNotificationValue>`**. L'SDK lo riconosce come parametro speciale, lo **esclude dallo schema di input** e lo inietta automaticamente, collegato al progress token del client.

### 2.14.2 Un tool con progress

Estendiamo il nostro catalogo con un tool che conta i prodotti simulando un lavoro lungo:

```csharp
using ModelContextProtocol.Protocol;

[McpServerTool, Description("Counts products, reporting progress while working.")]
public async Task<string> CountWithProgress(
    IProgress<ProgressNotificationValue>? progress = null,
    CancellationToken cancellationToken = default)
{
    await using var db = await factory.CreateDbContextAsync(cancellationToken);

    progress?.Report(new ProgressNotificationValue
    {
        Progress = 0.2f,
        Total = 1f,
        Message = "querying the database"
    });

    var total = await db.Products.CountAsync(cancellationToken);

    progress?.Report(new ProgressNotificationValue
    {
        Progress = 1f,
        Total = 1f,
        Message = "done"
    });

    return $"counted {total} products";
}
```

Osservazioni:

- `Progress` e `Total` sono di tipo `float`: da qui i suffissi `f` sui letterali.
- Il parametro è opzionale (`? progress = null`): se il client non fornisce un progress token, l'SDK passa `null` e il tool funziona comunque.
- Lo schema di input del tool resta **vuoto** (`{"type":"object","properties":{}}`): `IProgress` non è un argomento, è un canale.

### 2.14.3 Perché è utile

In un tool che importa migliaia di righe o interroga più sistemi, il progress trasforma un'attesa cieca in un'esperienza informata: l'host può mostrare una barra o un messaggio, e il modello può decidere se attendere o suggerire alternative. È un primitivo semplice ma che aumenta molto la percezione di affidabilità di un agente.

### 2.14.4 Una nota sul token

Non devi gestire il token a mano: l'SDK associa il parametro `IProgress` al token della richiesta corrente. Se più invocazioni avvengono in parallelo, ogni tool ha il suo canale di progress isolato. È l'ennesimo caso in cui l'SDK trasforma una complessità di protocollo in un semplice costrutto C#.
