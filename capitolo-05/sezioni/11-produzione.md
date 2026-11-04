## 5.11 Container, CI/CD e produzione

La migrazione termina quando il sistema è esercibile dal team che lo mantiene: build riproducibile, artifact identificabile, configurazione esterna, deploy osservabile, rollback eseguibile e responsabilità di supporto chiare. Un endpoint che funziona sul computer dello sviluppatore non è ancora un servizio migrato.

### 5.11.1 Pubblicazione e artefatti

`dotnet publish -c Release` prepara output per un runtime e un ambiente di distribuzione. La pipeline deve compilare una volta e promuovere lo stesso artefatto tra gli ambienti, aggiungendo configurazione esterna. Ricostruire a ogni stage può produrre binari differenti senza che il team se ne accorga.

Registrare commit, versione SDK, dipendenze e provenance dell'immagine. Per applicazioni framework-dependent, il server deve avere un runtime compatibile; per self-contained, il pacchetto include runtime e richiede patching e dimensioni gestite diversamente. La scelta va documentata in relazione a hosting e policy di aggiornamento.

### 5.11.2 Dockerfile multi-stage

Un Dockerfile multi-stage separa compilazione e runtime:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["src/Catalogo.Api/Catalogo.Api.csproj", "src/Catalogo.Api/"]
COPY ["src/Catalogo.Infrastructure/Catalogo.Infrastructure.csproj", "src/Catalogo.Infrastructure/"]
RUN dotnet restore "src/Catalogo.Api/Catalogo.Api.csproj"
COPY . .
RUN dotnet publish "src/Catalogo.Api/Catalogo.Api.csproj" \
    -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
USER $APP_UID
ENTRYPOINT ["dotnet", "Catalogo.Api.dll"]
```

Adattare path, identità e immagini alla versione supportata e alla policy organizzativa. Non copiare segreti nel build context; usare `.dockerignore` per escludere `.git`, artefatti e file locali. Pinning e aggiornamento delle immagini devono essere governati: fissare un digest aumenta riproducibilità, ma richiede un processo per ricevere patch.

Eseguire con utente non root quando supportato; configurare porte e variabili dal runtime, non codificarle nel Dockerfile. Analizzare l'immagine, limitare capability e filesystem scrivibile, e verificare i certificati CA necessari alle chiamate HTTPS. Un container piccolo non è un container sicuro se contiene vulnerabilità non aggiornate.

### 5.11.3 CI/CD

La pipeline dovrebbe effettuare restore, build, test, analisi, pubblicazione, scansione, firma/provenance se prevista e deploy. I passaggi devono fallire in modo esplicito. Non stampare token in output e limitare i permessi del runner. Usare credenziali effimere o federate quando disponibili.

Separare build da deploy: il job di build produce artefatto immutabile; gli stage successivi applicano configurazione e promuovono lo stesso digest. Le approvazioni manuali possono essere necessarie per ambienti sensibili, ma non devono sostituire test automatizzati. Conservare log e report in un sistema accessibile al team durante incidenti.

La strategia di database va coordinata con la pipeline: le migrazioni non devono partire in parallelo da ogni replica. Le modifiche incompatibili richiedono deployment in più fasi. La pipeline dovrebbe rendere visibili script SQL generati e l'approvazione necessaria.

### 5.11.4 Reverse proxy e hosting

In produzione Kestrel può essere dietro IIS, Nginx, un ingress Kubernetes o un gateway cloud. Configurare forwarded headers da proxy fidati per ricostruire schema e IP originali. Se si accettano header forwarded da qualunque client, un chiamante può falsificare indirizzi o aggirare regole basate sull'IP.

Terminare TLS nel punto previsto, proteggere il collegamento tra proxy e applicazione quando richiesto e configurare redirect HTTPS coerenti. Verificare `PathBase` se il gateway pubblica l'app sotto un prefisso. Controllare upload size, timeout, buffering e idle timeout a ogni livello: il limite effettivo è spesso quello più basso della catena.

### 5.11.5 Health, osservabilità e shutdown

Distinguere:

- **liveness:** il processo è in grado di continuare a funzionare?
- **readiness:** l'istanza può ricevere traffico?
- **startup:** l'inizializzazione è completata?

Un health check che prova ogni dipendenza a ogni intervallo può amplificare un guasto. Separare controlli superficiali da diagnostica profonda e usare timeout. Non esporre endpoint di diagnostica dettagliati al pubblico.

Usare log strutturati con trace/correlation id, metriche aggregate e distributed tracing per seguire chiamate tra servizi. Evitare identificativi personali o token nei label delle metriche: cardinalità e privacy. Definire dashboard e alert collegati a obiettivi di servizio, con runbook e owner.

Lo shutdown deve cessare l'accettazione di nuovo traffico e consentire il completamento del lavoro entro il grace period dell'orchestratore. I worker devono ricevere cancellation token e fermarsi in modo controllato. Testare terminazione con richieste in corso e drain del load balancer.

### 5.11.6 Scalabilità, storage e resilienza

Un'applicazione web stateless è più facile da scalare, ma cache locale, sessione, chiavi Data Protection, file caricati e job in memoria introducono stato di istanza. Documentare dove vive ciascun dato e cosa succede se un nodo viene rimosso.

Usare storage condiviso per file che devono sopravvivere al container; non considerare il filesystem locale una fonte durevole. Se sono necessari sticky session, documentare i limiti e pianificare una migrazione verso stato distribuito quando opportuno. Limitare pool di connessioni in relazione al numero massimo di repliche e alla capacità database.

Resilienza non significa retry illimitato. Configurare timeout, retry limitati con backoff, circuit breaker o bulkhead secondo il failure mode. L'operazione deve avere semantica idempotente o un identificatore di deduplicazione. Un upstream degradato non deve esaurire thread, connessioni e code del servizio migrato.

### 5.11.7 Rollout progressivo e rollback operativo

Con canary o blue/green, spostare percentuali di traffico e confrontare errori e latenza su gruppi simili. Impostare soglie automatiche e un responsabile umano per l'arresto. Un rollout graduale senza metriche segmentate è solo un deploy lento.

Il rollback del codice deve essere compatibile con lo schema dati e con gli eventi già prodotti. Se i messaggi sono stati consumati o i dati trasformati, tornare al binario precedente potrebbe non bastare. Preparare procedure per fermare consumer, drenare code, ripristinare dati o completare una compensazione.

Provare l'intero runbook in un ambiente rappresentativo: identificare la versione attiva, cambiare routing, confermare i segnali, annunciare lo stato e raccogliere evidenze. Registrare durata e impedimenti; assegnare le correzioni prima del cutover reale.

### 5.11.8 Costi, supporto e dismissione

Calcolare costo complessivo includendo doppio runtime durante la transizione, database, log, traffico, build runner, licenze e tempo operativo. La coesistenza dovrebbe avere una data o un criterio di uscita. Ogni dipendenza residua dal vecchio sistema va assegnata a un owner e classificata: necessaria, temporanea o da eliminare.

Prima di spegnere l'origine, verificare traffico residuo, job schedulati, webhook, client sconosciuti, backup, requisiti di audit e retention. Conservare solo ciò che è richiesto e con accessi limitati; spegnere credenziali e endpoint non più necessari. La riduzione della superficie d'attacco e del costo è parte del risultato della migrazione.
