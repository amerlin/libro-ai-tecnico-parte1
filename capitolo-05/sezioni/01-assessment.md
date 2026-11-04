## 5.1 Perché migrare e come valutare il progetto

Una migrazione viene spesso proposta come risposta a un problema percepito: un framework è fuori supporto, il team non riesce più a trovare competenze, il costo di manutenzione cresce o il servizio deve entrare in un ambiente standardizzato su .NET. La proposta tecnica, però, non dimostra da sola che la migrazione sia vantaggiosa. Prima di scegliere la destinazione bisogna comprendere il sistema che si intende sostituire, il valore che offre e i vincoli che non sono visibili osservando soltanto i file sorgente.

### 5.1.1 Migrazione non è traduzione

Un'applicazione è più del suo codice. Comprende almeno:

- comportamenti osservabili, inclusi casi limite e comportamenti accidentali su cui i client hanno finito per fare affidamento;
- contratti HTTP, formati, codici di stato, eventi, code, file e schemi dati;
- identità, ruoli, permessi, credenziali e regole di conservazione;
- operazioni pianificate, procedure manuali e strumenti di supporto;
- caratteristiche operative: latenza, disponibilità, throughput, costo e procedure di ripristino.

Trasferire ogni funzione una a una può perpetuare difetti e vincoli non più necessari. Cambiare tutto insieme, d'altra parte, rende difficile capire se un malfunzionamento dipende dalla nuova piattaforma o da una modifica funzionale. In una migrazione tecnologica ben controllata si definisce prima quali comportamenti devono restare invariati. Le nuove funzionalità e le correzioni di dominio possono essere introdotte separatamente, oppure identificate esplicitamente come variazioni di contratto.

Una distinzione utile è tra **parità funzionale** e **parità operativa**. La prima riguarda ciò che utenti e client possono fare; la seconda riguarda come il servizio si comporta sotto carico, come viene distribuito e osservato, quali procedure servono per ripristinarlo. Un endpoint che restituisce lo stesso JSON ma non rispetta più il limite di latenza del client è funzionalmente simile, non una sostituzione riuscita.

### 5.1.2 Motivazioni e controindicazioni

Tra le motivazioni ragionevoli ci sono il termine del supporto del runtime, la difficoltà di aggiornare dipendenze critiche, i requisiti di sicurezza o conformità, l'esigenza di unificare toolchain e infrastruttura, l'integrazione con librerie .NET già adottate e la necessità di sostenere un carico o una modalità di deployment diversi.

Non sono sufficienti, da sole, frasi come “C# è più veloce”, “il linguaggio è vecchio” o “vogliamo un'architettura moderna”. Un'applicazione stabile, ben testata e con costo operativo contenuto può essere più sicura da aggiornare sullo stack corrente. Una riscrittura consuma capacità di sviluppo, crea un periodo di doppia manutenzione e può introdurre regressioni. Il confronto deve includere il costo totale: sviluppo, licenze, hosting, supporto, formazione, incidenti e dismissione del vecchio sistema.

La domanda corretta non è «.NET è migliore?», ma «quali requisiti del nostro sistema soddisfa meglio il target, e con quali costi e rischi misurabili?». Un prototipo può validare un'integrazione o una libreria; non prova automaticamente che una migrazione completa sia conveniente.

### 5.1.3 Inventario tecnico e funzionale

L'assessment inizia da un inventario verificabile. Non basta contare controller e righe di codice. Raccogliere, dove disponibili:

1. **Superfici funzionali:** route, metodi, parametri, payload, errori, pagine e client che le usano.
2. **Processi:** job schedulati, consumer di code, import/export, webhook, strumenti amministrativi e script manuali.
3. **Dati:** database, tabelle, volumi, crescita, vincoli, indici, backup, retention e migrazioni pregresse.
4. **Dipendenze:** runtime, framework, pacchetti, servizi cloud, SDK, sistemi di identità e componenti nativi.
5. **Integrazioni:** API esterne, code, SMTP, storage di file, pagamenti, sistemi legacy e formati di scambio.
6. **Operazioni:** pipeline, deployment, secret store, logging, monitoraggio, alert, runbook, RTO e RPO.
7. **Utilizzo:** frequenza delle route, profili di carico, picchi, client attivi, operazioni costose e stagionalità.
8. **Vincoli:** finestre di fermo, requisiti legali, localizzazione dei dati, compatibilità, competenze e budget.

Accoppiare l'inventario statico con osservazioni runtime. Log, tracing e metriche rivelano percorsi davvero usati e dipendenze effettive; repository e documentazione rivelano intenzioni e configurazioni. Nessuna delle due fonti è completa. Un route presente nel codice può essere inutilizzato, ma non va rimosso senza verifica con i proprietari dei client.

### 5.1.4 Requisiti non funzionali e baseline

Per valutare il target servono misure di partenza. Registrare almeno:

- latenza per operazioni rappresentative, includendo percentili come p50, p95 e p99;
- richieste al secondo, concorrenza, code e frequenza degli errori;
- consumo di CPU, memoria, storage, connessioni e risorse di database;
- tempi di avvio, deploy, ripristino e build;
- disponibilità, incidenti, obiettivi RTO/RPO e carico operativo del team.

Misurare le stesse operazioni con input e ambiente confrontabili. Una media globale nasconde le route lente e la variabilità; un benchmark su una singola macchina non rappresenta una produzione con rete, database e cache. Annotare configurazione, versione, dimensione del dataset e data della misura. Senza una baseline il team non può distinguere un miglioramento reale da una differenza di ambiente.

Definire criteri d'accettazione prima dell'implementazione. Per esempio: tutti i flussi critici hanno test di caratterizzazione; il target rispetta la compatibilità API; p95 non supera il budget concordato; il rollback è stato provato; nessun segreto è contenuto nell'immagine. I numeri devono provenire dal servizio e dai suoi utenti, non da soglie arbitrarie.

### 5.1.5 Registro delle decisioni e dei rischi

Per ogni funzione si può registrare proprietario, frequenza, criticità, dipendenze e strategia proposta. Un registro decisionale breve dovrebbe descrivere la decisione, le alternative considerate, le evidenze e le condizioni che la farebbero rivedere. Esempio: mantenere inizialmente il database invariato perché più servizi condividono lo schema; riconsiderare la separazione solo dopo aver stabilizzato API e ownership.

Valutare probabilità e impatto dei rischi: dati non interpretabili allo stesso modo, dipendenza non portabile, identità non migrabili, traffico non riproducibile, doppia scrittura incoerente, indisponibilità durante il cutover o mancanza di rollback. Ogni rischio importante deve avere una mitigazione e un responsabile. Se manca un'informazione critica, trasformarla in un'attività di discovery con un risultato atteso, non in una supposizione nascosta nel piano.

**Risultato dell'assessment:** una mappa del sistema, una baseline, un insieme di contratti da preservare, una lista di incertezze e una raccomandazione motivata tra migrare, modernizzare sullo stack esistente o rimandare. Questo pacchetto è la base della pianificazione, non un documento da archiviare senza seguito.
