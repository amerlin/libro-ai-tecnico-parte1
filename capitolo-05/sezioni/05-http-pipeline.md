## 5.5 Richieste HTTP e pipeline

Un'API migra con successo solo se i suoi client osservano il contratto previsto. Cambiare framework spesso cambia dettagli che non erano scritti: codici di stato, forma degli errori, parsing di date, comportamento sui campi null, header, encoding e ordine delle operazioni. Questa sezione tratta la pipeline HTTP come un contratto da preservare e testare.

### 5.5.1 Ricostruire il contratto prima di spostare le route

Per ciascun endpoint registrare metodo e percorso, autenticazione, parametri, schema request/response, codici di stato, header, paginazione, ordinamento, idempotenza e limiti. Salvare esempi realistici, inclusi input invalidi e casi limite. OpenAPI aiuta a descrivere il contratto ma non sempre riflette il comportamento effettivo; confrontare specifica, implementazione e traffico anonimizzato.

Attenzione alle differenze di parsing:

- distinzione maiuscole/minuscole nei nomi JSON e nei valori;
- date locali, offset e precisione dei timestamp;
- separatori decimali e formati numerici;
- `null`, proprietà assente, stringa vuota e valore predefinito;
- encoding, Unicode normalizzato e limiti sulla dimensione del body;
- parametri duplicati, query string e codifica degli spazi.

Una modifica “più corretta” può essere breaking. Se si decide di correggere un comportamento, documentare la variazione e verificare la compatibilità dei consumer.

### 5.5.2 Middleware e ordine della pipeline

Il middleware è una sequenza. Un componente può modificare la richiesta prima del successivo, osservare la risposta dopo `await next()`, oppure terminare la pipeline. L'ordine influenza error handling, routing, autenticazione e autorizzazione.

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddProblemDetails();
builder.Services.AddControllers();
builder.Services.AddAuthentication();
builder.Services.AddAuthorization();

var app = builder.Build();

app.UseExceptionHandler();
app.UseHttpsRedirection();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

Per rendere operativo il gestore standard, registrare prima `AddProblemDetails`. In assenza di un handler personalizzato, il middleware restituisce una risposta Problem Details quando il servizio è disponibile. L'ordine reale dipende da servizi e hosting: seguire la documentazione della versione ASP.NET Core scelta. In generale il gestore eccezioni deve avvolgere i componenti che si vogliono gestire; autenticazione deve precedere autorizzazione; il routing deve aver stabilito l'endpoint prima che componenti dipendenti dall'endpoint lo usino. Non copiare meccanicamente un ordine trovato in un progetto diverso.

Un middleware per correlare le richieste deve propagare un identificatore sicuro e aggiungere contesto ai log, ma non deve fidarsi ciecamente di un valore arbitrario passato dall'esterno. Anche un header di correlazione può essere usato per iniettare caratteri o dati ingannevoli nei log; normalizzare e limitare la lunghezza.

### 5.5.3 Routing e binding

Minimal API e controller offrono convenzioni diverse per dichiarare route e binding. Una route esplicita rende visibile il contratto:

```csharp
app.MapGet("/api/products/{id:int}", async (
    int id, IProductService service, CancellationToken ct) =>
{
    var item = await service.FindAsync(id, ct);
    return item is null
        ? Results.NotFound()
        : Results.Ok(item);
});
```

La constraint `:int` restringe il matching; non sostituisce una risposta coerente per input non valido. Per request complesse definire un tipo DTO anziché legare un'entità interna. Evitare parametri implicitamente ambigui e testare l'overload di route, slash finali, versioni e route non trovate.

La validazione deve avvenire al confine e includere vincoli di dominio pertinenti. Un controllo sintattico (campo obbligatorio, lunghezza massima) è diverso da una regola di business (prodotto attivo, prezzo modificabile). Restituire errori leggibili e stabili, senza stack trace o dettagli di database.

### 5.5.4 Errori prevedibili

Definire una tassonomia di errori: input non valido, risorsa inesistente, conflitto, non autenticato, non autorizzato, dipendenza non disponibile e errore inatteso. Mappare ogni categoria a status code e corpo consistente. `ProblemDetails` è un formato standard utile per risposte HTTP, ma i dettagli sensibili devono essere esclusi in produzione.

Le eccezioni non dovrebbero essere usate come controllo di flusso ordinario. La logica applicativa può restituire un risultato esplicito per conflitti attesi; il middleware centrale gestisce gli errori inattesi, registra l'eccezione e restituisce un identificatore di correlazione. Non restituire HTTP 200 con `{ "success": false }` se il contratto prevede status semantici; non trasformare ogni errore in 500 senza classificazione.

Un `catch` locale è appropriato se il componente può recuperare, aggiungere contesto utile o tradurre una specifica eccezione in un risultato noto. Altrimenti lasciar propagare al gestore centrale. Evitare log duplicati della stessa eccezione a ogni livello.

### 5.5.5 Filtri, middleware ed endpoint filter

La scelta del punto d'estensione dipende dall'ambito:

- **middleware:** cross-cutting a livello di pipeline, per log, header o gestione globale;
- **filtro MVC:** comportamento nel lifecycle dei controller, per endpoint MVC;
- **endpoint filter:** logica riutilizzabile per gruppi di Minimal API, inclusi controlli su argomenti;
- **codice applicativo:** regole specifiche del caso d'uso che devono essere testabili senza HTTP.

Non collocare regole di dominio in middleware solo perché è il primo hook conosciuto. Un middleware non dovrebbe conoscere il concetto di “ordine annullato” o “cliente premium”.

### 5.5.6 Timeout, cancellazione e resilienza

Ogni chiamata remota può fallire o impiegare troppo tempo. Propagare `CancellationToken` dalle API alle query e ai client HTTP; applicare timeout espliciti e limiti per componente. Un timeout del client non garantisce che l'operazione remota sia stata annullata: l'esito può essere ambiguo, quindi le operazioni di scrittura devono considerare idempotency key o meccanismi di verifica.

Retry automatici sono adatti solo a errori transitori e operazioni sicure da ripetere. Non fare retry indiscriminati su ogni eccezione o su operazioni non idempotenti. Usare backoff con jitter, budget complessivo, circuit breaker se utile e telemetria che mostri i tentativi. Evitare retry annidati in più livelli: moltiplicano la pressione sul servizio già degradato.

### 5.5.7 CORS, rate limiting e documentazione

CORS è una policy applicata dai browser, non un'autenticazione. Consentire origini, metodi e header minimi; non combinare wildcard con credenziali. Il rate limiting protegge risorse e client equamente, ma una policy in memoria per istanza non produce limiti globali in un cluster. Scegliere chiave e storage coerenti con il deployment, proteggendo le chiavi da spoofing.

OpenAPI descrive endpoint e schemi e può generare client, ma la specifica deve essere parte della revisione. Mantenere esempi, errori, autenticazione e versionamento aggiornati. Diff automatizzati tra specifiche aiutano a individuare breaking change prima del rilascio.

### 5.5.8 Checklist della parità HTTP

Prima di spostare il traffico verificare: status code; schema e casing JSON; header; autenticazione; codici di errore; date e timezone; paginazione; ordinamento; CORS; timeout; payload grandi; input malformati; richieste duplicate; cancellazione e versionamento. Eseguire i test contro vecchio e nuovo sistema con gli stessi casi, confrontando gli output normalizzati e documentando ogni differenza intenzionale.
