## 3.7 `/speckit-specify`: dalla richiesta alla specifica

Il primo comando del flusso trasforma una descrizione in linguaggio naturale in una **specifica strutturata**. È il momento in cui l'idea vaga diventa un documento con requisiti, scenari e criteri di successo.

### 3.7.1 Come si invoca

```text
/speckit-specify Crea una Task Manager API dove gli utenti possono creare task,
elencarli con un filtro per stato, completarli ed eliminarli.
```

Il comando:

1. determina il nome e il numero della feature (per esempio `001-task-manager`);
2. crea la cartella `specs/001-task-manager/`;
3. copia il **template di specifica** in `spec.md` e lo compila con i requisiti estratti dalla richiesta;
4. genera la **checklist di qualità** in `checklists/requirements.md`.

### 3.7.2 La struttura di `spec.md`

Il template di specifica è il cuore del comando. Le sue sezioni principali:

| Sezione | Scopo |
|---------|-------|
| **User Scenarios & Testing** | User story prioritarie (P1, P2, ...), ciascuna con test indipendente e scenari Given/When/Then |
| **Edge Cases** | Condizioni limite e scenari d'errore |
| **Requirements** | Requisiti funzionali `FR-xxx` + entità chiave |
| **Success Criteria** | Criteri di successo misurabili `SC-xxx`, indipendenti dalla tecnologia |
| **Assumptions** | Ipotesi ragionevoli quando la richiesta non specifica dettagli |

### 3.7.3 Le user story prioritarie e indipendenti

La sezione più importante è quella delle user story. Il template impone due proprietà fondamentali:

1. **Priorità** — ogni story ha una priorità (`P1`, `P2`, `P3`...), con `P1` la più critica.
2. **Testabilità indipendente** — ogni story deve poter essere sviluppata, testata e dimostrata **da sola**: se implementi solo la `P1`, hai comunque un MVP che porta valore.

Per ogni story il template chiede:

- una descrizione in linguaggio semplice;
- il **motivo della priorità**;
- un **test indipendente** (come verificarla da sola);
- gli **acceptance scenarios** in formato **Given/When/Then**.

### 3.7.4 L'esempio C#: la specifica

Applichiamo subito il template alla nostra feature. Ecco come appare `specs/001-task-manager/spec.md` compilata (mostriamo le parti essenziali):

```markdown
# Feature Specification: Task Manager API

**Feature Branch**: `001-task-manager`
**Status**: Draft
**Input**: User description: "Crea una Task Manager API dove gli utenti
possono creare task, elencarli con un filtro per stato, completarli ed
eliminarli."

## User Scenarios & Testing

### User Story 1 - Creare un task (Priority: P1)

Un utente crea un task fornendo un titolo e, facoltativamente, una data di
scadenza. Il task viene salvato e restituito con il suo identificativo.

**Why this priority**: senza la creazione non esiste alcun dato su cui
operare: è il fondamento dell'intera feature.

**Independent Test**: si può verificare con una singola chiamata
POST /tasks e la successiva lettura del task creato.

**Acceptance Scenarios**:
1. **Given** nessun task esistente, **When** l'utente invia POST /tasks
   con un titolo valido, **Then** il task viene creato e restituito con id.
2. **Given** una richiesta senza titolo, **When** l'utente invia POST /tasks,
   **Then** il sistema risponde 400 con un messaggio di validazione.

---

### User Story 2 - Elencare e filtrare i task (Priority: P2)

L'utente elenca i task, con un filtro opzionale per stato (open/completed).

**Why this priority**: la creazione è inutile senza la possibilità di
consultare i task.

**Independent Test**: si verifica con GET /tasks e GET /tasks?status=...

**Acceptance Scenarios**:
1. **Given** task esistenti in stati diversi, **When** l'utente richiede
   GET /tasks?status=open, **Then** riceve solo i task aperti.

---

### User Story 3 - Completare ed eliminare (Priority: P3)

L'utente marca un task come completato o lo elimina.

**Why this priority**: chiude il ciclo di vita, ma il sistema è già utile
con le prime due story.

**Acceptance Scenarios**:
1. **Given** un task esistente, **When** l'utente invia
   POST /tasks/{id}/complete, **Then** il task risulta completato.
2. **Given** un task esistente, **When** l'utente invia
   DELETE /tasks/{id}, **Then** il task viene eliminato.

### Edge Cases

- Cosa succede se il titolo è vuoto o supera 200 caratteri?
- Cosa succede se si richiede un task con id inesistente?
- Cosa succede se la data di scadenza è nel passato?

## Requirements

### Functional Requirements

- **FR-001**: Il sistema DEVE permettere di creare un task con titolo
  obbligatorio (max 200 caratteri) e data di scadenza opzionale.
- **FR-002**: Il sistema DEVE elencare i task, con filtro opzionale per stato.
- **FR-003**: Il sistema DEVE permettere di marcare un task come completato.
- **FR-004**: Il sistema DEVE permettere di eliminare un task.
- **FR-005**: Il sistema DEVE restituire errori chiari in caso di input
  non valido o risorsa inesistente.

### Key Entities

- **Task**: un'attività con titolo, stato (aperto/completato),
  data di scadenza opzionale e data di creazione.

## Success Criteria

- **SC-001**: una task può essere creata e letta in meno di 100 ms in locale.
- **SC-002**: il 100% degli scenari di accettazione è coperto da test.
- **SC-003**: nessuna richiesta valida produce un errore 500.

## Assumptions

- Il primo rilascio non prevede autenticazione: l'API è monoutente.
- La persistenza usa un database locale SQLite.
- La paginazione è fuori scope per la v1.
```

### 3.7.5 I punti chiave del template

Osserva come il template **vincola** il modello:

- i requisiti sono `FR-xxx` numerati e verificabili, non prosa libera;
- le incertezze sono esplicitate (il template prevede il marcatore `[NEEDS CLARIFICATION]` per i requisiti non specificati: lo vedremo con `/speckit-clarify`);
- i criteri di successo sono **misurabili e indipendenti dalla tecnologia** (nessun "usa .NET": quello appartiene al piano, non alla specifica);
- le entità sono descritte **senza dettagli implementativi** ("titolo, stato, scadenza", non "tabella SQL con colonna VARCHAR(200)").

Questa separazione tra *cosa* (specifica) e *come* (piano) è il principio più importante dell'intero metodo.
