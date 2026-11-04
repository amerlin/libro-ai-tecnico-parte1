## 2.13 Testare il server con l'MCP Inspector

Come per il Capitolo 1, l'MCP Inspector è il banco di prova ideale. Per un server con database, però, il collaudo ha un'attenzione in più: verificare che lo **stato** cambi correttamente tra una chiamata e l'altra.

### 2.13.1 Avviare l'Inspector

```bash
> npx @modelcontextprotocol/inspector dotnet run --project C:\percorso\CatalogMcpServer
```

Per la versione HTTP:

```bash
> npx @modelcontextprotocol/inspector --transport http http://localhost:5080/mcp
```

### 2.13.2 La sequenza di collaudo

Esegui queste operazioni in ordine e verifica i risultati:

1. **`list_products` senza argomenti** — deve restituire i due prodotti seminati all'avvio.
2. **`list_products` con `{"category": "Books"}`** — deve restituire solo il prodotto della categoria "Books".
3. **`search_products` con `{"term": "Mac"}`** — deve trovare "MacBook Air".
4. **`create_product`** con `{"name": "Headphones", "price": 199.99, "categoryName": "Electronics"}` — deve creare il prodotto e restituire l'id.
5. **`list_products` di nuovo** — deve ora mostrare il nuovo prodotto: questo conferma che il **database persiste** le modifiche.
6. **`delete_product`** con l'id del prodotto appena creato — deve eliminarlo.
7. **`create_product` con una categoria inesistente** — deve restituire l'errore `Category not found: ...`, non un crash.
8. **`delete_product` con un id inesistente** — deve restituire `Product not found: ...`.

### 2.13.3 Cosa osservare negli errori

Una `McpException` lanciata dal tool non è un errore di protocollo JSON-RPC: `tools/call` restituisce normalmente un risultato con `isError: true` e il messaggio in `content`, per esempio:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [{ "type": "text", "text": "Product not found: 999" }],
    "isError": true
  }
}
```

Il campo JSON-RPC di primo livello `error` è invece riservato agli errori di protocollo, per esempio una richiesta non valida o un metodo sconosciuto. Verifica che il risultato del tool sia **chiaro e contestualizzato**, non un generico "internal error": se il modello riceve un errore chiaro, può correggersi; se riceve un errore opaco, fallisce e frustra l'utente.

### 2.13.4 Testare la persistenza attraverso il riavvio

Un test che vale la pena fare: crea un prodotto, **chiudi l'Inspector** (che termina il server), riavvia il server e verifica con `list_products` che il prodotto esista ancora. L'inizializzazione dimostrativa usa `EnsureCreated` senza cancellare il database e semina i prodotti solo se non ce ne sono: il prodotto creato deve quindi persistere al riavvio. È comunque un artificio didattico, non una strategia di inizializzazione per la produzione.

### 2.13.5 Test automatici con un client .NET

Nel Capitolo 1 abbiamo visto come scrivere un client .NET. Lo stesso approccio si applica qui e diventa un **test di integrazione** prezioso: avvia il server, invoca `create_product`, poi `list_products`, e verifica che il nuovo prodotto compaia. Il pattern è identico a quello già mostrato; la differenza è che ora, dietro i tool, c'è un database reale.
