## 4.12 Precedenza, merge e conflitti

Quando più file dicono cose diverse, che cosa vince? La risposta non è unica — dipende dal motore — ma i modelli possibili sono due, e riconoscerli evita molte sorprese.

![Come si combinano i livelli: stratificazione additiva e precedenza a cascata](figure/precedenza.pdf)

### 4.12.1 Due modelli: somma e sostituzione

**Somma (additivo).** I testi vengono concatenati in un ordine definito e il modello li vede tutti. È il modello di Gemini CLI (`GEMINI.md` globale + workspace + JIT) e, in parte, di Claude Code (i `CLAUDE.md` della gerarchia si sommano). Il vantaggio è che nulla va perso; il rischio è la **contraddizione silenziosa**: due file che dicono cose opposte e nessuno che segnali il conflitto.

**Override (solo dove documentato).** Alcuni client o sistemi di configurazione stabiliscono che, per lo stesso valore o la stessa impostazione, una fonte prevalga sulle altre: è il caso di configurazioni a cascata come `.codex/config.toml`. Non si può però dedurre che il testo di una regola sostituisca le altre solo perché è più specifico. `applyTo`, `paths` e `globs` definiscono soprattutto **quando** una regola si applica; i client possono caricare insieme più regole corrispondenti. Il vantaggio di un override esplicito è la prevedibilità; il rischio è che una regola importante venga **sovrascritta** da una fonte che non sapevi esistesse.

### 4.12.2 Livelli tipici, non ordine universale

Non esiste un ordine di precedenza valido per tutti i motori. I livelli seguenti sono un inventario orientativo: i punti 5–7 dipendono in particolare dalle regole di scoperta e precedenza documentate dal client.

1. **policy aziendale** (gestita da IT, non modificabile);
2. **istruzioni utente** (`~/.claude/CLAUDE.md`, `~/.copilot/…`);
3. **istruzioni di progetto** (`.github/copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`);
4. **istruzioni locali** (`CLAUDE.local.md`: personali, non versionate);
5. **istruzioni mirate** per i file toccati (`applyTo`, `globs`, `paths`), incluse secondo le regole di scoperta del client; il pattern non stabilisce da solo una precedenza;
6. **istruzioni dell'agente** selezionato, che in VS Code hanno la precedenza in caso di conflitto;
7. **contenuto della skill** attivata, che però è materiale di consultazione, non un override di configurazione.

Due conseguenze pratiche:

- se una regola «non viene rispettata», verifica prima che sia stata scoperta e attivata; solo dopo controlla eventuali conflitti e le precedenze specifiche del client;
- se una regola è **davvero** non negoziabile, non va in un file di progetto: va in una policy gestita o in un hook che blocca l'azione.

### 4.12.3 Il caso più frequente: la regola duplicata

Lo scenario classico in un team:

```text
AGENTS.md                      → "Usa record per i DTO."
.github/copilot-instructions.md → "Usa classi con proprietà get/set per i DTO."
```

L'agente riceve due istruzioni contrarie. Quale segua dipende dall'ordine interno e dal modello: il risultato è che **a volte** usa i `record` e **a volte** no, e nessuno capisce perché. Non è un problema di intelligenza del modello: è un problema di configurazione.

La diagnosi è meccanica: cerca le parole chiave nei file di personalizzazione, non nel codice.

```bash
# Windows PowerShell: cerca una regola in tutti i file di personalizzazione
Get-ChildItem -Recurse -Include *.md,*.mdc -Force |
  Where-Object { $_.FullName -match '\\?\.(github|claude|cursor|gemini|codex|agents|specify)' } |
  Select-String -Pattern 'DTO' |
  Select-Object Path, LineNumber, Line
```

### 4.12.4 Scrivere regole che non collidono

Tre accorgimenti che eliminano quasi tutti i conflitti:

1. **Un solo posto per ogni concetto.** Le convenzioni dei DTO stanno in un file solo; gli altri file non le ripetono.
2. **Regole locali, non globali.** Se una regola vale solo per `tests/`, mettila in un file mirato invece che nel file di progetto: così non compete con nulla.
3. **Nessuna negazione implicita.** «Usa i `record`» e «non usare le classi» sono la stessa regola scritta due volte; se una cambia, l'altra mente.

E una pratica di team che vale più delle altre: **tratta i file di personalizzazione come codice**. Vanno rivisti in pull request, hanno un proprietario, e le modifiche si giustificano con un problema concreto.
