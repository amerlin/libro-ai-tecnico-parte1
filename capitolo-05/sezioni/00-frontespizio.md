---
title: "Quaderno AI"
subtitle: "Concetti, strumenti e percorsi pratici per lo sviluppo software con AI"
author: "Andrea Merlin"
date: "Numero 1 - Novembre 2026"
lang: it
---

# Capitolo 5
## Migrare a .NET da altri linguaggi e piattaforme

**Abstract.** Migrare un'applicazione non significa riscrivere ogni riga cambiando sintassi. Significa trasferire in un nuovo ecosistema un insieme di comportamenti, dati, contratti, vincoli operativi e aspettative degli utenti, riducendo il rischio di interrompere il servizio. Questo capitolo guida chi conosce già PHP, Python, JavaScript/Node.js, Java o un altro stack attraverso il passaggio a .NET moderno e ASP.NET Core. Partiremo dall'assessment del sistema esistente e confronteremo le strategie di migrazione; poi costruiremo una mappa dei concetti, esploreremo hosting, pipeline HTTP, Dependency Injection, dati, sicurezza, test, prestazioni e deployment. Un caso pratico mostrerà come migrare un servizio per passi, mantenendo compatibili i client e predisponendo rollback e osservabilità. L'obiettivo non è dichiarare un framework universalmente migliore, ma fornire un metodo verificabile per scegliere cosa trasferire, cosa adattare e cosa lasciare temporaneamente nel sistema originale.

### Cosa imparerai in questo capitolo

Al termine saprai:

- distinguere una migrazione tecnologica da una riscrittura funzionale e raccogliere le informazioni necessarie prima di stimare il lavoro;
- confrontare PHP, Python, Node.js e Java con C# e .NET senza confondere analogie utili con equivalenze perfette;
- scegliere tra riscrittura completa, migrazione per moduli e sostituzione incrementale con il pattern *strangler*;
- creare e organizzare un servizio ASP.NET Core, capire il ruolo dell'host, di Kestrel e di `Program.cs`;
- trasferire route, middleware, validazione, error handling, configurazione e stato;
- pianificare schema, migrazioni e dati con Entity Framework Core mantenendo le compatibilità necessarie;
- migrare autenticazione, autorizzazioni e segreti senza abbassare il livello di protezione;
- costruire test che descrivano il comportamento attuale e verificare la parità funzionale;
- misurare prestazioni, integrare CI/CD, distribuire in container e preparare rollout e rollback;
- usare checklist e criteri di uscita per dimostrare che la migrazione è pronta.

### Prerequisiti

- Conoscenza di base di almeno un linguaggio e framework di sviluppo.
- Familiarità con HTTP, API, database relazionali, test automatici e controllo versione.
- Un SDK .NET 10 installato per eseguire gli esempi. Non è richiesta esperienza precedente con C# o ASP.NET Core.

### Convenzioni

- I comandi sono mostrati in forma multipiattaforma con `dotnet`; i frammenti di shell possono richiedere piccoli adattamenti in PowerShell.
- Il riferimento è .NET 10, salvo indicazione diversa. Le API e i template possono variare tra versioni: verificare sempre il target dichiarato nel `.csproj`.
- Gli esempi sono didattici: prima di usarli in produzione occorre adattare autenticazione, segreti, storage, log e policy operative.
- “Sistema sorgente” indica l'applicazione da cui si migra; “sistema target” indica quella realizzata con .NET. “Cutover” indica il passaggio del traffico al target.

### Indice concettuale

1. Perché migrare e come valutare il progetto
2. Mappare linguaggi, runtime e strumenti
3. Pianificare una migrazione controllata
4. Architettura e organizzazione del codice
5. Richieste HTTP e pipeline
6. Configurazione, stato e dipendenze
7. Dati e integrazione con i sistemi esistenti
8. Sicurezza e identità
9. Testing e qualità
10. Prestazioni e comportamento del runtime
11. Container, CI/CD e produzione
12. Caso pratico: migrare un servizio catalogo
13. Approfondire la mappa dai principali ecosistemi
14. Prove di migrazione dei dati: runbook e controlli
15. Diagnosi operativa durante la migrazione
16. Verifica finale, criteri di successo e fonti ufficiali
17. Checklist, glossario e anti-pattern
18. Appendice: piano di migrazione riutilizzabile
