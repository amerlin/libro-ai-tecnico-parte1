## 5.8 Sicurezza e identità

La sicurezza non è un passaggio finale di hardening. Cambiare framework e identità modifica cookie, token, chiavi, policy e trust boundary. Una migrazione può mantenere gli endpoint e allo stesso tempo disconnettere gli utenti, accettare token non validi o rivelare dati. Definire i requisiti e verificare il flusso end-to-end prima del cutover.

### 5.8.1 Iniziare da threat model e inventario

Identificare asset (dati personali, credenziali, pagamenti, sessioni), attori, confini di fiducia e minacce rilevanti. Per ogni flusso chiedersi chi può invocarlo, come viene autenticato, quali permessi servono, quali input controlla e cosa accade se la dipendenza fallisce.

Mappare:

- provider di identità e modalità di login;
- cookie, sessioni, token access e refresh, durata e revoca;
- ruoli, claims, tenant e regole d'autorizzazione;
- segreti applicativi, chiavi di firma e certificati;
- dati sensibili nei log, backup, cache e telemetria;
- protezioni esistenti, dipendenze vulnerabili e procedure d'incidente.

Le policy scritte nel codice possono essere incomplete rispetto alla configurazione del gateway o del provider. Verificare la catena completa, inclusi reverse proxy e client. Fare approvare i cambiamenti da chi è responsabile di sicurezza e identità.

### 5.8.2 Autenticazione e autorizzazione non sono la stessa cosa

L'autenticazione stabilisce l'identità; l'autorizzazione decide cosa quell'identità può fare. In ASP.NET Core la pipeline usa handler di autenticazione e policy:

```csharp
builder.Services.AddAuthentication()
    .AddJwtBearer();

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("CatalogEditors", policy =>
        policy.RequireClaim("permission", "catalog.write"));
});

app.UseAuthentication();
app.UseAuthorization();

app.MapPost("/api/products", CreateProduct)
   .RequireAuthorization("CatalogEditors");
```

Il frammento mostra la forma generale, non una configurazione JWT completa: emittente (`iss`), destinatario (`aud`), chiavi, HTTPS, scarto orario e validazione dei claim vanno configurati secondo l'identity provider. Non disabilitare la validazione della firma o del destinatario per far passare un test.

Ruoli e claims hanno semantiche diverse. Un ruolo descrive appartenenza a una categoria; un claim può rappresentare un attributo o permesso. Non affidarsi a un claim ricevuto da un client non autenticato. Per multi-tenant, verificare che l'identificativo tenant sia vincolato all'identità e che ogni query applichi il perimetro corretto.

### 5.8.3 Migrare password e account

Gli hash delle password non sono password reversibili. Se il sistema nuovo usa un algoritmo o formato diverso, le opzioni includono:

- mantenere temporaneamente la verifica tramite il sistema identità esistente;
- validare al primo login con il vecchio verificatore e aggiornare l'hash in modo sicuro;
- richiedere reset password se la verifica compatibile non è disponibile;
- migrare verso un identity provider condiviso con processo supportato.

Non abbassare il costo dell'hash o introdurre una password universale per semplificare il passaggio. Non esportare hash in file non protetti. Proteggere il flusso di reset, limitare tentativi e non rivelare se un account esiste. Pianificare account bloccati, MFA, utenti disabilitati e audit.

### 5.8.4 Cookie, token e continuità di sessione

I cookie devono avere `Secure`, `HttpOnly` e una policy `SameSite` coerente con i flussi di login. Se contengono credenziali, gestire CSRF per richieste che modificano stato. La protezione CSRF non è sostituita da CORS.

JWT è un formato di token, non una strategia di autorizzazione completa. Validare firma, emittente (`iss`), destinatario (`aud`), scadenza e algoritmo consentito; limitare durata e proteggere refresh token. Non usare token come sessione revocabile senza un meccanismo di revoca o rotazione. Ridurre i dati sensibili contenuti nel payload: il payload firmato non è necessariamente cifrato.

I cookie di ASP.NET Core Identity o la Data Protection API possono essere specifici dell'applicazione e delle chiavi usate. Se durante il rollout vecchio e nuovo sistema devono accettare lo stesso cookie, verificare esplicitamente formato, scopo, chiavi e compatibilità supportata. Non improvvisare la condivisione delle chiavi: comprometterle può consentire la forgiatura di cookie o la decifratura di dati protetti.

### 5.8.5 Data Protection API e chiavi

ASP.NET Core Data Protection protegge payload applicativi, inclusi cookie e token antiforgery. In sviluppo le chiavi possono essere locali; in produzione le istanze devono avere una configurazione durevole e coerente quando devono decifrare gli stessi payload. Conservare le chiavi in storage protetto, limitarne l'accesso, pianificare rotazione e backup e impostare un application name appropriato per isolare applicazioni.

Un container effimero non deve essere l'unico luogo dove risiedono chiavi che servono dopo il riavvio. D'altra parte, condividere indiscriminatamente lo stesso key ring fra applicazioni aumenta l'impatto di una compromissione. Testare restart, scale-out e rotazione in un ambiente simile alla produzione.

### 5.8.6 Segreti e configurazione sicura

Usare identità gestite o secret store quando disponibili, permessi minimi, rotazione e audit. Evitare chiavi in `appsettings.Production.json`, Dockerfile, immagini, repository o log CI. Un secret presente nella history Git va considerato compromesso: rimuoverlo dal file non revoca la credenziale.

Separare segreti e configurazione ordinaria, ma non trattare un URL interno o un nome utente come sicuro per definizione. Tutto ciò che compare nelle eccezioni o negli header può finire in un log. Definire redazione e classificazione dei dati per log, tracing e metriche.

### 5.8.7 Difese per API web

- Validare input sul server, limitare dimensione e complessità delle richieste.
- Usare query parametrizzate; non costruire SQL concatenando input.
- Codificare output secondo il contesto e non fidarsi di dati già salvati.
- Configurare CORS con origini esplicite; non è un controllo di accesso per client non-browser.
- Impostare TLS e forwarded headers solo per proxy fidati.
- Applicare rate limiting, timeout e limiti di concorrenza appropriati.
- Ridurre permessi di database, file system e identità cloud.
- Mantenere pacchetti e immagini aggiornati e scansionare le dipendenze.

I middleware di sicurezza devono essere ordinati e testati in hosting reale. Una policy CORS corretta in locale può essere diversa dietro gateway. Non esporre stack trace in produzione; associare l'errore a un correlation id che il supporto può cercare.

### 5.8.8 Test di sicurezza nella transizione

Provare almeno: anonimo su route protetta; utente autenticato senza permesso; permesso valido; token scaduto, malfirmato o con destinatario (`aud`) errato; tenant diverso; cookie senza protezione CSRF; credenziale revocata; limite di rate; input e payload eccessivi. Verificare che gli errori non rivelino dati e che i log non contengano token o password.

Mantenere una matrice delle policy per endpoint. Ogni route deve avere una decisione esplicita: anonima, autenticata o protetta da policy nominata. Le route nuove non devono diventare anonime per omissione. Integrare test automatici e una verifica di configurazione in CI.

### 5.8.9 Cutover dell'identità

Durante una migrazione incrementale è possibile che alcuni endpoint usino il vecchio provider e altri il nuovo. Definire chi emette il token, chi lo valida e quali claims sono autorevoli. Se si usa un gateway per tradurre identità, documentare i trust boundary e impedire che il client possa falsificare gli header interni.

Preparare una strategia per sessioni non trasferibili: riautenticazione comunicata agli utenti, durata della transizione, revoca delle sessioni e supporto. Misurare i login falliti dopo il cutover e predisporre un rollback che non riattivi credenziali compromesse. La continuità non giustifica mantenere per sempre un algoritmo o un cookie legacy insicuro.
