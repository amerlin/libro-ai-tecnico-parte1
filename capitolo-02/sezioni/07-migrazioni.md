## 2.7 Le migrazioni

`EnsureCreated` va bene per un prototipo, ma un progetto reale evolve: il modello cambia (nuove colonne, nuove tabelle) e il database deve seguirlo **senza perdere i dati**. Le **migrazioni** di EF Core risolvono esattamente questo problema: registrano le modifiche allo schema come una sequenza di passi versionati, applicabili e reversibili.

### 2.7.1 Come funzionano

Una migrazione è un file C# che descrive una **transizione** dello schema (per esempio "aggiungi la colonna `Stock` alla tabella `Products`"). Il comando `dotnet ef` confronta il modello attuale con l'ultima migrazione e genera la migrazione successiva. Applicando le migrazioni in ordine, il database raggiunge lo stato desiderato.

### 2.7.2 Creare la prima migrazione

Con il modello definito, generiamo la migrazione iniziale:

```bash
> dotnet ef migrations add InitialCreate
```

Il comando crea una cartella `Migrations/` con due file: la migrazione (con i metodi `Up` e `Down`) e uno snapshot del modello. `InitialCreate` è il nome che diamo alla migrazione; scegli nomi descrittivi ("AddStockColumn", "AddCustomerTable").

### 2.7.3 Applicare la migrazione

Per creare (o aggiornare) il database:

```bash
> dotnet ef database update
```

Questo comando applica tutte le migrazioni pendenti. Al termine, il database è allineato al modello.

### 2.7.4 Il ciclo di lavoro quotidiano

Il flusso tipico è:

1. modifichi il modello (aggiungi una proprietà, una tabella);
2. generi una migrazione: `dotnet ef migrations add <NomeDescrittivo>`;
3. applichi: `dotnet ef database update`;
4. versioni la cartella `Migrations/` insieme al codice.

Mai modificare a mano una migrazione già applicata in produzione: meglio aggiungerne una nuova.

### 2.7.5 Migrazioni vs EnsureCreated

```{=latex}
\small
\begin{longtable}[]{@{}>{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.42}}>{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.26}}>{\raggedright\arraybackslash}p{(\linewidth - 4\tabcolsep) * \real{0.32}}@{}}
\toprule\noalign{}
Aspetto & \texttt{EnsureCreated} & Migrazioni \\
\midrule\noalign{}
\endhead
\bottomrule\noalign{}
\endlastfoot
Scopo & Prototipi, test & Produzione \\
Aggiorna lo schema esistente? & No & Sì, incrementalmente \\
Conserva i dati? & Non rilevante (ricrea) & Sì \\
Versionabile? & No & Sì (cartella \texttt{Migrations/}) \\
Comando & Codice & \texttt{dotnet\ ef} \\
\end{longtable}
\normalsize
```

Per il resto del capitolo useremo `EnsureCreated` per la semplicità dell'esempio, ma in produzione scegli le migrazioni: il tuo database (e chi lo usa) ti ringrazierà.

### 2.7.6 Migrazioni e server MCP

Un dettaglio operativo: i comandi `dotnet ef` hanno bisogno di poter **creare un'istanza** del `DbContext` in fase di design. Quando il `DbContext` è registrato via `AddDbContextFactory` e il progetto è un eseguibile, `dotnet ef` di solito riesce a istanziarlo da solo; se così non fosse (perché il costruttore richiede opzioni non ovvie), si può aggiungere un costruttore senza parametri che configura SQLite di default, oppure un `IDesignTimeDbContextFactory`. Per il nostro progetto semplice non serve: la stringa di connessione è già nel codice.
