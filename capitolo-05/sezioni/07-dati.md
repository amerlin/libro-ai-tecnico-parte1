## 5.7 Dati e integrazione con i sistemi esistenti

Il database è spesso il vincolo più forte di una migrazione. L'applicazione nuova può essere distribuita in poche ore; i dati possono essere condivisi con altri servizi, avere anni di storia e contenere anomalie che nessun modello documenta. Pianificare insieme schema, codice, ownership, sincronizzazione e rollback.

### 5.7.1 EF Core e scelta dell'accesso ai dati

Entity Framework Core è un ORM che traduce query LINQ in operazioni sul database e tiene traccia delle entità caricate. È adatto a molti casi applicativi, ma non è obbligatorio per ogni query. SQL esplicito o un micro-ORM possono essere più chiari per report, query complesse o requisiti di prestazione. La scelta va fatta per workload e misurazioni, non per fedeltà all'ORM sorgente.

| Concetto di altri ORM | EF Core | Verifica necessaria |
|---|---|---|
| Session/entity manager | `DbContext` | Scope, tracking e concorrenza |
| Entity/model | Entità CLR | Identità, navigazioni e mapping |
| Schema migration | EF migrations | SQL generato e deploy sicuro |
| Lazy loading | Opzionale, non predefinito in ogni scenario | Query implicite e N+1 |
| Unit of work | `SaveChanges`/transazione | Confini e atomicità |

`DbContext` è un'unità di lavoro breve, normalmente scoped per richiesta. Non è thread-safe: non lanciare query concorrenti sullo stesso contesto con `Task.WhenAll`. Usare query proiettate per leggere solo i campi necessari e `AsNoTracking` quando il risultato non verrà aggiornato tramite il context.

```csharp
var products = await db.Products
    .AsNoTracking()
    .Where(p => p.IsActive)
    .OrderBy(p => p.Name)
    .Select(p => new ProductListItem(
        p.Id, p.Name, p.Price, p.Currency))
    .ToListAsync(cancellationToken);
```

La proiezione esplicita rende visibile il contratto della query e riduce trasferimento di dati. Non enumerare query infinite o materializzare grandi tabelle senza paginazione. `IQueryable` esegue lavoro quando enumerato; la query va mantenuta nel livello che conosce il database per evitare sorprese.

### 5.7.2 Modello, schema e confini

Non assumere che la struttura del modello sorgente si trasferisca direttamente. Identificare chiavi primarie e naturali, vincoli, nullability, precisione dei numeri, timezone, collations, indici, relazioni e politiche di cancellazione. Confrontare il tipo logico e il tipo fisico: `decimal` può avere scale diverse, un timestamp può essere locale oppure UTC, un `string` può avere limiti e collation.

Separare modello persistito e DTO quando la forma pubblica o le regole del dominio differiscono dalla tabella. Non usare il database come unico documento del dominio, ma non duplicare ogni campo in modelli senza un confine utile. Le regole di integrità devono essere applicate anche nel database per proteggere da race condition e percorsi non HTTP.

Prima di introdurre un nuovo database, capire quali altri componenti leggono o scrivono lo schema attuale. Uno schema condiviso è un contratto implicito. Migrare un servizio lasciando integrazioni non documentate può interrompere sistemi che non fanno parte del repository.

### 5.7.3 Migrazioni dello schema

Le migrazioni EF Core descrivono evoluzioni dello schema; non sostituiscono revisione e piano di deploy. Ispezionare lo SQL generato, capire lock e durata, e distinguere modifiche additive da modifiche distruttive. Un `ALTER TABLE` può bloccare una tabella grande; il comportamento dipende dal provider e dalla versione del database.

Un pattern compatibile è **expand–migrate–contract**:

1. aggiungere colonna o tabella compatibile con il codice precedente;
2. distribuire codice che legge/scrive nel formato compatibile;
3. copiare o trasformare i dati a batch e verificare conteggi;
4. passare la lettura al nuovo campo e osservare;
5. rimuovere il vecchio campo solo quando nessun consumer o rollback lo richiede.

Non eseguire automaticamente migrazioni potenzialmente lunghe all'avvio di ogni replica. Le istanze possono partire insieme e competere per lock; il processo applicativo potrebbe non avere permessi DDL in produzione. Preferire un passaggio controllato in pipeline o un job di deployment con un solo proprietario e log chiari.

Per un rollback, la migrazione inversa deve essere realmente possibile. Se il nuovo codice scrive valori non rappresentabili nel vecchio schema, il downgrade non è sicuro. Conservare backup testati e definire una strategia di ripristino coerente con RPO e RTO; un backup mai ripristinato non è evidenza sufficiente.

### 5.7.4 Migrare i dati

Il piano dipende da volume, downtime consentito e possibilità di mantenere sincronizzati i sistemi. Opzioni comuni:

- **Finestra di fermo:** bloccare scritture, esportare, trasformare, importare, verificare e riaprire. Semplice, ma richiede una finestra accettabile.
- **Snapshot e delta:** copiare una fotografia iniziale, poi applicare le modifiche intervenute fino al cutover. Richiede un meccanismo affidabile per identificare il delta.
- **Replica/CDC:** acquisire cambiamenti dal log del database o da un processo dedicato. Riduce il fermo, ma aggiunge dipendenze e necessità di controllo della consistenza.
- **Migrazione per partizioni/tenant:** trasferire porzioni indipendenti e cambiare ownership progressivamente. Funziona solo se il confine è stabile.

Per ciascuna opzione descrivere il punto di consistenza, il comportamento delle scritture durante la copia, l'ordine delle trasformazioni e come riprendere dopo un'interruzione. Gli script devono essere idempotenti o avere checkpoint persistenti. Registrare errori per record e consentire la ripresa senza duplicare dati.

### 5.7.5 Qualità e semantica dei dati

I dati storici possono violare le regole attuali: stringhe vuote al posto di null, date impossibili, duplicati, codici fuori dominio, valute miste o relazioni orfane. Non correggere silenziosamente senza una regola approvata. Classificare gli elementi in validi, trasformabili, da mettere in quarantena e bloccanti.

Per date e orari distinguere istante UTC, orario locale e data civile. `DateTime` senza `Kind` esplicito può essere ambiguo; `DateTimeOffset` preserva offset ma non identifica da solo il fuso orario nominato. Convertire secondo il significato di business, non aggiungendo semplicemente `Z` alle stringhe.

Per denaro definire valuta, scala e arrotondamento; non usare floating point binario per valori monetari senza una motivazione. Per testo considerare Unicode, normalizzazione e collation: due stringhe visivamente identiche possono avere rappresentazioni differenti. Per identificativi preservare zeri iniziali se fanno parte del valore.

### 5.7.6 Riconciliazione verificabile

Il confronto tra origine e target deve andare oltre il conteggio righe. Verificare:

- conteggi per tabella, tenant e intervallo temporale;
- checksum o hash di colonne canoniche;
- riferimenti e vincoli;
- aggregati di business, per esempio totali per stato;
- campioni mirati di record complessi;
- dati modificati durante il delta e record scartati.

Definire tolleranze solo dove la trasformazione le giustifica, come precisione numerica o normalizzazione. Conservare report firmati o immutabili del processo, con timestamp, versione dello script e conteggi. Un esito “completato” senza numeri è difficile da auditare.

### 5.7.7 Transazioni, concorrenza e query

Una transazione database protegge un insieme di modifiche all'interno del provider e del suo contesto; non rende atomica una chiamata HTTP più una scrittura. Non tenere una transazione aperta mentre si attende un servizio remoto. Per coordinare DB ed eventi usare pattern come outbox con consumer idempotente.

Gestire concorrenza ottimistica con token o timestamp e restituire un conflitto comprensibile quando una versione è cambiata. Testare query reali con il provider di produzione: SQLite in memoria può differire per tipi, collations, transazioni e funzioni. I test rapidi con provider sostitutivo sono utili ma non sostituiscono test d'integrazione sul motore effettivo.

Misurare query e piani d'esecuzione prima di aggiungere repository o cache. Attenzione a N+1, caricamento eccessivo, assenza di indici e paginazione con offset su dataset enormi. Non interpolare SQL con input; usare parametri e permessi minimi.

### 5.7.8 Connessioni e continuità

Le stringhe di connessione provengono da configurazione protetta. Impostare pool, timeout, TLS e retry secondo provider; una connessione esaurita può apparire come lentezza dell'API. Il pool riduce l'overhead ma non aumenta la capacità del database: moltiplicare repliche moltiplica anche le connessioni potenziali.

Durante la convivenza, definire quale sistema può scrivere ciascuna entità e come viene mantenuta la consistenza. Evitare di far dipendere la nuova API direttamente da uno schema che il vecchio sistema può cambiare senza coordinamento. Un contratto dati versionato o un adapter temporaneo può isolare la migrazione e rendere esplicita la dipendenza da rimuovere.
