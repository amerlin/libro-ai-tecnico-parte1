## 5.17 Checklist, glossario e anti-pattern

Una migrazione efficace è una sequenza di decisioni verificabili. Le checklist che seguono non sostituiscono il giudizio del team: aiutano a non dimenticare dipendenze e criteri prima di una fase irreversibile.

### 5.17.1 Checklist di assessment

- [ ] Sono stati identificati owner funzionali e tecnici per ogni capacità?
- [ ] Sono state inventariate route, job, consumer, webhook e strumenti amministrativi?
- [ ] Sono noti database, writer, volumi, vincoli e consumer dello schema?
- [ ] Sono state elencate integrazioni, librerie, licenze e dipendenze non supportate?
- [ ] Esistono baseline di latenza, throughput, errori, disponibilità e costi?
- [ ] Sono documentati RTO, RPO, retention e requisiti di sicurezza?
- [ ] I comportamenti impliciti e i casi limite sono stati verificati con client reali o test?
- [ ] Le incertezze sono attività con owner, evidenza attesa e scadenza?

### 5.17.2 Checklist di progettazione

- [ ] La strategia (big bang, componenti, strangler o ibrida) è motivata dal rischio?
- [ ] Ogni unità migrabile ha un confine e un proprietario dei dati?
- [ ] È definito come instradare traffico e come disattivare il nuovo percorso?
- [ ] I contratti API/dati hanno versioni, esempi e test?
- [ ] Il modello di autenticazione e la migrazione delle sessioni sono approvati?
- [ ] Le modifiche schema sono compatibili e il rollback è possibile?
- [ ] Sono stati definiti timeout, retry, idempotenza e cancellazione?
- [ ] Le differenze intenzionali rispetto alla sorgente sono state approvate?

### 5.17.3 Checklist prima del cutover

- [ ] Build, test, scansioni e pubblicazione passano da checkout pulito.
- [ ] Il target è stato avviato in un ambiente simile alla produzione.
- [ ] Test di caratterizzazione e differenziali non hanno differenze critiche.
- [ ] Sono verificati status, JSON, date, autorizzazioni, paginazione e limiti.
- [ ] Dashboard, alert, log strutturati e correlation id funzionano.
- [ ] Health check e shutdown sono provati con il load balancer.
- [ ] Backup e restore sono stati testati; lo schema è compatibile con rollback.
- [ ] Runbook identifica responsabili, soglie, canali e comandi di ritorno.
- [ ] Il canary ha una durata, percentuale e criterio per proseguire.
- [ ] Le operazioni di scrittura non vengono replicate senza idempotenza.

### 5.17.4 Checklist per la dismissione

- [ ] Non esiste traffico, job, webhook o client che dipenda ancora dalla sorgente.
- [ ] I dati sono riconciliati e la retention dei backup è approvata.
- [ ] Credenziali, chiavi e route obsolete sono revocate.
- [ ] Le dipendenze residue e la coesistenza hanno owner o data di rimozione.
- [ ] Runbook, supporto e dashboard sono aggiornati sul sistema definitivo.
- [ ] Costi e risorse del sistema precedente sono stati rimossi o motivati.

### 5.17.5 Glossario essenziale

| Termine | Significato nel capitolo |
|---|---|
| Assessment | Raccolta di evidenze sul sistema, i suoi contratti, vincoli e rischi |
| Baseline | Misure del sistema sorgente usate per confrontare il target |
| Cutover | Passaggio del traffico o della proprietà di una capacità al target |
| Strangler | Strategia che sostituisce un sistema per capacità, mantenendo temporaneamente l'originale |
| Canary | Rilascio progressivo a una parte del traffico prima dell'estensione |
| Parità funzionale | Equivalenza del comportamento osservabile per i flussi concordati |
| Idempotenza | Proprietà per cui ripetere un'operazione non duplica l'effetto |
| Outbox | Registro transazionale degli eventi da consegnare dopo il commit |
| RTO/RPO | Obiettivo di tempo di ripristino e perdita dati massima accettabile |
| Expand–migrate–contract | Evoluzione graduale di schema e codice mantenendo compatibilità temporanea |

### 5.17.6 Gli errori da evitare

1. **Riscrivere senza caratterizzare.** Il team si affida a ricordi e documenti incompleti; i test sul comportamento esistente vanno creati prima del cutover.
2. **Confondere parità e miglioramento.** Cambiare contratto, dati e architettura nello stesso rilascio rende impossibile isolare le cause delle regressioni.
3. **Tradurre i nomi invece delle responsabilità.** Un middleware o un service container con nome simile può avere lifecycle diverso; verificare semantica e scope.
4. **Ignorare il database condiviso.** Le tabelle possono essere un contratto di altri servizi; identificare tutti i writer e reader prima di migrare.
5. **Duplicare scritture senza protocollo.** Due sistemi non sono sincronizzati perché entrambi hanno ricevuto una chiamata; progettare idempotenza e riconciliazione.
6. **Confondere rollback applicativo e rollback dati.** La versione precedente può non interpretare i dati scritti dalla nuova.
7. **Ottimizzare prima di misurare.** AOT, cache o parallelismo aumentano complessità se il collo di bottiglia è altrove.
8. **Considerare test unitari come prova di produzione.** Database, proxy, identity e container richiedono test d'integrazione mirati.
9. **Lasciare la coesistenza senza data di uscita.** Il doppio sistema raddoppia costi e superficie di rischio; assegnare owner e milestone di dismissione.
10. **Fare del cutover una scommessa.** Soglie, responsabilità e rollback devono essere definiti e provati prima che il traffico venga spostato.

## 5.18 Appendice: piano di migrazione riutilizzabile

Il seguente schema può essere copiato nel backlog di un progetto e adattato. Ogni riga deve avere owner, data, evidenza e stato; non lasciare caselle spuntate sulla sola base di una dichiarazione.

| Fase | Deliverable | Criterio di completamento |
|---|---|---|
| Discovery | Inventario, baseline, rischi e contratti | Owner e dipendenze identificati; lacune tracciate |
| Foundation | Repo, SDK, CI, ambiente, logging | Build pulita, deploy e health check provati |
| Caratterizzazione | Fixture e test sorgente | Flussi critici riproducibili e approvati |
| Vertical slice | Endpoint target completo | HTTP, dominio, storage e test passano |
| Parità | Confronto sorgente/target | Differenze critiche risolte o approvate |
| Canary | Traffico controllato | Soglie rispettate per la finestra concordata |
| Cutover | Ownership e routing aggiornati | Target proprietario; rollback ancora possibile |
| Stabilizzazione | Runbook e supporto | Incidenti e metriche entro obiettivi |
| Dismissione | Sistema sorgente spento | Traffico nullo, accessi revocati, dati conservati |

Per ogni capacità, annotare un punteggio qualitativo di rischio (basso/medio/alto) e le evidenze: non sommare numeri senza significato. Se il criterio non è raggiunto, la decisione corretta può essere fermarsi e ridurre l'incertezza, non accelerare il rilascio.
