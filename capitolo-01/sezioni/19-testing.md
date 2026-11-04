## 1.19 Testare con MCP Inspector

Prima di collegare il server a un host, conviene collaudarlo in isolamento. Lo strumento ufficiale per farlo è l'**MCP Inspector**, un'applicazione web che si avvia da riga di comando e permette di: vedere i tool/risorse/prompt esposti, invocarli a mano, ispezionare i messaggi JSON-RPC e verificare l'handshake.

### 1.19.1 Avviare l'Inspector con un server stdio

L'Inspector si esegue con `npx` (richiede Node.js) e accetta come argomento il comando di avvio del server:

```bash
> npx @modelcontextprotocol/inspector dotnet run --project C:\percorso\MeteoServer
```

L'Inspector:

1. avvia il server come processo figlio (trasporto `stdio`);
2. apre una pagina web (di solito su `http://localhost:6274`);
3. mostra lo stato della connessione e l'esito dell'handshake.

Nella scheda **Tools** vedrai l'elenco dei tool con nome, descrizione e schema di input. Puoi selezionare un tool, compilare gli argomenti in un modulo e premere **Run** per invocarlo, osservando la risposta.

### 1.19.2 Avviare l'Inspector con un server HTTP

Per un server HTTP l'Inspector accetta direttamente l'URL:

```bash
> npx @modelcontextprotocol/inspector --transport http http://localhost:5080/mcp
```

### 1.19.3 Cosa verificare

Usa l'Inspector per controllare, in ordine:

1. **Handshake riuscito** — la connessione si stabilisce e la versione del protocollo è negoziata correttamente;
2. **Discovery** — tool, risorse e prompt compaiono con descrizioni e schemi corretti;
3. **Invocazione** — ogni tool, chiamato con argomenti validi, restituisce il risultato atteso;
4. **Errori** — chiamato con argomenti che causano un errore di esecuzione, il tool restituisce un `CallToolResult` con `isError: true` e un messaggio comprensibile (non un crash); gli errori JSON-RPC riguardano invece il protocollo;
5. **Risorse e prompt** — la lettura delle risorse e il recupero dei prompt funzionano.

### 1.19.4 Leggere i messaggi grezzi

L'Inspector espone anche la **vista dei messaggi**, che mostra i JSON-RPC scambiati. È il modo migliore per familiarizzare con il protocollo "dal vivo": vedrai esattamente le richieste `initialize`, `tools/list`, `tools/call` e le relative risposte, identiche a quelle che abbiamo descritto nella sezione sul JSON-RPC. Se qualcosa non torna, questa vista è il primo posto dove guardare.

### 1.19.5 L'Inspector come strumento di sviluppo quotidiano

Integrare l'Inspector nel flusso di lavoro ha un valore enorme: permette di iterare sul server (aggiungere un tool, migliorare una descrizione, correggere uno schema) e verificarne subito l'effetto, senza dover ogni volta riavviare un host completo. È, in pratica, il "debugger" di MCP.

Se preferisci non usare Node.js, ricorda che un server `stdio` si può collaudare anche inviando i messaggi JSON-RPC a mano sullo standard input, come abbiamo fatto nelle sezioni precedenti; l'Inspector rende però l'operazione molto più comoda e visiva.
