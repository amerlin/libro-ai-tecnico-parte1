## 5.12 Caso pratico: migrare un servizio catalogo

Per collegare le decisioni, immaginiamo di migrare un servizio catalogo esistente, scritto in Python con FastAPI, verso ASP.NET Core. Il servizio pubblica prodotti, legge un database PostgreSQL condiviso con un back office e viene consumato da un sito e da un'app mobile. L'esempio non è un tutorial per ricostruire un catalogo completo: mostra come delimitare il lavoro, mantenere il contratto e produrre evidenze prima di spostare il traffico.

### 5.12.1 Scenario e vincoli

Il sistema attuale espone:

- `GET /api/products?category=...&page=...` per elencare prodotti attivi;
- `GET /api/products/{id}` per leggere un prodotto;
- `POST /api/products` per creare un prodotto, riservato agli editor;
- un job notturno che importa disponibilità da un partner.

Il database contiene milioni di righe storiche, mentre l'endpoint pubblico restituisce solo prodotti attivi. Il back office continua a scrivere nello schema durante la migrazione. L'app mobile non può essere aggiornata rapidamente. La disponibilità richiesta non consente un fermo lungo e l'autenticazione usa un identity provider aziendale.

L'assessment mostra che le letture pubbliche sono il primo candidato: sono frequenti, hanno contratto documentabile e possono rimanere read-only sul database esistente. La scrittura di prodotti resta sul servizio sorgente nella prima fase; non si duplicano gli effetti di `POST`. Il job notturno viene migrato separatamente perché ha un lifecycle e un profilo di retry diversi.

### 5.12.2 Baseline e test di caratterizzazione

Prima di scrivere il target si raccolgono:

- esempi di response per prodotto attivo, assente e non visibile;
- comportamento dei filtri e paginazione;
- status e schema per query non valide;
- requisiti di autorizzazione del `POST`;
- p95/p99, richieste al secondo, error rate e carico sul database;
- piano query corrente e indici usati.

Le fixture contengono dati sintetici con casi di null, descrizione lunga, prezzo al limite e categoria inesistente. Per i casi di produzione si usano payload anonimizzati, senza identificativi o informazioni personali. I test memorizzano anche ordinamento e proprietà JSON richieste dai client.

Si concorda che l'implementazione nuova deve restituire la stessa semantica dei filtri e i medesimi codici, salvo variazioni approvate. Il nuovo sistema deve mantenere il budget di latenza del servizio e non superare il limite di connessioni assegnato al database.

### 5.12.3 Creazione del progetto

La solution può iniziare con API e test, senza creare tutti i progetti architetturali possibili:

```text
Catalogo.sln
src/
  Catalogo.Api/
  Catalogo.Infrastructure/
tests/
  Catalogo.Api.Tests/
```

Il progetto API configura hosting, autenticazione, logging, endpoint e composizione dei servizi. Infrastructure contiene `DbContext`, mapping e query SQL/EF Core. Se le regole del dominio diventano complesse, si può introdurre un progetto Domain con una decisione esplicita, non come prerequisito per un endpoint di lettura.

La foundation si considera pronta quando un commit pulito passa `dotnet restore`, `dotnet build`, `dotnet test`, produce l'immagine, gira nel namespace di test e legge configurazione esterna. Un health check minimale può essere registrato e mappato così:

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHealthChecks();

var app = builder.Build();
app.MapHealthChecks("/health");
app.Run();
```

Questo endpoint verifica che l'applicazione risponda; controlli di readiness sulle dipendenze vanno aggiunti solo se richiesti. La pipeline non usa una connection string reale nei log.

### 5.12.4 Contratto e query di lettura

Il DTO è separato dal modello persistito:

```csharp
public sealed record ProductListItem(
    int Id,
    string Name,
    decimal Price,
    string Currency);

public sealed record ProductPage(
    IReadOnlyList<ProductListItem> Items,
    int Page,
    int PageSize,
    int TotalCount);
```

La paginazione deve essere limitata lato server; non accettare page size illimitata. Per dataset in crescita, una paginazione a cursore può essere più stabile ed efficiente di un offset elevato, ma cambiare il contratto va coordinato con i client. Nella prima fase si mantiene l'interfaccia esistente e si usa il piano database per verificare il costo.

Un service applicativo riceve filtri già validati e restituisce un risultato; l'endpoint mappa il risultato a HTTP:

```csharp
app.MapGet("/api/products", async (
    string? category,
    int page,
    int pageSize,
    IProductQueries queries,
    CancellationToken ct) =>
{
    if (page < 1 || pageSize is < 1 or > 100)
        return Results.BadRequest();

    var result = await queries.ListAsync(
        category, page, pageSize, ct);
    return Results.Ok(result);
});
```

Il frammento illustra il flusso e non definisce da solo tutte le regole: i default per i parametri, il formato errore, i limiti e l'ordinamento vanno allineati al contratto sorgente. In codice di produzione la validazione restituisce una risposta coerente e documentata; l'endpoint non deve trasformare un errore database in lista vuota.

### 5.12.5 Mantenere il database condiviso in sicurezza

Il nuovo servizio apre un accesso read-only se il provider e i permessi lo consentono. Questo riduce il rischio di alterare dati durante la prima fase. Le query sono proiettate sui campi necessari, limitano risultati e usano parametri. Si controllano indici e piani; l'utente DB non ha permessi DDL o scrittura non necessari.

Prima del deploy si verificano schema e tipi con i proprietari del back office. Se il vecchio sistema cambia una colonna, il target deve fallire con log diagnostico e alert, non continuare con un risultato parziale apparentemente valido. Un contratto dati o una vista stabile può isolare il nuovo servizio dalle tabelle interne, se il team database può mantenerli.

Il modello EF Core mappa solo la parte necessaria dello schema, senza avviare migrazioni automatiche. Il target non è proprietario del database in questa fase; non può quindi presumere di aggiornare tabelle condivise. Le migrazioni future richiedono un piano separato con tutti i writer coinvolti.

### 5.12.6 Test differenziale e osservazione in shadow

La suite d'integrazione invia richieste al sistema sorgente e al target usando un database di test fissato. Le risposte sono confrontate su status, schema e valori. Timestamp e campi variabili sono normalizzati solo dove il contratto li dichiara non deterministici.

In ambiente di preproduzione il traffico sintetico esercita route e limiti. In produzione, se privacy, policy e architettura lo permettono, il gateway può duplicare **solo richieste di lettura** verso il target in modalità shadow. Il target esegue il calcolo ma la sua risposta non viene restituita all'utente. Si confrontano risultati in forma redatta e si misurano query e latenza.

Non duplicare il `POST` o il job di importazione: un secondo invio potrebbe creare un prodotto, inviare notifiche o alterare stock. Shadow traffic non è una licenza a replicare dati personali; minimizzare payload, applicare retention breve e ottenere le approvazioni necessarie.

Un report giornaliero classifica differenze per categoria: status, proprietà mancanti, ordinamento, valori numerici, null e timeout. Ogni differenza ha owner e decisione: bug nel nuovo codice, bug sorgente da correggere, differenza intenzionale o dato invalido. Il traffico non viene spostato finché le differenze critiche non sono comprese.

### 5.12.7 Canary e cutover

Con test differenziali soddisfacenti, il gateway indirizza al target una piccola percentuale di richieste di lettura, mantenendo identificabile la coorte. Si controllano:

- error rate e status per route e versione;
- p95/p99 e timeout;
- pool connessioni, CPU, memoria e query lente;
- differenze di contenuto e errori di deserializzazione client;
- log di autenticazione e richieste senza tenant.

Si amplia gradualmente la percentuale solo se le metriche restano entro budget per una finestra definita. Il criterio non è “nessuna segnalazione”: un client mobile può essere usato poco e segnalare tardi. Gli alert e i log devono offrire copertura tecnica indipendente dal feedback degli utenti.

Per rollback, il gateway riporta la route al servizio Python. Poiché il target è read-only e usa lo schema invariato, il rollback non richiede sincronizzare nuove scritture. Si prova prima in preproduzione, verificando cache, DNS, warm-up e propagazione della configurazione. Il piano include un referente che può arrestare il rollout.

### 5.12.8 Migrare la scrittura

Una volta stabile la lettura, la creazione prodotto diventa una capacità separata. Il team decide se il nuovo servizio assume la scrittura oppure se il vecchio sistema resta owner temporaneamente. Non basta duplicare le scritture: si deve evitare che back office e API sovrascrivano modifiche in modo inconsistente.

Se il target assume ownership, il rollout della scrittura avviene solo dopo aver verificato:

1. policy di autorizzazione e mapping claims;
2. validazione e invarianti condivise con il back office;
3. unicità e concorrenza nel database;
4. audit e notifiche prodotte una sola volta;
5. idempotenza delle richieste ritentate;
6. schema compatibile con la versione precedente durante il rollback.

Una chiave di idempotenza può aiutare per richieste ripetibili, ma deve avere storage e scadenza definiti. L'outbox può garantire che un evento venga registrato nella stessa transazione della creazione, con consegna asincrona e consumer deduplicante. Non rende transazionale il sistema esterno.

### 5.12.9 Migrare il job notturno

Il job è una capacità distinta dall'API. Si verificano frequenza, finestra, volume, checkpoint, dati parziali e comportamento al retry. Un `BackgroundService` può ospitare un ciclo semplice, ma se il job deve sopravvivere a riavvii, essere schedulato da più istanze o riprendere da un checkpoint, si usa un orchestratore o una coda durevole.

Durante la prova, il target importa in un ambiente isolato e confronta conteggi e aggregati con il job esistente. Non si eseguono entrambi in scrittura sullo stesso dataset senza una strategia d'idempotenza. Il cutover del job ha un lock o un singolo scheduler owner, un run id, report e procedura di replay.

### 5.12.10 Risultato e lezioni

Il servizio di lettura può essere considerato migrato quando il target ha sostenuto il traffico previsto, rispetta contratto e budget, è osservabile, ha un rollback provato e il sistema sorgente non riceve più quelle route. Il capitolo di progetto non si chiude però finché scrittura, job, integrazioni residue e dismissione non hanno owner e date.

Le decisioni hanno mantenuto il perimetro piccolo, ma non hanno ignorato il sistema completo. Si è iniziato con letture reversibili; dati condivisi e scritture sono rimasti sotto un owner; test e telemetria hanno preceduto il cutover; infine ogni capability ha avuto il suo piano. In un caso PHP o Java cambierebbero framework, tool e dettagli di persistenza, non il metodo di mappatura, caratterizzazione e rollout.

### 5.12.11 Adattare il caso ad altri ecosistemi

- **PHP/Laravel o Symfony:** inventariare middleware, service container, queue worker, session driver e convenzioni Eloquent/Doctrine. Verificare differenze di null, timezone e gestione dei job.
- **Python/Django o FastAPI:** distinguere ASGI/WSGI, dependency overrides, task asincroni, ORM e migration framework. Non assumere che codice `async` sia non bloccante se una libreria sottostante è sincrona.
- **Node.js/Express o NestJS:** mappare middleware e pipe/interceptor, controllare event loop, stream e dipendenze native dei pacchetti.
- **Java/Spring Boot:** confrontare lifecycle bean, scope request, filtri, transazioni e thread pool. Verificare semantica di ORM, lazy loading e gestione delle eccezioni.

Per ciascuno, costruire una scheda per concetto: comportamento sorgente, candidato ASP.NET Core, differenza osservabile, test di prova, impatto e decisione. Un mapping documentato riduce il rischio che una differenza venga scoperta solo da un utente in produzione.
