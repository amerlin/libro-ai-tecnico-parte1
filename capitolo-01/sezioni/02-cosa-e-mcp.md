## 1.2 Che cos'è il Model Context Protocol

Il **Model Context Protocol (MCP)** è un protocollo aperto e libero (open source) che standardizza il modo in cui le applicazioni forniscono **contesto** ai modelli linguistici. In termini concreti, MCP definisce:

- un **formato di messaggi** basato su JSON-RPC 2.0 con cui client e server comunicano;
- un insieme di **operazioni** standard (elenca gli strumenti, invoca uno strumento, leggi una risorsa, ottieni un prompt, ecc.);
- un modello di **capabilities** (capacità) che client e server dichiarano e negoziano;
- una famiglia di **trasporti** (canali di comunicazione) su cui i messaggi viaggiano: il più comune è `stdio`, seguito da HTTP.

La definizione ufficiale, ripresa dai documenti del progetto, è particolarmente chiara:

> Il Model Context Protocol è un protocollo aperto che standardizza il modo in cui le applicazioni forniscono contesto ai Large Language Model (LLM). Consente un'integrazione sicura tra gli LLM e le varie sorgenti di dati e strumenti.

### 1.2.1 Chi c'è dietro MCP

MCP è stato **annunciato da Anthropic nel novembre 2024**, insieme ai primi SDK ufficiali, tra cui quelli per TypeScript e Python. L'obiettivo dichiarato era duplice: da un lato semplificare la vita agli sviluppatori di applicazioni basate su Claude, dall'altro offrire alla comunità un unico standard aperto invece di una miriade di formati proprietari.

Fin dall'inizio MCP è stato pubblicato con licenza **MIT** e con una specifica pubblica, ospitata nell'organizzazione GitHub `modelcontextprotocol`. Questo ha permesso un'adozione rapida e trasversale: oggi esistono SDK ufficiali o mantenuti dalla comunità per decine di linguaggi (C#, Java, Go, Rust, Kotlin, Swift, PHP e molti altri), e migliaia di server MCP pubblici per servizi come GitHub, Google Drive, PostgreSQL, Slack, Spotify e così via.

Oltre ad Anthropic, numerosi attori dell'ecosistema hanno annunciato supporto a MCP: OpenAI, Microsoft, Google (con Gemini), AWS e molti strumenti di sviluppo. Visual Studio Code e GitHub Copilot, in particolare, supportano nativamente la configurazione di server MCP, come vedremo più avanti.

### 1.2.2 Gli obiettivi di progetto

Dalla specifica emergono alcuni principi guida che conviene tenere a mente mentre si progetta un server:

- **Semplicità.** Il protocollo deve essere semplice da implementare e da comprendere. Non è richiesto alcun framework complesso: bastano un canale di I/O e un parser JSON.
- **Riusabilità.** Un server MCP scritto una volta deve poter essere usato da qualsiasi client MCP, senza modifiche.
- **Sicurezza.** Il protocollo definisce meccanismi di autenticazione e autorizzazione (incluso OAuth 2.1 per i trasporti HTTP) e incoraggia il principio del minimo privilegio.
- **Estensibilità.** Le capabilities permettono di evolvere il protocollo senza rompere la compatibilità.
- **Simmetria.** Il protocollo è bidirezionale: non solo il client chiede e il server risponde, ma anche il server può fare richieste al client (per esempio per il *sampling*, cioè chiedere al modello di generare testo).

### 1.2.3 Un server, molti client

La promessa centrale di MCP si riassume in una frase: **scrivi una volta, usa ovunque**. Un server MCP che espone, poniamo, gli strumenti del tuo CRM viene "capito" da:

- Claude Desktop, l'applicazione desktop di Anthropic;
- Visual Studio Code con GitHub Copilot;
- qualsiasi client che implementi la specifica, sia esso un chatbot, un agente autonomo, un'estensione di un IDE o un tool da riga di comando.

Il server non sa nulla del client che lo sta usando: non conosce il nome del modello, non sa se il chiamante è un utente umano o un agente autonomo. Il server espone una *descrizione* dei propri strumenti e dati, e il client (con il suo LLM) decide come usarli. Questa separazione netta delle responsabilità è il cuore del design.

### 1.2.4 MCP e LSP: una parentela naturale

Se hai mai sviluppato un'estensione per un editor di codice, avrai probabilmente incontrato il **Language Server Protocol (LSP)**, lo standard che permette a VS Code (e ad altri editor) di offrire completamento, refactoring e diagnostica per qualsiasi linguaggio. MCP è, per molti versi, il "cugino" di LSP per il mondo dei modelli:

- LSP standardizza la comunicazione tra un *editor* e un *language server*;
- MCP standardizza la comunicazione tra un'*applicazione AI* e un *server di contesto*.

Entrambi nascono da un'intuizione comune: invece di far parlare ogni client con ogni server tramite integrazioni ad hoc, si definisce un unico contratto. In entrambi i casi il trasporto più comune è `stdio`, ed entrambi usano messaggi JSON-RPC. La differenza sostanziale è l'oggetto della comunicazione: LSP riguarda il codice sorgente (diagnostica, simboli, riferimenti), MCP riguarda strumenti e dati generici messi a disposizione di un modello.
