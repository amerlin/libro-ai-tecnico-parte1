## 4.3 Le istruzioni

Le istruzioni sono il livello più diffuso e quello con più varianti: ogni motore ha il suo nome di file. I concetti però sono comuni: un file principale per il progetto, file aggiuntivi attivati da un pattern, e una distinzione tra ambito utente e ambito progetto.

### 4.3.1 Che cosa scrivere (e che cosa no)

Un buon file di istruzioni contiene **fatti** e **regole verificabili**, non raccomandazioni generiche. Il confronto rende l'idea:

| Da evitare | Meglio |
| --- | --- |
| «Scrivi codice pulito e ben strutturato» | «Le entità EF Core stanno in `src/Models`, i DTO in `src/Contracts`, le configurazioni in `src/Data/Configurations`» |
| «Fai attenzione alla sicurezza» | «Non loggare mai `ConnectionString`, `ApiKey`, `Password`; usa `ILogger` con parametri strutturati» |
| «Testa il codice» | «Dopo ogni modifica a `src/`, esegui `dotnet test tests/Taskify.Tests --filter Category=Unit`» |
| «Usa le convenzioni del progetto» | «Le interfacce iniziano con `I`, i metodi asincroni finiscono con `Async` e accettano `CancellationToken`» |

La regola pratica: **se non è verificabile, non è un'istruzione**. «Scrivi codice pulito» non si può controllare; «i DTO sono `record` immutabili» sì.

### 4.3.2 Un file di progetto

Un file di istruzioni tipico, in Markdown semplice, è fatto di sezioni brevi:

```markdown
# Taskify — istruzioni di progetto

## Stack
- .NET 10, Minimal API ASP.NET Core, EF Core 10 con SQLite in sviluppo.
- Test: xUnit + `Microsoft.AspNetCore.Mvc.Testing`.

## Struttura
- `src/Models` entità EF Core; `src/Contracts` DTO (`record`); `src/Data` `DbContext`.
- Nessuna logica di dominio nei endpoint: va in `src/Services`.

## Comandi
- Build: `dotnet build -warnaserror`
- Test: `dotnet test --filter Category!=Integration`
- Migrazione: `dotnet ef migrations add <Nome> -p src/Data`

## Regole
- Ogni endpoint asincrono accetta `CancellationToken` e lo passa a EF Core.
- Non introdurre nuove dipendenze NuGet senza approvazione.
- Non committare `appsettings.Development.local.json`.
```

Niente fronzoli, nessuna introduzione, nessun "sei un assistente esperto": l'agente sa già cosa deve fare. Ogni riga è un vincolo che si può verificare in una revisione.

### 4.3.3 Istruzioni mirate: `applyTo` e `globs`

Il file di progetto vale ovunque. Ma in un repository reale le regole cambiano per area: i test hanno convenzioni diverse dal codice di produzione, il frontend ha uno stile diverso dal backend. Per questo i motori supportano file di istruzioni **con un pattern di attivazione** nel frontmatter.

In VS Code con Copilot il file si chiama `*.instructions.md` e il campo è `applyTo`:

```markdown
---
description: Convenzioni per i test di integrazione
applyTo: "tests/**/*.cs"
---

# Test di integrazione

- Ogni test usa `WebApplicationFactory<Program>` e un database SQLite in memoria.
- Il nome segue `Metodo_Scenario_RisultatoAtteso`.
- Non usare `Thread.Sleep`: usa `WaitAsync` con timeout esplicito.
- Un solo `Assert` per test quando possibile; per i casi multipli usa `[Theory]`.
```

In Cursor il file è `.mdc` e i campi sono `globs`, `description` e `alwaysApply`:

```markdown
---
description: Convenzioni degli endpoint della Minimal API
globs: src/Api/**/*.cs
alwaysApply: false
---

- Ogni gruppo di endpoint è mappato in `MapXxxEndpoints(this IEndpointRouteBuilder app)`.
- Le risposte di errore usano `ProblemDetails`, mai stringhe.
- Ogni endpoint dichiara `.WithName`, `.WithSummary` e `.Produces<T>()`.
```

Claude Code usa invece file Markdown in `.claude/rules/` con il campo `paths`:

```markdown
---
paths: ["src/Api/**/*.cs"]
---

- Le risposte di errore usano `ProblemDetails`.
- Ogni endpoint dichiara `.WithName` e `.WithSummary`.
```

Tre sintassi per associare **regole diverse a file diversi**, caricate quando servono. Il pattern definisce l'ambito di applicazione: non significa, da solo, che la regola sostituisca quelle generali. Quando più regole corrispondono, il comportamento dipende dal client.

### 4.3.4 La trappola delle istruzioni duplicate

Quando le regole crescono, è facile ritrovarsi la stessa frase in tre file. Se poi una copia cambia e le altre no, l'agente riceve istruzioni contraddittorie. Non esiste una regola universale per stabilire quale prevalga: dipende dal client, e un pattern di attivazione non equivale a una sostituzione.

La contromisura è la stessa del codice: **una sola fonte di verità**. Il file di progetto contiene le regole globali; i file mirati contengono solo ciò che è specifico di quell'area, e non ripetono nulla del livello superiore.
