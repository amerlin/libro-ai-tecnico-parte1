## 4.22 Risoluzione dei problemi

Ogni voce è un sintomo osservabile, la causa probabile e la verifica concreta.

### 4.22.1 «L'agente ignora il mio file di istruzioni»

**Cause probabili**, in ordine di frequenza:

1. percorso errato (`docs/` invece di `.github/`, `skills` invece di `skill`, maiuscole sbagliate);
2. frontmatter invalido: un errore YAML invalida l'intero file, senza messaggi evidenti;
3. livello superiore che sovrascrive (`CLAUDE.local.md`, istruzioni utente, agente selezionato);
4. harness sbagliato in VS Code: il file è in `.github/` ma la sessione usa l'harness Claude, che cerca `.claude/`.

**Verifica.** Apri il pannello delle personalizzazioni (VS Code) o esegui `/context` (Claude Code) e cerca il file. Se non compare, il problema è di scoperta, non di contenuto.

### 4.22.2 «La skill non viene mai attivata»

**Cause.** `description` troppo generica o troppo corta; `name` diverso dal nome della cartella; skill duplicata in due percorsi (vince una sola, e non è quella che stai modificando).

**Verifica.** Chiedi esplicitamente di usarla per nome. Se funziona su richiesta esplicita ma non automaticamente, il problema è solo nella `description`.

### 4.22.3 «L'agente non modifica i file»

**Causa.** L'agente selezionato ha `tools` senza `edit`, oppure stai usando un subagente con permessi ridotti, oppure c'è una modalità di sola lettura attiva.

**Verifica.** Controlla il frontmatter dell'agente in uso; cambia agente e riprova. È il caso in cui il comportamento è corretto e inatteso: il vincolo funziona.

### 4.22.4 «Il plugin non compare»

**Cause.** Manifest nel percorso sbagliato (`.claude-plugin/plugin.json` per Claude, `plugin.json` alla radice per Agent Plugins); marketplace non aggiunto; plugin disabilitato; supporto ai plugin spento nell'editor (`chat.plugins.enabled`).

**Verifica.** Elenca i plugin installati (`/plugin list`) e controlla che il marketplace sia tra quelli registrati.

### 4.22.5 «Dopo l'aggiornamento del motore non funziona più nulla»

**Causa.** I formati cambiano: un campo rinominato, una cartella spostata, un comportamento di scoperta modificato. È il rischio strutturale di questo capitolo.

**Verifica.** Confronta i file con la documentazione della versione installata, non con un articolo. Poi esegui il validatore della sezione 4.17.2: intercetta i campi obbligatori mancanti anche dopo un cambio di formato.

### 4.22.6 «Le risposte sono più lente e più care»

**Cause.** Troppe skill installate (ogni skill aggiunge nome e descrizione a ogni turno), un file di istruzioni enorme, un plugin che aggiunge molti strumenti, server MCP sempre attivi.

**Verifica.** Disabilita metà delle skill e confronta. Il conteggio degli strumenti e delle skill visibili è un indicatore diretto del costo fisso per sessione.

### 4.22.7 «Su Windows i percorsi non funzionano»

**Cause.** Nei file di configurazione i percorsi vanno scritti con `/`, non con `\`: la barra rovesciata è un carattere di escape in YAML e JSON. `~` non viene sempre espanso.

**Verifica.** Sostituisci `\` con `/` e usa percorsi relativi al progetto quando possibile. Per i percorsi assoluti in JSON, raddoppia le barre (`C:\\repo\\progetto`) o usa `/`.

### 4.22.8 Tabella riassuntiva

| Sintomo | Prima verifica | Correzione tipica |
| --- | --- | --- |
| Istruzioni ignorate | Il file compare nel pannello? | Percorso o YAML |
| Skill mai attivata | Funziona se invocata per nome? | Riscrivere `description` |
| Nessuna modifica ai file | `tools` dell'agente | Aggiungere `edit` o cambiare agente |
| Plugin assente | `/plugin list` | Manifest o marketplace |
| Tutto rotto dopo un update | Documentazione della versione | Adeguare i campi |
| Costi alti | Numero di skill e strumenti attivi | Disabilitare ciò che non serve |
| Percorsi rotti su Windows | Barre e `~` | `/` e percorsi relativi |
