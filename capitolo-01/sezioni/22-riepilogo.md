## 1.22 Riepilogo, glossario ed esercizi

Siamo arrivati alla fine del capitolo. Ripercorriamo il cammino fatto e consolidiamo i concetti con un glossario e alcuni esercizi.

### 1.22.1 Riepilogo

In questo capitolo abbiamo:

- capito **perché** i modelli, da soli, sono isolati e perché servono strumenti, dati e istruzioni;
- introdotto il **Model Context Protocol** come standard aperto che risolve il problema M×N delle integrazioni;
- esaminato l'**architettura** a tre ruoli (host, client, server) e la negoziazione delle capabilities;
- studiato i **primitivi** (tool, risorse, prompt) e i primitivi secondari;
- letto il **JSON-RPC 2.0** e i metodi standard del protocollo;
- confrontato **MCP e REST API**, concludendo che sono complementari, non alternativi;
- esplorato i **trasporti** (`stdio` e Streamable HTTP) e il **ciclo di vita** di una sessione;
- configurato l'ambiente **.NET 10** e aggiunto i pacchetti ufficiali del C# SDK;
- implementato e collaudato un **primo server `stdio`**;
- approfondito i **tool** (parametri, ritorni, asincronia, DI, annotazioni);
- costruito due esempi completi: un server per il **file system** e un server **meteo**;
- esposto **risorse** e **prompt**;
- realizzato un **server HTTP** con ASP.NET Core;
- configurato i **client** (Claude Desktop, VS Code) e usato l'**MCP Inspector**;
- raccolto le **best practice** di errori, logging e **sicurezza**, insieme a una guida alla **risoluzione dei problemi comuni**;
- scritto anche un **client .NET** per consumare i server MCP nei nostri programmi e test.

### 1.22.2 Glossario

| Termine | Definizione |
|---------|-------------|
| **MCP** | Model Context Protocol: protocollo aperto che standardizza la fornitura di contesto agli LLM |
| **Host** | L'applicazione che ospita il modello e orchestra i client (es. Claude Desktop, VS Code) |
| **Client** | Componente che gestisce la connessione con un singolo server MCP |
| **Server** | Processo che espone tool, risorse e prompt |
| **Tool** | Funzione eseguibile dal modello su richiesta |
| **Resource** | Dato esposto con un URI, letto dal client per il contesto |
| **Prompt** | Modello di istruzioni riutilizzabile |
| **Capabilities** | Capacità dichiarate e negoziate tra client e server |
| **JSON-RPC 2.0** | Il formato di messaggi su cui si basa MCP |
| **stdio** | Trasporto su standard input/output |
| **Streamable HTTP** | Trasporto di rete raccomandato dalla specifica moderna |
| **Handshake** | La fase di inizializzazione (`initialize` + `notifications/initialized`) |
| **Structured content** | Contenuto strutturato restituito da un tool (oltre al testo) |

### 1.22.3 Esercizi proposti

1. **Estendi il server file system.** Aggiungi un tool `delete_file` che elimina un file dentro la root, annotandolo `Destructive = true`, e un tool `list_directories` che elenca le sottocartelle.
2. **Schema personalizzato.** Aggiungi al server meteo un parametro `units` di tipo `enum` (`Celsius`, `Fahrenheit`) e usa il valore per scegliere il parametro dell'API.
3. **Una risorsa dinamica.** Esponi come risorsa `stats://filecount` il numero di file presenti nella directory radice, usando un metodo che esegue il conteggio al momento della lettura.
4. **Un prompt con argomenti.** Crea un prompt `commit_message` che, dati un elenco di modifiche e un contesto, produca l'istruzione per scrivere un buon messaggio di commit.
5. **Versione HTTP.** Converti il server file system in un server HTTP con `MapMcp("/files")` e collaudalo con l'MCP Inspector.
6. **Gestione errori.** Rendi `ReadFile` capace di distinguere tra file inesistente (errore chiaro) e permessi negati (errore chiaro), senza far mai crashare il server.
7. **Test unitario.** Scrivi un test per il tool `Divide` che verifichi il caso di divisione per zero.
8. **Configurazione.** Collega il server meteo a Claude Desktop e chiedi "che tempo fa a Milano?" (latitudine 45.46, longitudine 9.19).

### 1.22.4 Nel prossimo capitolo

Nel prossimo capitolo costruiremo su queste fondamenta e approfondiremo l'integrazione con i dati, realizzando un **server MCP che interagisce con un database** con Entity Framework Core.
