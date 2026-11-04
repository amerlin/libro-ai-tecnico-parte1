---
title: "Quaderno AI"
subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"
author: "Andrea Merlin"
date: "Numero 1 - Novembre 2026"
lang: it
---

# Capitolo 3
## GitHub Spec Kit: sviluppo guidato dalle specifiche con esempi in C\#

**Abstract.** Nei primi due capitoli abbiamo costruito software "a mano": scrivevamo il codice e, al massimo, lo descrivevamo mentre lo producevamo. Esiste però un approccio diverso e sempre più diffuso: **capovolgere la piramide** e partire dalla *specifica* — il *cosa* e il *perché* — per poi derivare piano, task e codice in modo strutturato. **GitHub Spec Kit** è il toolkit open source che rende questo approccio concreto per gli agenti di codifica AI. In questo capitolo capiremo come funziona, ne esploreremo comandi, template e meccanismi, e lo applicheremo per intero a una feature reale in **C# e .NET 10**.

### Cosa imparerai in questo capitolo

Al termine della lettura e della pratica saprai:

- spiegare cos'è lo **spec-driven development** e perché inverte il rapporto tradizionale tra specifica e codice;
- installare Spec Kit (CLI `specify` + integrazione con GitHub Copilot o altri agenti);
- orientarti nella struttura di un progetto Spec Kit (`.specify/`, `specs/`, template, file di stato);
- usare il **workflow completo**: constitution, specify, clarify, plan, checklist, tasks, analyze, implement, polish e converge;
- leggere e compilare i **template ufficiali** (spec, plan, tasks, checklist, constitution);
- applicare l'intero flusso a una feature **C#** (una Minimal API ASP.NET Core con EF Core), dalla specifica al codice funzionante;
- integrare Spec Kit con **VS Code e Copilot** e automatizzare i controlli in **CI/CD**;
- riconoscere le **best practice** e gli errori comuni.

### Prerequisiti

- .NET SDK 10 e un editor (VS Code con GitHub Copilot, oppure un altro agente supportato);
- Python 3.11+ e `uv` per installare il CLI (vedremo come);
- familiarità con C# e ASP.NET Core (per l'esempio pratico);
- nessuna conoscenza pregressa di Spec Kit: è l'oggetto di questo capitolo.

### Una nota sulla versione

Spec Kit è in rapida evoluzione: i nomi dei comandi, i percorsi e i template cambiano tra una versione e l'altra. Questo capitolo usa gli esempi di comando con trattino (`/speckit-specify`, `/speckit-plan`) e descrive la directory `specs/` per le feature e lo stato in `.specify/feature.json`. La sintassi effettivamente invocabile dipende dall'agente e dalle skill generate dall'integrazione: fai riferimento ai comandi presenti nel progetto, senza dedurre dalla punteggiatura che una forma sia necessariamente obsoleta.
