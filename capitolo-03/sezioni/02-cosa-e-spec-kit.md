## 3.2 Cos'è GitHub Spec Kit

GitHub Spec Kit è un **toolkit open source** (repository `github/spec-kit`, licenza MIT) che fornisce agli agenti di codifica AI *processi strutturati*, *template riutilizzabili* e *risultati documentati*. Non è un framework applicativo né un linguaggio: è un **livello di metodo** che si appoggia ai coding agent esistenti (GitHub Copilot, Claude Code, Cursor e altri).

### 3.2.1 I tre processi pronti all'uso

Spec Kit offre tre punti di ingresso indipendenti — non fasi obbligatorie di un unico processo:

| Cosa ti serve | Processo | Risultato |
|---------------|----------|-----------|
| Costruire una feature o un'app | **Spec-Driven Development** (incluso nel core) | Una specifica portata attraverso piano, implementazione e convergenza |
| Diagnosticare e riparare un comportamento rotto | **Bug fixing** (estensione) | Una causa valutata, una correzione mirata e una verifica registrata |
| Decidere se un'idea merita investimento | **Idea assessment** (estensione) | Una decisione motivata: `go`, `needs-clarification` o `kill` |

In questo capitolo ci concentriamo sul processo principale, lo **SDD**; nelle sezioni finali accenniamo agli altri due, che seguono la stessa filosofia.

### 3.2.2 Le capabilities: un toolkit componibile

Oltre ai processi, Spec Kit espone un insieme di meccanismi componibili:

- **Integration** — collegamento ai diversi coding agent (Copilot, Claude Code, Cursor, ecc.);
- **Extension** — aggiunta di comandi, gate di qualità o processi interi;
- **Preset** — adattamento di template, comandi e terminologia agli standard del team;
- **Workflow** — automazione di prompt, comandi, gate e task di shell;
- **Bundle** — pacchetti riutilizzabili di estensioni, preset e workflow (per ruoli o team);
- **Catalog** — catalogo di componenti della comunità, con la possibilità di ospitarne di privati;
- **Project-local override** — sostituzione di un singolo template in un progetto.

Questa componibilità è ciò che distingue Spec Kit da una semplice raccolta di prompt: puoi partire con il processo pronto, adattarlo al tuo team e persino costruirne uno tuo.

### 3.2.3 Come si usa, in estrema sintesi

1. Si installa il **CLI** (`specify`) con `uv tool install specify-cli`.
2. Si inizializza un progetto con `specify init <nome> --integration copilot`.
3. Si apre il progetto nell'agente e si invocano i **comandi** (`/speckit-specify`, `/speckit-plan`, ...) **nella chat dell'agente**, uno alla volta, rivedendo ogni risultato prima di proseguire.

Il CLI fa il lavoro "di terra" (scaffolding, controlli dei prerequisiti, gestione di estensioni e cataloghi); i comandi esposti dall'integrazione fanno il lavoro "di testa", guidando l'agente nella produzione degli artefatti.

### 3.2.4 Una breve storia

Spec Kit nasce dall'esperienza di **GitHub Next** e dal progetto precedente noto come *Specify*, poi evoluto e donato come progetto open source dell'organizzazione `github`. I comandi disponibili e la loro sintassi dipendono dall'integrazione e dalle skill che questa genera per l'agente: nelle sezioni seguenti usiamo la forma con trattino mostrata dall'integrazione dell'esempio. Se un progetto espone una forma diversa, va seguita quella effettivamente generata; la punteggiatura da sola non indica che si tratti di una generazione precedente.

### 3.2.5 Perché dovrebbe interessarti

Se sviluppi con un coding agent, Spec Kit risponde a tre domande ricorrenti:

- "Come faccio a far produrre all'agente **esattamente ciò che voglio**, e non qualcosa di plausibile ma sbagliato?" — con una specifica strutturata e rivista;
- "Come **traccio** il lavoro e lo rendo revisionabile da un team?" — con artefatti versionati in `specs/`;
- "Come impongo gli **standard** del mio team all'agente?" — con la constitution, i preset e le checklist.

È, in sintesi, il modo per passare da "chiedo una cosa alla volta all'agente" a "dirigo un processo di sviluppo documentato e ripetibile".
