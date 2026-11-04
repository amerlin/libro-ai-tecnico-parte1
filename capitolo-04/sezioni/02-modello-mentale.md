## 4.2 Il modello mentale: quattro livelli

Prima di vedere dove vanno i file, serve un modello mentale. I quattro strumenti non sono alternative equivalenti: sono **livelli** che rispondono a esigenze diverse e che si compongono.

![I quattro livelli di personalizzazione, dal contenuto sempre presente alla confezione distribuibile](figure/livelli.pdf)

### 4.2.1 Livello 1: il contesto persistente

Le **istruzioni** sono testo che entra nel contesto della conversazione senza che tu faccia nulla. Sono il livello più semplice e il più potente: costano poco, si leggono in fretta e valgono per ogni richiesta.

Il loro limite è che le istruzioni vengono lette **sempre**, quindi devono essere brevi. Un file di istruzioni da duemila righe prosciuga la finestra di contesto prima ancora che tu abbia scritto la prima richiesta.

### 4.2.2 Livello 2: la conoscenza su richiesta

Le **skill** sono procedure. La differenza fondamentale rispetto alle istruzioni è il **caricamento differito**: all'agente arriva solo il nome e la descrizione della skill; il corpo del file viene letto **solo quando** la skill viene attivata.

Questo meccanismo si chiama *progressive disclosure* (divulgazione progressiva) e cambia l'economia del contesto: puoi avere cinquanta skill installate e pagarne il costo solo per quella che usi. Ed è per questo che le skill possono contenere procedure lunghe, esempi, script e riferimenti.

### 4.2.3 Livello 3: il contesto isolato

Gli **agenti** (detti anche *custom agents*, *chat modes* o *subagent*, a seconda del motore) aggiungono due cose che le skill non hanno:

- una **configurazione di strumenti**: puoi dare a un revisore solo strumenti di lettura, o a un agente di migrazione solo il terminale;
- un **contesto separato**: quando un agente lavora come subagente, la sua conversazione non sporca la principale. Legge venti file e restituisce un riassunto.

Un agente può anche avere un **modello** diverso: uno economico e veloce per i compiti meccanici, uno più capace per la progettazione.

### 4.2.4 Livello 4: la distribuzione

I **plugin** non aggiungono capacità nuove: sono **confezioni**. Un plugin raggruppa skill, agenti, hook e server MCP in un'unità installabile e aggiornabile, così un collega (o tu su un altro computer) ottiene lo stesso setup con un comando.

Senza plugin, ogni componente va copiato a mano, e ogni aggiornamento è una copia manuale. Con i plugin c'è una versione, un manifest e un marketplace da cui installare.

### 4.2.5 Come si compongono

In una sessione reale i livelli convivono:

1. il motore carica le **istruzioni** del progetto (sempre);
2. allega i file di istruzioni che corrispondono ai file toccati (`applyTo`/`globs`);
3. l'agente selezionato aggiunge le sue istruzioni, che hanno **precedenza** in caso di conflitto;
4. quando il compito lo richiede, l'agente attiva una **skill** e ne legge il corpo;
5. se serve isolamento, delega a un **subagente**;
6. tutto ciò che arriva da un **plugin** segue le stesse regole, semplicemente è stato installato invece che scritto a mano.

Il punto da ricordare: **non esiste un livello "migliore"**. Esiste il livello giusto per il tipo di contenuto. Mettere una convenzione di due righe in una skill la rende invisibile; mettere una procedura di duecento righe nelle istruzioni la rende dannosa.
