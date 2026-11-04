---
title: "Quaderno AI"
subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"
author: "Andrea Merlin"
date: "Numero 1 - Novembre 2026"
lang: it
---

# Capitolo 1
## Model Context Protocol: fondamenti e implementazione di un MCP Server in .NET 10

**Abstract.** I modelli linguistici di grandi dimensioni (Large Language Model, LLM) sono strumenti potenti ma, presi da soli, "isolati": non possono accedere ai tuoi file, alle tue API, ai tuoi database o agli strumenti che usi ogni giorno. Il *Model Context Protocol* (MCP) è lo standard aperto che risolve questo problema, definendo un modo uniforme con cui un'applicazione basata su intelligenza artificiale può scoprire e usare **strumenti**, **dati** e **modelli di prompt** esposti da un processo chiamato *MCP server*. In questo capitolo capiremo perché MCP è nato, in che cosa si distingue da una classica API REST, e costruiremo passo dopo passo, con codice reale e funzionante, un MCP server completo in .NET 10.

### Cosa imparerai in questo capitolo

Al termine della lettura e della pratica saprai:

- spiegare a parole semplici cos'è il Model Context Protocol e quale problema risolve;
- distinguere con chiarezza un MCP server da una REST API e scegliere lo strumento giusto per ogni scenario;
- descrivere l'architettura del protocollo (host, client, server) e i suoi primitivi (tools, resources, prompts);
- leggere e scrivere i messaggi JSON-RPC 2.0 che costituiscono il "linguaggio" di MCP;
- creare da zero un progetto .NET 10 e aggiungere i pacchetti NuGet ufficiali del C# SDK;
- implementare un MCP server su trasporto `stdio` e su trasporto HTTP con ASP.NET Core;
- esporre tool con attributi C#, gestire parametri, descrizioni, codice asincrono ed errori;
- esporre risorse (resources) e template di prompt (prompts);
- configurare client reali come Claude Desktop e Visual Studio Code;
- collaudare il server con l'MCP Inspector;
- applicare le principali best practice di sicurezza e di progettazione.

### Prerequisiti

- Conoscenza di base del linguaggio C# e dell'ecosistema .NET;
- .NET SDK 10 installato (vedremo come verificarlo e installarlo nella sezione dedicata);
- un editor di testo o un IDE (Visual Studio Code, Visual Studio o Rider);
- facoltativa ma consigliata: familiarità con il formato JSON e con il concetto di HTTP.

### Convenzioni tipografiche

Nel corso del capitolo useremo alcune convenzioni ricorrenti:

- Il **grassetto** evidenzia concetti nuovi o importanti.
- Il testo `monospace` indica nomi di pacchetti, tipi, metodi, comandi e frammenti di codice nel testo.
- I blocchi di codice riportano il linguaggio nell'intestazione (per esempio `csharp`, `json`, `bash`).
- I comandi da eseguire in un terminale sono preceduti dal prompt `>` e vanno eseguiti nella cartella indicata.
- Le note *Importante* e *Attenzione* segnalano rispettivamente un concetto da ricordare e una trappola comune in cui è facile cadere.

Ogni frammento di codice di questo capitolo è stato **compilato ed eseguito** con .NET 10 e con la versione 2.3.0 dei pacchetti ufficiali del C# SDK: puoi quindi copiarlo e incollarlo con fiducia. Dove la versione del pacchetto è rilevante, la indicheremo esplicitamente, perché le API dell'SDK sono in rapida evoluzione.
