## 4.19 Governance del team e versionamento

Una configurazione che funziona per una persona, in un team, diventa un problema di governance: chi decide le regole, come si aggiornano, come si evitano derive incontrollate.

### 4.19.1 I tre ambiti e chi li possiede

| Ambito | Contenuto tipico | Chi lo possiede |
| --- | --- | --- |
| **Organizzazione** (policy gestita) | Regole non negoziabili: sicurezza, licenze, dati | IT / platform team |
| **Progetto** (versionato) | Convenzioni, comandi, skill del team | Il team, via pull request |
| **Utente** | Preferenze personali, scorciatoie | Il singolo sviluppatore |

La regola di ripartizione: **ciò che vale per tutti sta in progetto o in organizzazione; ciò che è gusto personale sta in utente**. Un file utente che contiene le convenzioni del team è un problema in attesa di accadere: non è versionato, non è rivisto e vale solo per una persona.

### 4.19.2 Le regole come artefatto di progetto

Tre pratiche che fanno la differenza:

**1. Revisione.** I file di personalizzazione passano in pull request come il codice. Chi rivede chiede: «questa regola risolve un problema reale? È verificabile? È già scritta altrove?».

**2. Proprietà.** Un `CODEOWNERS` che assegna `.github/`, `.claude/`, `.cursor/` a un gruppo. Senza proprietario, ogni file di configurazione degenera.

**3. Dimensione.** Un limite indicativo: il file di istruzioni principale dovrebbe stare **sotto le 150 righe**. Oltre, o si sta descrivendo troppo, o c'è materiale che dovrebbe essere una skill. Molti team hanno un controllo in CI che fallisce oltre una soglia.

```powershell
$main = ".github/copilot-instructions.md", "AGENTS.md", "CLAUDE.md" |
    Where-Object { Test-Path $_ } | Select-Object -First 1
if ($main) {
    $lines = (Get-Content $main).Count
    if ($lines -gt 150) {
        Write-Error "$main ha $lines righe (limite 150): sposta le procedure in una skill."
    }
}
```

### 4.19.3 Il monorepo

In un monorepo le regole cambiano per pacchetto. Le due strategie possibili:

- **file annidati**: un `AGENTS.md` o un `CLAUDE.md` in ogni pacchetto, caricato quando si lavora lì (Claude Code e Gemini CLI lo fanno nativamente);
- **istruzioni mirate**: un solo file di progetto e file con pattern per area (`applyTo: "packages/api/**"`).

La prima è più semplice da capire, la seconda più facile da controllare. In entrambi i casi va evitato l'errore classico: **regole globali duplicate in ogni pacchetto**, che poi divergono. La regola globale sta nella radice, una volta sola.

VS Code ha anche un'impostazione per scoprire le personalizzazioni dalla radice del repository padre (`chat.useCustomizationsInParentRepositories`), utile quando i repository sono annidati in una cartella comune.

### 4.19.4 Migrazioni e cambi di motore

Quando il team cambia motore — o ne aggiunge uno — la domanda non è «quanto lavoro c'è», ma «quanto lavoro ci sarà la prossima volta». Tre passi:

1. **inventario**: elenca i file di personalizzazione esistenti e classificali per portabilità (sezione 4.13);
2. **consolidamento**: sposta ciò che è portabile nella fonte unica (`AGENTS.md`, skill standard);
3. **rigenerazione**: produci le copie con uno script, non a mano.

Il risultato è che il costo di un cambio futuro si misura in minuti, non in giorni. È lo stesso principio del Capitolo 3: la specifica è la fonte, gli artefatti derivati si rigenerano.

### 4.19.5 Un esempio di organizzazione realistica

```text
taskify/
|-- AGENTS.md                    # fonte unica delle regole (~80 righe)
|-- .github/
|   |-- copilot-instructions.md  # generato da AGENTS.md (banner in testa)
|   |-- instructions/
|   |   |-- tests.instructions.md
|   |   `-- api.instructions.md
|   `-- agents/revisore.agent.md
|-- .claude/
|   |-- CLAUDE.md                # generato da AGENTS.md
|   |-- rules/tests.md
|   `-- skills/release-notes/
|-- .github/skills/release-notes/ # copia o symlink della stessa skill
`-- tools/
    |-- sync-agent-config.ps1     # genera le copie
    `-- Test-AgentConfig.ps1      # valida in CI
```

Con questa struttura, aggiungere domani Cursor significa aggiungere una riga allo script e una regola in `.cursor/rules/`. Tutto il resto è già a posto.
