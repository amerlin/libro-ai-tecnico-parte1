## 4.15 Scrivere un agente: revisione in sola lettura

Ora costruiamo l'agente che nella sezione 4.1 avevamo identificato come caso d'uso: un revisore che **non può** modificare i file.

### 4.15.1 Il file

` .github/agents/revisore.agent.md`:

```markdown
---
name: Revisore
description: Revisione del codice in sola lettura. Usalo quando vuoi un parere su una modifica senza che nulla venga toccato.
tools: ['read', 'search']
model: claude-sonnet-4
---

# Ruolo

Sei un revisore. **Non modifichi file**: leggi, analizzi e riporti.
Se ti accorgi che servirebbe una modifica, la descrivi; non la applichi.

# Criteri di revisione

Per ogni file modificato verifica, in quest'ordine:

1. **Contratti**: i DTO sono `record` immutabili? Le firme pubbliche sono cambiate
   senza aggiornare i test?
2. **Asincronia**: ogni metodo `async` accetta e propaga `CancellationToken`?
   Ci sono `.Result` o `.Wait()`?
3. **Dati**: le query filtrano prima di materializzare? C'è `AsNoTracking`
   nelle letture?
4. **Sicurezza**: ci sono segreti, stringhe di connessione o input non validati
   che finiscono in una query?
5. **Test**: ogni comportamento nuovo ha un test che lo copre?

# Formato della risposta

Una tabella Markdown:

| Severità | File | Riga | Problema | Correzione proposta |

Severità ammesse: `bloccante`, `importante`, `minore`.
Se non trovi problemi, rispondi solo: `Nessun problema rilevante.`
Non aggiungere riassunti, complimenti o considerazioni generali.
```

### 4.15.2 Le tre scelte che contano

**Gli strumenti.** `tools: ['read', 'search']` è il cuore dell'agente: senza `edit` e senza `terminal`, il vincolo "non modificare" non è una richiesta gentile, è un'impossibilità tecnica. È la differenza tra un'istruzione e un permesso.

**Il formato di risposta.** Chiedere una tabella con colonne fisse rende l'output verificabile e confrontabile tra esecuzioni. Un revisore che risponde in prosa è piacevole da leggere e inutile da processare.

**Il caso vuoto.** «Se non trovi problemi, rispondi solo *Nessun problema rilevante*» previene il difetto più comune dei revisori automatici: inventare osservazioni generiche per giustificare la propria esistenza.

### 4.15.3 Usarlo come subagente

Il valore maggiore si ottiene quando il revisore non è l'agente principale ma un **subagente** chiamato da un altro agente. In quel caso:

1. l'agente principale implementa;
2. delega la revisione al revisore;
3. riceve una tabella compatta, non venti file di contesto;
4. applica le correzioni, se le accetta.

Il beneficio è di contesto: la conversazione principale resta corta, mentre il lavoro rumoroso avviene altrove.

### 4.15.4 Handoff: planner → implementer → revisore

Il flusso completo, con gli handoff:

```markdown
---
name: Planner
description: Produce un piano di implementazione senza toccare il codice
tools: ['read', 'search']
handoffs:
  - agent: Implementer
    label: "Implementa il piano"
    prompt: "Implementa il piano approvato, un passo alla volta, con i test."
---
```

```markdown
---
name: Implementer
description: Scrive codice e test seguendo il piano
tools: ['read', 'search', 'edit', 'terminal']
handoffs:
  - agent: Revisore
    label: "Revisiona le modifiche"
    prompt: "Revisiona le modifiche non ancora committate."
---
```

Il campo `handoffs` non è un dettaglio sintattico: è ciò che trasforma tre agenti separati in un **processo**. Senza, hai tre strumenti; con, hai un flusso con passaggi di consegne espliciti.

### 4.15.5 Un avvertimento

Un agente in sola lettura non è un confine di sicurezza. Se l'agente ha accesso al terminale, può eseguire comandi che modificano file; se ha accesso a server MCP, può chiamare strumenti che hanno effetti. La restrizione dei `tools` serve a **ridurre il rischio e l'errore**, non a garantire l'immutabilità. Per una garanzia servono permessi a livello di sistema operativo, sandbox o un hook che blocca le azioni: ne parliamo nella sezione 4.18.
