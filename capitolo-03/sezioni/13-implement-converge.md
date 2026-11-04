## 3.13 Implement e Converge

Siamo al momento in cui l'agente scrive il codice. Gli ultimi due comandi — implement e converge — lavorano in coppia e chiudono il ciclo.

### 3.13.1 `/speckit-implement`

```text
/speckit-implement
```

Il comando esegue i task di `tasks.md` **in ordine di dipendenza** (fase per fase). Prima di partire:

1. **legge la checklist** (`checklists/requirements.md`): se ci sono voci non spuntate, **chiede** all'utente prima di procedere (senza modificare i file di checklist, che restano di proprietà del revisore);
2. rispetta i gate della constitution definiti nel piano.

Per feature grandi, si può eseguire **una fase alla volta** (per esempio solo la Phase 3), per controllare meglio l'avanzamento. Per feature piccole, una singola esecuzione costruisce tutto.

### 3.13.2 Cosa produce

L'output è il **codice sorgente vero e proprio**: nel nostro caso, i file C# della Minimal API, l'entità, il `DbContext`, i DTO e i test — esattamente i percorsi indicati nei task. Lo vedremo in dettaglio nella sezione dell'esempio completo.

### 3.13.3 `/speckit-converge`

```text
/speckit-converge
```

Dopo l'implementazione, converge **confronta il codice con spec, plan e task**:

- se trova funzionalità richieste ma non implementate (gap), **aggiunge nuovi task** a `tasks.md`;
- altrimenti riporta **Converged**.

Se ci sono gap, il ciclo è: esegui di nuovo `/speckit-implement` per i nuovi task, poi di nuovo `/speckit-converge`, finché non riporta `Converged`.

### 3.13.4 Il ciclo implement–converge

![Il ciclo implement–converge](figure/ciclo-implement-converge.pdf)

Quando converge riporta `Converged`, il lavoro è completo: puoi procedere con la revisione umana o aprire la pull request.

### 3.13.5 Cosa garantisce la convergenza

La convergenza è ciò che trasforma "l'agente ha scritto del codice" in "l'agente ha scritto **il** codice richiesto". È una verifica di **completezza**, non di correttezza: i test (scritti in modalità test-first) coprono la correttezza; la convergenza copre la completezza. Insieme, danno una ragionevole fiducia che il risultato corrisponda alla specifica.

### 3.13.6 Il risultato finale

Al termine del flusso completo hai:

- una specifica rivista (`spec.md`);
- un piano tecnico con modello dati e contratti;
- una lista di task eseguiti;
- il codice sorgente;
- i test;
- la conferma di convergenza.

E tutto è **versionato**: chiunque riapra la feature — un collega, un revisore, o te stesso tra sei mesi — trova non solo il codice, ma il *perché* e il *come* documentati.
