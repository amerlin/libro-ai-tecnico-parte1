## 2.15 Riepilogo, glossario ed esercizi

Abbiamo trasformato il catalogo MCP senza stato del Capitolo 1 in un servizio che consulta e modifica dati persistenti. Ripercorriamo le scelte principali e usiamole come base per la pratica.

### 2.15.1 Riepilogo

- Entity Framework Core traduce le query LINQ in operazioni sul database; `Select` definisce i dati restituiti e spesso rende superfluo `Include`.
- Un `DbContext` non va condiviso tra invocazioni concorrenti: `IDbContextFactory<TContext>` permette di creare un contesto per ogni chiamata del tool.
- I DTO limitano i dati esposti al modello e separano il contratto MCP dalle entità persistite.
- Gli input del modello vanno convalidati come qualsiasi altro input esterno; le scritture e le operazioni distruttive richiedono particolare cautela.
- `EnsureCreated` e la semina idempotente sono comodi per una demo, ma non sostituiscono le migrazioni né una strategia di deployment.
- `stdio` e Streamable HTTP cambiano il trasporto, non il contratto dei tool; Progress comunica l'avanzamento quando un'operazione richiede tempo.

### 2.15.2 Glossario

| Termine | Significato |
|---|---|
| **ORM** | Libreria che mappa oggetti e relazioni alle strutture di un database. |
| **DbContext** | Unità di lavoro EF Core che gestisce query, tracking e salvataggi. |
| **DTO** | Oggetto che definisce i dati scambiati attraverso un contratto esterno. |
| **Migration** | Modifica versionata dello schema del database, applicabile in modo controllato. |
| **Progress token** | Token fornito dal client per correlare le notifiche di avanzamento di una richiesta. |

### 2.15.3 Esercizi proposti

1. Estendi `list_products` con un intervallo di prezzo opzionale e verifica che il filtro venga eseguito dal database.
2. Scrivi un test d'integrazione per `delete_product` e verifica che il client possa rilevare l'annotazione distruttiva.
3. Scrivi un test d'integrazione per la ricerca per nome e specifica il comportamento atteso quando il termine è vuoto.
4. Aggiungi una migration e prova ad applicarla a un database di sviluppo senza cancellare i dati esistenti.
5. Estendi il tool con Progress per un'importazione simulata; gestisci la cancellazione e comunica solo avanzamenti significativi.
