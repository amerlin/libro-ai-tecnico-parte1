# Report di revisione

## _Quaderno AI_

### Concetti, strumenti e percorsi pratici per lo sviluppo software con AI

**Autore:** Andrea Merlin  
**Numero:** 1 — Novembre 2026  
**Esito iniziale:** bozza avanzata; non ancora pronta per la stampa

## Sintesi

Il libro propone un percorso coerente: strumenti MCP, persistenza con EF Core, sviluppo guidato dalle specifiche, personalizzazione degli agenti e migrazione a .NET. La progressione didattica è valida e il testo offre numerosi esempi pratici.

La revisione iniziale ha rilevato errori tecnici negli esempi, promesse non mantenute in particolare nel Capitolo 2, testo segnaposto e problemi di impaginazione. Dopo la revisione sono stati applicati interventi ai sorgenti e rigenerati i PDF. I rilievi originali e i loro riferimenti di riga descrivono lo stato precedente alle correzioni; lo stato aggiornato è riportato qui sotto.

## Stato dopo le correzioni

| # | Stato | Esito |
|---:|---|---|
| 1 | Risolto | La pagina autore contiene la biografia fornita dall'autore; verificata nel testo estratto dal PDF. |
| 2 | Parziale | Il controllo distingue la radice dai percorsi fratelli con prefisso simile. I collegamenti simbolici e i relativi target restano un limite esplicitamente documentato. |
| 3 | Risolto | Abstract e obiettivi del Capitolo 2 sono stati riallineati ai contenuti effettivi. |
| 4 | Risolto | `specify check` è descritto come controllo dei prerequisiti; la CI usa build e test .NET. |
| 5 | Risolto | I tool MCP dichiarano nomi espliciti in `snake_case`; il server completo e la tabella includono i sei tool. |
| 6–7 | Risolti | La proiezione EF Core è inline e i test importano `Taskify.Contracts`. |
| 8 | Risolto | Il DTO, la proiezione e il campo `Currency` sono allineati. |
| 9–10 | Risolti | Percorso HTTP `/mcp` coerente e pacchetto `Microsoft.Extensions.Http` aggiunto ai prerequisiti. |
| 11–14 | Risolti | Semantica degli errori MCP corretta; frammenti di database autonomi, proiezioni senza `Include` superfluo e inizializzazione non distruttiva con avvertenze. |
| 15–16 | Risolti | Il server `stdio` espone tutti i tool descritti; la versione HTTP usa la stessa semina dei dati. |
| 17 | Risolto | Riferimento aggiornato a C# 14 con .NET 10. |
| 18–19 | Risolti | Distinte la portabilità del formato e la scoperta per percorso; aggiornata la mappa dei motori e datate le fonti. |
| 20–23 | Risolti | Percorsi del Dockerfile, gestione Problem Details, health check e proiezione con valuta sono coerenti. |
| — | Intervento editoriale | Aggiornati copertina, metadati, numerazione delle sezioni e biografia; ridotte le ridondanze del Capitolo 5; aggiunti riepilogo, glossario ed esercizi al Capitolo 2. |

### Metriche della versione sottoposta alla revisione iniziale

| Indicatore                     |                      Esito |
| ------------------------------ | -------------------------: |
| Valutazione complessiva        |                    **3/5** |
| Capitoli                       |                          5 |
| Lunghezza stimata              |        circa 68.700 parole |
| Pagine del volume unico        |                        224 |
| Sezioni Markdown               |                        106 |
| Blocchi di codice              |                        242 |
| Figure                         | 13; nessuna nel Capitolo 5 |
| Overfull `\hbox` nel log LaTeX |     84, fino a circa 98 pt |

Le versioni NuGet verificate durante la revisione — `ModelContextProtocol` 2.3.0, EF Core 10.0.14 e `Microsoft.Extensions.Hosting` 10.0.13 — risultano esistenti. I link esterni verificati sono in gran parte raggiungibili; due URL GitHub con proprietario `esempio` sono chiaramente segnaposto.

## Rilievi bloccanti iniziali

Da correggere prima di distribuire o stampare il volume.

| #   | Capitolo/file                                                                                     | Rilievo                                                                                                                                                                                                                                                                                  | Intervento suggerito                                                                                                                       |
| --- | ------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | [pagina-autore.tex](./capitolo-05/pagina-autore.tex), r. 15                                       | La pagina autore del PDF contiene il testo segnaposto “Lorem ipsum dolor sit amet…” (visibile nel volume unico).                                                                                                                                                                         | Inserire una biografia approvata oppure rimuovere la pagina.                                                                               |
| 2   | [capitolo-01.md](./capitolo-01/capitolo-01.md), r. 1134 e 1847                                    | Il controllo `full.StartsWith(_root)` non garantisce il confinamento alla directory: un percorso fratello con lo stesso prefisso, per esempio `C:\dati-esterni`, può superarlo. Il testo presenta questo controllo come protezione anti-traversal.                                       | Verificare il confine di directory con un separatore esplicito o con `Path.GetRelativePath` e un controllo robusto dei segmenti.           |
| 3   | [capitolo-02/sezioni/00-frontespizio.md](./capitolo-02/sezioni/00-frontespizio.md), rr. 12, 24–27 | Abstract e obiettivi promettono Elicitation, una nota sul Sampling deprecato, pubblicazione/containerizzazione e logging/osservabilità; il capitolo tratta invece solo Progress e termina alla sezione 2.14.                                                                             | Aggiungere i contenuti promessi oppure ridurre abstract, obiettivi e rimandi del Capitolo 1.                                               |
| 4   | [capitolo-03.md](./capitolo-03/capitolo-03.md), rr. 1043, 1603                                    | `specify check` è descritto come validatore degli artefatti Spec Kit e come gate CI. Il comando ufficiale controlla la disponibilità degli strumenti esterni, non la coerenza di specifiche e artefatti; la CI descritta poggia quindi su una capacità inesistente.                      | Correggere la descrizione e ridisegnare la CI usando verifiche reali, ad esempio test del progetto ed eventuali controlli CLI appropriati. |
| 5   | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 556–559, 641, 994, 1117–1123                  | I metodi dei tool MCP non impostano un nome esplicito, mentre il testo invoca nomi `snake_case` come `list_products` e `create_product`. Il Capitolo 1 spiega che i nomi derivati dai metodi sono normalizzati in minuscolo: `ListProducts` diventa `listproducts`, non `list_products`. | Specificare `Name` sugli attributi MCP oppure uniformare tutte le invocazioni ai nomi effettivamente esposti.                              |
| 6   | [capitolo-03.md](./capitolo-03/capitolo-03.md), r. 1274                                           | La query EF Core usa `.Select(t => TaskDto.From(t))`. EF Core non traduce una chiamata a metodo statico arbitrario nella query SQL; l'endpoint può fallire a runtime.                                                                                                                    | Proiettare direttamente i campi nel `Select`, oppure materializzare prima e convertire poi.                                                |
| 7   | [capitolo-03.md](./capitolo-03/capitolo-03.md), rr. 1355–1359                                     | Il codice dei test usa `TaskDto` ma non importa il namespace `Taskify.Contracts`; il test non compila se non esiste un global using non mostrato.                                                                                                                                        | Aggiungere l'import necessario o dichiarare esplicitamente il global using.                                                                |
| 8   | [capitolo-05.md](./capitolo-05/capitolo-05.md), rr. 669–671 e 1131–1135                           | La proiezione costruisce `ProductListItem` con tre argomenti, mentre il record dichiarato richiede anche `Currency`.                                                                                                                                                                     | Allineare il record e la proiezione.                                                                                                       |
| 9   | [capitolo-01.md](./capitolo-01/capitolo-01.md), r. 1487 e rr. 1628, 1652, 1716, 2068              | L'esempio HTTP chiama `app.MapMcp()` (endpoint alla radice), ma configurazioni, Inspector e client puntano a `/mcp`. Il percorso didattico non è coerente e può impedire la connessione.                                                                                                 | Mappare esplicitamente lo stesso percorso usato da client e Inspector, oppure correggere tutti gli URL.                                    |
| 10  | [capitolo-01.md](./capitolo-01/capitolo-01.md), rr. 750–755 e 1226                                | L'esempio meteo usa `AddHttpClient<WeatherTool>` senza aggiungere il pacchetto `Microsoft.Extensions.Http`, richiesto per tale registrazione nel progetto descritto.                                                                                                                     | Aggiungere il pacchetto ai prerequisiti e ai comandi di installazione.                                                                     |

## Rilievi tecnici maggiori iniziali

| #   | Capitolo/file                                                                                                    | Rilievo                                                                                                                                                                                                                                                                           | Intervento suggerito                                                                                                                |
| --- | ---------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| 11  | [capitolo-01.md](./capitolo-01/capitolo-01.md), r. 1761; [capitolo-02.md](./capitolo-02/capitolo-02.md), r. 1128 | Si afferma che le eccezioni `McpException` dei tool diventano errori JSON-RPC con campo `error`. Per una chiamata a un tool, l'SDK restituisce un `CallToolResult` marcato `isError: true`; l'errore JSON-RPC è un livello diverso.                                               | Descrivere il formato effettivo del risultato dei tool e aggiornare le istruzioni di verifica nell'Inspector.                       |
| 12  | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 441–462                                                      | Il frammento di creazione del database usa `options` senza mostrarne la definizione; il successivo frammento di seeding usa `db` fuori dallo scope del blocco precedente. Presi come codice da copiare, non compilano.                                                            | Fornire un esempio autonomo con opzioni e contesto nello stesso scope.                                                              |
| 13  | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 563–571, 578                                                 | `Include(p => p.Category)` è presentato come ciò che evita query aggiuntive, ma la query termina con una proiezione `Select`: in questa forma l'`Include` non è il meccanismo che produce la proiezione della categoria; è la proiezione stessa a determinare i dati richiesti.   | Rimuovere l'`Include` superfluo e spiegare la traduzione della proiezione.                                                          |
| 14  | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 856–870                                                      | La semina con `EnsureDeletedAsync` e `EnsureCreatedAsync` avviene all'avvio prima che l'host parta. Se collocata nel `Program.cs` completo, anche l'esecuzione di strumenti di progettazione come `dotnet ef` può attivare codice che cancella il database.                       | Separare la semina didattica dall'avvio ordinario e avvertire esplicitamente del rischio.                                           |
| 15  | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 910–993                                                      | Il server completo espone quattro tool, ma non include `GetProduct` né `UpdatePrice`, già presentati in precedenza; la tabella iniziale promette inoltre `get_product`.                                                                                                           | Allineare il codice completo, la tabella e il riepilogo delle funzionalità.                                                         |
| 16  | [capitolo-02.md](./capitolo-02/capitolo-02.md), rr. 1023, 1045–1058, 1117–1123                                   | Il server HTTP è dichiarato identico a quello `stdio`, ma la semina HTTP mostrata inserisce solo le categorie; la sequenza di test si aspetta anche i due prodotti.                                                                                                               | Riutilizzare la stessa inizializzazione dati o correggere i risultati attesi.                                                       |
| 17  | [capitolo-03.md](./capitolo-03/capitolo-03.md), r. 700                                                           | L'esempio dichiara “C# 13 / .NET 10”; .NET 10 corrisponde a C# 14 come versione predefinita.                                                                                                                                                                                      | Correggere la versione del linguaggio o dichiarare una versione C# impostata intenzionalmente.                                      |
| 18  | [capitolo-04.md](./capitolo-04/capitolo-04.md), rr. 518, 953–962                                                 | Il capitolo presenta `.github/skills/` come combinazione portabile con `AGENTS.md`, ma in seguito riconosce che i motori scoprono le skill in cartelle differenti (`.claude/skills/`, `.agents/skills/`). Le due indicazioni si contraddicono.                                    | Precisare che il formato del contenuto può essere portabile, mentre la scoperta dipende dal percorso previsto da ciascun motore.    |
| 19  | [capitolo-04.md](./capitolo-04/capitolo-04.md), rr. 793–811                                                      | La tabella comparativa segna Cursor senza skill e agenti e il testo afferma che non usa file di agenti. La documentazione Cursor corrente descrive regole `.cursor/rules/` e `AGENTS.md`; le capacità e i percorsi andrebbero ricontrollati e datati, anziché dichiarati assenti. | Aggiornare la mappa sulla base della documentazione vigente e indicare la data/versione di verifica.                                |
| 20  | [capitolo-05.md](./capitolo-05/capitolo-05.md), rr. 1007–1013, 1114–1120                                         | Il Dockerfile cerca `Catalogo.Api/Catalogo.Api.csproj`, ma la struttura del caso pratico colloca il progetto sotto `src/Catalogo.Api/`.                                                                                                                                           | Rendere coerenti i percorsi del Dockerfile e quelli della solution.                                                                 |
| 21  | [capitolo-05.md](./capitolo-05/capitolo-05.md), rr. 449–455                                                      | L'esempio `app.UseExceptionHandler()` è presentato senza path né registrazione/handler che configuri una gestione predefinita; la sequenza mostrata va verificata e resa avviabile nel contesto dichiarato.                                                                       | Mostrare una configurazione completa con `IExceptionHandler` o `ProblemDetails`, oppure usare l'overload appropriato per l'esempio. |
| 22  | [capitolo-05.md](./capitolo-05/capitolo-05.md), rr. 1122–1124                                                    | La checklist di avvio afferma che il servizio restituisce health check, ma nel capitolo non è mostrata la registrazione o la mappatura di `AddHealthChecks`/`MapHealthChecks`.                                                                                                    | Aggiungere l'implementazione oppure ridurre la dichiarazione della checklist.                                                       |
| 23  | [capitolo-05.md](./capitolo-05/capitolo-05.md), rr. 1128–1135                                                    | Il record `ProductListItem` richiede quattro campi, incluso `Currency`; il codice precedente lo costruisce con tre.                                                                                                                                                               | Correggere la proiezione e includere la valuta prevista.                                                                            |

## Struttura, impaginazione e coerenza editoriale iniziali

- **Copertina:** [copertina-contenuto.tex](./capitolo-05/copertina-contenuto.tex), r. 87, inizialmente riportava `Parte1`; ora indica `Numero 1`, coerentemente con l'idea di una serie di quaderni.
- **Metadati dei capitoli:** i frontespizi dei capitoli usano `author: "Capitolo N"` invece di `Andrea Merlin`; i PDF dei singoli capitoli possono quindi attribuire il titolo del capitolo come autore.
- **Numerazione:** il sommario contiene intestazioni come `1.21-bis`, `1.21-ter` e `3.21-quater`; la numerazione è incoerente con il resto del volume. Considerare numeri decimali e aggiornare i rimandi.
- **Tabelle:** nel PDF alcune tabelle del Capitolo 4 risultano visibilmente sovrapposte: per esempio la tabella nella sezione 4.7.1/4.7.2, con colonne troppo larghe per la pagina. Il log riporta 84 `Overfull \hbox`, con overflow fino a circa 98 pt. Ridurre il numero di colonne, consentire l'andata a capo o usare un layout adatto alle tabelle larghe.
- **Figure:** le 13 figure dei Capitoli 1–4 sono incluse; il Capitolo 5, il più lungo, non ne contiene. La mappa del Capitolo 4 mostra sei motori mentre la didascalia parla di cinque; il testo rimanda inoltre a “figura 4” anche se nel PDF la mappa è numerata Figura 12. Aggiornare didascalie e riferimenti dopo la composizione definitiva.
- **Capitolo 2:** manca una sezione conclusiva con riepilogo, glossario o esercizi, a differenza dei capitoli 1, 3 e 5. È inoltre il capitolo più breve, ma promette temi che non tratta.
- **Capitolo 5:** presenta più chiusure sovrapposte (5.16 e 5.17, oltre a 5.17.7 “Conclusioni”), ripete la stessa lista di fonti in 5.16.1 e 5.17.8 e include schede modello parzialmente duplicate. L'indice concettuale non annuncia tutte le sezioni, tra cui runbook, diagnosi operativa e appendice.
- **Sorgenti e distribuzione:** il README mostra una struttura abbreviata e non descrive in modo completo i file di copertina e autore. Il libro non indica un repository di codice o una raccolta di soluzioni agli esercizi.
- **Terminologia:** uniformare forme come “MCP Server”/“server MCP”, “Tools”/“tool” e “capability”/“capacità”; definire una convenzione e applicarla ai titoli, alle tabelle e al corpo del testo.

## Correzioni linguistiche verificate nella revisione iniziale

| Dove                                                    | Testo attuale                                                  | Correzione suggerita                         |
| ------------------------------------------------------- | -------------------------------------------------------------- | -------------------------------------------- |
| [capitolo-05.md](./capitolo-05/capitolo-05.md), r. 942  | «capacità mig rata»                                            | «capacità migrata»                           |
| [capitolo-05.md](./capitolo-05/capitolo-05.md), r. 425  | «Una API»                                                      | «Un'API»                                     |
| [capitolo-05.md](./capitolo-05/capitolo-05.md), r. 787  | «validazione … del pubblico»                                   | «validazione dell'audience/del destinatario» |
| [capitolo-01.md](./capitolo-01/capitolo-01.md), r. 127  | «un'agente autonomo»                                           | «un agente autonomo»                         |
| [capitolo-04.md](./capitolo-04/capitolo-04.md), r. 94   | «vengono letti sempre» riferito alle istruzioni                | «vengono lette sempre»                       |
| [capitolo-04.md](./capitolo-04/capitolo-04.md), r. 351  | «Il handoff»                                                   | «L'handoff»                                  |
| [capitolo-04.md](./capitolo-04/capitolo-04.md), r. 1498 | «deriving incontrollate»                                       | «derive/deviazioni incontrollate»            |
| [capitolo-03.md](./capitolo-03/capitolo-03.md), r. 773  | «check-ato»                                                    | «verificato»                                 |
| [capitolo-04.md](./capitolo-04/capitolo-04.md), r. 1641 | rimando alla sezione 4.12.4 per uno script collocato in 4.12.3 | correggere il rimando                        |

Altri dettagli: [capitolo-01.md](./capitolo-01/capitolo-01.md), r. 270 parla di quattro tipi di messaggio JSON-RPC, mentre `error` è una variante della risposta; r. 905 promette un listato “in meno di venti righe” che è più lungo; r. 775 usa “paragrafo” per una sezione.

## Valutazione iniziale per capitolo

| Capitolo              |  Voto | Punti di forza                                                                        | Criticità principale                                                                         |
| --------------------- | ----: | ------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| 1 — MCP               |   3/5 | Progressione chiara da `stdio` a filesystem, meteo, HTTP e client; analogie efficaci. | Pacchetto HTTP mancante, percorso HTTP incoerente e protezione anti-traversal insufficiente. |
| 2 — EF Core           | 2,5/5 | Buona spiegazione del pattern `IDbContextFactory` e delle migrazioni.                 | Promesse non mantenute, nomi dei tool incoerenti e frammenti non autonomi.                   |
| 3 — Spec Kit          |   3/5 | Flusso didattico e tracciabilità tra specifica, codice e test.                        | Uso errato di `specify check` in CI e esempio non eseguibile senza correzioni.               |
| 4 — Personalizzazione |   3/5 | Modello mentale utile e buona attenzione alla sicurezza.                              | Mappa dei motori e indicazioni sulla portabilità non coerenti.                               |
| 5 — Migrazione        |   3/5 | Approccio incrementale, shadow traffic, canary e rollback trattati con criterio.      | Esempi disallineati, ridondanze e chiusure/fonti duplicate.                                  |

## Piano di revisione iniziale e stato

1. **Completato.** Rimossi i segnaposto e aggiornati copertina, biografia e metadati dei capitoli.
2. **Parziale.** Corretto il confinamento dei percorsi e allineati endpoint, client e Inspector; i link simbolici non sono risolti dall'esempio.
3. **Parziale.** Corretti i frammenti indicati e rigenerati i PDF; i listati non sono stati compilati come progetti autonomi.
4. **Completato.** Riallineate le promesse del Capitolo 2 ai contenuti e alle funzionalità mostrate.
5. **Completato.** Corretto `specify check` e aggiornata la sezione CI/CD con verifiche reali.
6. **Completato.** Aggiornata la mappa del Capitolo 4 e precisata la scoperta delle skill per motore.
7. **Completato.** Allineati Dockerfile, health check e DTO del Capitolo 5.
8. **Completato.** Ridotte le chiusure e le schede ridondanti; aggiornato l'indice concettuale.
9. **Parziale.** Riformattate le tabelle più problematiche e rigenerati i PDF; controllate visivamente le pagine 17–18 del Capitolo 4. Restano avvisi di impaginazione in altre pagine.
10. **Parziale.** Aggiornati README e refusi specifici; i repository d'esempio sono ora esplicitamente marcati come segnaposto. Restano utili una revisione terminologica complessiva e la scelta di un repository del codice.

## Nota sullo stato

I rilievi numerati e le valutazioni sopra documentano la revisione iniziale; non vanno letti come elenco di difetti ancora presenti. La tabella “Stato dopo le correzioni” registra l'esito degli interventi. I riferimenti di riga delle tabelle storiche puntano ai Markdown aggregati precedenti e possono essere cambiati.

La build è riuscita: 13 figure, volume unico di 284 pagine in formato 6″ × 9″ (15,24 × 22,86 cm) e PDF dei capitoli di 68, 42, 64, 58 e 62 pagine. Con l'abilitazione della sillabazione del codice inline (`hyphenat`) il log del volume è passato da 89 a 54 avvisi `Overfull \hbox`, con overflow massimo di circa 66 pt; i residui riguardano perlopiù identificatori e URL lunghi in monospazio e alcune celle di tabella, da sistemare con una passata mirata prima della stampa.

La build dei PDF verifica la composizione editoriale, non la compilazione di ciascun frammento C#: gli esempi sono distribuiti nel testo e non esiste un progetto di codice completo incluso nel repository. Restano inoltre da valutare il comportamento dei collegamenti simbolici nell'esempio filesystem e una revisione terminologica complessiva.
