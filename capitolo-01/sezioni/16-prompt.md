## 1.16 I Prompt

Il terzo primitivo, il **prompt**, permette di esporre modelli di istruzioni riutilizzabili. A differenza dei tool (che eseguono codice) e delle risorse (che forniscono dati), un prompt produce **testo pronto da inviare al modello**.

### 1.16.1 Un prompt semplice

Come per i tool, si marca una classe con `[McpServerPromptType]` e i metodi con `[McpServerPrompt]`:

```csharp
using System.ComponentModel;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using ModelContextProtocol.Server;

var builder = Host.CreateApplicationBuilder(args);
builder.Logging.ClearProviders();

builder.Services.AddMcpServer()
    .WithStdioServerTransport()
    .WithPrompts<AppPrompts>();

await builder.Build().RunAsync();

[McpServerPromptType]
public sealed class AppPrompts
{
    [McpServerPrompt, Description("Creates a code review prompt.")]
    public static string ReviewCode(
        [Description("The code to review.")] string code)
        => $"Please review the following code and suggest improvements:\n\n{code}";
}
```

Il client può elencare i prompt (`prompts/list`) e ottenerne il testo (`prompts/get`). L'utente, dall'interfaccia dell'host, seleziona il prompt `review_code` e il modello riceve l'istruzione già composta.

### 1.16.2 I prompt con argomenti

Un prompt può dichiarare **argomenti** con relativo schema, esattamente come un tool:

```csharp
[McpServerPrompt, Description("Creates a meeting summary prompt.")]
public static string SummarizeMeeting(
    [Description("Title of the meeting.")] string title,
    [Description("Raw meeting transcript.")] string transcript)
    => $"Summarize the meeting '{title}' highlighting decisions and action items.\n\nTranscript:\n{transcript}";
```

### 1.16.3 Prompt o tool?

La differenza è sottile ma importante:

- un **tool** *esegue* un'operazione e restituisce un risultato (dati, conferme, contenuti calcolati);
- un **prompt** *compone* istruzioni che saranno eseguite dal modello.

Se il tuo obiettivo è "genera un testo con queste istruzioni", un prompt è la scelta giusta. Se il tuo obiettivo è "esegui questa operazione e dammi il risultato", serve un tool. In molti casi i due si combinano: un prompt può istruire il modello su *come* usare i tool disponibili.

### 1.16.4 Un caso d'uso reale

Immagina un team che fa spesso code review. Invece di far riscrivere ogni volta le istruzioni all'utente, il server espone un prompt `review_code`. L'utente seleziona il prompt, incolla il codice, e il modello riceve istruzioni coerenti e complete, uguali per tutti i membri del team. Se un giorno il team decide di aggiungere un criterio di revisione (per esempio "controlla anche le dipendenze obsolete"), basta aggiornare il prompt nel server: tutti gli utenti ne beneficiano immediatamente, senza modificare alcun client.

Questa è la filosofia MCP applicata alle istruzioni: **centralizzare** ciò che è condiviso, **standardizzare** il modo di accedervi.
