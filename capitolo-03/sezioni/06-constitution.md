## 3.6 La Constitution: i principi del progetto

La **constitution** è la base di tutto: un insieme di principi che governano il modo in cui le specifiche diventano codice. Vive in `.specify/memory/constitution.md` e viene letta dai comandi di piano e implementazione, che devono **conformarsi** ad essa.

### 3.6.1 Cosa contiene

Il template della constitution definisce una struttura chiara:

```markdown
# [Nome progetto] Constitution

## Core Principles
### I. [Nome principio]
[Descrizione]

### II. [Nome principio]
[Descrizione]
...

## [Sezione aggiuntiva, es. Security Requirements]
[Contenuto]

## [Sezione aggiuntiva, es. Development Workflow]
[Contenuto]

## Governance
[Regole di governo: la constitution prevale sulle altre pratiche, ecc.]

**Version**: ... | **Ratified**: ... | **Last Amended**: ...
```

I **Core Principles** sono articoli numerati; le sezioni aggiuntive coprono vincoli specifici (sicurezza, performance, workflow); la sezione **Governance** stabilisce come si modifica la constitution e che essa prevale sulle altre pratiche.

### 3.6.2 Un esempio per un progetto .NET

Ecco una constitution realistica per il nostro progetto di esempio (la vedremo applicata nel resto del capitolo):

```markdown
# Taskify Constitution

## Core Principles

### I. Test-First (NON NEGOZIABILE)
TDD obbligatorio: i test si scrivono prima dell'implementazione,
devono fallire, e solo dopo si implementa (Red-Green-Refactor).

### II. Semplicità
Parti dalla soluzione più semplice. Niente astrazioni speculative:
introduci un'astrazione solo quando serve davvero (YAGNI).

### III. Validazione degli input
Ogni input esterno deve essere validato e restituire errori chiari.
Nessuna eccezione non gestita verso il chiamante.

### IV. API REST coerenti
Gli endpoint usano JSON, verbi HTTP corretti e codici di stato
semantici. Le risorse sono al plurale (/tasks).
Per una transizione di dominio modellata come comando esplicito, è
ammesso un endpoint `POST` dedicato (per esempio `/tasks/{id}/complete`),
purché il piano ne motivi la scelta e ne documenti gli effetti.

## Security Requirements
- Nessun segreto nel codice o nei file di configurazione versionati.
- Le operazioni distruttive richiedono conferma esplicita.

## Development Workflow
- Ogni feature passa da specifica, piano e task prima del codice.
- Le modifiche sono riviste tramite pull request.

## Governance
La constitution prevale sulle altre pratiche. Può essere emendata, ma le
modifiche richiedono documentazione, approvazione e un piano di migrazione;
gli emendamenti sono versionati e aggiornano le date indicate in calce.

**Version**: 1.0.0 | **Ratified**: 2026-01-15 | **Last Amended**: 2026-01-15
```

### 3.6.3 Come viene usata

La constitution non è un documento ornamentale. Durante il piano, il comando `/speckit-plan` esegue un **Constitution Check**: una lista di gate che il piano deve superare prima di procedere. Per esempio, con la constitution sopra, il piano dovrà dimostrare:

- che i test sono previsti **prima** dell'implementazione (Test-First);
- che l'architettura scelta è la più **semplice** (niente microservizi se basta una Minimal API);
- che la **validazione** degli input è prevista;
- che le API seguono le **convenzioni REST** dichiarate.

Se il piano viola un principio (per esempio introduce un'astrazione ingiustificata), deve **giustificarlo** esplicitamente nella sezione "Complexity Tracking", oppure semplificare.

### 3.6.4 La creazione con `/speckit-constitution`

Il comando si invoca **una volta per progetto**, con una descrizione dei principi voluti:

```text
/speckit-constitution Taskify è un progetto "security-first": tutti gli input
vanno validati. Usiamo una Minimal API .NET con SQLite. I test sono obbligatori
e vanno scritti prima del codice.
```

L'agente produce (o aggiorna) `.specify/memory/constitution.md` traducendo la descrizione in principi strutturati. Puoi poi **modificarla a mano**: è un normale file Markdown versionato.

### 3.6.5 Perché è potente

La constitution è ciò che rende il comportamento dell'agente **coerente nel tempo e tra i membri del team**. Senza di essa, ogni feature potrebbe essere implementata con scelte diverse; con essa, tutte le feature rispettano gli stessi principi, e le violazioni devono essere esplicite e motivate. In un'organizzazione, è il modo per codificare gli standard architetturali e farli rispettare — non per buona volontà, ma per **gate**.
