## 2.1 Perché un database in un MCP server

Nel Capitolo 1 i nostri server erano "senza stato": il server del file system leggeva e scriveva file, quello meteo interrogava un'API esterna, ma nessuno **ricordava** nulla tra una chiamata e l'altra. In moltissimi scenari reali, però, l'agente ha bisogno di dati che **persistono**, si **interrogano** e si **aggregano**.

### 2.1.1 Cosa chiede un agente a un database

Pensa a un assistente aziendale. Le sue richieste tipiche sono:

- "Quanti ordini sono stati evasi la settimana scorsa?" — una **aggregazione**;
- "Trovami i clienti che non comprano da più di sei mesi" — una **query con filtro**;
- "Aggiungi questo prodotto al catalogo con prezzo 29,90" — una **scrittura**;
- "Quali sono le categorie più vendute?" — una **join** con raggruppamento.

Nessuna di queste operazioni è ragionevolmente realizzabile leggendo file di testo o chiamando API generiche: serve un **motore di interrogazione**, e un database relazionale è lo strumento naturale.

### 2.1.2 Il ruolo del MCP server

Il MCP server si colloca esattamente nel punto giusto: è il **ponte** tra il modello e il database. Da un lato espone *tool* descrittivi (`list_products`, `create_product`, ...) che il modello scopre e invoca; dall'altro traduce quei tool in **query SQL** (o, meglio, in query LINQ che il provider traduce in SQL) e restituisce risultati strutturati.

Il modello non sa nulla di tabelle, indici o join: vede un menu di strumenti ben descritti. Il database non sa nulla di modelli o di prompt: riceve query. Il server è il traduttore che vive in mezzo, e il suo compito è rendere l'incontro **sicuro, controllato e coerente**.

### 2.1.3 Perché Entity Framework Core

Potremmo usare ADO.NET o un micro-ORM come Dapper per scrivere SQL a mano. Ma Entity Framework Core offre tre vantaggi decisivi per questo scenario:

1. **Modello a oggetti.** Definiamo entità C# (`Product`, `Category`) e relazioni; EF Core si occupa dello schema e delle query.
2. **LINQ.** Le query si scrivono in C# tipizzato, con il completamento automatico e il controllo dei tipi a compile time.
3. **Provider multipli.** Lo stesso codice funziona con SQLite, SQL Server, PostgreSQL, MySQL e altri, cambiando un solo pacchetto e una stringa di connessione.

In più, EF Core è il modo **idiomatico** di accedere ai dati in .NET: un lettore che conosce ASP.NET Core troverà naturale integrare un `DbContext` in un server MCP.

### 2.1.4 La sfida specifica di MCP: il lifetime del DbContext

C'è una complicazione, ed è il motivo per cui questo capitolo esiste: un `DbContext` è progettato per vivere **poco**, legato a una singola unità di lavoro. In una richiesta web, per esempio, vive per la durata della richiesta. In un server MCP, invece, ogni invocazione di tool è un "lavoro" a sé, e il server resta in vita a lungo.

Se iniettassimo un singolo `DbContext` condiviso tra tutte le invocazioni, incapperemmo in problemi classici: contesto non thread-safe, tracking che cresce senza controllo, dati stantii. La soluzione corretta — che esploreremo e useremo — è il **`IDbContextFactory<T>`**: una factory che crea un contesto nuovo per ogni invocazione. Dedichiamo a questo pattern un'intera sezione, perché è il cuore dell'integrazione tra EF Core e MCP.

### 2.1.5 La mappa del capitolo

Partiremo da un ripasso essenziale di EF Core, poi definiremo il dominio di esempio (un catalogo prodotti), creeremo il progetto, i modelli e il database. Implementeremo i tool di lettura e scrittura, li esporremo su `stdio` e HTTP, e infine vedremo come comunicare il progresso di un'operazione. Alla fine avrai un server MCP **con persistenza** completo, pronto per essere collegato a Claude Desktop o VS Code.
