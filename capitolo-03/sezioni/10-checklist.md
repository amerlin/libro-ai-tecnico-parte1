## 3.10 `/speckit-checklist`: i gate di qualità della specifica

Prima di scomporre il lavoro, Spec Kit offre un controllo di qualità dedicato alla specifica: `/speckit-checklist`. È il modo per assicurarsi che i requisiti siano **completi, chiari e coerenti** prima di impegnarsi nell'implementazione.

### 3.10.1 Cosa fa

```text
/speckit-checklist
```

Il comando genera una checklist aggiuntiva e mirata al controllo richiesto (per esempio `checklists/api-quality.md`), distinta dalla checklist dei requisiti prodotta dai comandi di specifica. È una sorta di "unit test per i requisiti" e resta **di proprietà del revisore** (reviewer-owned): le caselle vanno spuntate `[x]` solo quando un revisore (umano o agente, ma esplicitamente in veste di revisore) stabilisce che il criterio è soddisfatto.

> **Importante.** Spuntare una voce della checklist **non** significa che l'implementazione è completa: significa che il *requisito* ha superato il controllo di qualità. L'implementazione è tracciata altrove (in `tasks.md`).

### 3.10.2 Un esempio di checklist

Per la nostra feature, una checklist aggiuntiva di qualità dell'API potrebbe contenere voci come:

```markdown
# API Quality Checklist

## Completezza
- [ ] Ogni user story ha priorità, test indipendente e scenari di accettazione
- [ ] Tutti i requisiti funzionali sono numerati (FR-xxx)
- [ ] Tutti gli edge case rilevanti sono elencati

## Chiarezza
- [ ] Nessun requisito usa un linguaggio ambiguo ("veloce", "robusto")
- [ ] Ogni requisito è verificabile in modo oggettivo
- [ ] Nessun dettaglio implementativo nella specifica

## Coerenza
- [ ] I criteri di successo sono misurabili (SC-xxx)
- [ ] Le entità chiave coprono i dati menzionati dalle story
- [ ] Non ci sono contraddizioni tra story e requisiti
```

### 3.10.3 Chi mantiene cosa

Spec Kit distingue la checklist di requisiti generata nel flusso di specifica dalle checklist aggiuntive:

- **`checklists/requirements.md`** — prodotta da `/speckit-specify` e aggiornata da `/speckit-clarify`; è il gate letto da `/speckit-implement`.
- **checklist aggiuntive** — generate da `/speckit-checklist` per un ambito specifico, con un nome distinto (per esempio `checklists/api-quality.md`), e di proprietà del revisore.

### 3.10.4 Il gate in `/speckit-implement`

La checklist non è fine a se stessa: quando esegui `/speckit-implement`, il comando **legge lo stato delle caselle** e, se trova voci non spuntate, **chiede** prima di procedere. È un semaforo: se la specifica non ha superato il controllo, non si costruisce sopra una base incerta.

### 3.10.5 Il valore

In un flusso classico, i problemi di requisiti emergono durante lo sviluppo o, peggio, in produzione. Con la checklist, emergono **prima di scrivere una riga di codice**, quando correggerli costa quasi nulla. È lo stesso principio dei test automatici, applicato ai requisiti.
