## 3.1 Lo spec-driven development: invertire la piramide

Prima di parlare dello strumento, capiamo la **filosofia** che lo anima. GitHub Spec Kit è l'implementazione pratica dello *Specification-Driven Development* (SDD), un approccio che cambia il ruolo della specifica nel ciclo di vita del software.

### 3.1.1 Il potere invertito

Per decenni il codice è stato il re. Le specifiche servivano il codice: si scrivevano documenti di requisiti per guidare lo sviluppo, e li si **scartava** appena cominciava il "vero lavoro". Il PRD (Product Requirements Document) diventava rapidamente obsoleto, il design doc finiva in un cassetto, e la fonte di verità rimaneva, di fatto, solo il codice.

Lo spec-driven development inverte questa gerarchia: **la specifica è la fonte di verità**, e il codice è una sua **derivazione**. La specifica non è un artefatto usa-e-getta, ma un documento vivo che viene portato avanti attraverso la pianificazione, l'implementazione e la convergenza finale.

### 3.1.2 Perché proprio adesso

Tre fattori rendono questo approccio possibile (e conveniente) oggi, quando in passato era impraticabile:

1. **Gli agenti AI possono scrivere molto codice in fretta.** Il collo di bottiglia non è più digitare il codice, ma decidere *cosa* deve fare. Investire tempo nella specifica diventa l'investimento a più alto rendimento.
2. **Gli LLM lavorano bene con strutture.** Un template ben progettato "guida" il modello verso output di qualità costante, riducendo divagazioni e dettagli prematuri.
3. **I team sono distribuiti e asincroni.** Una specifica versionata, rivista e approvata diventa il contratto condiviso tra chi definisce e chi implementa — umano o agente che sia.

### 3.1.3 L'idea in una frase

> Definisci **cosa** costruire e **perché**, poi trasforma la specifica in un piano, in task e in codice funzionante.

Tutto il resto — comandi, template, checklist — è al servizio di questa frase.

### 3.1.4 Il flusso SDD in pratica

Il flusso parte da un'idea, spesso vaga e incompleta:

1. **Specifica.** Attraverso un dialogo con l'agente, l'idea diventa una specifica strutturata: user story prioritarie, criteri di accettazione, requisiti funzionali, entità, criteri di successo misurabili.
2. **Chiarimento.** Le ambiguità vengono esplicitate e risolte (o marcate come `[NEEDS CLARIFICATION]`).
3. **Piano.** La specifica diventa un piano tecnico: stack, architettura, modello dati, contratti.
4. **Task.** Il piano viene scomposto in task ordinati per dipendenza, raggruppati per user story.
5. **Implementazione.** I task vengono eseguiti nell'ordine giusto.
6. **Convergenza.** Il codice viene confrontato con la specifica: se manca qualcosa, si aggiungono task e si itera finché non c'è convergenza.

Ciò che richiedeva giorni di riunioni e documentazione si comprime in ore di lavoro focalizzato. E, a differenza del passato, gli artefatti non vengono scartati: restano, versionati, come documentazione viva del sistema.

### 3.1.5 Il ruolo dei template

La qualità dell'output dipende in modo cruciale dai **template**. Un buon template è, di fatto, un *prompt strutturato* che vincola il modello in modi produttivi:

- **impedisce i dettagli implementativi prematuri** (la specifica non deve dire "usa React", deve dire "l'utente deve vedere aggiornamenti in tempo reale");
- **forza i marcatori di incertezza** (`[NEEDS CLARIFICATION]`) invece di lasciare che il modello inventi;
- **include checklist** che funzionano come "unit test" per la specifica;
- **impone gate di conformità** ai principi del progetto (la *constitution*).

Vedremo ciascuno di questi meccanismi in dettaglio nelle prossime sezioni, perché sono il cuore di Spec Kit.

### 3.1.6 Cosa NON è lo SDD

Per evitare fraintendimenti:

- non è "scrivere documenti invece di codice": è scrivere **prima** i documenti giusti, per scrivere **meglio** il codice dopo;
- non elimina la revisione umana: la sposta, anzi, più a monte, dove costa meno;
- non è un processo a cascata rigido: le fasi sono iterative (si può tornare indietro e rivedere la specifica);
- non è legato a un linguaggio: funziona con C#, Python, TypeScript, qualunque stack.
