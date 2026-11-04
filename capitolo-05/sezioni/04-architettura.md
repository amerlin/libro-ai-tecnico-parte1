## 5.4 Architettura e organizzazione del codice

L'architettura di destinazione non dovrebbe essere una copia dei package del framework sorgente né una collezione di pattern scelti per moda. Il suo compito è rendere espliciti i confini: dove termina HTTP, dove risiede la logica di dominio, chi possiede i dati e come si integrano le dipendenze esterne.

### 5.4.1 Dal framework sorgente alle responsabilità ASP.NET Core

Laravel, Django, Express/NestJS e Spring Boot offrono combinazioni diverse di routing, middleware, controller, container, configurazione e persistenza. Durante la migrazione, decomporre il comportamento:

| Responsabilità sorgente | Possibile destinazione ASP.NET Core |
|---|---|
| Route/controller | Minimal API o controller MVC |
| Hook globale per richiesta | Middleware |
| Hook limitato a endpoint | Endpoint filter o filtro MVC |
| Container dei servizi | `IServiceCollection` e provider DI |
| Configurazione ambientale | Configuration providers e Options |
| Worker/job | `BackgroundService`, worker o scheduler esterno |
| Validazione input | Validazione esplicita, filtri o libreria adottata |
| Template/server rendering | Razor Pages, MVC o frontend separato |

La tabella indica candidati, non una traduzione automatica. Un middleware ASP.NET Core avvolge una richiesta e può decidere se proseguire; un filtro MVC opera nel ciclo MVC; un endpoint filter si applica ai delegate degli endpoint. Scegliere il livello in base alla responsabilità evita middleware globali che contengono eccezioni specifiche per una sola route.

### 5.4.2 Minimal API o controller?

Le Minimal API sono un modo conciso per definire endpoint e si adattano bene a servizi piccoli, API focalizzate e team che vogliono comporre route per feature. Non sono un framework “senza architettura”: dipendenze, validazione, errori, mapping e test devono comunque essere organizzati.

I controller MVC offrono convenzioni e struttura familiare per API articolate, applicazioni con molti endpoint simili, filtri MVC e team che beneficiano di classi e attributi. Non obbligano a usare tutte le funzionalità MVC. La scelta non va basata sul numero di righe iniziali: valutare complessità delle regole trasversali, standardizzazione, familiarità del team e necessità di organizzare i contratti.

Esempio Minimal API con gruppo:

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<IProductService, ProductService>();

var app = builder.Build();
var products = app.MapGroup("/api/products");

products.MapGet("/{id:int}", async (
    int id, IProductService service, CancellationToken ct) =>
{
    var product = await service.FindAsync(id, ct);
    return product is null ? Results.NotFound() : Results.Ok(product);
});

app.Run();
```

Il delegate riceve parametri che ASP.NET Core associa a route, servizi o body secondo regole di binding. Per mantenere leggibile il punto di composizione, spostare la definizione in un metodo `MapProductEndpoints` o in un modulo quando le route crescono. Non trasformare subito ogni gruppo in un'astrazione generica: estrarre quando si chiarisce una responsabilità riutilizzabile.

### 5.4.3 Confini applicativi e dipendenze

Una struttura minima può separare:

- **API:** protocollo HTTP, autenticazione, mapping request/response;
- **Application:** casi d'uso e coordinamento;
- **Domain:** regole e invarianti di business;
- **Infrastructure:** database e integrazioni esterne.

Questi nomi non sono obbligatori. In un servizio piccolo, più progetti possono aggiungere overhead senza proteggere alcun confine. In un sistema con dominio complesso e più adapter, la separazione riduce l'accoppiamento. La direzione desiderata è che le regole del dominio non dipendano dal server web o dal provider database; i dettagli infrastrutturali implementano contratti necessari ai casi d'uso.

Un layout possibile per feature:

```text
src/
  Catalogo.Api/
    Program.cs
    Features/
      Products/
        ProductEndpoints.cs
        CreateProductRequest.cs
  Catalogo.Application/
  Catalogo.Domain/
  Catalogo.Infrastructure/
tests/
  Catalogo.UnitTests/
  Catalogo.IntegrationTests/
```

Questo è uno schema, non un requisito. Una cartella `Features/Products` può contenere endpoint e request specifiche, mentre servizi applicativi e dominio vivono in progetti distinti. Evitare cartelle generiche `Helpers`, `Common` o `Utils` come destinazione per qualsiasi codice non collocato: diventano rapidamente dipendenze senza ownership.

### 5.4.4 Dominio, DTO e mapping

Non esporre direttamente l'entità database come contratto pubblico per comodità. Una modifica interna allo schema potrebbe cambiare involontariamente l'API; inoltre l'entità può contenere campi che il client non deve vedere. Usare DTO di richiesta e risposta quando esiste un confine reale, definendo mapping espliciti per campi, null e valori predefiniti.

```csharp
public sealed record ProductResponse(
    int Id, string Name, decimal Price, string Currency);
```

La logica di conversione deve essere testata. Un mapping automatico può essere utile, ma non deve nascondere conversioni lossy, date senza timezone o proprietà omesse. Per ogni contratto documentare proprietà obbligatorie, formato, unità, precisione e compatibilità.

### 5.4.5 Hosting e Kestrel

`WebApplication.CreateBuilder(args)` compone configuration, logging, servizi e ambiente. L'app risultante può girare in foreground, in container o come servizio gestito. Kestrel gestisce HTTP; in produzione spesso c'è un reverse proxy o un ingress davanti. Questo proxy può terminare TLS, imporre limiti, fare routing e aggiungere header forwarded. L'app deve fidarsi solo dei proxy configurati, non di qualunque header fornito dal client.

Il binding delle porte e degli URL deve provenire dalla configurazione dell'ambiente. Non codificare `localhost` o porte di sviluppo nell'immagine. Verificare che il processo ascolti sull'interfaccia prevista, che i controlli health siano raggiungibili dal sistema di orchestrazione e che lo shutdown consenta di terminare richieste in corso.

### 5.4.6 Processi web, worker e job

Un'applicazione sorgente può eseguire job nello stesso processo HTTP. In .NET un `BackgroundService` è appropriato per lavoro persistente controllato dall'host, ma non è una coda durevole: se il processo si arresta, gli elementi in memoria possono andare persi. Per job che richiedono retry, scheduling distribuito o garanzie di consegna, usare una coda o un sistema di scheduling adeguato.

I worker devono gestire cancellazione e shutdown, limitare concorrenza, registrare gli errori e rendere idempotenti le operazioni ripetibili. Non avviare thread detached da un endpoint e non ignorare eccezioni in task non osservati. Il lifecycle del lavoro deve essere parte della strategia di deployment e scaling.

### 5.4.7 Strutturare per comprendere, non per imitare

Portare il modello mentale del vecchio framework è utile come punto di partenza, ma il target deve rispettare le sue convenzioni. Per ogni astrazione chiedersi: quale responsabilità protegge? Quale test la rende verificabile? Quale cambiamento futuro diventa più semplice? Se non c'è una risposta, l'astrazione probabilmente anticipa un problema non ancora dimostrato.

Una migrazione ben strutturata è quella che permette di trovare rapidamente un endpoint, capire chi possiede una regola, sostituire una dipendenza esterna e testare il comportamento senza avviare l'intero sistema. Non è necessariamente quella con più progetti o livelli.
