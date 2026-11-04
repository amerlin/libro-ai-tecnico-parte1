## 3.11 `/speckit-tasks`: la scomposizione in task

A questo punto la specifica è chiara e il piano tecnico definito. `/speckit-tasks` trasforma tutto in una **lista di task eseguibili e ordinati per dipendenza**.

### 3.11.1 Come si invoca

```text
/speckit-tasks
```

Nessun argomento: il comando legge `plan.md` (obbligatorio), `spec.md` (per le user story) e, se presenti, `research.md`, `data-model.md` e `contracts/`, e produce `tasks.md`.

### 3.11.2 Il formato dei task

Il template impone un formato compatto:

```text
- [ ] T001 [P] [US1] Creare il progetto e aggiungere i pacchetti in src/
```

Dove:

- `T001` — identificativo progressivo del task;
- `[P]` — opzionale, indica che il task può essere eseguito **in parallelo** (file diversi, nessuna dipendenza);
- `[US1]` — la **user story** a cui appartiene il task;
- la descrizione include **i percorsi file esatti** da toccare.

### 3.11.3 Le fasi

I task sono raggruppati in **fasi**, in quest'ordine:

1. **Phase 1: Setup** — inizializzazione del progetto (struttura, dipendenze, linting).
2. **Phase 2: Foundational** — infrastruttura **bloccante** che deve esistere prima di ogni user story (schema del database, routing, middleware, configurazione). Nessuna user story può partire prima di questa fase.
3. **Phase 3+: User Story N** — un gruppo di task per ogni user story, in ordine di priorità (P1, P2, ...). Ogni gruppo è **indipendente**: si può implementare e testare la P1 da sola.

### 3.11.4 L'esempio C#: i task

Ecco `specs/001-task-manager/tasks.md` (parti essenziali):

```markdown
# Tasks: Task Manager API

**Input**: design da specs/001-task-manager/

## Phase 1: Setup

- [ ] T001 Creare il progetto web `src/Taskify.csproj` e aggiungere EF Core Sqlite
- [ ] T002 Creare `tests/Taskify.Tests/Taskify.Tests.csproj` con xUnit, aggiungere il riferimento a `src/Taskify.csproj` e il pacchetto `Microsoft.AspNetCore.Mvc.Testing`

## Phase 2: Foundational (Bloccante)

- [ ] T003 Creare l'entità TaskItem in src/Models/TaskItem.cs
- [ ] T004 Creare TaskDbContext in src/Data/TaskDbContext.cs
- [ ] T005 Creare i DTO in src/Contracts/TaskDtos.cs
- [ ] T006 Configurare EF Core e il database in src/Program.cs, rendendo `Program` accessibile ai test

**Checkpoint**: fondamenta pronte — le user story possono partire in parallelo.

## Phase 3: User Story 1 - Creare un task (P1) [MVP]

**Goal**: POST /tasks crea e persiste un task.
**Independent Test**: una chiamata POST /tasks seguita da GET /tasks/{id}.

- [ ] T007 [US1] Scrivere il test per POST /tasks in tests/Taskify.Tests/TaskEndpointsTests.cs
- [ ] T008 [US1] Eseguire il test e verificare che fallisca (RED)
- [ ] T009 [US1] Implementare l'endpoint POST /tasks in src/Program.cs
- [ ] T010 [US1] Verificare che il test passi (GREEN)

## Phase 4: User Story 2 - Elencare e filtrare (P2)

- [ ] T011 [US2] Scrivere il test per GET /tasks?status=... in tests/Taskify.Tests/TaskEndpointsTests.cs
- [ ] T012 [US2] Eseguire il test e verificare che fallisca (RED)
- [ ] T013 [US2] Implementare GET /tasks con filtro in src/Program.cs
- [ ] T014 [US2] Verificare che il test passi (GREEN)

## Phase 5: User Story 3 - Completare ed eliminare (P3)

- [ ] T015 [US3] Scrivere i test per POST /tasks/{id}/complete e DELETE /tasks/{id} in tests/Taskify.Tests/TaskEndpointsTests.cs
- [ ] T016 [US3] Eseguire i test e verificare che falliscano (RED)
- [ ] T017 [US3] Implementare i due endpoint in src/Program.cs
- [ ] T018 [US3] Verificare che i test passino (GREEN)
```

### 3.11.5 Il test-first nei task

Nota la struttura di ogni gruppo: **prima i test, poi la verifica RED, poi l'implementazione e la verifica GREEN**. È la constitution (principio Test-First) che si riflette direttamente nella forma dei task.

### 3.11.6 Perché i task funzionano

Un task ben formato è:

- **atomico** — una sola responsabilità, un solo file (o pochi);
- **ordinato** — le fasi impongono l'ordine; `[P]` segnala il parallelismo possibile;
- **tracciabile** — ogni task è legato a una user story, quindi a un requisito, quindi alla specifica;
- **verificabile** — ogni gruppo ha un "Independent Test" che ne conferma il completamento.

È questa tracciabilità a rendere il flusso Spec Kit molto più di una lista di cose da fare: è una **catena di responsabilità** che va dall'idea al codice.
