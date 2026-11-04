## 3.21 Best practice e anti-pattern

Come ogni metodo, Spec Kit funziona se usato bene. Raccogliamo le pratiche che fanno la differenza e gli errori in cui è facile cadere.

### 3.21.1 Le best practice

**Una feature, una specifica, un flusso.** Non accumulare più funzionalità in una sola specifica. Una specifica focalizzata è più facile da rivisitare, pianificare e implementare.

**Constitution prima di tutto.** Definisci la constitution **una volta**, con cura, e falla rispettare dai gate. Una constitution vaga è inutile; una constitution chiara è il tuo "standard di qualità" codificato.

**Un comando alla volta, con revisione.** Non incatenare i comandi. Rivedi `spec.md` prima di pianificare, `plan.md` prima di scomporre, `tasks.md` prima di implementare. Il costo della revisione cresce con l'avanzamento.

**Risolvi i `[NEEDS CLARIFICATION]`.** Non lasciarli nella specifica sperando che l'agente "ci arrivi": usa `/speckit-clarify` o correggi a mano. Un requisito ambiguo è un bug in attesa.

**Mantieni la specifica libera dalla tecnologia.** Lo stack appartiene al piano, non alla specifica. Se nella specifica leggi "usa .NET", stai mescolando i livelli: la specifica deve dire *cosa*, il piano *come*.

**Versiona tutto.** Spec, piano, task e constitution sono parte del repository. La tracciabilità è il valore principale del metodo: non buttarla via con i `.gitignore`.

**Itera sulla convergenza.** Non accontentarti del primo `/speckit-converge` se non riporta `Converged`. Il ciclo implement→converge è ciò che garantisce la completezza.

### 3.21.2 Gli anti-pattern

**La specifica "romanzo".** Una specifica di 50 pagine di prosa è tanto inutile quanto l'assenza di specifica. Le sezioni strutturate (user story, FR, SC) esistono per questo: restare concisi e verificabili.

**Saltare i gate.** Ignorare `/speckit-clarify`, `/speckit-checklist` o `/speckit-analyze` "per fare prima" sposta i problemi più avanti, dove costano di più.

**La constitution ipertrofica.** Dieci principi generici ("il codice deve essere di qualità") non aiutano. Pochi principi **verificabili** valgono più di molti principi generici.

**Fidarsi ciecamente dell'agente.** L'agente produce bozze di qualità, ma le decisioni di prodotto sono tue. Rivedi, correggi, approva.

**Ignorare la checklist come gate.** Spuntare le caselle "tanto per" svuota il meccanismo di qualità. La checklist è di proprietà del revisore: usala con onestà.

**Mescolare le feature.** Modificare a mano i task di una feature per includerne un'altra rompe la tracciabilità. Se serve una nuova funzionalità, apri una nuova specifica.

### 3.21.3 La regola d'oro

> La specifica è tua. Spec Kit la struttura, la rende coerente e la porta fino al codice, ma **il contenuto — il cosa e il perché — è responsabilità tua**.

Se tieni fermo questo principio, Spec Kit amplificherà il tuo lavoro; se lo dimentichi, amplificherà i tuoi errori.
