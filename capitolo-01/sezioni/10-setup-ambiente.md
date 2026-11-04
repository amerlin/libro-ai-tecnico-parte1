## 1.10 Preparare l'ambiente di sviluppo

Prima di scrivere la prima riga di codice, prepariamo l'ambiente. Il procedimento è identico su Windows, macOS e Linux; i comandi che seguono funzionano in qualsiasi terminale.

### 1.10.1 Verificare l'installazione di .NET

Apri un terminale e verifica la versione dell'SDK:

```bash
> dotnet --version
10.0.400
```

Se il comando non viene trovato, o restituisce una versione precedente alla 10, installa l'SDK dal sito ufficiale `https://dotnet.microsoft.com/download` (scegli la build SDK, non il solo runtime). Su Windows puoi anche usare il gestore `winget`:

```bash
> winget install Microsoft.DotNet.SDK.10
```

Verifica poi l'elenco degli SDK installati:

```bash
> dotnet --list-sdks
```

Se vedi la riga `10.0.x`, sei pronto. Nota: non è necessario installare Visual Studio; bastano l'SDK e un editor di testo, anche se un IDE con IntelliSense (Visual Studio Code con l'estensione C# Dev Kit, Visual Studio o Rider) renderà l'esperienza molto più comoda.

### 1.10.2 Creare la cartella del progetto

Creiamo una cartella per il progetto di esempio. In questo capitolo costruiremo più server; per ora ne creiamo uno per il "primo contatto":

```bash
> mkdir MioPrimoMcpServer
> cd MioPrimoMcpServer
```

### 1.10.3 Creare il progetto .NET

Per un server `stdio` useremo un semplice progetto *console*, che è il punto di partenza più leggero:

```bash
> dotnet new console -n MioPrimoMcpServer -o .
```

Il comando genera un progetto con un file `Program.cs` di esempio e un file di progetto `MioPrimoMcpServer.csproj`. Possiamo già dare un'occhiata al file di progetto:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
```

`ImplicitUsings` e `Nullable` sono già abilitati, come da template .NET moderno. Non serve altro.

### 1.10.4 Aggiungere i pacchetti NuGet

Aggiungiamo il C# SDK di MCP e il pacchetto di hosting generico di .NET. Aggiungiamo anche `Microsoft.Extensions.Http`, necessario per usare `AddHttpClient` nell'esempio meteo.

```bash
> dotnet add package ModelContextProtocol --version 2.3.0
> dotnet add package Microsoft.Extensions.Hosting
> dotnet add package Microsoft.Extensions.Http
```

Il pacchetto `ModelContextProtocol` porta con sé le API del protocollo e le estensioni di dependency injection (oltre alla dipendenza `ModelContextProtocol.Core`). Il pacchetto `Microsoft.Extensions.Hosting` serve perché i nostri server `stdio` useranno l'**host generico** (`Host.CreateApplicationBuilder`) per registrare i servizi e restare in ascolto: l'SDK, infatti, dipende solo da `Microsoft.Extensions.Hosting.Abstractions`, che non include la classe `Host`. `Microsoft.Extensions.Http` fornisce invece `AddHttpClient` per la registrazione dei client HTTP tipizzati. Non ne fissiamo qui una versione: lasciando il comando senza `--version`, NuGet seleziona una versione compatibile con il progetto `net10.0` durante il restore.

Se in futuro vorrai una versione più recente dell'SDK, puoi omettere `--version`:

```bash
> dotnet add package ModelContextProtocol
```

> **Attenzione.** L'SDK evolve rapidamente e alcune API cambiano tra una versione e l'altra. Per seguire questo capitolo senza sorprese, consigliamo di fissare la versione `2.3.0`, come nei comandi sopra.

### 1.10.5 Verificare il ripristino

Esegui una compilazione di prova per assicurarti che tutto sia in ordine:

```bash
> dotnet build
```

Se il comando termina con `Build succeeded` (o l'equivalente in italiano), l'ambiente è pronto. Nella prossima sezione sostituiremo il contenuto di `Program.cs` con il nostro primo server MCP.

### 1.10.6 Uno sguardo a ciò che abbiamo installato

Il pacchetto porta con sé, tra le altre cose, i trasporti (`StdioServerTransport` e affini), gli attributi di registrazione e le estensioni di dependency injection. Non ci sono server esterni da avviare, database da configurare o porte da aprire: un server MCP `stdio` è un normale eseguibile .NET che comunica tramite standard input/output. Questa semplicità operativa è uno dei motivi della diffusione di MCP.
