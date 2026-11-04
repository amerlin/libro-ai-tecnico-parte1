## 3.24 Confronti, evoluzione e progetti esistenti

Per usare bene Spec Kit, conviene collocarlo rispetto alle pratiche che già conosci, e sapere come farlo convivere con il codice esistente.

### Confronto con TDD e BDD

```{=latex}
\footnotesize
```

| | TDD | BDD | SDD (Spec Kit) |
|------------|------------|------------|------------|
| Punto di partenza | Un test che fallisce | Un comportamento descritto (Given / When / Then) | Una specifica strutturata |
| Granularità | Classe / metodo | Feature / comportamento | Feature |
| Artefatto centrale | Test | Scenario eseguibile | `spec.md` + `plan.md` + `tasks.md` |
| Verifica della correttezza | Test verdi | Scenari verdi | Test (test-first) |
| Verifica della completezza | Implicita | Implicita | `/speckit-converge` |

```{=latex}
\normalsize
```

I tre approcci **non si escludono**: Spec Kit, anzi, *impone* il test-first nei suoi task, e usa il formato Given/When/Then negli scenari di accettazione. SDD è TDD/BDD "scalato" al livello della feature, con in più una **specifica esplicita** e una **verifica di completezza**.

### Confronto con i design doc tradizionali

Un design doc tradizionale e un `plan.md` di Spec Kit coprono terreni simili, ma differiscono in tre aspetti:

1. **Struttura vincolata.** Il `plan.md` segue un template rigido (Technical Context, Constitution Check, Project Structure), mentre il design doc è in prosa libera. La struttura costante rende i piani confrontabili tra feature.
2. **Tracciabilità.** Il piano Spec Kit è collegato a una specifica (`spec.md`) e genera task (`tasks.md`): è un anello di una catena, non un documento isolato.
3. **Verifica.** Il piano passa da un **gate** (Constitution Check) e da una verifica di coerenza (`/speckit-analyze`), cosa che i design doc tradizionali non hanno.

### Far evolvere una specifica esistente

Il software evolve, e così le specifiche. Spec Kit prevede esplicitamente questo caso: quando una feature cambia (nuovi requisiti, chiarimenti, correzioni), si **aggiorna la specifica** e si ripropaga il cambiamento lungo la catena:

1. modifica `spec.md` (a mano o con l'agente);
2. riallinea `plan.md` se il cambiamento tocca il *come*;
3. rigenera o aggiorna `tasks.md`;
4. riesegui `/speckit-analyze` per verificare la coerenza;
5. implementa e converge.

La regola è: **non modificare mai il codice scavalcando la specifica**. Se il codice cambia, la specifica deve cambiare prima (o insieme): è ciò che mantiene la tracciabilità viva nel tempo.

### Adottare Spec Kit su un progetto esistente

Spec Kit non richiede un progetto nuovo. Su un repository esistente:

1. esegui `specify init . --integration <agente>` per aggiungere la struttura;
2. scrivi una **constitution** che rifletta gli standard già in uso (non imporre principi estranei);
3. parti dalle **nuove feature**: usa il flusso SDD completo per ciò che arriva;
4. per il codice esistente, procedi per gradi: puoi scrivere specifiche "a posteriori" per i moduli critici, o usare il processo di bug fixing per le riparazioni.

L'adozione incrementale è esplicitamente incoraggiata: "inizia con il cambiamento più piccolo che soddisfa le tue esigenze; non devi sostituire l'intero processo".

### Quando (non) usare Spec Kit

Spec Kit brilla per feature **non banali** e per team in cui la revisione delle specifiche ha valore. Per una correzione di una riga o un prototipo usa-e-getta, il flusso completo sarebbe un overhead: in quei casi, il processo di bug fixing o un semplice dialogo con l'agente sono più adatti. La maturità sta nel saper scegliere, non nell'applicare sempre lo stesso processo.
