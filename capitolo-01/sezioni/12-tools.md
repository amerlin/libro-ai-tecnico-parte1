## 1.12 I Tools in dettaglio

Il tool è il primitivo più usato, e merita un approfondimento. In questa sezione esamineremo tutto ciò che si può controllare nell'esposizione di un tool: nomi, descrizioni, tipi di parametro, tipi di ritorno, asincronia, annullamento e annotazioni.

### 1.12.1 L'anatomia di un metodo-tool

Un tool è, in definitiva, un **metodo C# marcato con `[McpServerTool]`**. L'SDK, tramite reflection, ne ricava:

- il **nome** (dal nome del metodo, normalizzato in minuscolo, o dalla proprietà `Name`);
- la **descrizione** (dall'attributo `[Description]` o dal commento XML `<summary>`);
- lo **schema di input** (dai parametri: nome, tipo .NET mappato a tipo JSON, obbligatorietà, `[Description]`);
- il **tipo di ritorno** (che determina la forma del contenuto restituito).

### 1.12.2 I tipi di parametro supportati

L'SDK converte i tipi .NET in tipi JSON Schema. I mapping più comuni:

| Tipo .NET | Tipo JSON Schema |
|-----------|------------------|
| `string` | `string` |
| `int`, `long`, `short` | `integer` |
| `double`, `float`, `decimal` | `number` |
| `bool` | `boolean` |
| `DateTime`, `DateTimeOffset` | `string` (formato data/ora) |
| `enum` | `string` con `enum` dei valori |
| array e classi/record | `array` e `object` annidati |

I parametri **opzionali** (con valore di default) non vengono inseriti nell'elenco `required` dello schema; i parametri senza default sono obbligatori. Esiste inoltre un supporto sperimentale per i tipi *nullable* di riferimento.

### 1.12.3 I tipi di ritorno supportati

Un tool può restituire:

- **`string`** — viene incapsulata in un contenuto di tipo testo (`{ "type": "text", "text": ... }`);
- **un oggetto, un record o un array** — viene serializzato in JSON e incapsulato **in un blocco di testo**; se inoltre si imposta `UseStructuredContent = true` sull'attributo, il risultato viene duplicato anche nel campo `structuredContent`, che il client espone come dato già deserializzato;
- **`Task<T>` / `ValueTask<T>`** — per l'esecuzione asincrona;
- **`IAsyncEnumerable<T>`** — per restituire più risultati in modo incrementale.

Nel nostro primo server abbiamo usato `string`. Vediamo ora un esempio con un **record**, più vicino ai casi reali:

```csharp
[McpServerTool, Description("Sums two numbers and returns a structured result.")]
public static AddResult Add(
    [Description("First operand.")] int a,
    [Description("Second operand.")] int b)
    => new AddResult(a, b, a + b);

public sealed record AddResult(int A, int B, int Sum);
```

Quando il client invoca `add` con `a = 2, b = 3`, il server restituisce per default un contenuto di testo contenente il JSON serializzato:

```json
{ "type": "text", "text": "{\"a\":2,\"b\":3,\"sum\":5}" }
```

Se invece vogliamo che il dato viaggi anche come **contenuto strutturato** (cioè già deserializzato, senza doverlo rileggere dal testo), abilitiamo la proprietà corrispondente:

```csharp
[McpServerTool(UseStructuredContent = true)]
[Description("Sums two numbers and returns a structured result.")]
public static AddResult Add(
    [Description("First operand.")] int a,
    [Description("Second operand.")] int b)
    => new AddResult(a, b, a + b);
```

In questo caso il client riceve sia il blocco di testo sia il campo `structuredContent` pari a `{"a":2,"b":3,"sum":5}`. La scelta dipende dal client: molti client (e modelli) si trovano bene con il testo JSON, ma se sai che il consumatore preferisce dati strutturati, `UseStructuredContent` è l'opzione giusta.

### 1.12.4 Tool asincroni e annullamento

I tool reali spesso eseguono I/O (chiamate HTTP, query, letture da disco). In questi casi il metodo deve essere asincrono e deve accettare un `CancellationToken`, che l'SDK associa alla cancellazione della richiesta:

```csharp
[McpServerTool, Description("Waits for the given number of milliseconds.")]
public static async Task<string> Delay(
    [Description("Milliseconds to wait.")] int milliseconds,
    CancellationToken cancellationToken = default)
{
    await Task.Delay(milliseconds, cancellationToken);
    return $"waited {milliseconds} ms";
}
```

Il `CancellationToken` **non** diventa un argomento del tool: l'SDK lo riconosce come parametro speciale e lo inietta automaticamente, escludendolo dallo schema di input. Lo stesso vale per eventuali parametri di servizio risolti dal container (ci torneremo nell'esempio meteo).

### 1.12.5 Iniezione delle dipendenze nei tool

Le classi tool vengono istanziate dal container di dependency injection. Possiamo quindi usare il **costruttore** per ricevere i servizi, esattamente come in una qualunque classe .NET:

```csharp
[McpServerToolType]
public sealed class TicketTool(TicketService service, ILogger<TicketTool> logger)
{
    [McpServerTool, Description("Creates a new support ticket.")]
    public async Task<string> CreateTicket(
        [Description("Subject of the ticket.")] string subject,
        CancellationToken cancellationToken = default)
    {
        logger.LogInformation("Creating ticket {Subject}", subject);
        var id = await service.CreateAsync(subject, cancellationToken);
        return $"ticket created with id {id}";
    }
}
```

Qui `TicketService` e `ILogger<TicketTool>` vengono iniettati nel costruttore primario, mentre `subject` è l'unico vero argomento del tool. La combinazione di *argomenti dichiarativi* e *dipendenze iniettate* è uno dei punti di forza dell'SDK .NET.

### 1.12.6 Le annotazioni dei tool

MCP prevede alcune **annotazioni** facoltative che aiutano il client (e il modello) a capire la natura di un tool. L'SDK le espone come proprietà dell'attributo `[McpServerTool]`:

| Proprietà | Significato |
|-----------|-------------|
| `Title` | Un titolo breve e leggibile per l'interfaccia utente |
| `Destructive` | `true` se il tool può distruggere o alterare dati in modo irreversibile |
| `Idempotent` | `true` se chiamate ripetute con gli stessi argomenti producono lo stesso effetto |
| `OpenWorld` | `true` se il tool interagisce con un sistema "aperto" e mutevole |
| `ReadOnly` | `true` se il tool non modifica alcuno stato |

Esempio:

```csharp
[McpServerTool(Title = "Delete customer", Destructive = true, ReadOnly = false)]
[Description("Permanently deletes a customer and all related data.")]
public static string DeleteCustomer([Description("Customer id.")] int id)
    => $"customer {id} deleted";
```

Queste annotazioni non cambiano il comportamento del server, ma consentono ai client di mostrare conferme ("sei sicuro?") o di applicare politiche di sicurezza più prudenti per le operazioni distruttive.

### 1.12.7 Best practices

La descrizione di un tool è il suo "biglietto da visita" verso il modello. Alcune regole pratiche:

- descrivi **cosa fa** il tool, non come è implementato;
- indica **quando** usarlo e **quando no** ("usa questo tool per...", "non usarlo se...");
- descrivi ogni parametro con precisione, indicando formato e vincoli (per esempio "YYYY-MM-DD", "IATA code");
- sii coerente nel linguaggio: se un tool dice "customer", tutti i tool dovrebbero dire "customer", non alternare con "client";
- mantieni le descrizioni in inglese se il modello è usato prevalentemente in inglese; in italiano se il tuo contesto è italiano.

Una descrizione vaga produce un uso incerto del tool; una descrizione precisa è la differenza tra un agente che "ci azzecca" e uno che fallisce.
