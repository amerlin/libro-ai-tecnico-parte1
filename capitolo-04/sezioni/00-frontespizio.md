---
title: "Quaderno AI"
subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"
author: "Andrea Merlin"
date: "Numero 1 - Novembre 2026"
lang: it
---

# Capitolo 4
## Istruzioni, skill, agenti e plugin: estendere un agente di codifica

**Abstract.** Nei primi tre capitoli abbiamo costruito server MCP e applicato un flusso di sviluppo guidato dalle specifiche. In entrambi i casi l'agente era "di passaggio": gli davamo un protocollo o una specifica e lui lavorava. Ma un agente che lavora ogni giorno sullo stesso repository ha un problema diverso: **dimentica**. Ogni sessione riparte da zero, e ogni volta dobbiamo ripetere le stesse regole, gli stessi comandi, le stesse procedure. Questo capitolo spiega i quattro strumenti con cui si risolve il problema — **istruzioni**, **skill**, **agenti** e **plugin** — e, soprattutto, **dove vanno messi i file** nei motori più diffusi: GitHub Copilot in VS Code, Claude Code, Cursor, Gemini CLI, Codex e l'ecosistema DeepSeek. Vedremo cosa è standard, cosa è specifico di un motore e come scrivere una volta sola ciò che vale per tutti.

### Cosa imparerai in questo capitolo

Al termine della lettura e della pratica saprai:

- distinguere **istruzioni**, **skill**, **agenti** e **plugin**, e scegliere lo strumento giusto per ogni esigenza;
- spiegare la differenza tra contenuto **sempre in contesto**, **caricato su richiesta** ed **eseguito in contesto isolato**;
- scrivere un file di istruzioni con attivazione per pattern (`applyTo`/`globs`) senza appesantire il contesto;
- scrivere una **skill** conforme allo standard Agent Skills (`SKILL.md` più risorse);
- definire un **agente** con tool limitati, e usarlo anche come subagente;
- impacchettare una **skill**, un agente e un server MCP in un **plugin** distribuibile;
- orientarti nelle cartelle dei motori: `.github/`, `.claude/`, `.cursor/`, `.gemini/`, `.codex/`, `~/.copilot/`, `~/.claude/`;
- capire perché **DeepSeek** non ha un formato proprietario di istruzioni e come si usa come motore;
- prevedere **precedenze e conflitti** quando più file dicono cose diverse;
- mettere in sicurezza istruzioni, skill e plugin, che sono a tutti gli effetti codice eseguito sulla tua macchina.

### Prerequisiti

- Aver letto (o padroneggiare) il Capitolo 1: in particolare la distinzione tra host, client e server;
- un agente di codifica installato: VS Code con GitHub Copilot, Claude Code, Cursor, Gemini CLI o Codex;
- familiarità con il formato Markdown e con lo YAML di frontmatter;
- nessuna conoscenza pregressa di skill o plugin: è l'oggetto di questo capitolo.

### Convenzioni

Valgono le convenzioni dei capitoli precedenti. In più:

- **`~`** indica la cartella home dell'utente (`C:\Users\nome` su Windows, `/home/nome` su Linux e macOS).
- **Ambito**: *utente* significa visibile in tutti i progetti; *progetto* (o *workspace*) significa versionato nel repository e condiviso col team.
- I nomi dei file sono quelli documentati al momento della scrittura. Questi formati evolvono in fretta: dove un dettaglio può cambiare lo segnaliamo, e in ogni caso la fonte autorevole è sempre la documentazione del motore che stai usando.
