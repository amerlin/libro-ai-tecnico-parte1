## 2.4 Setup del progetto e pacchetti

Prepariamo l'ambiente. Il procedimento ricalca il Capitolo 1, con l'aggiunta dei pacchetti EF Core.

### 2.4.1 Creare il progetto

Come per ogni server `stdio`, partiamo da un progetto console:

```bash
> mkdir CatalogMcpServer
> cd CatalogMcpServer
> dotnet new console -n CatalogMcpServer -o .
```

### 2.4.2 Aggiungere i pacchetti

Servono quattro pacchetti:

```bash
> dotnet add package ModelContextProtocol --version 2.3.0
> dotnet add package Microsoft.Extensions.Hosting
> dotnet add package Microsoft.EntityFrameworkCore.Sqlite --version 10.0.14
> dotnet add package Microsoft.EntityFrameworkCore.Design --version 10.0.14
```

A cosa serve ciascuno:

- `ModelContextProtocol` — il C# SDK di MCP (con le estensioni DI);
- `Microsoft.Extensions.Hosting` — l'host generico (`Host.CreateApplicationBuilder`) per il server `stdio`;
- `Microsoft.EntityFrameworkCore.Sqlite` — il provider EF Core per SQLite;
- `Microsoft.EntityFrameworkCore.Design` — gli strumenti di design-time, necessari per il comando `dotnet ef` (migrazioni). Si usa solo in sviluppo: per questo, se preferisci, puoi marcarlo con `PrivateAssets="all"`, ma non è indispensabile.

### 2.4.3 Il file di progetto risultante

Dopo l'aggiunta, il file `CatalogMcpServer.csproj` assomiglierà a:

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="10.0.14" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="10.0.14" />
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="10.0.13" />
    <PackageReference Include="ModelContextProtocol" Version="2.3.0" />
  </ItemGroup>

</Project>
```

> **Nota sulle versioni.** `Microsoft.Extensions.Hosting` compare con la versione che `dotnet add package` risolve automaticamente (qui 10.0.13); non serve fissarla a mano, purché sia una 10.x. Per l'SDK MCP e per EF Core, invece, fissiamo le versioni indicate per riproducibilità.

### 2.4.4 Installare gli strumenti EF Core (una tantum)

Il comando `dotnet ef` (che useremo per le migrazioni) non fa parte dell'SDK .NET di base: va installato come strumento globale, una sola volta per macchina:

```bash
> dotnet tool install --global dotnet-ef
```

Se è già installato, puoi aggiornarlo con:

```bash
> dotnet tool update --global dotnet-ef
```

Verifica che sia disponibile:

```bash
> dotnet ef --version
```

### 2.4.5 Verificare la compilazione

Prima di scrivere una riga di codice nostro, assicuriamoci che il progetto compili:

```bash
> dotnet build
```

Con l'ambiente pronto, passiamo a definire il modello e il `DbContext`.
