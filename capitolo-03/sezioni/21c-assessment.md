## 3.23 Il processo di idea assessment

Il terzo processo di Spec Kit risponde a una domanda ancora più a monte: **vale la pena investire su questa idea?** Prima di scrivere specifiche o codice, l'idea assessment raccoglie evidenze per decidere.

### Come si installa

```bash
specify extension add assess
```

L'estensione aggiunge cinque comandi:

```text
/speckit-assess-intake  "Consenti agli utenti di lavorare offline." slug=offline-mode
/speckit-assess-research slug=offline-mode
/speckit-assess-define  slug=offline-mode
/speckit-assess-shape   slug=offline-mode
/speckit-assess-decide  slug=offline-mode
```

### Le cinque fasi

1. **Intake** — raccoglie l'idea e ne definisce i confini.
2. **Research** — raccoglie evidenze: fattibilità tecnica, alternative esistenti, rischi.
3. **Define** — definisce il problema e il valore atteso in modo chiaro.
4. **Shape** — delinea le opzioni di soluzione e il loro costo.
5. **Decide** — produce la decisione finale.

### La decisione

La decisione è espressa in tre esiti netti:

| Decisione | Significato |
|-----------|-------------|
| `go` | L'idea merita investimento: si procede |
| `needs-clarification` | Mancano informazioni: si torna a ricercare |
| `kill` | L'idea non merita investimento: si ferma (documentando il perché) |

Gli artefatti finiscono in `.specify/assessments/<slug>/`, con un `decision.md` finale. Se la decisione è `go`, il **riepilogo** di `decision.md` diventa l'input di `/speckit-specify`: l'idea valutata si trasforma in una specifica da costruire.

### Un esempio (concettuale)

```text
/speckit-assess-intake "Un sistema di cache distribuita per le nostre API."
slug=distributed-cache
```

Le fasi di ricerca e definizione potrebbero scoprire che il 90% delle API ha un carico modesto e che una cache in-process con Redis opzionale basterebbe. La decisione potrebbe essere `go` con ambito ridotto, oppure `kill` se il costo supera il beneficio. Il punto è che la decisione è **documentata ed evidenza-based**, non basata sull'intuizione del momento.

### Il valore dell'assessment

In un mondo in cui generare codice è diventato economico, il **costo di perseguire l'idea sbagliata** domina. L'idea assessment sposta la riflessione ("è davvero una buona idea?") prima dell'investimento, dove è più produttiva. Fermare un'idea con una motivazione documentata è, in Spec Kit, un **risultato utile** tanto quanto un `go`.
