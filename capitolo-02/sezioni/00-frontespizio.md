---
title: "Quaderno AI"
subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"
author: "Andrea Merlin"
date: "Numero 1 - Novembre 2026"
lang: it
---

# Capitolo 2
## Un MCP Server con Entity Framework Core: dati, query e primitivi avanzati

**Abstract.** Nel primo capitolo abbiamo costruito server MCP che espongono tool "senza memoria": file system e chiamate HTTP. Ora facciamo il passo successivo: un server che parla con un **database relazionale** tramite **Entity Framework Core**, il framework ORM di .NET. Implementeremo un catalogo prodotti completo — letture, ricerche, inserimenti, aggiornamenti e cancellazioni — scopriremo il pattern giusto per usare un `DbContext` dentro un tool, affronteremo le migrazioni e i trasporti `stdio` e HTTP, e infine vedremo come un tool può comunicare il proprio avanzamento con il primitivo **Progress**.

### Cosa imparerai in questo capitolo

Al termine della lettura e della pratica saprai:

- spiegare perché un agente ha bisogno di **dati persistenti** e come un MCP server può fornirglieli;
- usare **Entity Framework Core 10** per modellare entità e relazioni;
- collegare un `DbContext` a un tool MCP con il pattern **`IDbContextFactory`**, evitando i problemi di lifetime;
- creare il database con `EnsureCreated` e, per i progetti reali, con le **migrazioni** (`dotnet ef`);
- implementare tool di **lettura** e **scrittura** con query LINQ, filtri e gestione degli errori;
- esporre lo stesso server su **`stdio`** e su **HTTP**;
- usare il primitivo **Progress** per comunicare l'avanzamento di un tool.

### Prerequisiti

- Aver letto (o padroneggiare) il Capitolo 1: in particolare tool, trasporti, configurazione dei client e MCP Inspector;
- .NET SDK 10 e un editor (VS Code, Visual Studio o Rider);
- conoscenza di base del linguaggio **LINQ** e, facoltativamente, di SQL.

### Convenzioni

Valgono le convenzioni del Capitolo 1. In più, in questo capitolo useremo **SQLite** come database: è un database relazionale completo, basato su file, che non richiede alcun server da installare — perfetto per un server `stdio` locale. I concetti e il codice si trasferiscono quasi identici a SQL Server o PostgreSQL, cambiando solo il provider (lo vedremo).

Come nel capitolo precedente, ogni frammento è stato **compilato ed eseguito** con .NET 10, `ModelContextProtocol` 2.3.0 ed Entity Framework Core 10.0.14.
