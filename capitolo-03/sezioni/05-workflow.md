## 3.5 Il workflow a colpo d'occhio

Spec Kit definisce due percorsi per lo SDD: uno **breve** (per feature piccole) e uno **completo** (per feature di produzione). In entrambi i casi, i comandi si invocano **nella chat dell'agente**, uno alla volta, rivedendo ogni risultato prima di procedere.

### 3.5.1 Il percorso breve

Per feature piccole o prototipi:

1. `/speckit-specify` → la specifica (`spec.md`)
2. `/speckit-plan` → il piano tecnico (`plan.md`, …)
3. `/speckit-tasks` → i task (`tasks.md`)
4. `/speckit-implement` → il codice
5. `/speckit-converge` → verifica della completezza

### 3.5.2 Il percorso completo

Per feature di produzione, con i gate di qualità:

1. `/speckit-constitution` (una volta per progetto)
2. `/speckit-specify`
3. `/speckit-clarify` → risolve le ambiguità
4. `/speckit-plan`
5. `/speckit-checklist` → checklist di qualità della specifica
6. `/speckit-tasks`
7. `/speckit-analyze` → verifica di coerenza tra gli artefatti
8. `/speckit-implement`
9. **Polish** → revisione mirata, rifinitura e test del risultato, senza ampliare la specifica
10. `/speckit-converge` → verifica della completezza

**Polish** è un'attività di revisione, non un comando standard di Spec Kit: si esegue dopo l'implementazione e si ripetono i test prima della convergenza. Il diagramma mostra i comandi del flusso e perciò non rappresenta questa attività trasversale. Se l'integrazione offre una skill dedicata, usane la sintassi generata.

Le fasi aggiuntive (`clarify`, `checklist`, `analyze`) sono **gate di qualità**: costano poco, si eseguono in chat e intercettano i problemi prima che diventino codice sbagliato.

### 3.5.3 Il diagramma del flusso

![Il flusso completo di Spec Kit: comandi a sinistra, artefatti prodotti a destra](figure/workflow-flusso.pdf)

### 3.5.4 Le regole d'uso

Tre regole fondamentali, ripetute nella documentazione ufficiale:

1. **Un comando alla volta.** Non incatenare i comandi: esegui `/speckit-specify`, rivedi il risultato, poi passa al successivo. Ogni comando dipende dall'output del precedente.
2. **Rivedi prima di proseguire.** Gli artefatti sono tuoi: se la specifica non riflette ciò che volevi, correggila (a mano o chiedendo all'agente) prima di pianificare.
3. **I comandi si eseguono nella chat, non nel terminale.** Il CLI `specify` serve per `init`, estensioni e controlli dei prerequisiti; i comandi `/speckit-*` sono skill dell'agente.

### 3.5.5 Cosa produce la convergenza

L'ultimo comando, `/speckit-converge`, confronta il **codice** con **spec, plan e task**. Se trova gap (funzionalità richieste ma non implementate), **aggiunge nuovi task** a `tasks.md`; poi riesegui `/speckit-implement` e di nuovo `/speckit-converge`, finché non riporta **Converged**. È il meccanismo che chiude il cerchio e garantisce che il codice corrisponda alla specifica — non "più o meno", ma in modo verificabile.
