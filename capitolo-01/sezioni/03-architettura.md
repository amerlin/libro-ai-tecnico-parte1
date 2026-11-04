## 1.3 Architettura: Host, Client e Server

L'architettura di MCP distingue tre ruoli, che è fondamentale non confondere:

- **Host** — l'applicazione che l'utente vede e usa: Claude Desktop, VS Code, un'app mobile, un agente autonomo. L'host è responsabile dell'esperienza utente e, di norma, ospita il modello linguistico.
- **Client** — il componente interno all'host che gestisce la comunicazione con un singolo server. L'host può contenere **molti client**, uno per ogni server MCP a cui è collegato.
- **Server** — il processo che espone strumenti, risorse e prompt. È il componente che implementeremo in questo capitolo.

La relazione tra i tre ruoli può essere riassunta così:

![Architettura di MCP: un host, uno o più client (uno per server) e i server che espongono le capacità](figure/architettura.pdf)

Ogni client è legato a **un solo server**: la specifica prevede una relazione 1:1 tra client e server all'interno della sessione. L'host, invece, aggrega più client e orchestra il modello, passandogli i risultati dei vari server sotto forma di messaggi.

### 1.3.1 Cosa fa l'host

L'host è il regista della conversazione:

1. avvia i client e, tramite loro, i server (nel caso di `stdio` li lancia come processi figli);
2. raccoglie le capabilities dei server (quali tool, risorse e prompt offrono);
3. presenta questi strumenti al modello linguistico (tipicamente iniettandone le descrizioni nel prompt di sistema);
4. quando il modello decide di chiamare uno strumento, l'host inoltra la richiesta al client giusto;
5. restituisce al modello il risultato, permettendogli di continuare il ragionamento.

Nota bene: **il server non parla mai direttamente con il modello**. È l'host che media. Il server si limita a esporre funzioni e dati; è il modello, tramite l'host, a decidere se e quando usarli.

### 1.3.2 Cosa fa il client

Il client è un componente "meccanico": gestisce la connessione, serializza e deserializza i messaggi JSON-RPC, mantiene lo stato della sessione (handshake, negoziazione delle capabilities) e inoltra le risposte all'host. Negli SDK, il client è quasi sempre una classe già pronta: per noi, nel ruolo di sviluppatori del server, il client è soprattutto il "chiamante" che invierà i messaggi.

### 1.3.3 Cosa fa il server

Il server è il nostro oggetto di studio. Le sue responsabilità sono:

- dichiarare le proprie **capabilities** durante l'handshake iniziale;
- rispondere alle richieste di **discovery** (elenco dei tool, delle risorse, dei prompt);
- **eseguire** le operazioni richieste (invocare un tool, leggere una risorsa, comporre un prompt);
- restituire risultati strutturati, eventualmente con contenuti testuali e immagini;
- notificare al client eventuali **eventi** asincroni (per esempio il cambiamento di una risorsa).

Nel C# SDK gran parte di questo lavoro è automatizzato: come vedremo, per esporre un tool basterà marcare un metodo C# con un attributo. L'SDK si occupa di introspezione, serializzazione, discovery e gestione del trasporto.

### 1.3.4 La negoziazione delle capabilities

MCP è un protocollo *capace di evolvere*: non tutti i client e i server supportano tutte le funzionalità. Per questo, durante l'handshake, client e server si scambiano le rispettive **capabilities**, cioè un elenco dichiarativo di ciò che sanno fare.

Il client dichiara, tra le altre cose:

- se supporta il **sampling** (permettere al server di chiedere generazione al modello);
- se supporta le **roots** (informare il server sulle cartelle o sugli ambiti di lavoro);
- se supporta la gestione di **tool, risorse e prompt**.

Il server dichiara:

- se espone **tool** (e con quali funzionalità);
- se espone **risorse** (e se supporta le sottoscrizioni ai cambiamenti);
- se espone **prompt**;
- se supporta il **logging** (inviare messaggi di log al client);
- eventuali estensioni sperimentali.

Il risultato è che un server molto semplice (solo tool) e un client molto semplice (solo tool) possono comunque comunicare correttamente, ignorando le funzionalità non condivise. Quando, più avanti, useremo l'SDK .NET, vedremo che la negoziazione avviene in modo automatico: a noi basterà dichiarare ciò che il server espone, e l'SDK costruirà la risposta di inizializzazione corretta.
