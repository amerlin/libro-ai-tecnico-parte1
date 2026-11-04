## 3.4 La struttura di un progetto Spec Kit

Capire la struttura delle cartelle è essenziale per orientarsi e per personalizzare il toolkit. Ecco l'anatomia di un progetto inizializzato.

### 3.4.1 La struttura d'insieme

![Anatomia di un progetto Spec Kit dopo `specify init`](figure/struttura-spec-kit.pdf)

### 3.4.2 La cartella `.specify/`

È il "cervello" della configurazione. Contiene:

- **`feature.json`** — registra quale feature è **attiva** in questo momento. I comandi `/speckit-*` risolvono la feature da questo stato, **non** dal branch Git corrente. È ciò che permette di lavorare su una feature senza fare `git checkout`, e di cambiarla aggiornando il file (o la variabile d'ambiente `SPECIFY_FEATURE_DIRECTORY`).
- **`init-options.json`** — conserva le scelte fatte in fase di `init`, in particolare la **numerazione** delle feature (`feature_numbering`): da qui deriva il nome della cartella, per esempio `003-user-auth`.
- **`memory/constitution.md`** — i principi stabili del progetto, modificabili solo attraverso le regole di governance. È la "legge" che i comandi di piano e implementazione devono rispettare.
- **`templates/`** — se presenti, i template in questa cartella **sostituiscono** quelli di default per il singolo progetto (project-local override).
- **`extensions.yml`** — (facoltativo) registra estensioni e **hook**, cioè azioni da eseguire prima o dopo i comandi (per esempio creare il branch Git all'avvio di una feature).

### 3.4.3 La cartella `specs/`

È dove vivono gli **artefatti di ogni feature**. Ogni feature ha una cartella con un nome del tipo `<prefisso>-<slug>` (per esempio `001-task-manager`), che contiene i file prodotti dai comandi:

| Artefatto | Comando e scopo |
|------|-------|
| `spec.md` | `/speckit-specify`: specifica (cosa e perché) |
| `plan.md` | `/speckit-plan`: piano tecnico (come) |
| `research.md` | `/speckit-plan`: ricerche tecniche (fase 0) |
| `data-model.md` | `/speckit-plan`: modello dati (fase 1) |
| `quickstart.md` | `/speckit-plan`: scenari chiave di validazione |
| `contracts/` | `/speckit-plan`: contratti di endpoint ed eventi |
| `tasks.md` | `/speckit-tasks`: task eseguibili |
| `checklists/requirements.md` | `/speckit-specify` e `/speckit-clarify`: checklist di qualità dei requisiti |

### 3.4.4 Lo stato della feature attiva

Il file `.specify/feature.json` ha una forma simile a:

```json
{
  "feature_directory": "specs/001-task-manager"
}
```

Quando invochi `/speckit-plan` o `/speckit-tasks`, il comando legge questo file e sa **dove** andare a lavorare. È un dettaglio piccolo ma potente: svincola il flusso dal branch Git e lo rende deterministico (e più facile da automatizzare in CI).

### 3.4.5 Il codice sorgente

Spec Kit non impone una struttura al codice: la struttura del codice viene decisa **nel piano** (il file `plan.md` contiene una sezione "Project Structure" con l'albero delle cartelle scelto). Per un'applicazione web, per esempio, il piano potrà proporre `src/` e `tests/`, o `backend/` e `frontend/`. I task faranno riferimento a quei percorsi.

### 3.4.6 Dove vengono creati i file: un riepilogo

- **`specify init`** crea `.specify/`, i template di default e la constitution;
- **`/speckit-constitution`** aggiorna `.specify/memory/constitution.md`;
- **`/speckit-specify`** crea `specs/<slug>/spec.md` e `checklists/requirements.md`;
- **`/speckit-plan`** crea `plan.md`, `research.md`, `data-model.md`, `quickstart.md` e `contracts/`;
- **`/speckit-tasks`** crea `tasks.md`;
- **`/speckit-implement`** crea il codice sorgente vero e proprio.

Con questa mappa in testa, il resto del capitolo scorrerà molto più facilmente.
