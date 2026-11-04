## 3.14 Il CLI `specify`

I comandi `/speckit-*` vivono nella chat dell'agente, ma Spec Kit include anche un **CLI** (`specify`) per le operazioni di terra: inizializzazione, controlli dei prerequisiti, gestione di estensioni, preset e workflow.

### 3.14.1 I comandi principali

| Comando | Scopo |
|---------|-------|
| `specify init` | Inizializza un progetto (già visto) |
| `specify check` | Controlla la disponibilità degli strumenti e dei prerequisiti CLI |
| `specify extension add <nome>` | Installa un'estensione (per esempio `bug`, `assess`) |
| `specify preset search/apply` | Cerca e applica preset della comunità |
| `specify workflow search/run` | Cerca ed esegue workflow |
| `specify bundle search/install` | Cerca e installa bundle |

### 3.14.2 `specify check`

Il comando `specify check` controlla la disponibilità degli strumenti e dei prerequisiti richiesti dal CLI nella versione installata. Non legge né convalida la coerenza di `spec.md`, `plan.md`, `tasks.md` o degli altri artefatti; per questi servono la revisione e i controlli del workflow Spec Kit (per esempio `/speckit-analyze` e `/speckit-converge`).

```bash
specify check
```

Se manca un prerequisito, il comando segnala il problema e può restituire un codice di uscita diverso da zero. `specify self check`, se disponibile nella versione installata, è un'autodiagnosi del CLI; non è un validatore degli artefatti del progetto.

### 3.14.3 Le estensioni: bug fixing e assessment

Abbiamo accennato ai due processi opzionali. Si installano come estensioni:

```bash
specify extension add bug
specify extension add assess
```

**Bug fixing** aggiunge i comandi:

```text
/speckit-bug-assess "Sottomettere una password vuota manda in crash il form." slug=login-crash
/speckit-bug-fix slug=login-crash
/speckit-bug-test slug=login-crash
```

Gli artefatti finiscono in `.specify/bugs/<slug>/`, e il verdetto finale è `verified`, `partial` o `failed`: solo `verified` conferma la correzione.

**Idea assessment** aggiunge i comandi:

```text
/speckit-assess-intake "Consenti agli utenti di lavorare offline." slug=offline-mode
/speckit-assess-research slug=offline-mode
/speckit-assess-define slug=offline-mode
/speckit-assess-shape slug=offline-mode
/speckit-assess-decide slug=offline-mode
```

Gli artefatti finiscono in `.specify/assessments/<slug>/`, e la decisione finale è `go`, `needs-clarification` o `kill`. Se l'idea ottiene un `go`, il riepilogo di `decision.md` diventa l'input di `/speckit-specify`.

### 3.14.4 Preset e workflow

- Un **preset** adatta template, comandi e terminologia agli standard del tuo team (per esempio "richiedi tracciabilità normativa nei piani").
- Un **workflow** automatizza sequenze di prompt, comandi, gate e task di shell: per esempio, un workflow CI che compila ed esegue i test del progetto. `specify check` può servire durante la configurazione dell'ambiente, ma non è un gate di qualità degli artefatti.
- Un **bundle** impacchetta estensioni, preset e workflow per distribuirli a un team o a un ruolo.

### 3.14.5 Estensioni e hook

Il file `.specify/extensions.yml` può registrare **hook**, cioè azioni da eseguire prima o dopo i comandi. Un caso tipico: un hook `before_specify` che crea (o cambia) il **branch Git** all'avvio di una feature. Questo è ciò che permette di integrare Spec Kit con le abitudini del team (feature branch numerati, `001-task-manager`, ecc.), senza che il flusso ne dipenda: come abbiamo visto, la feature attiva è determinata da `.specify/feature.json`, non dal branch.

### 3.14.6 Quando usare il CLI

- `init` — una volta per progetto;
- `check` — per diagnosticare la disponibilità dei prerequisiti, non per convalidare gli artefatti;
- `extension add` — quando attivi un processo opzionale;
- `preset`/`workflow`/`bundle` — quando adatti Spec Kit al tuo team.

Il resto del lavoro quotidiano avviene nella chat dell'agente, con i comandi `/speckit-*`.
