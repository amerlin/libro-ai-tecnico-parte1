## 3.26 Riepilogo, glossario ed esercizi

Siamo alla fine del capitolo. Ripercorriamo il cammino e consolidiamo i concetti.

### 3.26.1 Riepilogo

In questo capitolo abbiamo:

- introdotto lo **spec-driven development** e il suo principio guida: la specifica come fonte di verità;
- presentato **GitHub Spec Kit** come toolkit open source per agenti di codifica, con i suoi tre processi (SDD, bug fixing, idea assessment);
- installato il **CLI `specify`** e inizializzato un progetto con integrazione Copilot;
- esplorato la **struttura** del progetto (`.specify/`, `specs/`, `feature.json`, constitution, template);
- percorso il **workflow completo**: constitution, specify, clarify, plan, checklist, tasks, analyze, implement, polish e converge;
- studiato i **template ufficiali** (spec, plan, tasks, checklist, constitution) e i loro meccanismi (priorità, Given/When/Then, `[NEEDS CLARIFICATION]`, Constitution Check, test-first);
- applicato l'intero flusso a una feature **C#**: una Task Manager API con Minimal API, EF Core e test xUnit, dalla specifica al codice funzionante;
- visto l'integrazione con **VS Code e Copilot** e l'automazione in **CI/CD**;
- raccolto **best practice** e soluzioni ai problemi comuni.

### 3.26.2 Glossario

| Termine | Definizione |
|---------|-------------|
| **SDD** | Specification-Driven Development: sviluppo guidato dalla specifica |
| **Spec Kit** | Toolkit open source di GitHub per applicare lo SDD con gli agenti AI |
| **Constitution** | Principi stabili del progetto, emendabili secondo la governance (`.specify/memory/constitution.md`) |
| **Spec** | La specifica della feature (`spec.md`) |
| **Plan** | Il piano tecnico (`plan.md`) con modello dati e contratti |
| **Tasks** | La lista di task eseguibili, ordinati per dipendenza (`tasks.md`) |
| **Checklist** | Checklist dei requisiti (`checklists/requirements.md`) e checklist aggiuntive per ambito |
| **Converge** | Verifica che il codice corrisponda a spec, plan e task |
| **Feature attiva** | La feature su cui lavorano i comandi (in `.specify/feature.json`) |
| **Hook** | Azioni eseguite prima/dopo i comandi (`.specify/extensions.yml`) |
| **Preset/Workflow/Bundle** | Meccanismi per adattare e distribuire processi |

### 3.26.3 Esercizi proposti

1. **La tua constitution.** Scrivi (o genera con `/speckit-constitution`) una constitution per un progetto .NET di tua scelta: 4 principi verificabili, una sezione di sicurezza e una di governance.
2. **Una specifica.** Genera con `/speckit-specify` la specifica di una feature che conosci bene (per esempio un endpoint di autenticazione). Poi verifica a mano che rispetti i criteri della checklist (priorità, Given/When/Then, FR numerati, SC misurabili).
3. **Chiarimento.** Individua tre `[NEEDS CLARIFICATION]` in una specifica esistente e risolvili con `/speckit-clarify`.
4. **Piano e task.** A partire dalla specifica dell'esercizio 2, genera piano e task, e verifica che ogni user story abbia i suoi task e i suoi test.
5. **Implementazione.** Estendi la Task Manager API con una data di completamento registrata (oltre allo stato booleano): modifica specifica, piano, task e codice, poi esegui `/speckit-converge`.
6. **CI.** Aggiungi un workflow GitHub Actions che compili il progetto ed esegua `dotnet test tests/Taskify.Tests/Taskify.Tests.csproj`; usa `specify check` solo per diagnosticare i prerequisiti del CLI, non come gate degli artefatti.
7. **Bug fixing.** Installa l'estensione `bug` e usala su un bug reale di un tuo progetto: osserva come il verdetto finale (`verified`/`partial`/`failed`) documenta l'esito.

### 3.26.4 Il filo conduttore

Tre capitoli, tre tasselli. Gli **strumenti** (i server MCP) permettono all'agente di agire; i **dati** (EF Core) gli danno continuità; il **metodo** (Spec Kit) lo guida con un processo. Solo insieme trasformano un modello linguistico in un compagno di sviluppo affidabile.
