## 4.1 Perché personalizzare un agente

Un agente di codifica, senza contesto, è un collaboratore brillante al primo giorno: sa programmare, ma non sa nulla del *tuo* progetto. Non sa che i test si lanciano con `dotnet test --filter`, che i DTO stanno in `src/Contracts`, che le migrazioni non si scrivono a mano, che il branch `main` è protetto. Ogni sessione ricomincia da capo, e ogni volta glielo dobbiamo spiegare.

Il costo di questa amnesia non è solo il tempo speso a ripetere. È soprattutto l'**incoerenza**: se le regole vivono nella chat, ogni conversazione applica una versione leggermente diversa delle stesse regole, e il repository si riempie di stili che nessuno ha deciso.

### 4.1.1 Il problema del contesto

La finestra di contesto è una risorsa finita, e ogni token speso in istruzioni è un token che non è disponibile per il codice. Da qui nasce un compromesso che attraversa tutto il capitolo:

- le regole **brevi e sempre valide** (convenzioni, comandi di build) conviene tenerle sempre presenti;
- le procedure **lunghe e occasionali** (generare le note di rilascio, fare un audit di sicurezza) non devono occupare contesto finché non servono;
- i compiti **rumorosi** (leggere venti file per rispondere a una domanda) non devono inquinare la conversazione principale.

Questi tre casi corrispondono ai tre livelli che vedremo tra poco: istruzioni, skill, agenti.

### 4.1.2 Quattro strumenti, quattro scopi

Chi arriva a questi strumenti per la prima volta tende a confonderli, perché tutti e quattro sono "file di testo che dicono all'AI cosa fare". La differenza è nel **perimetro**:

| Strumento | Risponde alla domanda | Quando si carica |
| --- | --- | --- |
| **Istruzioni** | «Quali sono le regole di questo progetto?» | Sempre, o per i file che corrispondono a un pattern |
| **Skill** | «Come si fa questa procedura?» | Quando il compito la rende pertinente, o su richiesta esplicita |
| **Agente** | «Chi deve fare questo lavoro, con quali strumenti?» | Quando lo selezioni, o quando un altro agente gli delega il compito |
| **Plugin** | «Come distribuisco tutto questo a un'altra persona?» | All'installazione; poi i suoi componenti seguono le regole sopra |

### 4.1.3 Un esempio concreto

Immagina di lavorare a una Minimal API in .NET. Ti servono quattro cose diverse:

1. che l'agente usi sempre `record` per i DTO e non classi con proprietà mutabili → **istruzione**;
2. che sappia eseguire la procedura di rilascio (aggiornare il changelog, taggare, pubblicare) → **skill**;
3. che le revisioni del codice siano fatte da un agente in sola lettura, senza toccare i file → **agente**;
4. che un collega possa installare tutto questo con un comando → **plugin**.

Nelle prossime sezioni costruiremo esattamente questo insieme.
