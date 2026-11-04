## 5.2 Mappare linguaggi, runtime e strumenti

Chi arriva in .NET porta con sé un modello mentale valido per il proprio ecosistema. Riutilizzarlo rende più rapido l'apprendimento, a patto di non supporre che due strumenti con nomi o scopi simili abbiano lo stesso lifecycle, la stessa semantica o gli stessi limiti. In questa sezione costruiamo una mappa e una piccola applicazione che useremo nei capitoli successivi.

### 5.2.1 Da .NET Core a .NET moderno

“.NET Core” è il nome della linea open source multipiattaforma fino a .NET Core 3.1. Da .NET 5 il prodotto si chiama **.NET**: .NET 6, 7, 8, 9 e 10 sono versioni della piattaforma unificata. **ASP.NET Core** è il framework web moderno della piattaforma e ha mantenuto “Core” nel proprio nome. Il vecchio **.NET Framework** è un prodotto distinto, principalmente legato a Windows; non è il target di questo capitolo.

Per un nuovo servizio, fissare una versione supportata e dichiararla esplicitamente. .NET 10 è il riferimento degli esempi. Non scegliere il target perché il computer dello sviluppatore lo ha installato per caso: SDK, target framework, pipeline CI e runtime di produzione devono essere coordinati. Per la policy di supporto e le patch correnti fare riferimento alla pagina ufficiale del ciclo di vita .NET.

### 5.2.2 Concetti e strumenti a confronto

- **PHP:** linguaggio PHP; runtime PHP e Composer; progetto `composer.json`; avvio dipendente dal framework o dal worker; framework come Laravel e Symfony; pacchetti da Packagist.
- **Python:** linguaggio Python; runtime e pip/Poetry; progetto `pyproject.toml`; avvio tramite modulo, ASGI o WSGI; framework come Django, Flask e FastAPI; pacchetti da PyPI.
- **Node.js:** JavaScript o TypeScript; Node.js con npm/pnpm; progetto `package.json`; entry point Node; framework come Express e NestJS; pacchetti dal registry npm.
- **Java:** linguaggio Java; JDK con Maven/Gradle; progetto `pom.xml` o file Gradle; avvio da `main` o framework; framework come Spring Boot; pacchetti da Maven Central.
- **.NET:** linguaggio C#; SDK e runtime .NET; progetto `.csproj`; avvio da `Program.cs` e host; framework come ASP.NET Core; pacchetti da NuGet.

La tabella orienta, ma non mappa capacità uno-a-uno. Per esempio un provider del framework sorgente può combinare routing, dependency injection, sessione e configurazione; nel target queste responsabilità possono appartenere a servizi differenti. Prima di sostituirlo, scomporre quali comportamenti effettivamente offre.

### 5.2.3 SDK, runtime e CLI

L'**SDK** include compilatore, template e strumenti per sviluppare; il **runtime** esegue un'applicazione già pubblicata. Un server di build richiede l'SDK; un container di produzione può usare solo il runtime, oppure un artefatto self-contained a seconda della strategia. La distinzione influenza immagini, dimensione del deploy, patching e installazione.

La CLI standardizza molte operazioni:

```text
dotnet --info
dotnet new webapi -n Catalogo.Api
cd Catalogo.Api
dotnet restore
dotnet build
dotnet test
dotnet run
dotnet publish -c Release -o publish
```

`dotnet restore` risolve i pacchetti; `build` compila; `test` esegue i test; `run` avvia il progetto; `publish` produce l'output destinato alla distribuzione. Non sono sinonimi: per esempio una build riuscita non garantisce che l'applicazione sia configurata correttamente in produzione.

Per pinning riproducibile, il repository può contenere `global.json` con la policy SDK usata dal team. Il file `.csproj` dichiara il target:

```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>
</Project>
```

`TargetFramework` non è una lista di pacchetti. Le librerie esterne si aggiungono con `dotnet add package` e vengono registrate nel progetto; in una soluzione con più progetti si distingue il progetto API dai progetti di dominio e test.

### 5.2.4 Sintassi C# per chi conosce già un linguaggio

C# è staticamente tipizzato e compilato. Il compilatore intercetta categorie di errori prima dell'avvio, ma il sistema dei tipi non sostituisce validazione e test. `string?` indica che un valore può essere null quando nullable reference types sono attivi; `string` esprime l'intenzione opposta. I dati ricevuti da HTTP sono comunque input non attendibile e vanno validati.

Un record può descrivere un DTO immutabile:

```csharp
public sealed record CreateProductRequest(string Name, decimal Price);
```

La definizione non valida automaticamente `Name` o `Price`: occorrono regole esplicite. Un metodo asincrono restituisce normalmente `Task<T>` o `ValueTask<T>` e usa `await`; l'asincronia è essenziale per non bloccare thread mentre si aspetta I/O, ma non rende automaticamente veloce una query.

```csharp
public async Task<Product?> FindAsync(
    int id, CancellationToken cancellationToken)
{
    return await db.Products
        .SingleOrDefaultAsync(p => p.Id == id, cancellationToken);
}
```

Il codice non dovrebbe nascondere le eccezioni con `catch { return null; }`: un errore database non equivale a un prodotto assente. Gli errori devono essere tradotti in modo coerente al confine applicativo e registrati con contesto sufficiente, senza esporre dettagli interni al client.

### 5.2.5 Lifecycle e hosting

Molti framework sorgente offrono un processo per richiesta, un worker persistente, oppure più processi con un server applicativo davanti. ASP.NET Core usa un **host** che costruisce configurazione, logging, dependency injection e lifecycle dell'applicazione. Kestrel è il server HTTP integrato; può ricevere direttamente traffico o lavorare dietro un reverse proxy, in base all'ambiente.

Nel modello moderno `Program.cs` configura servizi e pipeline e avvia l'host. La parte essenziale può essere molto breve:

```csharp
var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();
app.MapGet("/health", () => Results.Ok(new { status = "ok" }));
app.Run();
```

`AddEndpointsApiExplorer()` da solo registra metadati, ma non genera né espone un documento OpenAPI: serve insieme a un generatore. Per esempio, in .NET 10, aggiungendo il pacchetto `Microsoft.AspNetCore.OpenApi`, si può usare `AddOpenApi()` con `MapOpenApi()`; qui non è necessario e viene omesso.

La brevità non implica assenza di struttura: route, servizi, opzioni e componenti possono essere estratti in metodi o moduli. Il punto d'ingresso non è il luogo in cui inserire tutta la logica di dominio; è il punto in cui si compone l'applicazione.

### 5.2.6 Pacchetti e dipendenze

NuGet è il sistema di pacchetti .NET. Ogni dipendenza aggiunta aumenta superficie di aggiornamento, licenze e rischio di supply chain. Prima di portare un pacchetto, verificare compatibilità con il target, manutenzione, advisory, licenza, dipendenze transitive e necessità effettiva. Un equivalente con nome simile può avere una filosofia o un lifecycle differenti.

Per build riproducibili, versionare il file di lock quando il workflow lo usa, mantenere gli aggiornamenti automatizzati e non includere credenziali del registry nel progetto. Configurazioni di feed e token devono stare in ambienti o secret store protetti. La pipeline dovrebbe ripristinare, compilare e testare da una copia pulita del repository.

### 5.2.7 Un primo servizio e le verifiche di ambiente

Creare un progetto è solo la prima verifica. Prima di migrare logica applicativa, accertarsi che il team possa:

1. installare o selezionare la versione SDK prevista;
2. ripristinare i pacchetti dietro le restrizioni di rete del progetto;
3. compilare e testare dalla CLI e in CI;
4. avviare l'applicazione con la configurazione locale;
5. produrre un artefatto pubblicabile e avviarlo in un ambiente simile alla produzione.

Registrare i comandi funzionanti e le versioni nel README del progetto. Un "funziona sul mio IDE" non è ancora una toolchain condivisa.

### 5.2.8 La mappa deve essere verificata sul caso reale

Per ogni concetto del sistema sorgente, compilare una scheda con tre colonne: responsabilità attuale, candidato .NET, differenza da provare. Per esempio: un hook di richiesta in un framework Python può essere middleware, filtro o endpoint filter; la scelta dipende dal fatto che debba avvolgere l'intera richiesta, agire solo su una route o validare parametri. Questa verifica evita migrazioni basate sulla sola somiglianza dei nomi.
