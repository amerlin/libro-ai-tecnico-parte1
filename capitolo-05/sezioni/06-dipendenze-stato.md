## 5.6 Configurazione, stato e dipendenze

I framework di partenza spesso rendono facili da condividere servizi, configurazione e stato di richiesta. In ASP.NET Core queste responsabilità sono esplicite: il container DI crea le dipendenze, i provider di configurazione aggregano valori e i servizi di cache o sessione gestiscono lo stato. Esplicitarle è un vantaggio solo se il lifecycle scelto è corretto.

### 5.6.1 Dependency Injection integrata

La registrazione avviene prima di costruire l'applicazione:

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<IOrderService, OrderService>();
builder.Services.AddSingleton<IClock, SystemClock>();
builder.Services.AddHttpClient<PaymentClient>();
var app = builder.Build();
```

Il container integrato risolve i servizi e li libera secondo il lifecycle. I tre lifetime principali sono:

- **Transient:** nuova istanza a ogni risoluzione. Adatto a oggetti leggeri e senza stato condiviso.
- **Scoped:** una istanza per scope; nelle API web di norma uno scope per richiesta. `DbContext` è tipicamente scoped.
- **Singleton:** una istanza per l'intera durata del processo. Deve essere thread-safe e non conservare dati specifici della richiesta.

Il lifetime non definisce soltanto l'efficienza. Un singleton che dipende da uno scoped può catturare un oggetto oltre la sua durata (*captive dependency*). Un servizio scoped risolto dal singleton può accedere a un `DbContext` condiviso in modo non sicuro; due richieste concorrenti potrebbero interferire. L'abilitazione delle verifiche di scope in sviluppo aiuta a rilevare configurazioni errate, ma i test devono coprire il comportamento reale.

Iniettare attraverso il costruttore rende visibili le dipendenze:

```csharp
public sealed class OrderService(
    IOrderRepository repository,
    IClock clock) : IOrderService
{
    public Task<Order?> FindAsync(
        int id, CancellationToken ct) =>
        repository.FindAsync(id, ct);
}
```

Una classe con moltissimi parametri può indicare che coordina troppe responsabilità. Non risolvere il problema iniettando il provider generico `IServiceProvider` e facendo service locator: le dipendenze diventano invisibili, l'errore emerge a runtime e i test richiedono più setup.

### 5.6.2 Configuration providers e priorità

La configurazione standard combina valori da più fonti, tipicamente file JSON, variabili d'ambiente, user secrets in sviluppo e argomenti CLI. I provider successivi possono sovrascrivere valori precedenti; conoscere l'ordine è essenziale per capire quale valore è effettivamente attivo.

```json
{
  "Catalog": {
    "PageSize": 50,
    "EnableBetaSearch": false
  }
}
```

Le variabili d'ambiente usano convenzioni come `Catalog__PageSize=100` per rappresentare la gerarchia. `appsettings.json` contiene configurazione non segreta e valori predefiniti; non vi si inseriscono password, token o chiavi di produzione. La configurazione non è una stringa da leggere liberamente in ogni metodo: raggruppare opzioni correlate in tipi tipizzati, validarne i valori all'avvio e fallire esplicitamente se manca un requisito essenziale.

```csharp
builder.Services
    .AddOptions<CatalogOptions>()
    .BindConfiguration("Catalog")
    .Validate(o => o.PageSize is > 0 and <= 200,
        "PageSize deve essere compreso tra 1 e 200.")
    .ValidateOnStart();
```

Un default silenzioso per una configurazione obbligatoria può produrre un'applicazione che si avvia ma invia dati all'host sbagliato o disabilita una protezione. Preferire un errore chiaro in fase di avvio e loggare il nome della chiave mancante, non il suo valore segreto.

### 5.6.3 Secrets e ambienti

In sviluppo, User Secrets evita di commettere segreti nel repository, ma non è un vault di produzione. In produzione, usare il secret manager della piattaforma o un provider protetto, con rotazione, accesso minimo e audit. Evitare segreti in immagini container, argomenti di processo e log.

Separare configurazione per ambiente senza duplicare interi file con valori divergenti. Il codice dovrebbe leggere la configurazione da un'unica interfaccia; è l'ambiente a fornire il valore. La pipeline deve poter distribuire lo stesso artefatto in ambienti diversi e applicare i parametri esternamente.

Una chiave di produzione non deve essere copiata su una macchina locale per “far funzionare” il test. Usare credenziali effimere, identità gestite o servizi sostitutivi con permessi limitati.

### 5.6.4 Stato: richiesta, sessione e cache

Lo stato di una richiesta HTTP vive nell'oggetto `HttpContext` e non va conservato oltre la richiesta. Il server può servire richieste concorrenti su più thread: campi statici o singleton mutabili non sono un sostituto della sessione.

Distinguere:

- **stato di dominio persistente:** database o sistema autorevole;
- **cache:** dato ricostruibile con scadenza, invalidazione e comportamento in caso di miss;
- **sessione:** dati temporanei legati a un utente, con implicazioni di privacy e scalabilità;
- **stato locale al processo:** utile per ottimizzazioni effimere, mai fonte di verità in un cluster.

Con più istanze, cache o sessioni in memoria divergono. Una richiesta successiva può arrivare a un nodo diverso; sticky sessions riducono alcuni sintomi ma non sostituiscono storage distribuito e resilienza. Documentare durata, chiave, invalidazione, consistenza e comportamento in caso di indisponibilità della cache.

Non mettere nella cache dati sensibili o per-utente usando chiavi non isolate. Stabilire un limite di memoria e TTL; un cache stampede può saturare database e servizi proprio quando una chiave scade. Le strategie di refresh in background, lock distribuiti o stale-while-revalidate vanno scelte in base alla tolleranza alla staleness.

### 5.6.5 Client HTTP e integrazione

Per chiamare servizi esterni usare `IHttpClientFactory` o client tipizzati; evitare di creare e distruggere `HttpClient` a ogni chiamata. Configurare base address, timeout, handler e credenziali in modo centralizzato. Un client tipizzato rende visibili gli endpoint esterni e facilita test, logging e policy di resilienza.

Non registrare token nei log. Configurare timeout sia per la richiesta sia per operazioni specifiche; un timeout infinito può accumulare richieste e socket. Distinguere errori DNS, connessione rifiutata, timeout, status non riuscito e contenuto non valido. La risposta di un sistema remoto è input non attendibile anche quando usa TLS.

### 5.6.6 Background services e lavoro durevole

`BackgroundService` avvia un task con il lifecycle dell'host. È adatto a polling o lavori periodici semplici, non è una coda persistente. Se serve consegna affidabile, retry dopo crash, scheduling distribuito o visibilità operativa, usare un broker o un job scheduler con storage durevole.

Quando il worker usa servizi scoped, creare uno scope per l'unità di lavoro:

```csharp
public sealed class ImportWorker(
    IServiceScopeFactory scopeFactory,
    ILogger<ImportWorker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(
        CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            await using var scope = scopeFactory.CreateAsyncScope();
            var importer = scope.ServiceProvider
                .GetRequiredService<IImporter>();
            await importer.ProcessBatchAsync(stoppingToken);
            await Task.Delay(TimeSpan.FromSeconds(10), stoppingToken);
        }
    }
}
```

In codice reale gestire cancellazione e backoff: un'eccezione non recuperata può terminare il worker o il processo secondo configurazione. Il batch deve essere ripetibile, limitato e osservabile. Non avviare un task fire-and-forget da una route, perché l'host non ne governa durata o errori.

### 5.6.7 Progettare le dipendenze come confini

Ogni dipendenza esterna dovrebbe essere descritta da un'interfaccia o da un adapter quando questo aiuta a isolare un confine reale: provider di pagamento, clock, file storage o API remota. Non serve creare un'interfaccia per ogni classe. L'obiettivo è sostituire un'integrazione durante test o migrazione senza nascondere le capacità utilizzate.

Annotare chi possiede la configurazione e il lifecycle. Nei test, usare servizi in-memory soltanto se preservano la semantica necessaria; un dizionario non simula transazioni o concorrenza di un database relazionale. La sostituzione di una dipendenza deve essere esplicita e non attivata per errore in produzione.
