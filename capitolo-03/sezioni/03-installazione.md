## 3.3 Installazione e inizializzazione

Spec Kit ha due componenti da installare: il **CLI** (uno strumento da terminale) e l'**integrazione** con il tuo coding agent (i comandi `/speckit-*`).

### 3.3.1 I prerequisiti

Ti servono:

- **Python 3.11 o superiore**;
- **`uv`**, il gestore di pacchetti Python veloce (il CLI `specify` è distribuito come pacchetto Python);
- un coding agent supportato: GitHub Copilot, Claude Code, Cursor, Windsurf, Qoder, Amazon Q, Antigravity, Crush, Gemini CLI, Kilo Code, OpenCode, Roo Code e altri;
- sistema operativo Linux, macOS o Windows.

### 3.3.2 Installare il CLI

```bash
uv tool install specify-cli
```

Il comando installa l'eseguibile `specify` nel tuo ambiente. Verifica l'installazione:

```bash
specify --version
```

> **Nota.** `uv` è il metodo di installazione raccomandato nella documentazione ufficiale. Esistono anche altri installer (release pinnate, pacchetti per CI); per questo capitolo usiamo `uv`, che è il percorso più semplice.

### 3.3.3 Inizializzare un progetto

```bash
specify init taskify --integration copilot
cd taskify
```

Il comando:

1. crea la cartella del progetto;
2. genera la struttura di base di Spec Kit (`.specify/` con template, constitution e configurazione);
3. configura l'**integrazione** scelta (`--integration copilot`): per Copilot, crea le skill `/speckit-*` nella cartella `.github/` (o equivalente), pronte per essere invocate nella chat dell'agente;
4. se interattivo, ti chiede alcune preferenze (per esempio la variante degli script di automazione: Bash, PowerShell o Python).

Dopo `init`, apri la cartella nel tuo agente (per esempio `code taskify` in VS Code) e sei pronto a lavorare.

### 3.3.4 Inizializzare in un progetto esistente

Spec Kit può essere adottato anche in un repository già esistente: la procedura è la stessa, eseguita dentro la cartella del progetto:

```bash
cd mio-progetto-esistente
specify init . --integration copilot
```

In questo caso Spec Kit aggiunge la sua struttura senza toccare il codice esistente, e puoi iniziare a usare il flusso SDD per le **nuove** feature (e, con le guide appropriate, per far evolvere le specifiche esistenti).

### 3.3.5 Le opzioni di `init`

`specify init` accetta opzioni utili:

| Opzione | Scopo |
|---------|-------|
| `--integration <agente>` | Configura l'agente (copilot, claude, cursor, ...) |
| `--script sh\|ps\|py` | Sceglie la variante degli script di automazione |
| `--non-interactive` | Esecuzione senza prompt (per CI) |

In modalità non interattiva (nessun terminale, o `--non-interactive`), Spec Kit sceglie automaticamente una variante di script adatta al sistema operativo.

### 3.3.6 Aggiornare

Per aggiornare un'installazione esistente:

```bash
uv tool upgrade specify-cli
```

L'upgrade del CLI non sovrascrive i tuoi template e le tue specifiche: aggiorna il tool, lasciando intatti gli artefatti del progetto (che restano versionati in Git).

### 3.3.7 Cosa succede alla prima esecuzione

Alla prima invocazione di un comando `/speckit-*`, l'agente legge la configurazione del progetto (`.specify/`) e i template, e produce il primo artefatto (per esempio `specs/<numero>-<slug>/spec.md`). Non c'è un "server" da avviare: tutto avviene tramite file Markdown versionati e il dialogo con l'agente. Questa semplicità — nessun servizio, nessun database — è parte del fascino dello strumento.
