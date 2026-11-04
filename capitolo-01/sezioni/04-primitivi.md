## 1.4 I primitivi del protocollo: Tools, Resources e Prompts

Il cuore di MCP è costituito da tre primitivi, a cui se ne aggiungono alcuni secondari. Comprenderli a fondo è indispensabile, perché tutto il codice che scriveremo ruota attorno a essi.

### 1.4.1 Tools: le azioni

Un **tool** è una funzione che il server mette a disposizione del modello. Quando il modello "chiama" un tool, invia al server un nome e una lista di argomenti; il server esegue la funzione e restituisce un risultato.

Ogni tool è descritto da:

- un **nome** (stringa, univoco all'interno del server);
- una **descrizione** testuale, che il modello usa per capire *quando* e *come* usarlo: una buona descrizione è il fattore che più influenza la qualità dell'uso;
- uno **schema JSON** degli argomenti in ingresso (nome, tipo, obbligatorietà, descrizione di ogni parametro);
- opzionalmente, uno schema dell'output.

Esempi tipici di tool: `search_documents`, `send_email`, `create_ticket`, `get_weather`, `read_file`, `run_query`. Un tool può essere **idempotente** o meno, **che modifica lo stato** o di sola lettura: MCP prevede annotazioni facoltative per dichiararlo (ci torneremo).

È importante capire la direzione del flusso: nei tool è il **modello** a prendere l'iniziativa. Il server espone il menu, il modello sceglie dal menu e il server esegue.

### 1.4.2 Resources: i dati

Una **resource** è un dato esposto dal server e identificato da un **URI**. Se i tool sono le "azioni", le risorse sono i "documenti": file, record, configurazioni, immagini, log. Il modello (o il client, per conto dell'utente) può *leggere* una risorsa per acquisire contesto.

Le risorse hanno una differenza concettuale fondamentale rispetto ai tool: nei tool il controllo è del modello, nelle risorse il controllo è **del client o dell'applicazione**. Un'applicazione può decidere autonomamente di "agganciare" una risorsa al contesto del modello, senza che il modello debba chiederla.

Le risorse possono essere:

- **statiche**, con un URI fisso (per esempio `config://app/settings`);
- **parametrizzate tramite template**, in cui l'URI contiene dei segnaposto (per esempio `file://docs/{id}`): il client può elencare i template e poi leggere una risorsa concreta sostituendo i parametri.

Ogni risorsa dichiara un **tipo MIME** (per esempio `text/plain`, `application/json`, `image/png`), così il client sa come interpretarla.

### 1.4.3 Prompts: i modelli di istruzione

Un **prompt** è un modello di istruzioni riutilizzabile, esposto dal server e richiamabile dal client o dall'utente. Mentre un tool *esegue* qualcosa, un prompt *produce testo* (o una sequenza di messaggi) pronto per essere inviato al modello.

Un caso d'uso tipico: il server espone un prompt `review_code` che, dato un frammento di codice, produce il testo "Fai una revisione approfondita del seguente codice, segnalando bug, problemi di sicurezza e suggerimenti di stile: ...". L'utente, dall'interfaccia dell'host, può selezionare il prompt senza doverlo riscrivere.

I prompt possono dichiarare **argomenti** (con schema JSON), e la loro esecuzione restituisce una lista di messaggi (ruolo + contenuto), non necessariamente una singola stringa.

### 1.4.4 Gli altri primitivi

Oltre ai tre principali, la specifica prevede primitivi più avanzati, che non implementeremo in dettaglio ma che è bene conoscere:

- **Sampling** — permette al *server* di chiedere al *client* di generare testo con il modello. Utile per scenari in cui il server deve, per esempio, riassumere un documento.
- **Roots** — permette al client di comunicare al server quali sono le "radici" del progetto (cartelle, URL) su cui l'utente sta lavorando.
- **Elicitation** — permette al server di porre una domanda all'utente durante l'esecuzione di un tool.
- **Logging** — permette al server di inviare messaggi di log strutturati al client.
- **Completions** — permette al server di suggerire completamenti per gli argomenti dei prompt.
- **Pagination e Progress** — per gestire elenchi lunghi e operazioni lente.

### 1.4.5 La tabella riassuntiva

| Primitivo | Direzione del controllo | Scopo | Esempio |
|-----------|--------------------------|-------|---------|
| Tool      | Modello                  | Eseguire azioni | `create_ticket`, `get_weather` |
| Resource  | Client / applicazione    | Fornire dati di contesto | `config://app`, `docs://123` |
| Prompt    | Utente / client          | Riutilizzare istruzioni | `review_code`, `summarize_meeting` |

Tenere a mente questa tabella aiuta a scegliere il primitivo giusto quando si progetta un server: se il modello deve *fare* qualcosa, serve un tool; se deve *leggere* qualcosa, una resource; se l'utente deve *invocare un'istruzione pronta*, un prompt.
