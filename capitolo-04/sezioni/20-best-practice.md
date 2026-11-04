## 4.20 Best practice

Il decalogo che raccoglie le indicazioni sparse nel capitolo, in ordine di impatto.

### 4.20.1 Sul contenuto

1. **Scrivi regole verificabili.** «I DTO sono `record` immutabili» è un'istruzione; «scrivi codice pulito» è un desiderio.
2. **Un concetto, un posto.** Ogni regola compare in un solo file. Le copie divergono, sempre.
3. **Il file principale sotto le 150 righe.** Ciò che non è una regola, ma una procedura, va in una skill.
4. **Descrivi il "cosa" e il "quando", non il "come mai".** L'agente ha bisogno di operare, non di essere convinto.

### 4.20.2 Sulla struttura

5. **Una fonte unica, copie generate.** Scrivi in `AGENTS.md` e genera il resto con uno script, con un banner che dice «non modificare a mano».
6. **Standard prima dei formati proprietari.** `AGENTS.md` e `SKILL.md` viaggiano; `applyTo`, `globs` e `paths` no.
7. **Skill per le procedure, istruzioni per le regole, agenti per i permessi.** Se ti accorgi di usare un agente solo per il testo, non ti serve un agente.

### 4.20.3 Sulla sicurezza

8. **Permessi limitati, non promesse.** Un revisore senza `edit` è più affidabile di un revisore a cui è stato *chiesto* di non modificare.
9. **Niente segreti nei file, mai.** Finiscono nel contesto, oltre che in Git.
10. **Versioni fissate e revisione umana.** Plugin come dipendenze: pin, changelog, pull request.

### 4.20.4 Il criterio del "dopo"

Un ultimo criterio, che vale più di tutti gli altri messi insieme: **scrivi pensando alla prossima sessione, non a questa**. La domanda giusta non è «l'agente ha capito adesso?», ma «tra due settimane, senza di me in chat, quali regole gli impediranno di sbagliare?».

Tutto ciò che sopravvive a questa domanda è una buona personalizzazione. Tutto il resto è una conversazione particolarmente riuscita.
