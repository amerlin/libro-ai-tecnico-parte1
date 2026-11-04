## 4.21 Anti-pattern

Gli errori ricorrenti, con il sintomo che li rende riconoscibili e la correzione.

### 4.21.1 La «bibbia» di progetto

**Sintomo.** Il file di istruzioni è cresciuto a 800 righe, contiene la storia del progetto, le decisioni architetturali, tre procedure e un glossario. Le risposte dell'agente peggiorano: ignora regole scritte a metà documento.

**Causa.** Ogni volta che succede qualcosa, si aggiunge una riga invece di chiedersi dove vada.

**Correzione.** Le regole restano; le procedure diventano skill; la storia va in un `docs/adr/`. Un buon esercizio: rileggi il file e per ogni riga chiediti «serve in *ogni* sessione?». Se la risposta è no, non è un'istruzione.

### 4.21.2 La skill invisibile

**Sintomo.** La skill esiste, è ben scritta, ma l'agente non la usa mai.

**Causa.** La `description` descrive il *cosa* e non il *quando*: «Genera changelog» invece di «Usa quando si prepara una release o si chiede cosa è cambiato».

**Correzione.** Riscrivi la descrizione con le parole che useresti tu nella richiesta. Aggiungi i sinonimi che un utente userebbe davvero.

### 4.21.3 L'agente tuttofare

**Sintomo.** Un solo agente con tutti gli strumenti, che «fa tutto». Le revisioni finiscono per modificare file, i piani diventano implementazioni.

**Causa.** La comodità di non dover scegliere.

**Correzione.** Un agente per ruolo, con gli strumenti minimi. Il costo di cambiarli è un clic; il costo di un agente che può fare tutto è che farà la cosa sbagliata al momento sbagliato.

### 4.21.4 Il duplicato silenzioso

**Sintomo.** L'agente applica una regola «a volte»: usa i `record` in un file e le classi in un altro, senza una logica.

**Causa.** La stessa regola esiste in due file con contenuti diversi, e vince quella caricata per ultima.

**Correzione.** La ricerca della sezione 4.12.3. Poi la regola della fonte unica.

### 4.21.5 Il plugin «proviamolo»

**Sintomo.** Un plugin installato per curiosità, che esegue un hook a ogni commit, e settimane dopo nessuno ricorda perché certi comandi falliscano.

**Causa.** I plugin vengono trattati come estensioni del browser, non come dipendenze con privilegi.

**Correzione.** Prova in un repository usa-e-getta o in un container. Installa solo da fonti fidate, con versione fissata e un motivo documentato.

### 4.21.6 La configurazione non versionata

**Sintomo.** Ogni sviluppatore ha il suo `CLAUDE.local.md` che contiene le convenzioni del team. Le regole sono diverse per ognuno, e nessuna è nel repository.

**Causa.** Confondere l'ambito personale con quello di progetto.

**Correzione.** Tutto ciò che il team deve condividere va in un file versionato; nei file locali restano solo i percorsi personali e le preferenze.

### 4.21.7 Il riepilogo degli anti-pattern

| Anti-pattern | Sintomo | Correzione |
| --- | --- | --- |
| Bibbia di progetto | Istruzioni ignorate a metà documento | Regole brevi + skill per le procedure |
| Skill invisibile | Mai attivata | `description` con il *quando* |
| Agente tuttofare | Fa la cosa sbagliata | Un agente per ruolo, strumenti minimi |
| Duplicato silenzioso | Comportamento incoerente | Fonte unica, controllo in CI |
| Plugin «proviamolo» | Effetti collaterali inspiegati | Sandbox, fonti fidate, pin |
| Configurazione non versionata | Regole diverse per persona | Progetto nel repository, personale in locale |
