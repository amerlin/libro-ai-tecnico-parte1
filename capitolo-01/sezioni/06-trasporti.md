## 1.6 I trasporti: stdio, Streamable HTTP e SSE

JSON-RPC definisce *cosa* si dice, ma non *come* lo si trasporta. MCP definisce una famiglia di **trasporti**: canali concreti su cui i messaggi viaggiano. La scelta del trasporto è una delle decisioni progettuali più importanti, perché determina dove e come il server verrà eseguito.

### 1.6.1 stdio: il trasporto dei processi locali

Nel trasporto `stdio`, il server viene **lanciato come processo figlio** dal client, e la comunicazione avviene attraverso lo standard input e lo standard output del processo:

- il client scrive i messaggi JSON-RPC sullo **stdin** del server;
- il server risponde sullo **stdout**;
- i messaggi sono delimitati da **newline** (un oggetto JSON per riga).

È il trasporto più semplice e più diffuso per i server locali: non richiede porte di rete, né configurazioni di firewall, né esposizione a Internet. Il ciclo di vita del server coincide con quello del processo: quando il client si chiude (o lo stdin raggiunge la fine), il server termina.

La conseguenza pratica più importante, che vale la pena evidenziare subito, è questa: **su `stdio` lo stdout appartiene al protocollo**. Qualsiasi altra scrittura sullo stdout — per esempio i log della console — corrompe il flusso JSON-RPC e rende il server inutilizzabile. Per questo, nei nostri server `stdio`, disabiliteremo il logging su console con `builder.Logging.ClearProviders()`.

### 1.6.2 Streamable HTTP: il trasporto di rete

Il trasporto **Streamable HTTP** è il trasporto di rete raccomandato dalla specifica moderna. Il server espone un **singolo endpoint HTTP** (per esempio `http://localhost:8080/mcp`) e:

- il client invia le richieste JSON-RPC con normali richieste `POST`;
- il server può rispondere direttamente nel body della risposta (per le richieste singole) oppure aprire uno **stream** (per esempio con Server-Sent Events) per inviare risposte e notifiche multiple nel tempo.

Streamable HTTP è pensato per funzionare bene con i load balancer, i reverse proxy e i meccanismi standard di HTTP (autenticazione, TLS, cache). Supporta anche una modalità **stateless**, in cui ogni richiesta è indipendente e il server non mantiene una sessione persistente.

### 1.6.3 Il vecchio trasporto HTTP+SSE

La prima versione di MCP definiva un trasporto HTTP basato su due endpoint: uno per le richieste del client e uno per lo stream di eventi del server (SSE). Questo trasporto è oggi **deprecato** in favore di Streamable HTTP, ma lo si incontra ancora in molti server esistenti e in molta documentazione. L'SDK .NET lo supporta ancora (con l'opzione `EnableLegacySse`), per compatibilità.

### 1.6.4 Come scegliere il trasporto

| Scenario | Trasporto consigliato |
|----------|------------------------|
| Server personale, usato da un client locale sulla stessa macchina | `stdio` |
| Server condiviso tra più utenti o macchine | Streamable HTTP |
| Server in un container o dietro un proxy/reverse proxy | Streamable HTTP |
| Server che deve inviare eventi asincroni frequenti | Streamable HTTP |
| Integrazione con un IDE (VS Code, ecc.) | `stdio` o HTTP, a seconda del caso |

In questo capitolo implementeremo entrambi: prima un server `stdio` completo, poi la sua versione HTTP con ASP.NET Core, in modo da padroneggiare l'intero spettro.

### 1.6.5 Il ruolo dell'SDK

Da sviluppatori non dobbiamo occuparci dei dettagli di framing: l'SDK .NET fornisce i trasporti già pronti. In particolare, nel pacchetto troviamo le classi `StdioServerTransport`, `StreamableHttpServerTransport` e `StreamServerTransport`, che vengono selezionate con un semplice metodo di configurazione (`WithStdioServerTransport()`, `WithHttpTransport()`). La nostra responsabilità si riduce a scegliere il trasporto giusto e a rispettare le sue regole (per esempio, non scrivere sullo stdout nei server `stdio`).
