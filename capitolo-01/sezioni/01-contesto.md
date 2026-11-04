## 1.1 Il problema: modelli intelligenti ma isolati

Immagina di dover costruire un assistente che risponde a domande sui dati della tua azienda: "quante fatture sono state emesse questa settimana?", "riassumi i commenti dei clienti sul prodotto X", "aggiorna lo stato della pratica 1234". Un LLM, da solo, non può farlo. Il modello conosce il linguaggio, sa ragionare e sa produrre testo, ma:

- non può **leggere** il tuo database, i tuoi file o le tue API;
- non può **agire** — cioè compiere operazioni come creare un ticket, inviare una email o aggiornare un record;
- non ha **memoria persistente** tra una sessione e l'altra: ogni conversazione riparte da zero;
- non conosce il **contesto specifico** della tua organizzazione, che non fa parte del suo addestramento.

La soluzione tradizionale è stata per anni l'integrazione "a mano": ogni volta che nasceva una nuova applicazione di intelligenza artificiale, si scrivevano connettori su misura verso ogni sorgente dati, e viceversa. È quello che viene chiamato il **problema M×N**: con *M* applicazioni AI e *N* sorgenti di dati o strumenti, servono potenzialmente *M × N* integrazioni, ognuna con la propria logica, i propri formati e i propri bug.

Se un team costruisce un assistente che deve parlare con un CRM, un database SQL, un file system e un servizio meteo, e poi un secondo team ne costruisce un altro che deve parlare con lo stesso CRM e lo stesso database, ciascun team riscriverà da capo (o quasi) il codice di connessione. Il risultato è duplicazione, costi crescenti e una qualità disomogenea.

### 1.1.1 L'analogia con le prese di corrente

Un'analogia efficace è quella delle prese elettriche. Prima della standardizzazione, ogni elettrodomestico aveva il suo tipo di spina e ogni stanza la sua presa: per collegare un nuovo dispositivo serviva un adattatore. La standardizzazione della spina ha permesso a qualsiasi apparecchio di funzionare in qualsiasi presa, una sola volta per tutte.

Il Model Context Protocol fa la stessa cosa per il mondo dell'IA generativa: definisce una **"presa standard"** a cui ogni applicazione AI può collegarsi, e una **"spina standard"** che ogni fornitore di dati o strumenti può esporre. Una volta implementata la presa, tutte le spine sono compatibili; una volta implementata la spina, tutte le prese funzionano.

### 1.1.2 Cosa serve davvero a un LLM per essere utile

Possiamo riassumere le esigenze di un'applicazione LLM in tre categorie:

1. **Strumenti (tools)** — capacità di compiere azioni: eseguire una query, creare un file, inviare una richiesta HTTP. Il modello decide *quando* e *come* usarli, in base alla richiesta dell'utente.
2. **Dati (resources)** — contenuti informativi da inserire nel contesto: documenti, record di database, configurazioni, log. Il modello li *legge* per rispondere meglio.
3. **Istruzioni riutilizzabili (prompts)** — modelli di prompt predefiniti che l'utente o il client possono richiamare, per non riscrivere ogni volta le stesse istruzioni.

Un LLM dotato di questi tre ingredienti smette di essere un semplice "generatore di testo" e diventa un **agente**: un sistema che osserva, ragiona e agisce.

### 1.1.3 Perché serve un *protocollo* e non una libreria

A questo punto potresti chiederti: perché non usare semplicemente una libreria client per parlare con il database o le API? In effetti è possibile, e in molti casi si fa. Il problema è che ogni libreria ha la propria sintassi, i propri tipi, i propri errori. Quando l'applicazione AI deve imparare a usare un nuovo strumento, deve "imparare" anche la sua API specifica.

Un **protocollo** standardizza invece l'intera conversazione: come si scoprono gli strumenti disponibili, come si invoca uno strumento, come si ricevono i risultati, come si gestiscono gli errori. L'applicazione AI non deve più conoscere i dettagli di ogni singola sorgente: conosce il protocollo, e tutto ciò che parla il protocollo è automaticamente utilizzabile.

Questa è la stessa idea che ha reso di successo, in altri campi, protocolli come HTTP per il web, SMTP per la posta o il Language Server Protocol (LSP) per gli editor di codice: definire un **contratto unico** e lasciare che il resto del mondo vi si adegui.

> **Nota.** MCP non sostituisce il *funzionamento interno* dei tuoi sistemi. Il tuo database continuerà a usare SQL, le tue API REST continueranno a esporre endpoint HTTP. MCP è un **livello di interfaccia standard** che si appoggia sopra questi sistemi e li rende consumabili da un LLM in modo uniforme. Torneremo su questa distinzione fondamentale nella sezione dedicata al confronto con le REST API.
