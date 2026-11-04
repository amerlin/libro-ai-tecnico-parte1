## 3.18 Esempio C#: eseguire, verificare e convergere

Chiudiamo l'esempio eseguendo l'applicazione, provandola con richieste reali e portando a termine la convergenza.

### 3.18.1 Avviare l'applicazione

```powershell
> dotnet run --urls http://localhost:5080
```

L'applicazione parte su `http://localhost:5080`. Ora possiamo provarla con `curl.exe` da PowerShell:

### 3.18.2 Creare un task

```powershell
> curl.exe -X POST "http://localhost:5080/tasks" `
    -H "Content-Type: application/json" `
    -d '{"title": "Scrivere il capitolo 3", "dueDate": null}'
```

Risposta attesa (201 Created):

```json
{
  "id": 1,
  "title": "Scrivere il capitolo 3",
  "isCompleted": false,
  "dueDate": null,
  "createdAt": "2026-10-27T12:00:00+00:00"
}
```

### 3.18.3 Elencare con filtro

```powershell
> curl.exe "http://localhost:5080/tasks?status=open"
```

```json
[
  { "id": 1, "title": "Scrivere il capitolo 3", "isCompleted": false, ... }
]
```

### 3.18.4 Completare ed eliminare

```powershell
> curl.exe -X POST "http://localhost:5080/tasks/1/complete"
> curl.exe -X DELETE "http://localhost:5080/tasks/1"
```

La prima risponde con il task completato, la seconda con `204 No Content`.

### 3.18.5 La convergenza

Apri una nuova shell nella radice del repository e verifica che i test passino (`dotnet test tests/Taskify.Tests/Taskify.Tests.csproj`); poi torniamo all'agente e invochiamo:

```text
/speckit-converge
```

Il comando confronta il codice con `spec.md`, `plan.md` e `tasks.md`. Se tutto è implementato, riporta **Converged**. Se, per esempio, avessimo dimenticato la validazione della data di scadenza nel passato (un edge case della specifica), converge lo segnalerebbe e **aggiungerebbe un task** a `tasks.md`: a quel punto basterebbe rieseguire `/speckit-implement` e di nuovo `/speckit-converge`.

### 3.18.6 Il risultato completo

Al termine del flusso, il repository contiene:

![Struttura finale del repository dopo il flusso completo](figure/risultato-finale.pdf)

Una feature completa: specifica, piano, task, codice, test e convergenza — tutto versionato e ricostruibile. È il percorso che abbiamo attraversato in questo capitolo, e che puoi ora ripetere per qualsiasi feature in C# (o in qualunque altro linguaggio).
