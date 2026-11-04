## 5.13 Approfondire la mappa dai principali ecosistemi

I confronti tra ecosistemi diventano utili quando partono da un'applicazione concreta. Questa sezione raccoglie differenze ricorrenti che una migrazione dovrebbe provare esplicitamente. Non sono regole assolute: framework e versioni cambiano, e un progetto può adottare convenzioni diverse da quelle più comuni.

### 5.13.1 Da PHP e framework PHP

In una classica applicazione PHP, il modello di esecuzione può essere per richiesta: un web server inoltra la richiesta al runtime, che carica codice e bootstrap. Framework come Laravel o Symfony introducono container, middleware, routing, ORM, sessioni e console command. In .NET il processo web rimane tipicamente attivo e gestisce molte richieste durante la propria vita.

Questa differenza impone di cercare stato globale mutabile e risorse inizializzate una sola volta. Un singleton .NET non viene ricreato per ogni richiesta; non deve trattenere l'utente corrente o un `DbContext`. L'applicazione deve essere thread-safe e non affidarsi al teardown implicito che il processo PHP poteva offrire.

Mappare:

- route e controller PHP verso endpoint/controller ASP.NET Core, conservando metodi, status e formati;
- service container e service providers verso registrazioni DI con lifetime appropriato;
- middleware e kernel events verso pipeline ASP.NET Core, distinguendo codice globale da logica endpoint;
- Eloquent o Doctrine verso EF Core o SQL esplicito, verificando lazy loading, transazioni e naming;
- queue worker e scheduler verso broker, worker o orchestratore, non necessariamente `BackgroundService`;
- sessioni e file upload verso storage distribuito e limiti HTTP espliciti.

Un aspetto spesso trascurato è il tipo dinamico dei dati. PHP può convertire implicitamente stringhe numeriche, valori booleani o date; C# richiede parsing e conversioni più visibili. Non replicare coercizioni ambigue senza capire quali client ne dipendano. Per importare valori storici, definire cultura, decimal separator, encoding e regole per stringhe vuote.

### 5.13.2 Da Python e framework ASGI/WSGI

In Python distinguere il modello WSGI dal modello ASGI e capire se l'applicazione è davvero asincrona. Un endpoint `async` che chiama una libreria sincrona può bloccare l'event loop. In .NET, chiamare un metodo sincrono di I/O in una route non viene reso asincrono dalla firma del delegate: occorre usare API asincrone della libreria o isolare il lavoro secondo un piano di capacità.

Django, Flask e FastAPI offrono convenzioni diverse per middleware, dependency override, serializzazione, migrazioni e background task. FastAPI genera OpenAPI da tipi e dichiarazioni, ma la specifica esistente va verificata contro le response effettive. Non assumere che il target generi gli stessi schema, descrizioni o default.

Per la persistenza, confrontare SQLAlchemy, Django ORM e l'eventuale SQL diretto con il modello EF Core. Verificare transazioni implicite, autoflush, session lifecycle, timezone e query lazy. Un Python `None` serializzato come `null` può diventare una proprietà assente se il serializer .NET è configurato diversamente.

Python consente spesso di distribuire sorgenti e dipendenze in un ambiente virtuale. In .NET l'artefatto publish, il runtime e il container sono parte della consegna. La pipeline dovrebbe ricreare l'output da checkout pulito, non riutilizzare un `venv` o un output locale. Le dipendenze native Python hanno analoghi problemi di piattaforma nelle librerie .NET con componenti nativi: provare l'immagine target, non soltanto il test locale.

### 5.13.3 Da JavaScript/Node.js

Node.js usa un event loop e un modello di I/O non bloccante. Il codice CPU-bound può bloccare l'event loop; in ASP.NET Core un lavoro CPU-bound può occupare thread del pool e saturare l'applicazione. In entrambi i casi servono limiti, profiling e un eventuale worker separato. Non trasferire un `setTimeout` o una promise non attesa come se fossero una coda affidabile.

Express compone middleware con convenzioni proprie, mentre NestJS introduce moduli, guard, pipe e interceptor. Mappare ciascuna responsabilità, senza trasformare ogni middleware in un servizio DI o ogni provider Nest in singleton .NET. Controllare l'ordine di middleware, la gestione degli errori asincroni e l'effetto delle route non corrispondenti.

TypeScript fornisce controlli statici durante la build ma i dati HTTP restano dinamici a runtime. C# offre un sistema statico integrato nel compilatore, tuttavia il binding JSON non sostituisce validazione. Non rimuovere i controlli runtime perché il DTO ha proprietà non-nullable: client non conformi possono inviare body incompleti.

Controllare differenze di serializzazione: `undefined` in JavaScript può essere omesso, `null` è distinto; in JSON non esiste `undefined`. Le opzioni di naming camelCase, enum come stringhe o numeri, date e proprietà ignorate devono essere definite e testate. Verificare inoltre gli stream: bufferizzare tutto il body può aumentare memoria e latenza rispetto a una pipeline che processava dati incrementali.

### 5.13.4 Da Java e Spring Boot

Java e .NET condividono alcuni concetti di runtime gestito, garbage collection, compilazione e applicazioni server long-running, ma il modello di librerie e framework resta specifico. In Spring, confrontare bean scope, filtri servlet, interceptor, controller advice, configurazione e transazioni con i componenti ASP.NET Core corrispondenti.

Un bean `singleton` Spring e un singleton DI .NET hanno entrambi una durata ampia, ma il comportamento effettivo dipende da proxy, scope e lifecycle del framework. Controllare le dipendenze scoped e la sicurezza concorrente. Non assumere che un `@Transactional` si traduca in una transazione che attraversa chiamate HTTP o eventi.

Confrontare JPA/Hibernate con EF Core su tracking, flush, lazy loading, cascade, lock ottimistico e query generation. Le due tecnologie possono produrre SQL diverso e differire nei limiti del provider. Provare query e migrazioni sullo stesso motore database; una conversione di annotation non è un piano dati.

Confrontare Maven/Gradle con NuGet e i file `.csproj` riguardo a versioni, dipendenze transitive, plugin e packaging. Verificare profili di build, variabili ambientali e configurazione del server. I test su Spring Test o container di test vanno sostituiti da test equivalenti sul target e sul provider effettivo, non semplicemente rimossi.

### 5.13.5 Tabella di mapping delle responsabilità

Durante l'assessment costruire una tabella concreta. Esempio:

| Sistema sorgente | Comportamento osservato | Candidato .NET | Prova di migrazione |
|---|---|---|---|
| Middleware Laravel | Aggiunge tenant da un claim e blocca utenti sospesi | Middleware più policy o servizio endpoint | Test anonimo, utente sospeso e tenant valido |
| Dependency FastAPI | Fornisce repository per richiesta | Servizio scoped e repository/query service | Due richieste non condividono stato |
| Middleware Express | Trasforma errori asincroni in JSON | Exception handler centrale | Eccezioni note e inattese con status coerente |
| Filtro Spring | Verifica permesso di scrittura | Policy authorization | Token scaduto, claim mancante e claim valido |
| Job Celery | Import idempotente con retry | Worker e broker/job scheduler | Crash durante batch e replay senza duplicati |
| Migrazione Doctrine | Aggiunge campo con backfill | Script controllato expand–migrate–contract | Rollout con vecchia versione ancora attiva |

La colonna “candidato .NET” è un'ipotesi finché la prova non la conferma. Annotare anche alternative e decisione. Se il comportamento sorgente non è determinabile, creare prima un test o una sessione di discovery.

### 5.13.6 Scheda di decisione per un concetto

Una scheda riutilizzabile può avere questi campi:

```text
Concetto sorgente:
Versione e configurazione:
Responsabilità osservata:
Input e output:
Lifecycle e scope:
Dipendenze e side effect:
Candidato ASP.NET Core:
Differenze semantiche:
Test che dimostra il mapping:
Decisione e motivazione:
Owner e data di revisione:
```

La scheda impedisce due errori opposti: tradurre tutto meccanicamente o ricominciare senza preservare nulla. I dettagli si possono archiviare vicino alla decisione tecnica e collegare ai test; il capitolo o la documentazione di progetto deve conservare almeno la motivazione e le incompatibilità ancora aperte.

### 5.13.7 Quando mantenere un componente nel sistema originario

Non tutto deve essere migrato immediatamente. Un motore di report con dipendenze non portabili, un adapter verso hardware o un job stabile possono restare temporaneamente dietro un contratto di servizio. La decisione va confrontata con il costo di mantenere runtime, competenze, security patch e pipeline separate.

Un componente mantenuto deve avere:

- owner, responsabile degli aggiornamenti e processo di incident response;
- interfaccia di rete o messaggio documentata, con autenticazione e timeout;
- monitoraggio e piano di continuità;
- dipendenze e dati che ne definiscono la vita residua;
- criterio e data di revisione della decisione.

La coesistenza è una strategia, non un risultato finale implicito. Se la migrazione completa non è conveniente, dichiarare il confine come architettura permanente e finanziarne la manutenzione; se è transitorio, misurarne la riduzione.

## 5.14 Prove di migrazione dei dati: runbook e controlli

Lo spostamento dei dati è un processo controllato con input, checkpoint e report. Il runbook seguente aiuta a trasformare uno script una tantum in un'attività ripetibile, verificabile e recuperabile.

### 5.14.1 Preparare il runbook

Prima di eseguire una copia reale, documentare:

1. database sorgente e target, versioni, region e responsabili;
2. oggetti e intervalli inclusi, esclusioni e regole di trasformazione;
3. permessi minimi delle identità usate e scadenza delle credenziali;
4. volume previsto, throughput, durata stimata e impatto sulle query;
5. punto di consistenza, strategia delta e trattamento delle scritture concorrenti;
6. checkpoint, retry, deduplicazione e ripresa dopo interruzione;
7. validazioni, soglie di errore, approvatore e piano di rollback;
8. retention e protezione dei file temporanei e dei report.

Il runbook non deve includere segreti in chiaro. I riferimenti alle credenziali devono indicare il secret store e l'identità autorizzata. Limitare accesso ai dump, cifrarli in transito e a riposo e cancellarli secondo retention approvata.

### 5.14.2 Snapshot, delta e freeze

Il piano di migrazione deve definire cosa significa “dati coerenti”. Una fotografia estratta in più query a orari diversi può contenere righe incompatibili tra loro se il sistema continua a scrivere. Usare snapshot transazionali o un meccanismo CDC quando il provider lo supporta e la finestra di consistenza è necessaria.

Se si effettua un freeze:

- comunicare in anticipo il blocco e identificare tutte le write path, incluso back office;
- fermare job e consumer in ordine concordato;
- attendere che le transazioni in corso si completino;
- registrare watermark temporale o identificativo dell'ultimo record;
- estrarre, trasformare e importare;
- eseguire riconciliazione e test applicativi;
- riaprire le scritture una sola volta deciso il sistema owner.

Se il freeze non è possibile, usare uno snapshot più un delta ordinato e definire come trattare update e delete. Il timestamp `updated_at` da solo può non bastare se non è monotono, ha precisione insufficiente o non registra cancellazioni. Un log transazionale o una tabella outbox può fornire una sorgente di cambiamenti più affidabile.

### 5.14.3 Trasformazioni versionate

Ogni trasformazione deve essere identificata da una versione dello script e avere esempi prima/dopo. Separare parsing, validazione, mapping e scrittura per poter testare le regole senza connettersi ai database.

Esempi di trasformazioni che richiedono approvazione:

- stringa vuota convertita in `null`;
- codice paese normalizzato;
- date locali interpretate in un fuso nominato;
- enum legacy mappati a nuovi valori;
- importi con scala differente;
- record duplicati uniti secondo una regola di dominio.

Non inferire unità o timezone da un nome di campo ambiguo. Se un dato non può essere interpretato, metterlo in quarantena con ragione e chiave tecnica; non scartarlo silenziosamente. I report non devono esporre valori personali se bastano conteggio, categoria di errore e identificativo pseudonimo.

### 5.14.4 Importazione riprendibile

Per dataset grandi elaborare batch limitati, registrando il checkpoint in storage durevole. La chiave di ripresa deve rappresentare un ordine stabile, come una chiave primaria o un cursore monotono, non l'offset di una query che cambia mentre si importano righe.

Ogni batch può seguire questo ciclo:

1. leggere un intervallo consistente;
2. trasformare e validare in memoria limitata;
3. scrivere in transazione o staging;
4. verificare il batch;
5. registrare il checkpoint solo dopo il commit;
6. proseguire o fermarsi su soglia di errore.

Se il processo termina dopo il commit ma prima del checkpoint, il batch può essere ripetuto. Usare upsert con chiave stabile o una tabella di deduplicazione; non assumere consegna exactly-once. Il checkpoint prima del commit può invece saltare dati. Definire una strategia per ripetere in sicurezza.

### 5.14.5 Staging e cutover

Una tabella di staging consente di importare e validare senza esporre immediatamente i record agli utenti. Può contenere migration id, origine, timestamp e stato di validazione. Proteggere lo staging come il dato originale; non lasciarlo diventare un archivio permanente di copie non governate.

Il cutover richiede una decisione sulla lettura autorevole. Possibili percorsi: cambiare connection string, attivare un routing di tenant, promuovere tabelle o aggiornare un alias. Documentare la cache e la propagazione della configurazione, perché il cambio potrebbe non essere istantaneo.

Prima dell'attivazione, congelare le scritture secondo il piano oppure completare il delta, validare i criteri e verificare accesso e performance. Dopo l'attivazione, monitorare errori e mismatch per un periodo concordato; mantenere l'origine in sola lettura finché il rollback dati è ancora possibile.

### 5.14.6 Report di riconciliazione

Un report utile include:

| Verifica | Origine | Target | Esito |
|---|---:|---:|---|
| Righe lette, scritte, scartate | conteggio | conteggio | riconciliato? |
| Record per stato e tenant | aggregato | aggregato | scostamento |
| Chiavi orfane | conteggio | conteggio | soglia |
| Hash di campioni canonici | hash | hash | corrispondenza |
| Valori non trasformabili | conteggio | quarantena | owner |

I checksum devono essere calcolati su una rappresentazione canonica che definisce ordinamento, encoding e null. Un hash dell'intero file può rilevare differenze, ma non spiega quale record o trasformazione le abbia causate. Combinare aggregati, campioni e conteggi per localizzare rapidamente il problema.

Il report include migration id, commit dello script, configurazione non segreta, orari, watermark, durata e identità esecutrice. Conservare il report secondo policy e rendere riproducibili le query di verifica.

### 5.14.7 Criteri di stop

Interrompere l'importazione o il cutover se:

- gli errori superano la soglia concordata o coinvolgono dati critici;
- il delta non ha un watermark affidabile;
- la replica o il database supera il budget di carico;
- gli aggregati divergono senza una regola approvata;
- non è chiaro quale sistema possiede le scritture;
- il rollback richiesto non è più praticabile.

Fermarsi è un esito valido. Il runbook deve indicare come lasciare il sistema in uno stato consistente e chi decide se riprendere, ripristinare o applicare una correzione.

## 5.15 Diagnosi operativa durante la migrazione

Gli incidenti di migrazione spesso emergono solo quando il target incontra rete, proxy, credenziali e carichi reali. Una diagnosi efficace parte dai segnali e dal percorso della richiesta, non dalla modifica casuale di configurazioni.

### 5.15.1 La readiness fallisce, ma il processo è attivo

Separare liveness da readiness e leggere il dettaglio del controllo che fallisce. Verificare che hostname, certificati, DNS, accessi database e timeout siano quelli dell'ambiente target. Un health check che dipende da tutte le API esterne può rendere indisponibile l'intero servizio per una dipendenza non critica.

Confrontare configurazione attiva e sorgente attesa senza stampare segreti. Registrare quali provider di configurazione sono abilitati e validare opzioni all'avvio. Se il servizio si avvia con un endpoint esterno vuoto o un valore di default, correggere la validazione invece di aggiungere retry indefiniti.

### 5.15.2 Errori 401 o 403 dopo il cutover

401 indica in genere un problema di autenticazione; 403 indica identità riconosciuta ma non autorizzata, anche se il contratto può variare. Verificare emittente (`iss`), destinatario (`aud`), scadenze, chiavi di firma, scarto orario e claim ricevuti. Confrontare il token in modo sicuro senza copiarlo nei ticket o nei log.

Controllare mapping di claim e differenze di casing o nomi tra provider. Un framework sorgente può convertire automaticamente gruppi in ruoli, mentre il target richiede una policy esplicita. Testare un utente rappresentativo per ogni profilo e distinguere permesso mancante da route non autenticata. Non disabilitare authorization per “sbloccare il deploy”.

### 5.15.3 502, 503 e timeout intermittenti

Seguire la richiesta attraverso client, gateway, ingress, Kestrel e dipendenze. Confrontare timeout configurati a ogni livello e verificare se un proxy chiude la connessione prima dell'applicazione. Correlare trace id e timestamp tra sistemi; senza sincronizzazione oraria i log possono sembrare contraddittori.

Osservare pool connessioni, thread pool, code, DNS e saturazione database. Un retry su un timeout può moltiplicare il carico e peggiorare l'incidente. Ridurre temporaneamente il traffico o disattivare la capability può essere più sicuro che aumentare tutti i timeout.

### 5.15.4 Differenze di serializzazione

Se i test passano ma un client rifiuta la response, confrontare byte e schema: `Content-Type`, casing, proprietà omesse, enum, formato data, precisione numerica e encoding. Verificare opzioni globali del serializer e attributi sul DTO. Un aggiornamento del serializer o un modello con nullability diversa può cambiare il JSON senza modificare la route.

Riprodurre con fixture minime e un test contrattuale. Non patchare la risposta in middleware per correggere un singolo DTO: la regola deve vivere nel mapping o nella configurazione condivisa documentata.

### 5.15.5 Mismatch di database dopo la migrazione

Prima di correggere i record, verificare query, filtri, timezone, collations, precisione e ordine. Calcolare differenze per categoria e chiave, usando dati minimizzati. Una differenza può provenire da una query N+1 o da una proprietà null, non dalla copia dati.

Confrontare SQL generato e piani d'esecuzione. Verificare se il vecchio ORM applicava soft-delete, tenant filter o conversioni implicite. Non riparare manualmente il database live prima di sapere se il processo di importazione può riprodurre il problema.

### 5.15.6 Runbook di incidente

Per un errore in rollout:

1. identificare release, percentuale traffico e capability coinvolta;
2. verificare alert e impatto utente, distinguendo sintomo e causa;
3. applicare la soglia predefinita: fermare incremento o attivare rollback;
4. proteggere dati e fermare eventuali writer duplicati;
5. salvare log e metriche necessari, redigendo segreti e dati personali;
6. assegnare un responsabile tecnico e un comunicatore;
7. dopo la stabilizzazione, documentare causa, rilevazione e prevenzione.

Non fare debug direttamente in produzione con logging verboso permanente o query non controllate. Ogni modifica temporanea ha owner, scadenza e piano di rimozione.

## 5.16 Verifica finale: criteri di successo

Considerare la migrazione conclusa solo quando il target possiede chiaramente le capability previste e il sistema sorgente non mantiene dipendenze operative nascoste. Account, job, backup, credenziali e supporto devono avere un owner nel nuovo assetto o una data di dismissione.

Misurare il successo con criteri concordati: flussi critici conformi, error rate e latenza entro budget, dati riconciliati, sicurezza approvata, rollback provato, operatori formati e costi del vecchio sistema rimossi o motivati. Conservare le decisioni e i report in modo accessibile al team che sarà on-call.

### 5.16.1 Fonti ufficiali e aggiornamento

Consultare documentazione ufficiale e controllare la versione target prima di applicare un esempio. Le pagine evolvono; per un progetto reale annotare la data di verifica e la versione .NET:

- [.NET — Porting to .NET](https://learn.microsoft.com/dotnet/core/porting/)
- [.NET — Panoramica del ciclo di vita](https://dotnet.microsoft.com/platform/support/policy/dotnet-core)
- [ASP.NET Core — Panoramica](https://learn.microsoft.com/aspnet/core/introduction-to-aspnet-core)
- [ASP.NET Core — Middleware](https://learn.microsoft.com/aspnet/core/fundamentals/middleware/)
- [ASP.NET Core — Dependency Injection](https://learn.microsoft.com/dotnet/core/extensions/dependency-injection)
- [ASP.NET Core — Configurazione](https://learn.microsoft.com/aspnet/core/fundamentals/configuration/)
- [ASP.NET Core — Autenticazione](https://learn.microsoft.com/aspnet/core/security/authentication/)
- [ASP.NET Core — Test d'integrazione](https://learn.microsoft.com/aspnet/core/test/integration-tests)
- [Entity Framework Core — Migrazioni](https://learn.microsoft.com/ef/core/managing-schemas/migrations/)
- [Entity Framework Core — Performance](https://learn.microsoft.com/ef/core/performance/)
- [.NET — Docker](https://learn.microsoft.com/dotnet/core/docker/)
- [.NET — Architettura delle applicazioni](https://learn.microsoft.com/dotnet/architecture/)
