## 4.10 Il caso DeepSeek: un motore senza formato

Arrivati qui la domanda è naturale: «e per DeepSeek quale cartella devo creare?». La risposta onesta è: **nessuna**. E il motivo è istruttivo, perché chiarisce una distinzione che tendiamo a confondere.

### 4.10.1 Modello, host e formato

Una piattaforma come DeepSeek espone un'**API** (chat completions), non un'esperienza di codifica con una propria cartella di configurazione. La sua API è compatibile con il formato OpenAI e con quello Anthropic:

| Campo | Valore |
| --- | --- |
| `base_url` (OpenAI-compatible) | `https://api.deepseek.com` |
| `base_url` (Anthropic-compatible) | \url{https://api.deepseek.com/anthropic} |
| `model` | `deepseek-flash`, `deepseek-v4-pro` |

Questo significa che DeepSeek si usa quasi sempre **come backend di un altro host**: Claude Code, GitHub Copilot, OpenCode e altri strumenti compatibili permettono di puntare il modello a DeepSeek cambiando la configurazione del provider. In quel caso **i file di istruzioni, skill e agenti sono quelli dell'host**, non di DeepSeek: se usi DeepSeek dentro Claude Code, il tuo `CLAUDE.md` funziona esattamente come con un modello Anthropic.

La distinzione da tenere ferma:

- il **modello** è il motore di inferenza;
- l'**host** è il programma che gestisce file, strumenti, permessi e contesto;
- il **formato** delle personalizzazioni appartiene all'host, non al modello.

### 4.10.2 L'eccezione: DeepSeek Harness

Esiste però un caso in cui DeepSeek ha una propria nozione di estensione. **DeepSeek Harness** (in anteprima per sviluppatori) è un runtime agentico autonomo con una Web UI e una CLI (`dsh`), e definisce i plugin in modo molto diverso dagli altri motori di questo capitolo: un plugin è un **modulo TypeScript** che esporta una funzione `apply`, registrato in un file `cordis.yml`.

```ts
import type { Context } from '@deepseek-ai/cordis'

export const name = 'my-tool-plugin'
export const inject = ['tools']

export function apply(ctx: Context) {
  ctx.tools.register(/* ... */)
}
```

```yaml
# cordis.yml — overlay che inserisce il plugin locale
- insert:
    - id: hello
      name: '/percorso/assoluto/scratch-plugin/src/my-plugin.ts'
```

È un modello **imperativo**: il plugin è codice che si aggancia a un framework, non un pacchetto di Markdown che descrive comportamenti. Non esiste un `SKILL.md`, non c'è un frontmatter: se vuoi aggiungere una capacità, scrivi TypeScript.

### 4.10.3 Che cosa insegna questo caso

Il contrasto è utile perché mostra che «plugin» è una parola con due significati:

| Significato | Natura | Esempio |
| --- | --- | --- |
| Pacchetto di personalizzazioni | Markdown + manifest dichiarativo | Agent Plugins 1.0, plugin di Claude Code |
| Modulo di codice | Codice eseguito dal runtime | plugin di DeepSeek Harness, estensione di VS Code |

Sono entrambi legittimi, ma hanno conseguenze diverse sulla fiducia: un pacchetto di Markdown lo puoi leggere e capire in due minuti; un modulo di codice richiede di leggerlo come leggeresti una dipendenza. Quando valuti un plugin, la prima domanda da farsi è **in quale delle due categorie cade**.

### 4.10.4 In pratica

Se lavori con DeepSeek, la sequenza è:

1. scegli l'host (Claude Code, Copilot, OpenCode…);
2. configura il provider con `base_url` e chiave API;
3. scrivi le personalizzazioni nel formato **dell'host**;
4. ricorda che alcuni host hanno funzionalità che dipendono dal modello (per esempio il conteggio dei token o il caching del prompt): verifica che il comportamento che ti serve sia supportato dal modello che stai usando, non solo dall'host.

Il punto 3 è quello che risponde alla domanda iniziale: non c'è una `.deepseek/` da creare, perché la cartella giusta è quella dell'host che hai scelto.
