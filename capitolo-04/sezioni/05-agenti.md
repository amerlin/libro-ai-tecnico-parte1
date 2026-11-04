## 4.5 Gli agenti

Un **agente** (custom agent, chat mode, subagente) è una configurazione riutilizzabile composta da tre cose: **istruzioni**, **strumenti** e, facoltativamente, **modello**. Si sceglie dal selettore degli agenti e resta attivo finché non lo cambi.

### 4.5.1 A cosa serve davvero

Tre scenari in cui un agente batte qualsiasi istruzione:

1. **Ridurre i permessi.** Un revisore del codice non deve poter modificare file. Con un elenco di strumenti in sola lettura, il vincolo è strutturale, non una raccomandazione.
2. **Isolare il rumore.** Un compito che legge venti file produce un contesto enorme. Come subagente, restituisce solo il riassunto.
3. **Specializzare il ruolo.** Un agente "planner" che produce un piano e poi passa la mano a un agente "implementer" evita che la stessa conversazione mescoli progettazione ed esecuzione.

### 4.5.2 Il formato del file

In VS Code un agente è un file `.agent.md` con frontmatter:

```markdown
---
name: Revisore
description: Revisione del codice in sola lettura, con i criteri del team
tools: ['read', 'search']
model: claude-sonnet-4
---

Sei un revisore. Non modifichi file: leggi e riporti.

Per ogni modifica:
1. Verifica che i DTO siano `record` immutabili.
2. Verifica che ogni metodo asincrono accetti e propaghi `CancellationToken`.
3. Verifica che non ci siano stringhe di connessione o segreti nel codice.
4. Segnala solo problemi concreti, con file, riga e correzione proposta.

Rispondi con una tabella: Severità | File | Riga | Problema | Correzione.
Se non trovi problemi, scrivi "Nessun problema rilevante" e fermati.
```

In Claude Code il file di un subagente sta in `.claude/agents/` ed è Markdown con frontmatter (`name`, `description`, e i campi di configurazione come `tools`). La sintassi precisa dei campi cambia tra i motori: il *formato* è quasi identico, i nomi dei campi no.

### 4.5.3 Due proprietà che vale la pena conoscere

VS Code espone due campi che risolvono problemi concreti:

- `user-invocable: false` — l'agente resta disponibile come subagente ma non compare nel selettore: utile per gli agenti "di servizio", che devono essere richiamati da altri agenti e non scelti per errore;
- `disable-model-invocation` — il controllo opposto: impedisce che il modello lo richiami da solo.

Separare le due cose è importante: un agente di pianificazione vuole essere scelto da te (`user-invocable: true`) ma non chiamato a sorpresa in mezzo a una revisione.

### 4.5.4 Handoff: passare la palla

L'**handoff** è il meccanismo con cui un agente, finito il suo lavoro, propone il passaggio a un altro. Il caso classico:

```text
Planner --(piano approvato)--> Implementer --(codice)--> Revisore
```

Senza handoff, sei tu a copiare il piano nella chat successiva. Con l'handoff, il passaggio conserva il contesto utile e cambia strumenti e istruzioni in un colpo solo. È la traduzione tecnica di una pratica umana: prima si progetta, poi si scrive, poi si rilegge — con persone (o agenti) diversi per ogni fase.

### 4.5.5 Agente o skill?

La domanda si pone spesso. La risposta dipende da **cosa vuoi isolare**:

| Se vuoi isolare... | Usa |
| --- | --- |
| Il **contenuto** (una procedura lunga, da caricare solo se serve) | una skill |
| Il **permesso** (questo compito non deve poter scrivere) | un agente |
| La **conversazione** (molto rumore, poca informazione finale) | un subagente |
| Il **modello** (compito meccanico, costo basso) | un agente |

Spesso la soluzione corretta li combina: un agente "revisore" con strumenti in sola lettura che attiva la skill "checklist-di-sicurezza" per il controllo dei segreti.
