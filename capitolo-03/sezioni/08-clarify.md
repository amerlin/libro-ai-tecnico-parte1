## 3.8 `/speckit-clarify`: risolvere le ambiguità

Dopo la specifica, quasi sempre restano punti oscuri. Il comando `/speckit-clarify` li affronta sistematicamente, prima che diventino decisioni arbitrarie (o bug) in fase di implementazione.

### 3.8.1 Cosa fa

```text
/speckit-clarify Concentrati sul comportamento dei task: validazione del titolo,
gestione degli id inesistenti e semantica del filtro per stato.
```

Il comando:

1. esamina `spec.md` alla ricerca di ambiguità e punti deboli;
2. **pone domande** all'utente (una alla volta, con opzioni o risposte libere);
3. aggiorna `spec.md` con le risposte;
4. aggiorna la checklist dei requisiti in `checklists/requirements.md`.

È un dialogo, non un comando "one-shot": l'agente fa domande, tu rispondi, e la specifica si affina.

### 3.8.2 Il marcatore `[NEEDS CLARIFICATION]`

Il template di specifica prevede di marcare esplicitamente ciò che non è stato specificato. Per esempio:

```markdown
- **FR-006**: Il sistema DEVE autenticare gli utenti tramite
  [NEEDS CLARIFICATION: metodo non specificato — email/password, SSO, OAuth?]
```

`/speckit-clarify` è il momento in cui questi marcatori vengono **risolti**: la domanda viene posta, la risposta sostituisce il marcatore. L'alternativa — lasciare che l'agente inventi una risposta plausibile — è esattamente ciò che il metodo vuole evitare.

### 3.8.3 Esempi di domande per la nostra feature

Per la Task Manager API, domande tipiche di chiarimento:

- "Il titolo deve avere un limite di lunghezza? Se sì, quale?"
- "La data di scadenza può essere nel passato?"
- "Il filtro per stato accetta solo `open`/`completed`, o anche valori parziali?"
- "L'eliminazione deve essere fisica (record rimosso) o logica (soft delete)?"
- "Serve una data di completamento registrata quando un task viene completato?"

Ogni risposta si traduce in un requisito aggiornato o in una nuova voce nella sezione Edge Cases/Requirements.

### 3.8.4 Quando usarlo

- **Sempre** nel percorso completo (per feature di produzione);
- per feature piccole e ben definite si può saltare, come previsto dal percorso breve;
- in ogni caso, se la specifica contiene `[NEEDS CLARIFICATION]` irrisolti, è un segnale che serve un giro di chiarimento.

### 3.8.5 Il valore per il team

`/speckit-clarify` sposta le decisioni di prodotto **dove costano meno**: prima di pianificare e molto prima di scrivere codice. Una domanda risolta nella specifica vale dieci correzioni in code review. E poiché le risposte finiscono nel `spec.md` versionato, restano documentate per chiunque rilegga la feature in futuro.
