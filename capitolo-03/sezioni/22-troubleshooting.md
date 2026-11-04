## 3.25 Risoluzione dei problemi comuni

Raccogliamo i problemi più frequenti nell'uso di Spec Kit, con causa e soluzione.

### Il comando `/speckit-*` non viene trovato dall'agente

**Causa.** L'integrazione non è stata configurata: `specify init` è stato eseguito senza `--integration`, oppure l'agente non ha ricaricato le skill dopo l'init.

**Soluzione.** Esegui `specify init --integration <agente>` (o riapri il progetto/riavvia l'agente perché rilevi le nuove skill). Verifica che i comandi compaiano nell'elenco delle skill dell'agente.

### `specify` non è riconosciuto come comando

**Causa.** Il CLI non è installato o il percorso di `uv` non è nel `PATH`.

**Soluzione.** Reinstalla con `uv tool install specify-cli` e verifica con `specify --version`; se necessario, aggiungi la directory dei tool di `uv` al `PATH`.

### Il comando lavora sulla feature sbagliata

**Causa.** I comandi risolvono la feature da `.specify/feature.json` (o da `SPECIFY_FEATURE_DIRECTORY`), **non** dal branch Git. Se hai cambiato branch senza aggiornare lo stato, il comando continua a puntare alla feature precedente.

**Soluzione.** Controlla `.specify/feature.json`: deve contenere il percorso della feature giusta. Aggiornalo (o imposta `SPECIFY_FEATURE_DIRECTORY`) prima di eseguire i comandi.

### `/speckit-implement` si rifiuta di partire

**Causa.** La checklist `checklists/requirements.md` ha voci non spuntate: è il **gate** che funziona come previsto.

**Soluzione.** Rivedi le voci non spuntate: o le spunti (in veste di revisore) o correggi la specifica e riesegui il controllo.

### `/speckit-analyze` segnala conflitti

**Causa.** Gli artefatti si sono disallineati (per esempio hai modificato la specifica a mano dopo aver generato i task).

**Soluzione.** Correggi gli artefatti alla fonte (specifica, piano o task) per riallinearli, poi riesegui `/speckit-analyze`. Non ignorare le segnalazioni e non procedere con l'implementazione.

### `/speckit-converge` aggiunge task all'infinito

**Causa.** Se a ogni iterazione converge aggiunge nuovi task senza arrivare a `Converged`, di solito c'è un disallineamento sistematico (per esempio un requisito ambiguo che l'implementazione interpreta in modo diverso dalla specifica).

**Soluzione.** Fermati e rileggi la specifica: probabilmente va **chiarita** (torna a `/speckit-clarify` o modificala a mano). Un requisito chiaro produce un'implementazione convergente.

### Il comando ha una sintassi diversa da quella dell'esempio

**Causa.** Le skill e i comandi esposti dipendono dall'agente e dall'integrazione usata per generarle. La differenza tra punto e trattino, da sola, non identifica una versione obsoleta.

**Soluzione.** Controlla l'elenco dei comandi o i file di skill generati nel progetto e usa la sintassi prevista dalla tua integrazione. Gli esempi di questo capitolo adottano la forma con trattino.

### `specify check` segnala prerequisiti mancanti

**Causa.** Uno strumento richiesto dal CLI non è installato o non è disponibile nel `PATH`, oppure l'ambiente usa una configurazione diversa da quella locale.

**Soluzione.** Esegui `specify check` nello stesso ambiente per identificare il prerequisito mancante. Il comando non convalida gli artefatti; usa la revisione del workflow, `/speckit-analyze` e `/speckit-converge` per controllarli. `specify self check`, se disponibile, diagnostica il CLI e non sostituisce quei controlli.

### Metodo di diagnosi universale

Quando qualcosa non va, riduci il problema: verifica la **configurazione** (`.specify/feature.json`, integrazione), poi gli **artefatti** (specifica, piano, task allineati?), poi il **codice** (build e test). Quasi sempre l'errore è a monte di dove sembra.
