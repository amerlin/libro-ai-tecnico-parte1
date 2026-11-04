## 5.9 Testing e qualità

La migrazione è l'occasione per rendere esplicito il comportamento del sistema, non per sostituire i test del vecchio stack con test che verificano solo dettagli interni del nuovo. I test più preziosi descrivono ciò che client e utenti possono osservare, e permettono di confrontare le due implementazioni sugli stessi casi.

### 5.9.1 Test di caratterizzazione

Un test di caratterizzazione registra il comportamento attuale, anche quando la documentazione è incompleta. Si preparano input controllati, si invocano route o funzioni del sistema sorgente e si salvano status, header e payload normalizzati. Questi test diventano una specifica di compatibilità per il target.

La normalizzazione va limitata a campi realmente variabili, come timestamp generati o identificativi casuali. Normalizzare interi payload può nascondere regressioni. Per dati sensibili usare fixture sintetiche o anonimizzate; non importare dump di produzione nei test senza autorizzazione e protezioni.

Per endpoint rappresentativi raccogliere:

- risposta valida e codici di successo;
- input mancante, malformato e ai limiti;
- risorsa assente e conflitto;
- chiamante anonimo e permessi insufficienti;
- timeout o indisponibilità di una dipendenza;
- richieste duplicate e concorrenza.

Il test di caratterizzazione non dichiara che il comportamento corrente sia ideale. Un bug noto può essere registrato come comportamento da cambiare, con un test che viene aggiornato nella stessa modifica della decisione e con l'approvazione del proprietario del contratto.

### 5.9.2 Piramide e livelli di test

**Unit test** verificano funzioni e regole isolate, rapidamente e senza rete. Sono adatti a validazioni, calcoli, policy e transizioni di stato. Non devono ricreare l'intero framework con mock che duplicano l'implementazione.

**Test d'integrazione** esercitano più componenti: hosting, route, serializzazione, DI, database e adapter. In ASP.NET Core `WebApplicationFactory<TEntryPoint>` avvia l'applicazione nel processo di test e permette richieste HTTP in memoria. Sostituire configurazione o dipendenze in modo controllato; verificare anche la pipeline vera.

**Test end-to-end** attraversano deployment, gateway e servizi integrati. Sono più lenti e sensibili all'ambiente; riservarli ai flussi business critici, mantenere dati isolati e avere pulizia affidabile.

La piramide è una guida alla velocità e al feedback, non una quota rigida. Un test d'integrazione diretto sul database può essere più attendibile di un grande insieme di mock che non simula transazioni e SQL.

### 5.9.3 Test HTTP con WebApplicationFactory

Un test concettuale può verificare un contratto HTTP:

```csharp
public sealed class ProductApiTests(
    WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task Missing_product_returns_not_found()
    {
        using var client = factory.CreateClient();
        using var response =
            await client.GetAsync("/api/products/987654");

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }
}
```

Il progetto deve esporre il punto d'ingresso al test se necessario e configurare un database isolato. Non riutilizzare un database condiviso tra esecuzioni concorrenti senza namespace o transazioni pulite. Per test di persistenza, verificare vincoli, migrazioni e comportamento del provider adottato in produzione.

Testare le risposte come farebbe un client: status, content type, header, schema e valori. Non verificare il nome di una classe interna quando l'obiettivo è la compatibilità API. Test specifici di unità possono invece verificare il dominio senza attraversare HTTP.

### 5.9.4 Parità differenziale

Quando entrambi i sistemi sono avviabili, inviare lo stesso caso a sorgente e target e confrontare gli output. Il test differenziale può essere automatizzato su una collezione di casi deterministici. Escludere o normalizzare solo campi non deterministici, mantenendo visibili differenze nei codici, nei valori e negli errori.

Non inviare automaticamente richieste di scrittura reali a entrambe le versioni: potrebbero creare effetti duplicati, inviare email o addebitare un pagamento. Per i casi mutativi usare database isolati, simulazioni senza effetti collaterali o una modalità di shadow che calcola la risposta senza committare.

Il confronto deve considerare anche proprietà mancanti e ordine delle liste quando l'ordine è contrattuale. Per importi, date e testo, confrontare con regole esplicite; non applicare una tolleranza generica che renda irrilevanti differenze di business.

### 5.9.5 Dipendenze nei test

Mock e fake hanno valore quando isolano un confine, per esempio un servizio di pagamento. Non mockare il database con una collezione in memoria e concludere che le transazioni reali funzionano. Usare container effimeri o istanze dedicate per testare provider SQL, code o identity server quando la compatibilità è importante.

Ogni fake deve avere semantica dichiarata. Un fake cache senza scadenza non verifica TTL; un fake storage senza errori non prova retry; un fake repository che restituisce sempre l'entità non esercita i vincoli. Preferire test a contratto per verificare che adapter diversi rispettino lo stesso protocollo.

### 5.9.6 Flakiness, dati e parallelismo

Un test che dipende dall'orologio reale, da un endpoint esterno o da dati condivisi può essere intermittente. Iniettare un clock quando il tempo è parte del comportamento, controllare il seed e isolare risorse. Non disabilitare l'esecuzione parallela dell'intera suite per nascondere una race: identificare lo stato condiviso e isolare il test interessato.

I test devono poter essere ripetuti. Ogni esecuzione dovrebbe creare e rimuovere i propri dati, usare nomi univoci e produrre log utili in caso di fallimento. Non riutilizzare credenziali di produzione. La cleanup deve funzionare anche dopo un errore, senza cancellare database o namespace condivisi.

### 5.9.7 Qualità e pipeline CI

Una pipeline minima esegue restore, build Release, test, analisi e pubblicazione di artefatti. Aggiungere scansione dipendenze, formattazione e analisi statiche secondo il rischio e gli standard del team. Bloccare la release su fallimenti significativi e rendere i risultati rintracciabili con commit, versione SDK e configurazione.

```text
dotnet restore
dotnet format --verify-no-changes
dotnet build -c Release --no-restore
dotnet test -c Release --no-build --logger "trx"
dotnet publish src/Catalogo.Api -c Release -o artifacts/publish
```

La pipeline deve funzionare da checkout pulito e non dipendere da file generati presenti sulla workstation. Separare test che richiedono servizi esterni e rendere espliciti prerequisiti e cleanup. Verificare che il pacchetto pubblicato sia lo stesso che verrà promosso, non ricostruire da sorgenti diversi in ogni ambiente.

### 5.9.8 Copertura orientata al rischio

La percentuale di line coverage non misura quanto i test proteggono il contratto. Dare priorità a flussi con impatto alto, transizioni di stato, permessi, calcoli finanziari, migrazione dati e fallback. Un singolo test di integrazione ben progettato può coprire un rischio non espresso da decine di test di getter.

Per ogni capacità migrata, associare requisito, test, output e owner. I criteri di uscita possono richiedere: test di parità superati; regressioni spiegate; contratti aggiornati; test sul provider reale; nessun difetto bloccante; report di qualità archiviato. Se una parte non è testabile, registrare il rischio e una mitigazione alternativa.
