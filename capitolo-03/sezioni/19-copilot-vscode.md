## 3.19 Integrazione con Copilot e VS Code

Spec Kit è agente-agnostico, ma la combinazione più naturale per chi lavora in .NET è **Visual Studio Code + GitHub Copilot**. Vediamo come si presenta l'integrazione.

### 3.19.1 L'integrazione Copilot

Quando esegui `specify init --integration copilot`, Spec Kit registra i comandi `/speckit-*` come **skill di Copilot** nel progetto. In VS Code, questo significa che nella chat di Copilot (o nell'editor) puoi digitare:

```text
/speckit-specify Crea una Task Manager API con creazione, elenco, completamento ed eliminazione.
```

e Copilot eseguirà il comando, leggendo i template e scrivendo gli artefatti in `specs/`.

### 3.19.2 Dove vivono le skill

A seconda della versione di Copilot, le skill vengono registrate nella cartella del progetto (per esempio in `.github/prompts/` o nelle configurazioni delle skill). Non serve preoccuparsi del dettaglio: l'importante è che, dopo `init`, i comandi `/speckit-*` siano disponibili nella chat quando il progetto è aperto.

### 3.19.3 Il flusso in VS Code

Il ciclo tipico in VS Code:

1. apri il progetto (`code taskify`);
2. apri la chat di Copilot;
3. invochi `/speckit-specify` con la descrizione;
4. **rileggi** `spec.md` nell'editor (i file sono lì, modificabili a mano);
5. invochi i comandi successivi uno alla volta;
6. quando arrivi a `/speckit-implement`, Copilot scrive i file C# nel progetto;
7. esegui `dotnet test` nel terminale integrato;
8. chiudi con `/speckit-converge`.

### 3.19.4 Altri agenti

Spec Kit supporta molti agenti: Claude Code, Cursor, Windsurf, Qoder, Amazon Q, Antigravity, Crush, Gemini CLI, Kilo Code, OpenCode, Roo Code e altri. La sintassi di invocazione cambia leggermente (ogni agente ha il suo modo di invocare una skill), ma il flusso e gli artefatti sono identici: è il valore della standardizzazione.

### 3.19.5 Rivedere e modificare a mano

Un punto da non sottovalutare: **gli artefatti sono file Markdown normali**. In VS Code puoi aprirli, modificarli, confrontarli con il diff di Git e rivederli come faresti con qualsiasi documento. Se la specifica prodotta non ti convince, la correggi a mano e rilanci i comandi successivi. L'agente è un acceleratore, non un oracolo infallibile.

### 3.19.6 VS Code e Git

Il flusso Spec Kit si sposa naturalmente con Git: ogni feature ha la sua cartella in `specs/`, e (con l'estensione git opzionale) il suo branch. Commit e pull request diventano i punti di revisione: la specifica viene rivista e approvata **prima** che il codice venga scritto, spostando la review dove costa meno.
