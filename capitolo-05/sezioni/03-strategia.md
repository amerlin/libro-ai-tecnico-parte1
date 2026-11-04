## 5.3 Pianificare una migrazione controllata

Scelta la direzione, bisogna decidere come raggiungerla. La strategia influenza tempi, costi, possibilità di rollback, coordinamento tra team e probabilità di mantenere il servizio disponibile. Non esiste una tecnica universalmente corretta: la decisione dipende dai confini funzionali, dalle dipendenze condivise, dalle capacità di test e dai vincoli del business.

### 5.3.1 Tre strategie, non due

**Riscrittura completa (big bang).** Il sistema viene ricostruito in un ramo o ambiente separato e sostituito in un'unica data. È semplice da spiegare, ma raramente semplice da eseguire: per molto tempo due implementazioni divergono e il team scopre tardi differenze nei dati e nei comportamenti. Ha senso solo con superficie contenuta, confini chiari, test affidabili, breve durata e un cutover reversibile. Un lungo congelamento funzionale può ridurre la divergenza, ma comporta costi di business.

**Migrazione per componenti.** Si selezionano servizi o moduli autonomi e li si migra in sequenza. Riduce il perimetro di ogni rilascio, a condizione che i confini siano reali. Un modulo solo nominalmente separato ma accoppiato a tabelle condivise, sessioni o chiamate interne non è necessariamente una buona unità di migrazione.

**Sostituzione incrementale (*strangler*).** Un router, gateway o livello di ingresso dirige alcune capacità verso il sistema nuovo e mantiene le restanti sul sistema originale. Le funzionalità vengono spostate progressivamente; alla fine si rimuove il vecchio sistema. Consente feedback reale e rollback selettivo, ma richiede di gestire coesistenza, identità, osservabilità e contratti tra i due lati. Non è sinonimo di riscrittura in microservizi.

| Strategia | Rischio concentrato | Vantaggio | Condizione che la rende praticabile |
|---|---|---|---|
| Big bang | Cutover e regressioni aggregate | Confine di transizione semplice | Sistema piccolo e test completo |
| Per componenti | Integrazione tra moduli | Progressi e rollback per unità | Confini e ownership chiari |
| Strangler | Coesistenza e routing | Migrazione graduale in produzione | Ingresso instradabile e contratti stabili |

Una strategia ibrida è frequente: si crea un nuovo edge applicativo, si migrano prima funzionalità isolate, si sostituiscono poi i flussi con dipendenze più forti e si pianifica una finestra di cutover per elementi non separabili.

### 5.3.2 Scegliere la prima capacità

La prima funzionalità migrata non deve essere né un semplice endpoint senza valore, né il flusso più critico dell'azienda. È preferibile una capacità rappresentativa ma reversibile: possiede un contratto comprensibile, ha dipendenze sotto controllo e permette di esercitare build, deploy, logging, test e routing.

Valutare ogni candidato considerando valore, rischio, dipendenze, volume di traffico e facilità di verifica. Un indice sintetico può aiutare a confrontare opzioni, ma non deve sostituire la discussione: un punteggio numerico non elimina l'incertezza. Il team dovrebbe poter spiegare perché una capacità è pronta e quali evidenze mancano.

Prima di spostare il traffico occorre sapere come il router identifica la funzionalità: prefisso di route, host, tenant, feature flag o regola di gateway. Se la decisione dipende da un flag, deve essere possibile disabilitarlo rapidamente senza ricompilare o perdere tracciabilità delle modifiche. Un flag che resta indefinitamente nel codice non è un piano di migrazione.

### 5.3.3 Compatibilità durante la coesistenza

Due sistemi attivi contemporaneamente possono leggere e scrivere lo stesso dato. Le letture sono spesso più facili da spostare; le scritture richiedono un proprietario chiaro. Scrivere su due database indipendenti in sequenza non crea una transazione atomica: una scrittura può riuscire e l'altra fallire. La doppia scrittura non va introdotta come soluzione rapida senza un protocollo di riconciliazione, idempotenza e gestione dei conflitti.

Le alternative dipendono dal dominio:

- un solo sistema possiede temporaneamente la scrittura; l'altro legge dati replicati;
- si trasferisce la proprietà per entità o gruppo, con un registro di ownership;
- si usa un outbox transazionale per pubblicare cambiamenti dopo il commit;
- si effettua una migrazione con snapshot iniziale e sincronizzazione incrementale.

Ogni opzione ha costi e failure mode. L'outbox evita di perdere l'intenzione di pubblicare un evento nella stessa transazione locale, ma non rende atomici database diversi e consumer. La consegna può essere ripetuta; i consumer devono essere idempotenti. In tutte le opzioni vanno definiti conflitti, retry, deduplicazione e procedura di riconciliazione.

Anche i contratti devono evolvere con compatibilità. Aggiungere un campo opzionale è spesso più sicuro che rinominare o cambiare il tipo di uno esistente; tuttavia il client potrebbe rifiutare campi sconosciuti o interpretare diversamente un default. Versionamento e compatibilità vanno provati contro i client reali o le loro specifiche.

### 5.3.4 Fasi con condizioni di uscita

Una sequenza utile è:

1. **Discovery:** inventario, baseline, dipendenze e rischi approvati.
2. **Foundation:** SDK/CI, hosting, log, configurazione, sicurezza e deploy vuoto verificati.
3. **Caratterizzazione:** contratti ed esempi rappresentativi fissati nei test.
4. **Vertical slice:** un flusso completo attraversa HTTP, dominio, persistenza, test e produzione non critica.
5. **Migrazione per capacità:** ogni unità ha criteri d'accettazione, osservazione e rollback.
6. **Cutover:** traffico spostato con una finestra e responsabili espliciti.
7. **Stabilizzazione e rimozione:** dati riconciliati, dipendenze eliminate, vecchio sistema dismesso e costi ridotti.

Le fasi possono sovrapporsi, ma le condizioni d'uscita devono essere esplicite. Per esempio, la foundation non è completata se esiste soltanto un Dockerfile: bisogna dimostrare che l'immagine gira nell'ambiente previsto, riceve configurazione esterna, espone health check e termina correttamente.

### 5.3.5 Cutover e rollback

Il cutover va trattato come un'operazione controllata, non come una modifica improvvisata al load balancer. Il piano include orario, responsabile della decisione, metriche da osservare, soglie d'arresto, canali di comunicazione, ownership dei dati e comandi di ritorno.

Un rollback tecnico non annulla automaticamente le scritture già fatte dal nuovo sistema. Se lo schema o il formato dati non sono leggibili dal vecchio sistema, tornare indietro può richiedere restore, replay o riconciliazione. Applicare migrazioni database compatibili in più passi: espandere lo schema, distribuire codice che supporta entrambi i formati, migrare i dati, poi rimuovere gli elementi obsoleti solo quando il rollback non li richiede più.

Provare il rollback prima del cutover. Registrare durata, autorizzazioni necessarie, effetti sui dati e segnali che confermano che il traffico è tornato sul vecchio percorso. Un piano non provato è un'ipotesi.

### 5.3.6 Organizzazione e dipendenze

La migrazione richiede decisioni condivise tra sviluppo, piattaforma, sicurezza, database, supporto e product owner. Stabilire chi approva un contratto, chi controlla le metriche e chi può fermare il rollout. Esplicitare le dipendenze tra attività, evitando che più team cambino lo stesso schema o endpoint senza coordinamento.

Il backlog deve distinguere lavoro di migrazione, correzioni necessarie per la parità e nuove funzionalità. Questa separazione rende visibile il costo e impedisce che una funzionalità aggiunta a metà diventi la ragione per rinviare la dismissione. Ogni milestone dovrebbe produrre un incremento funzionante e una decisione informata sul passo successivo.
