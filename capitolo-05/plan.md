# Capitolo 5 — Migrare a .NET da altri linguaggi e piattaforme

## Obiettivo e perimetro

Il capitolo sarà una guida pratica alla migrazione di un'applicazione web o di un servizio da un linguaggio e dal relativo ecosistema — per esempio PHP, Python, JavaScript/Node.js, Java o un altro stack — a .NET e ASP.NET Core. Non sarà una guida riferita a una sola tecnologia di partenza: mostrerà come riconoscere i concetti equivalenti, verificare le differenze e scegliere un percorso di migrazione adatto al progetto.

Il riferimento sarà .NET moderno (attualmente .NET 10) e ASP.NET Core. Si chiarirà che “.NET Core” è il nome delle versioni fino a .NET Core 3.1, mentre dalla versione 5 la piattaforma si chiama semplicemente .NET.

Il capitolo dovrà accompagnare il lettore dall'assessment iniziale alla messa in produzione, distinguendo la riscrittura completa dalla migrazione incrementale e includendo esempi, checklist, test e criteri per valutare il risultato. Le analogie tra ecosistemi serviranno da orientamento, non implicheranno che framework o runtime diversi siano intercambiabili.

## Destinatari e prerequisiti

- Sviluppatori che conoscono già almeno un linguaggio o framework e devono orientarsi in .NET.
- Familiarità di base con HTTP, API, database, test e controllo versione.
- Non è richiesta esperienza precedente con C# o ASP.NET Core: i concetti specifici di .NET saranno introdotti nel contesto.

## Struttura prevista e budget delle pagine

Obiettivo editoriale: **circa 50 pagine complessive per il PDF del capitolo**, frontespizio, indice, esempi, conclusioni e riferimenti inclusi. La ripartizione è indicativa e andrà verificata con la build finale.

| Sezione | Contenuto | Pagine stimate |
|---|---|---:|
| Apertura | Frontespizio, abstract, obiettivi, prerequisiti e convenzioni | 2 |
| 1. Perché migrare e come valutare il progetto | Motivazioni, vincoli, costi, rischi, assessment e criteri di successo | 4 |
| 2. Mappare linguaggi, runtime e strumenti | Da PHP, Python, Node.js e Java a C#, .NET, NuGet e CLI | 4 |
| 3. Pianificare la migrazione | Strategie, fasi, priorità, coesistenza e rollback | 4 |
| 4. Architettura e organizzazione del codice | ASP.NET Core, hosting, struttura, Minimal API, MVC e pattern | 5 |
| 5. Richieste HTTP e pipeline | Routing, middleware, errori, filtri, validazione e formati | 4 |
| 6. Configurazione, stato e dipendenze | DI, lifetimes, opzioni, secrets, cache, sessioni e background task | 4 |
| 7. Dati e integrazione con i sistemi esistenti | EF Core, schema, migrazioni, trasferimento dati e contratti | 5 |
| 8. Sicurezza | Autenticazione, autorizzazione, cookie, token, segreti e protezione dati | 4 |
| 9. Testing e qualità | Test unitari e d'integrazione, automazione e parità funzionale | 4 |
| 10. Prestazioni e comportamento del runtime | Async, concorrenza, memoria, serializzazione e profiling | 3 |
| 11. Container, CI/CD e produzione | Docker, pipeline, hosting, osservabilità e deployment | 4 |
| 12. Caso pratico, checklist e conclusioni | Percorso end-to-end, verifiche finali, fonti e riepilogo | 3 |
| **Totale** |  | **50** |

## 1. Perché migrare e come valutare il progetto

- Motivazioni tipiche: manutenzione, supporto, prestazioni, sicurezza, competenze disponibili, costi operativi e standardizzazione.
- Distinguere una migrazione tecnologica da una riscrittura funzionale: conservare il comportamento prima di introdurre nuove funzionalità.
- Inventario iniziale: servizi, endpoint, processi pianificati, dipendenze, database, code, file, integrazioni, traffico e requisiti non funzionali.
- Analisi delle dipendenze e del loro stato: supporto per .NET, alternative disponibili, licenze e costi di sostituzione.
- Rilevazione dei requisiti impliciti nel codice e nei dati: formati, timezone, encoding, null, ordinamenti e compatibilità dei client.
- Stabilire baseline e criteri misurabili: copertura dei flussi, latenza, throughput, errori, disponibilità e tempi di build/deployment.
- Produrre una mappa delle funzionalità e una valutazione rischi/priorità prima di scegliere la strategia.

## 2. Mappare linguaggi, runtime e strumenti

- **Linguaggi e runtime:** corrispondenze tra PHP, Python, JavaScript/Node.js, Java e C#; differenze tra runtime gestiti, compilazione, tipizzazione e gestione della memoria.
- **Pacchetti e dipendenze:** da Composer, pip/Poetry, npm/pnpm o Maven/Gradle a NuGet e ai riferimenti dichiarati nel file `.csproj`.
- **Toolchain:** installazione dell'SDK, uso di `dotnet new`, `dotnet restore`, `dotnet build`, `dotnet test`, `dotnet run` e `dotnet publish`; integrazione con IDE ed editor.
- **Progetto e soluzione:** ruolo di `.csproj`, file di soluzione, target framework, configurazioni e gestione delle versioni dell'SDK.
- **Ciclo di vita:** passaggio dall'entry point del framework di partenza a `Program.cs`, all'host .NET e al server Kestrel.
- **Librerie e interoperabilità:** valutare porting, sostituzione, wrapper o mantenimento temporaneo dei componenti non migrabili.
- Evitare la traduzione meccanica riga per riga: migrare responsabilità e comportamento, adottando le convenzioni .NET dove portano un vantaggio concreto.

## 3. Pianificare la migrazione

- Confronto tra riscrittura completa, migrazione per moduli e approccio incrementale (*strangler pattern*).
- Quando scegliere un *big bang* e quando mantenere temporaneamente in esercizio i sistemi vecchio e nuovo.
- Definizione dei confini: API, moduli, processi batch, database e responsabilità dei team.
- Strategia di rilascio: feature flag, routing del traffico, rollout graduale, osservazione e rollback.
- Gestione della compatibilità durante la transizione: API versioning, eventi, code e client che non possono essere aggiornati tutti insieme.
- Piano di dismissione del sistema precedente, evitando una coesistenza temporanea che diventi permanente.
- Checklist di fase con responsabili, dipendenze, condizioni di uscita e criteri di successo.

## 4. Architettura e organizzazione del codice

- Mappatura dei framework web: per esempio Laravel/Symfony, Django/FastAPI/Flask, Express/NestJS e Spring Boot verso ASP.NET Core.
- Modello di hosting: `Program.cs`, host, Kestrel, server in-process/out-of-process e reverse proxy.
- Scelta tra Minimal APIs e MVC/Controllers in base a dimensione, convenzioni, complessità e organizzazione del team.
- Organizzazione delle cartelle e separazione tra API, dominio, applicazione e infrastruttura; quando Clean Architecture è utile e quando è superflua.
- Introduzione graduale a CQRS e altri pattern, evitando di aggiungere livelli senza un requisito concreto.
- Servizi singleton, stato per richiesta e modello concorrente: differenze rispetto ai modelli di esecuzione dei framework di partenza.
- Esempio di struttura di un servizio .NET piccolo e sua possibile evoluzione in una soluzione più articolata.

## 5. Richieste HTTP e pipeline

- Confronto tra middleware ASP.NET Core, filtri, interceptor, hook e pipeline dei framework di partenza.
- Ordine e composizione della pipeline HTTP; routing per endpoint e routing basato sugli attributi.
- Binding e validazione degli input, codici di stato, header e formati JSON.
- Gestione coerente degli errori: eccezioni, `UseExceptionHandler`, `IExceptionHandler` e risposte Problem Details.
- Logging per richiesta, correlazione e propagazione dei trace identifier.
- CORS, compressione, rate limiting e altre funzioni trasversali, configurate in base alle necessità.
- Differenze di comportamento da verificare nei contratti HTTP esistenti, per non rompere i client durante la migrazione.

## 6. Configurazione, stato e dipendenze

- Container DI integrato: registrazione dei servizi e lifetimes Transient, Scoped e Singleton; injection tramite costruttore.
- Errori tipici nella migrazione: dipendenze con lifetime incompatibili e stato mutabile condiviso tra richieste.
- Configurazione gerarchica: `appsettings.json`, variabili d'ambiente, provider esterni e opzioni fortemente tipizzate.
- Sostituzione dei file `.env` e gestione dei segreti con User Secrets in sviluppo e secret store in produzione.
- Differenza tra cache, sessione e stato applicativo; opzioni distribuite per deployment con più istanze.
- Lavori in background, hosted services, cancellazione e gestione del ciclo di vita delle risorse.
- Gestione di `async`/`await` e propagazione di `CancellationToken` lungo la richiesta.

## 7. Dati e integrazione con i sistemi esistenti

- Mappatura da ORM come Hibernate, Sequelize o Prisma a Entity Framework Core; quando usare SQL diretto o un micro-ORM.
- Modelli di dominio, entità, DTO, tracking e durata di `DbContext`.
- Progettazione e applicazione delle migrazioni Code-First, revisione dello SQL generato e strategie di rollback.
- Migrazione dei dati: qualità, conversioni, volumi, verifiche di coerenza, finestre di fermo e sincronizzazione durante la coesistenza.
- Gestione sicura delle stringhe di connessione e uso di secret store.
- Transazioni, concorrenza, indici, query N+1 e differenze del provider di database.
- Compatibilità dei contratti: nomi dei campi, valori null, date, precisione numerica, enum e versionamento dello schema.
- Repository: quando aggiunge isolamento utile e quando duplica le astrazioni già offerte da EF Core.

## 8. Sicurezza

- Ricognizione delle funzionalità di sicurezza già presenti e definizione dei requisiti da mantenere.
- Autenticazione e autorizzazione in ASP.NET Core: Cookie, JWT bearer e integrazione OAuth2/OIDC.
- Claims, ruoli e policy; protezione degli endpoint e principio del minimo privilegio.
- Migrazione di identità e credenziali: password hash, sessioni, chiavi di firma, token e revoca.
- Protezioni web: CORS, CSRF, XSS, SQL injection, validazione degli input e rate limiting.
- Data Protection API, gestione delle chiavi e condivisione sicura tra istanze.
- Gestione dei segreti, TLS, logging senza dati sensibili e verifiche delle dipendenze.
- Pianificare test di sicurezza e una transizione che non indebolisca l'autenticazione durante la convivenza dei sistemi.

## 9. Testing e qualità

- Separare test unitari, test d'integrazione e test end-to-end; scegliere xUnit o NUnit e librerie di supporto come Moq o NSubstitute.
- Usare `WebApplicationFactory` per ospitare l'applicazione in memoria e verificare gli endpoint HTTP.
- Testare database e servizi esterni con sostituti controllati o ambienti effimeri, senza confondere i test con la produzione.
- Definire test di caratterizzazione sul sistema esistente e riutilizzarli come specifica del comportamento da preservare.
- Verificare contratti, regressioni, autorizzazioni, casi limite e compatibilità dei dati.
- Integrare restore, build, analisi, test e pubblicazione nella pipeline CI.
- Stabilire criteri di qualità e di copertura basati sui flussi critici, non solo su una percentuale globale.

## 10. Prestazioni e comportamento del runtime

- Modello asincrono e I/O non bloccante; evitare `.Result` e `.Wait()` nei percorsi di richiesta.
- Differenze nella concorrenza, nel pooling, nella gestione della memoria e nella garbage collection.
- Profilare prima di ottimizzare: confrontare la baseline usando carichi e dati rappresentativi.
- Controllare serializzazione JSON, allocazioni, query al database, cache e chiamate di rete.
- Considerare trimming e Native AOT solo dopo aver verificato compatibilità delle librerie, reflection e requisiti operativi.
- Evitare confronti di benchmark non equivalenti tra linguaggi, macchine o configurazioni.

## 11. Container, CI/CD e produzione

- Dockerfile multi-stage, immagini runtime appropriate, utente non root e gestione dei certificati.
- Pipeline GitHub Actions o Azure DevOps: restore, build, test, publish, scansione e distribuzione.
- Configurare ASP.NET Core dietro reverse proxy come Nginx, IIS o servizi gestiti; inoltro corretto di schema e IP.
- Health check, readiness, graceful shutdown, logging strutturato, metriche e tracing distribuito.
- Distribuzione con più istanze: stato condiviso, sessioni, cache, chiavi Data Protection e migrazioni database.
- Strategie blue/green o canary, rollback applicativo e compatibilità tra versioni durante il rilascio.
- Verificare costi, consumi, latenza e limiti del target di hosting prima di adottare AOT o altre ottimizzazioni.

## 12. Caso pratico, checklist e conclusioni

- Caso didattico: portare un servizio web esistente verso una API ASP.NET Core, mantenendo contratto HTTP e database.
- Mostrare assessment, scelta della strategia, struttura del progetto, implementazione di un endpoint e migrazione di un test.
- Evidenziare le differenze da adattare a seconda che l'origine sia PHP, Python, Node.js o Java, senza pretendere di coprire ogni framework.
- Checklist pre-migrazione, per ogni fase, pre-produzione e dismissione del sistema precedente.
- Riepilogo dei rischi più frequenti: riscrittura senza test, conversione meccanica, gestione errata dello stato, migrazioni dati non verificabili e rilascio senza rollback.

## Fonti e link ufficiali da approfondire

- **Panoramica e tooling Microsoft:**
  - Porting to .NET - Overview.
  - .NET Application Architecture Guides.
  - Documentazione della .NET CLI e del formato dei file di progetto.
- **ASP.NET Core:**
  - ASP.NET Core Fundamentals, in particolare hosting, `Program.cs`, middleware, DI e configurazione.
  - Documentazione ufficiale di routing, Minimal APIs, MVC, autenticazione e deployment.
  - Migrating to ASP.NET Core, utile per i paradigmi web attuali anche se parte dal vecchio .NET Framework.
- **Dati e ORM:**
  - Documentazione di Entity Framework Core e gestione delle migrazioni.
- **Produzione e sicurezza:**
  - Linee guida Microsoft per sicurezza, logging, health check, Docker e distribuzione di applicazioni ASP.NET Core.

## Criteri editoriali e di verifica

- Usare esempi brevi, riproducibili e coerenti tra le sezioni; indicare versione di .NET, prerequisiti e comandi.
- Separare sempre ciò che è comune a tutte le migrazioni dai dettagli specifici del linguaggio o framework di origine.
- Non presentare una corrispondenza come equivalenza perfetta: esplicitare differenze di lifecycle, concorrenza, sicurezza e deployment.
- Preferire documentazione ufficiale e fonti aggiornate; verificare collegamenti, nomi API e versioni prima della pubblicazione.
- Generare il PDF e controllare il numero di pagine: il target è 50, includendo le pagine introduttive e i riferimenti; se lo scostamento è significativo, riequilibrare esempi e approfondimenti senza diluire il contenuto.
