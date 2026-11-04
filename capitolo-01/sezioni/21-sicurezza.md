## 1.21 Sicurezza e operatività

Un MCP server è un **ponte tra un modello e i tuoi sistemi**: se non è protetto, diventa un ponte per chiunque riesca a raggiungerlo. La sicurezza va considerata fin dall'inizio, non aggiunta alla fine.

### Il principio del minimo privilegio

Il principio guida è semplice: **esponi solo ciò che serve, con i permessi minimi necessari**. Se il server deve leggere file, non deve poter scrivere ovunque; se deve interrogare un database, usi un utente con soli diritti di lettura. Ogni tool in più, ogni permesso in più, è una superficie d'attacco in più.

Nel nostro esempio file system abbiamo applicato questo principio confinando tutte le operazioni in una directory radice. Il costruttore normalizza `_root` con `Path.GetFullPath` e rimuove gli eventuali separatori finali con `Path.TrimEndingDirectorySeparator`. In `Resolve`, il percorso normalizzato è ammesso solo se coincide con la radice o inizia con la radice seguita da un separatore: così un percorso come `C:\dati2` non supera il controllo per una root `C:\dati`. Il confronto ignora maiuscole e minuscole su Windows ed è sensibile al caso sugli altri sistemi.

```csharp
var full = Path.GetFullPath(Path.Combine(_root, relativePath));
var comparison = OperatingSystem.IsWindows()
    ? StringComparison.OrdinalIgnoreCase
    : StringComparison.Ordinal;
var rootPrefix = Path.EndsInDirectorySeparator(_root)
    ? _root
    : _root + Path.DirectorySeparatorChar;

if (!string.Equals(full, _root, comparison) &&
    !full.StartsWith(rootPrefix, comparison))
    throw new McpException("Access denied: path escapes the root directory.");
```

La radice stessa è ammessa, così un percorso relativo vuoto può indicare la directory radice. Questa difesa contro il **path traversal** (un argomento come `..\..\Windows`) è essenziale in qualunque tool che tocchi il file system. `GetFullPath` normalizza i percorsi ma non risolve i collegamenti simbolici: se la directory radice ne contiene, occorre verificare separatamente anche i relativi target.

### La minaccia della prompt injection

Il modello è, per sua natura, influenzabile dal testo che riceve. Un documento malevolo letto dal server, o un argomento fornito da un utente, potrebbe contenere istruzioni nascoste che spingono il modello a compiere azioni indesiderate (esfiltrare dati, eseguire tool pericolosi). È la cosiddetta **prompt injection**.

Le contromisure principali:

- **separa i dati dalle istruzioni**: quando inietti nel contesto il contenuto di una risorsa o il risultato di un tool, delimitalo chiaramente e istruisci il modello a trattarlo come dato, non come comando;
- **convalida e igienizza** gli input prima di usarli;
- **limita i tool pericolosi**: le operazioni distruttive richiedono conferma esplicita dell'utente (molti host lo fanno automaticamente se il tool è annotato `Destructive = true`);
- **non esporre segreti** nei dati che il server restituisce.

### Autenticazione e autorizzazione

- Per i server **`stdio`**, il trust è locale: il server gira come processo del client e, di norma, eredita i permessi dell'utente. La protezione è data dall'ambiente, non dal protocollo.
- Per i server **HTTP**, la specifica prevede **OAuth 2.1** per autenticare i client. Esporre un server MCP HTTP su Internet senza autenticazione è quasi sempre un errore: chiunque potrebbe usarne i tool.
- L'SDK ASP.NET Core offre primitive per l'autenticazione (`AddAuthorizationFilters`) e si integra con i meccanismi standard di ASP.NET Core (policy, middleware).

### Segreti e configurazione

Non scrivere mai chiavi API, password o token nel codice sorgente o nei file di configurazione condivisi. Usa:

- **variabili d'ambiente** (per gli host che le supportano);
- **user secrets** in sviluppo (`dotnet user-secrets`);
- un **gestore di segreti** (Azure Key Vault, AWS Secrets Manager, ecc.) in produzione;
- per i server HTTP, i meccanismi di autenticazione del protocollo.

### Controllare l'esposizione di rete

Un server HTTP MCP espone un endpoint: applicalo le stesse regole di qualunque servizio web. In particolare:

- usa **TLS** (HTTPS) in produzione;
- **limita l'accesso** con firewall, reti private o VPN;
- **registra** le richieste (senza dati sensibili) per poter indagare eventuali abusi;
- tieni **aggiornati** i pacchetti: l'SDK MCP evolve e corregge vulnerabilità.

### Checklist di sicurezza

Prima di mettere in produzione un server MCP, verifica:

- [ ] ogni tool applica il minimo privilegio;
- [ ] gli input sono validati e i percorsi sono confinati;
- [ ] i segreti non sono nel codice né nella configurazione condivisa;
- [ ] i tool distruttivi sono annotati e richiedono conferma;
- [ ] i server HTTP usano TLS e autenticazione;
- [ ] i log non contengono dati sensibili;
- [ ] le dipendenze sono aggiornate.

La sicurezza non è un punto di arrivo, ma un processo: rivedi questa checklist a ogni modifica rilevante del server.
