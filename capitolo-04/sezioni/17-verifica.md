## 4.17 Verificare che funzioni

Il problema più frustrante di questi strumenti è il **fallimento silenzioso**: hai scritto il file, hai fatto tutto come da documentazione, e l'agente lo ignora. Nella grande maggioranza dei casi il file è nel posto sbagliato, il frontmatter è invalido o il livello superiore lo sovrascrive.

### 4.17.1 Le quattro verifiche, in ordine

**1. Il file è nel percorso giusto?** Non «un percorso plausibile»: quello esatto per il motore e per l'ambito (progetto vs utente). Un `.github/instructions` senza la `s` è invisibile.

**2. Il frontmatter è valido?** Un errore di sintassi YAML invalida l'intero file. I casi frequenti:

- `description:` vuoto (è obbligatorio nelle skill);
- `applyTo` senza virgolette quando contiene `*` o `{}`;
- `name:` della skill diverso dal nome della cartella;
- indentazione con tabulazioni invece di spazi.

**3. Il motore lo vede?** Ogni ambiente ha un comando o un pannello:

| Motore | Come verificare |
| --- | --- |
| VS Code (Copilot) | `Chat: Open Customizations` dalla Command Palette |
| Claude Code | `/context` (file di memoria caricati) |
| Gemini CLI | `/memory show` (contesto concatenato) |
| Cursor | pannello delle regole, con tipo di applicazione |
| Codex | log di avvio con i file `AGENTS.md` caricati |

**4. Un livello superiore lo sovrascrive?** È la diagnosi della sezione 4.12: cerca la stessa regola negli altri file, in particolare in quelli dell'utente e in quelli dell'agente selezionato.

### 4.17.2 Un test automatico per il frontmatter

Poiché questi file sono codice, possono essere validati in CI. Un controllo minimo ma efficace:

```powershell
# tools/Test-AgentConfig.ps1
param([string]$Root = ".")

$errors = @()
$skills = Get-ChildItem $Root -Recurse -Filter "SKILL.md" -Force

foreach ($skill in $skills) {
    $raw = Get-Content $skill.FullName -Raw -Encoding UTF8
    if ($raw -notmatch '(?s)^\uFEFF?---\r?\n(.*?)\r?\n---') {
        $errors += "$($skill.FullName): manca il frontmatter YAML"
        continue
    }
    $fm = $Matches[1]

    $name = ([regex]::Match($fm, '(?m)^name:\s*(.+)$')).Groups[1].Value.Trim()
    if (-not $name) {
        $errors += "$($skill.FullName): campo 'name' mancante"
    } elseif ($name -ne $skill.Directory.Name) {
        $errors += "$($skill.FullName): 'name' ($name) non corrisponde alla cartella ($($skill.Directory.Name))"
    }
    if ($name -cmatch '[A-Z]' -or $name -match '^-|-$|--') {
        $errors += "$($skill.FullName): 'name' non valido (minuscolo, trattini singoli, senza estremi)"
    }

    $desc = ([regex]::Match($fm, '(?m)^description:\s*(.+)$')).Groups[1].Value.Trim()
    if (-not $desc) {
        $errors += "$($skill.FullName): campo 'description' mancante"
    } elseif ($desc.Length -lt 40) {
        $errors += "$($skill.FullName): 'description' troppo corta per essere attivabile"
    }
}

# I file di istruzioni mirate devono avere il pattern di attivazione
$targeted = Get-ChildItem $Root -Recurse -Filter "*.instructions.md" -Force
foreach ($file in $targeted) {
    $raw = Get-Content $file.FullName -Raw -Encoding UTF8
    if ($raw -notmatch '(?m)^applyTo:\s*\S+') {
        $errors += "$($file.FullName): manca 'applyTo', il file non si attiverà mai"
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
Write-Host "Configurazione agenti valida: $($skills.Count) skill, $($targeted.Count) file mirati."
```

Il controllo sulla lunghezza minima della `description` è deliberato: è il difetto più comune e il più costoso, perché la skill esiste ma non viene mai scelta.

### 4.17.3 Verificare il comportamento, non solo la sintassi

La sintassi corretta non garantisce che l'agente *usi* la skill. Per questo serve un test di comportamento, anche rudimentale:

1. **Test positivo**: chiedi qualcosa che dovrebbe attivare la skill («prepara le note di rilascio») e verifica che il risultato segua la procedura.
2. **Test negativo**: chiedi qualcosa di non correlato («scrivi un test per `Category`») e verifica che la skill **non** venga attivata.
3. **Test di conflitto**: chiedi qualcosa che due file regolano diversamente, e verifica che vinca quello che ti aspetti.

Il terzo è quello che nessuno fa e che scopre i problemi veri. Tenerlo come test manuale periodico, dopo ogni modifica alla configurazione, costa dieci minuti e previene settimane di comportamenti incoerenti.

### 4.17.4 Un consiglio di manutenzione

Aggiungi una data e un proprietario in testa ai file di personalizzazione, oppure affidati al versionamento. Le regole invecchiano: un'istruzione che dice «usa `Newtonsoft.Json`» sopravvive per anni dopo essere diventata falsa, e ogni sessione la applica con diligenza. Rivederle a ogni release è l'unico modo per non accumulare debito silenzioso.
