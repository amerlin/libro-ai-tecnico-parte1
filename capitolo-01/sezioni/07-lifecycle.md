## 1.7 Il ciclo di vita di una sessione MCP

Una sessione MCP attraversa fasi ben precise, regolate dalla specifica. Conoscerle aiuta a capire gli errori di connessione e a progettare server robusti.

### 1.7.1 Fase 1: l'inizializzazione

Appena la connessione è stabilita, il client invia una richiesta `initialize` con:

- la **versione del protocollo** che intende usare;
- le proprie **capabilities**;
- le proprie informazioni (`clientInfo`: nome e versione).

Il server risponde dichiarando:

- la versione del protocollo **effettiva** (che deve essere compatibile con quella richiesta);
- le proprie **capabilities**;
- le proprie informazioni (`serverInfo`);
- facoltativamente, le **istruzioni** per il modello (un testo che l'host può includere nel prompt di sistema per spiegare come usare il server).

Le versioni del protocollo sono identificate da una data (per esempio `2025-06-18`), non seguono il versionamento semantico dei pacchetti. Client e server negoziano una versione supportata; se non è possibile concordarne una, la sessione non può essere inizializzata.

### 1.7.2 Fase 2: la notifica di "initialized"

Dopo aver ricevuto la risposta a `initialize`, il client invia la **notifica** `notifications/initialized`. Solo da questo momento in poi il client è autorizzato a inviare richieste "normali" (elencare i tool, invocarli, ecc.). Un server corretto deve quindi **rifiutare le richieste che arrivano prima dell'inizializzazione**. L'SDK .NET applica questa regola automaticamente.

### 1.7.3 Fase 3: l'operatività

In questa fase avviene il lavoro vero e proprio: discovery, invocazione di tool, lettura di risorse, recupero di prompt. Le due parti possono inoltre scambiarsi:

- `ping` per verificare che la connessione sia viva;
- notifiche di log e di cambiamento delle risorse;
- richieste di sampling (dal server verso il client).

### 1.7.4 Fase 4: la chiusura

La sessione termina quando:

- una delle parti chiude il trasporto (per `stdio`, quando il processo termina o lo stdin si chiude);
- il client invia una richiesta di chiusura esplicita (se il trasporto la prevede);
- scatta un timeout o un errore irreversibile.

Non esiste un metodo `shutdown` universale nella specifica base: la chiusura è, di norma, legata alla vita del trasporto. Per un server `stdio` questo significa che il processo deve uscire in modo pulito quando lo stdin viene chiuso; l'SDK gestisce anche questo per noi.

### 1.7.5 La sequenza riassunta

![Sequenza completa del ciclo di vita di una sessione MCP](figure/lifecycle.pdf)

### 1.7.6 Cosa significa per il nostro codice

Tutta questa sequenza è gestita dall'SDK. La nostra unica accortezza, nel caso del trasporto `stdio`, sarà ricordare che il processo deve restare in esecuzione in attesa di messaggi, e che lo stdout è riservato al protocollo. Nelle prossime sezioni vedremo come il template `Host.CreateApplicationBuilder` + `RunAsync()` realizzi esattamente questo ciclo di vita in poche righe.
