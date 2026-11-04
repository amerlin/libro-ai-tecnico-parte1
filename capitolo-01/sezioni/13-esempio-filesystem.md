## 1.13 Esempio pratico: un server per il file system

Mettiamo in pratica quanto appreso costruendo un server MCP che espone operazioni sul file system: elencare i file di una cartella, leggere un file e scrivere un file. È un esempio classico, utile per capire come si traducono operazioni reali in tool.

### 1.13.1 Progettazione

Esporremo tre tool:

- `list_files` — elenca i file di una directory;
- `read_file` — legge il contenuto di un file di testo;
- `write_file` — scrive (o sovrascrive) un file di testo.

Per semplicità e sicurezza, tutte le operazioni saranno confinate in una **directory radice** configurabile: è una buona abitudine che limita i danni in caso di richieste errate o malevole.

### 1.13.2 Il codice completo

```csharp
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol;
using ModelContextProtocol.Server;

var builder = Host.CreateApplicationBuilder(args);

// Su stdio lo stdout è del protocollo: niente log su console.
builder.Logging.ClearProviders();

// Crea il tool con la sua directory radice e lo passa all'SDK.
var fileSystemTool = new FileSystemTool(rootDirectory: @"C:\dati");

builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithTools(fileSystemTool);

await builder.Build().RunAsync();

[McpServerToolType]
public sealed class FileSystemTool
{
    private readonly string _root;

    public FileSystemTool(string rootDirectory)
    {
        _root = Path.TrimEndingDirectorySeparator(Path.GetFullPath(rootDirectory));
        Directory.CreateDirectory(_root);
    }

    [McpServerTool, Description("Lists the files contained in a directory under the root.")]
    public string[] ListFiles(
        [Description("Relative directory path. Empty means the root.")] string relativePath = "")
    {
        var dir = Resolve(relativePath);
        return new DirectoryInfo(dir).GetFiles()
            .Select(f => f.Name)
            .OrderBy(name => name)
            .ToArray();
    }

    [McpServerTool, Description("Reads the text content of a file under the root.")]
    public string ReadFile(
        [Description("Relative file path.")] string relativePath)
    {
        var file = Resolve(relativePath);
        return File.ReadAllText(file);
    }

    [McpServerTool, Description("Writes text content to a file under the root, creating or overwriting it.")]
    public string WriteFile(
        [Description("Relative file path.")] string relativePath,
        [Description("Text content to write.")] string content)
    {
        var file = Resolve(relativePath);
        File.WriteAllText(file, content);
        return $"written {content.Length} characters to {relativePath}";
    }

    // Risolve un percorso relativo dentro la root, impedendo di uscirne.
    private string Resolve(string relativePath)
    {
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
        return full;
    }
}
```

### 1.13.3 Lettura guidata

**La registrazione del servizio.** Creiamo un'istanza di `FileSystemTool` con la directory radice e la passiamo direttamente a `WithTools(...)`. È la forma più semplice quando il tool ha una dipendenza che non deriva dal container (qui, una stringa di configurazione). In alternativa avremmo potuto usare l'overload `WithTools<FileSystemTool>()` e far risolvere la classe dal container, a patto di registrare prima tutti i parametri del costruttore come servizi.

**La radice.** Nel costruttore normalizziamo il percorso con `Path.GetFullPath` e ci assicuriamo che esista con `Directory.CreateDirectory`. Tutti i percorsi relativi ricevuti dai tool verranno risolti **dentro** questa radice.

**Il metodo `Resolve`.** È il cuore della sicurezza dell'esempio: combina la radice con il percorso relativo e normalizza entrambi. Accetta la radice stessa (utile per `list_files` con percorso vuoto) oppure un percorso che inizi con la radice seguita da un separatore: così `C:\dati2` non viene confusa con `C:\dati`. Il confronto ignora maiuscole e minuscole su Windows, ma è sensibile al caso sugli altri sistemi. Se il controllo fallisce, la `McpException` produce un `CallToolResult` con `isError: true`; non è un errore JSON-RPC di protocollo, che usa invece il campo `error`. `GetFullPath` normalizza il percorso ma non risolve i collegamenti simbolici: se la directory radice ne contiene, occorre verificare separatamente anche i relativi target.

**I tool.** `ListFiles` restituisce un array di stringhe: l'SDK lo serializza in JSON e lo incapsula in un blocco di testo (per avere anche il campo `structuredContent` basterebbe impostare `UseStructuredContent = true`). `ReadFile` e `WriteFile` restituiscono stringhe. Nota l'uso dei **valori di default** (`relativePath = ""`): rendono il parametro opzionale nello schema di input.

### 1.13.4 Provare il server

Avviamo il server e invochiamo i tool con una sessione JSON-RPC come visto prima. Per `list_files`:

```json
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{
  "name":"list_files",
  "arguments":{"relativePath":""}
}}
```

Il server risponderà con l'elenco dei file presenti in `C:\dati`, sotto forma di array in formato JSON. Prova poi a leggere un file:

```json
{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{
  "name":"read_file",
  "arguments":{"relativePath":"note.txt"}
}}
```

E a scriverne uno:

```json
{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{
  "name":"write_file",
  "arguments":{"relativePath":"saluto.txt","content":"Ciao dal file system!"}
}}
```

### 1.13.5 Limitazioni e possibili evoluzioni

Questo esempio è volutamente essenziale. In un server reale vorresti aggiungere: la gestione di file binari (con i tipi MIME delle risorse, che vedremo più avanti), la lettura incrementale per file grandi, la gestione degli errori di I/O (file inesistente, permessi negati) con messaggi amichevoli, e la registrazione strutturata su un file di log invece che su console. Riprenderemo diversi di questi punti nelle sezioni sulle risorse e sulle best practice.
