## 3.20 CI/CD e automazione

Spec Kit non si limita alla chat: la pipeline può automatizzare build e test del prodotto, mentre la revisione degli artefatti Spec Kit resta affidata al workflow dell'agente e ai revisori.

### 3.20.1 `specify check` non è un gate degli artefatti

`specify check` controlla la disponibilità degli strumenti e dei prerequisiti richiesti dal CLI; non convalida specifiche, piani, task o altri artefatti. È utile durante la configurazione dell'ambiente, ma non aggiunge un controllo di qualità degli artefatti alla CI. Anche `specify self check`, se disponibile, è un'autodiagnosi del CLI e non sostituisce la revisione degli artefatti.

Il comando si può eseguire localmente per diagnosticare l'ambiente. Non lo inseriamo nel workflow CI d'esempio: se fallisce, segnala un problema di prerequisiti CLI, non un artefatto Spec Kit non valido.

### 3.20.2 Build e test del progetto .NET

Il controllo automatico ripetibile del progetto è la build e l'esecuzione dei test. I comandi puntano esplicitamente al progetto di test perché l'esempio non presuppone una soluzione `.sln` nella radice:

```yaml
steps:
  - uses: actions/setup-dotnet@v4
    with:
      dotnet-version: '10.0.x'
  - run: dotnet restore tests/Taskify.Tests/Taskify.Tests.csproj
  - run: dotnet build tests/Taskify.Tests/Taskify.Tests.csproj --no-restore
  - run: dotnet test tests/Taskify.Tests/Taskify.Tests.csproj --no-build --no-restore
```

Questi passaggi compilano anche il progetto web referenziato e poi eseguono i test xUnit.

### 3.20.3 Workflow e hook

Spec Kit offre due meccanismi per andare oltre:

- **Hook** (in `.specify/extensions.yml`) — azioni prima/dopo i comandi. Un hook `before_specify` può creare il branch Git della feature automaticamente.
- **Workflow** — sequenze automatizzate di prompt, comandi, gate e task di shell, eseguibili anche senza interazione.

Per esempio, un workflow può incapsulare la sequenza `dotnet build` → `dotnet test` → report. È utile per ambienti in cui l'agente non è disponibile o per esecuzioni notturne; non certifica, da solo, la qualità della specifica o del piano.

### 3.20.4 L'automazione non sostituisce la revisione

La CI qui controlla che il codice compili e che i test passino; non verifica la qualità degli artefatti Spec Kit né che la specifica rifletta davvero ciò che serve. Per la coerenza degli artefatti si usano i controlli dell'agente, come `/speckit-analyze` e `/speckit-converge`, insieme alla revisione umana. La pipeline è una rete di sicurezza per il codice, non un sostituto del giudizio.

### 3.20.5 Un esempio di pipeline completa

```yaml
name: ci

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET 10
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'

      - name: Restore
        run: dotnet restore tests/Taskify.Tests/Taskify.Tests.csproj

      - name: Build
        run: dotnet build tests/Taskify.Tests/Taskify.Tests.csproj --no-restore

      - name: Test
        run: dotnet test tests/Taskify.Tests/Taskify.Tests.csproj --no-build --no-restore
```

Questa pipeline verifica il prodotto .NET senza attribuire a `specify check` o a un controllo CLI una validazione che non svolgono. La qualità del metodo e degli artefatti si rivede nel workflow Spec Kit.
