## 3.12 `/speckit-analyze`: la verifica di coerenza

Prima di implementare, Spec Kit offre un controllo trasversale: `/speckit-analyze` verifica che spec, piano e task siano **coerenti tra loro**.

### 3.12.1 Cosa fa

```text
/speckit-analyze
```

Il comando è **di sola lettura**: non modifica nulla. Esamina `spec.md`, `plan.md` e `tasks.md` e segnala:

- **conflitti** — per esempio un requisito nella specifica che il piano non copre, o due requisiti in contraddizione;
- **gap** — una user story della specifica che non ha task corrispondenti, o un endpoint nel piano senza task;
- **ambiguità** — marcatori `[NEEDS CLARIFICATION]` rimasti irrisolti.

### 3.12.2 Esempi di segnalazioni

Per la nostra feature, l'analisi potrebbe segnalare:

```text
[GAP] FR-004 ("eliminare un task") non ha task associati in tasks.md.
[GAP] L'edge case "data di scadenza nel passato" è nella specifica ma non
      è coperto da alcun requisito di validazione nel piano.
[CONFLITTO] Il piano usa /tasks/{id}/complete ma la specifica menziona
      "marcare come completato" senza specificare il metodo HTTP.
```

### 3.12.3 Cosa fare con le segnalazioni

La regola è netta: **si correggono gli artefatti alla fonte**, non si forza l'implementazione. Se l'analisi trova un gap, aggiorni `tasks.md` (o la specifica, o il piano), poi riesegui `/speckit-analyze` finché non è pulito. Implementare sopra un'analisi sporca è esattamente ciò che il gate vuole evitare.

### 3.12.4 Il posto nel flusso

Nel percorso completo, `/speckit-analyze` viene **dopo** `/speckit-tasks` e **prima** di `/speckit-implement`. È l'ultimo controllo prima che l'agente inizi a scrivere codice: il costo di una correzione qui è minimo, mentre il costo dello stesso errore scoperto dopo l'implementazione è alto.

### 3.12.5 La filosofia

`/speckit-analyze` incarna una convinzione profonda di Spec Kit: gli artefatti (spec, plan, task) non sono documenti separati, ma **viste dello stesso sistema**. Devono restare allineati. Quando un agente genera molto codice in fretta, l'allineamento è la prima cosa a rompersi; un controllo automatico di coerenza è la rete di sicurezza che lo preserva.
