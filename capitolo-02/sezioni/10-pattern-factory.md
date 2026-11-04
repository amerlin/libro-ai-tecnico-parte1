## 2.10 Il pattern IDbContextFactory

Dedichiamo una sezione al pattern che rende solida l'integrazione tra EF Core e MCP. È il punto in cui molti server "fai da te" si rompono, e vale la pena capirlo a fondo.

### 2.10.1 Il problema del DbContext condiviso

Un `DbContext` non è thread-safe e non è pensato per vivere a lungo. Se registrassimo un singolo contesto e lo condividessimo tra tutte le invocazioni di tool, avremmo:

- **race condition** — due tool che usano lo stesso contesto in parallelo possono corrompere lo stato o lanciare eccezioni;
- **crescita della memoria** — ogni entità caricata resta nel change tracker, consumando memoria e rallentando le query successive;
- **stale data** — il contesto tiene in cache le entità già lette, e rischia di restituire versioni vecchie.

Nelle applicazioni web il problema si risolve con lo scope: un `DbContext` per richiesta. Nei server MCP non c'è una "richiesta" lunga una sola unità di lavoro: c'è una **invocazione di tool** alla volta.

### 2.10.2 La soluzione: una factory

`AddDbContextFactory<T>` registra una `IDbContextFactory<T>`: un oggetto **singleton e thread-safe** che, a ogni chiamata di `CreateDbContextAsync`, produce un contesto **nuovo e indipendente**. Il pattern d'uso nei tool è sempre lo stesso:

```csharp
await using var db = await factory.CreateDbContextAsync(cancellationToken);
// ... query o scritture ...
```

L'`await using` chiude il contesto al termine del metodo, rilasciando la connessione al pool. Ogni invocazione di tool ha il suo contesto, con il suo tracker e la sua connessione: niente condivisione, niente race condition.

### 2.10.3 Perché funziona bene con MCP

Il ciclo di vita di un contesto creato dalla factory coincide con il ciclo di vita di un tool:

1. il tool riceve la richiesta;
2. crea il contesto;
3. esegue una o più query;
4. salva le eventuali modifiche;
5. chiude il contesto.

È esattamente l'unità di lavoro ideale per EF Core: corta, isolata, transazionale. E poiché l'SDK MCP **costruisce un'istanza del tool per ogni invocazione** (come abbiamo visto nel Capitolo 1), la factory iniettata nel costruttore è sempre pronta.

### 2.10.4 Factory vs contesto diretto

```{=latex}
\small
```

| Aspetto | `AddDbContext<T>` + iniezione diretta | `AddDbContextFactory<T>` |
|------------|--------------------------------|----------------------|
| Lifetime del contesto | Scoped (da gestire) | Per invocazione (esplicito) |
| Concorrenza | Rischiosa se condiviso | Sicura |
| Tracking | Accumula | Pulito a ogni chiusura |
| Adatto a MCP | No | Sì |

```{=latex}
\normalsize
```

### 2.10.5 Un'alternativa valida: il contesto "short-lived" per tool

C'è un altro pattern che funziona: creare il contesto **dentro** il tool con un `DbContextOptionsBuilder` o risolverlo da un provider di servizi. Ma è più verboso e aggira la dependency injection. La factory è la strada idiomatica, testata e raccomandata: usala.

### 2.10.6 Cosa ricordare

- Registra con `AddDbContextFactory<T>`, non `AddDbContext<T>`.
- Nei tool, crea il contesto con `await using var db = await factory.CreateDbContextAsync(ct)`.
- Non riusare mai un contesto tra due invocazioni.
- Le connessioni fisiche sono comunque riusate dal pool del provider: non c'è alcun costo nascosto.

Con questo pattern assodato, possiamo assemblare il server completo.
