## 3.22 Il processo di bug fixing

Spec Kit non serve solo a costruire feature: include un processo dedicato alla **diagnosi e riparazione dei bug**. È un'estensione opzionale, che si installa quando serve.

### Come si installa

```bash
specify extension add bug
```

L'estensione aggiunge tre comandi all'agente:

```text
/speckit-bug-assess "Sottomettere una password vuota manda in crash il login." slug=login-crash
/speckit-bug-fix slug=login-crash
/speckit-bug-test slug=login-crash
```

### Il flusso in tre passi

1. **Assess** — analizza il sintomo, ne individua la causa probabile e delimita l'ambito della correzione. Produce un report in `.specify/bugs/<slug>/`.
2. **Fix** — applica la correzione mirata, senza riscrivere interi moduli.
3. **Test** — verifica che il sintomo originale sia risolto e registra l'esito.

### Il verdetto

Il passo finale produce un **verdetto** documentato:

| Verdetto | Significato |
|----------|-------------|
| `verified` | La correzione risolve il sintomo: successo |
| `partial` | Il sintomo è attenuato ma non del tutto risolto |
| `failed` | La correzione non risolve il sintomo |

Solo `verified` conferma una correzione riuscita. Gli artefatti restano in `.specify/bugs/<slug>/` come **registrazione verificata** di ciò che è stato fatto: causa valutata, fix delimitato, verifica documentata.

### Un esempio in C\#

Supponiamo che la nostra Task Manager API abbia un bug: creare un task con un titolo di esattamente 201 caratteri produce un errore 500 invece di un 400. Il flusso:

```text
/speckit-bug-assess "POST /tasks con titolo di 201 caratteri restituisce 500
invece di 400." slug=title-length-500
```

L'assessment individua la causa: la validazione controlla `Title.Length > 200` **dopo** il salvataggio, ma il database (vincolo `HasMaxLength(200)`) lancia un'eccezione prima che la validazione venga raggiunta, producendo il 500.

```text
/speckit-bug-fix slug=title-length-500
```

Il fix sposta la validazione della lunghezza **prima** dell'inserimento nel database:

```csharp
// Prima del fix: la validazione arrivava dopo il database
// Dopo il fix: la validazione avviene prima di toccare il DbContext
if (request.Title is { Length: > 200 })
    return Results.BadRequest(new { error = "Title must be at most 200 characters." });
```

```text
/speckit-bug-test slug=title-length-500
```

Il test verifica che un titolo di 201 caratteri produca ora `400 Bad Request` e che il sintomo originale sia scomparso. Il verdetto finale, se tutto regge, è `verified`.

### Bug fixing vs feature workflow

Il processo di bug fixing **non richiede** il workflow SDD completo: puoi diagnosticare e riparare un bug senza una specifica di feature. I due processi convivono: lo SDD per il nuovo, il bug fixing per il rotto.
