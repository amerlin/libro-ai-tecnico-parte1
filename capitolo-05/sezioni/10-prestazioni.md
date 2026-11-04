## 5.10 Prestazioni e comportamento del runtime

Una migrazione cambia runtime, librerie, scheduling, serializer e modalità di accesso ai dati. Il nuovo servizio può risultare più efficiente, equivalente o peggiore: la risposta si misura sul workload reale. Ottimizzare sulla reputazione del linguaggio o su un benchmark isolato porta a decisioni costose e poco attendibili.

### 5.10.1 Baseline e carichi confrontabili

Scegliere scenari che rappresentino uso, picchi e operazioni costose: lettura cache hit, miss, query DB, payload grande, dipendenza lenta e endpoint mutativo. Usare dataset e distribuzione dei dati confrontabili; una tabella con mille righe non simula una con milioni.

Misurare latenza p50/p95/p99, throughput, errori, CPU, memoria, allocazioni, connessioni e tempi di avvio. Includere warm-up e durata sufficiente a osservare garbage collection e saturazione delle dipendenze. Separare misure del client e del server: una rete più lenta non è una regressione del codice applicativo.

Per ogni test annotare versione runtime, build Release, hardware, container limits, numero istanze, configurazione, seed e commit. I confronti devono essere ripetibili; se il rumore è alto, raccogliere più campioni e indicare intervalli, non il singolo valore migliore.

### 5.10.2 Asincronia e concorrenza

ASP.NET Core gestisce molte richieste concorrenti senza assegnare necessariamente un thread dedicato a ogni attesa I/O. `async`/`await` consente di restituire il thread mentre si aspetta rete o disco. Non rende un calcolo CPU-bound più rapido, né elimina i limiti di database e upstream.

Evitare `.Result`, `.Wait()` e `GetAwaiter().GetResult()` sul percorso HTTP: il blocco occupa thread e sotto carico può causare starvation. Propagare `CancellationToken` fino ai client e alla persistenza. Se il client annulla la richiesta, il server dovrebbe interrompere lavoro inutile quando è sicuro farlo.

Non avviare operazioni parallele sullo stesso `DbContext`. Se più query indipendenti sono davvero necessarie, usare scope/contesti distinti con limite di concorrenza e verificare che il database possa sostenere il carico. Il parallelismo indiscriminato peggiora la latenza quando satura pool e connessioni.

### 5.10.3 Memoria e garbage collection

Il runtime .NET usa garbage collector generazionale; allocazioni temporanee sono spesso economiche, ma allocazioni eccessive aumentano pressione GC e latenza. Profilare prima di introdurre pooling o strutture più complesse. Riutilizzare buffer in modo scorretto può causare corruzione o esposizione di dati tra richieste.

Evitare di leggere file o payload illimitati in memoria. Applicare limiti, streaming e backpressure dove appropriato. Cache, singleton e collezioni statiche possono trattenere oggetti per tutta la vita del processo; monitorare dimensioni e politiche di eviction. Un processo containerizzato deve rispettare limiti memoria: essere stabile sulla workstation non prova che lo sia con un memory limit ridotto.

### 5.10.4 Query, serializzazione e caching

La causa dominante di lentezza è spesso I/O o query non efficienti. Usare log delle query e strumenti del database per diagnosticare N+1, full scan, lock e attese. Proiettare i campi necessari, paginare, aggiungere indici motivati dal piano e misurare dopo la modifica.

La serializzazione JSON può diventare significativa per payload grandi o grafi complessi. Definire DTO, evitare cicli nelle navigazioni e misurare allocazioni e dimensione della risposta. Cambiare serializer o opzioni di naming può rompere il contratto, anche se migliora le prestazioni.

La cache è utile quando riduce lavoro ripetuto e la staleness è accettabile. Definire TTL, invalidazione, chiave, isolamento tenant, limite memoria e comportamento in caso di errore. Misurare hit ratio e costo di riempimento. Non aggiungere cache per compensare query senza aver compreso la causa.

### 5.10.5 Profiling e Native AOT

Usare profiler e tracing per individuare il tratto costoso, confrontando CPU sample, allocation, thread pool e dipendenze. Un flame graph aiuta a trovare hot path, ma va letto insieme a metriche applicative. Gli strumenti di tracing devono essere configurati per minimizzare overhead e non registrare payload sensibili.

Trimming e Native AOT possono ridurre footprint o tempo di avvio per scenari specifici, ma imposero vincoli a reflection, serializzazione, plugin e librerie. Abilitare l'analisi e correggere warning, non silenziarli indiscriminatamente. Misurare cold start, dimensione e throughput nel target effettivo. Non assumere che AOT migliori un servizio dominato da I/O o database.

### 5.10.6 Prestazioni come criterio di cutover

Definire budget per operazione e soglie di rollback prima del rollout. Durante canary confrontare gruppi equivalenti per traffico, carico e dipendenze. Osservare code, errori e saturazione, non soltanto latenza media. Se il target peggiora, poterlo disattivare deve essere più rapido che applicare una patch d'emergenza.

La decisione finale non è “più veloce a ogni costo”. Un sistema con latenza entro budget, meno incidenti e costo prevedibile può essere preferibile a un microbenchmark migliore ma a scapito di complessità e manutenibilità.
