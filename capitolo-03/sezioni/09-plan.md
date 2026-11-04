## 3.9 `/speckit-plan`: il piano tecnico

Ora che *cosa* costruire è chiaro, `/speckit-plan` decide *come*. È il comando che introduce — finalmente — la tecnologia, nel nostro caso **C# e .NET**.

### 3.9.1 Come si invoca

```text
/speckit-plan Usa .NET 10 con una Minimal API ASP.NET Core. Persistenza con
Entity Framework Core su SQLite. Test con xUnit.
```

La richiesta di piano fornisce i **vincoli tecnici** (stack, librerie, piattaforma). Se qualcosa non è specificato, il comando lo chiede o lo marca `NEEDS CLARIFICATION`.

### 3.9.2 Le fasi del piano

Il comando lavora in fasi:

- **Fase 0 — Ricerca.** Se serve, esplora le opzioni tecniche (librerie, pattern) e produce `research.md`.
- **Fase 1 — Progettazione.** Produce `data-model.md` (le entità), `contracts/` (gli endpoint e i loro contratti), `quickstart.md` (gli scenari chiave di validazione).
- **Fase 2 — Piano.** Produce `plan.md`, il documento principale.

In più, **prima della Fase 0** esegue il **Constitution Check**: il piano deve rispettare i principi della constitution, oppure giustificare le violazioni.

### 3.9.3 La struttura di `plan.md`

Il template di piano ha queste sezioni:

| Sezione | Contenuto |
|---------|-----------|
| **Summary** | Requisito primario + approccio tecnico scelto |
| **Technical Context** | Linguaggio, dipendenze, storage, test, piattaforma, performance, vincoli, scala |
| **Constitution Check** | I gate derivati dalla constitution |
| **Project Structure** | Albero delle cartelle del codice sorgente |
| **Complexity Tracking** | (solo se serve) giustificazione delle violazioni di semplicità |

### 3.9.4 L'esempio C#: il piano

Ecco `specs/001-task-manager/plan.md` compilata per la nostra feature:

```markdown
# Implementation Plan: Task Manager API

**Branch**: `001-task-manager` | **Spec**: specs/001-task-manager/spec.md

## Summary

Una Minimal API ASP.NET Core che espone operazioni CRUD su task
(creazione, elenco con filtro, completamento, eliminazione), con
persistenza su SQLite tramite Entity Framework Core.

## Technical Context

**Language/Version**: C# 14 / .NET 10
**Primary Dependencies**: ASP.NET Core (Minimal API),
  Microsoft.EntityFrameworkCore.Sqlite
**Storage**: SQLite (file locale)
**Testing**: xUnit + WebApplicationFactory
**Target Platform**: server Windows/Linux/macOS
**Project Type**: web-service
**Performance Goals**: <100 ms per operazione su set di 10.000 task
**Constraints**: nessun servizio esterno, API REST JSON
**Scale/Scope**: monoutente, migliaia di task

## Constitution Check

- [x] Test-First: i test di accettazione precedono l'implementazione
- [x] Semplicità: una sola Minimal API, nessuna astrazione superflua
- [x] Validazione input: DataAnnotations/minimal validation sugli endpoint
- [x] API REST coerenti: risorse al plurale (/tasks), codici di stato semantici; il completamento usa il comando esplicito `POST /tasks/{id}/complete`, ammesso dalla constitution

## Project Structure

src/
|-- Taskify.csproj
|-- Program.cs            # bootstrap + endpoint
|-- Models/
|   `-- TaskItem.cs
|-- Data/
|   `-- TaskDbContext.cs
`-- Contracts/
    `-- TaskDtos.cs

tests/
`-- Taskify.Tests/
    |-- Taskify.Tests.csproj
    `-- TaskEndpointsTests.cs

**Structure Decision**: progetto singolo con cartella tests/ separata.
```

### 3.9.5 Il modello dati e i contratti

Il piano produce anche due artefatti preziosi. `data-model.md`:

```markdown
# Data Model: Task Manager API

## TaskItem

| Campo | Tipo | Vincoli |
|-------|------|---------|
| Id | int | chiave primaria |
| Title | string | obbligatorio, max 200 |
| IsCompleted | bool | default false |
| DueDate | DateTime? | opzionale |
| CreatedAt | DateTimeOffset | impostato dall'applicazione in UTC |

Relazioni: nessuna (entità singola per la v1).
```

E `contracts/tasks-api.md` con i contratti degli endpoint:

```markdown
## POST /tasks
Request:  { "title": "string", "dueDate": "date-time?" }
Response: 201 Created, body: { "id": 1, "title": "...", ... }

## GET /tasks?status=open|completed
Response: 200 OK, body: [ { ...TaskItem... } ]

## POST /tasks/{id}/complete
Response: 200 OK oppure 404 Not Found

È un endpoint di comando per la transizione esplicita di stato `complete`,
ammessa dal principio API REST della constitution; non crea una nuova task.

## DELETE /tasks/{id}
Response: 204 No Content oppure 404 Not Found
```

### 3.9.6 Perché il piano è verificato rispetto alla constitution

Nota la sezione **Constitution Check** del piano: non è un commento, è un **gate**. Se, per esempio, il piano avesse proposto una soluzione a microservizi per una feature monoutente, la constitution (principio di Semplicità) avrebbe imposto di giustificarlo o semplificare. Il piano, quindi, non è una libera invenzione dell'agente: è un'interpretazione **vincolata** dei principi del progetto.
