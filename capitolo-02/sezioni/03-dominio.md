## 2.3 Il dominio di esempio: un catalogo prodotti

Per tutto il capitolo lavoreremo su un dominio semplice ma realistico: un **catalogo prodotti** organizzato in **categorie**. Due entità, una relazione, e un insieme di operazioni che coprono tutti i casi tipici: lettura con filtro, creazione, cancellazione.

### 2.3.1 Il modello concettuale

- **Category** — una categoria di prodotti (per esempio "Books", "Electronics"). Ha un nome univoco.
- **Product** — un prodotto che appartiene a **una** categoria. Ha nome, prezzo e un riferimento alla categoria.

La relazione è **uno-a-molti**: una categoria ha molti prodotti, ogni prodotto ha una sola categoria.

![Relazione uno-a-molti tra `Category` e `Product`](figure/modello-dati.pdf)

### 2.3.2 Le entità C\#

Traduciamo il modello in classi. Nota l'uso di `required` (C# 11+) per rendere obbligatorie le proprietà non nullable, e della collection expression `[]` per inizializzare la navigation:

```csharp
public sealed class Category
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public List<Product> Products { get; set; } = [];
}

public sealed class Product
{
    public int Id { get; set; }
    public required string Name { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public Category? Category { get; set; }
}
```

Alcune osservazioni:

- `Id` è la chiave primaria per convenzione.
- `Product.CategoryId` è la **chiave esterna**: EF Core la riconosce per convenzione (nome `Category` + `Id`) e la userà per la relazione.
- `Product.Category` è la navigation verso il "lato uno"; `Category.Products` verso il "lato molti". Entrambe servono per scrivere query leggibili con `Include`.

### 2.3.3 Cosa esporremo come tool

Dal modello deriviamo un set di tool MCP sensato:

| Tool | Tipo | Descrizione |
|------|------|-------------|
| `list_products` | Lettura | Elenca i prodotti, con filtro opzionale per categoria |
| `search_products` | Lettura | Cerca prodotti per nome (sottostringa) |
| `get_product` | Lettura | Restituisce un singolo prodotto per id |
| `create_product` | Scrittura | Crea un prodotto in una categoria |
| `update_price` | Scrittura | Aggiorna il prezzo di un prodotto |
| `delete_product` | Scrittura (distruttiva) | Elimina un prodotto per id |

A questi aggiungeremo, nella sezione sul Progress, un tool dimostrativo per comunicare l'avanzamento di un'operazione.

### 2.3.4 Il tipo di ritorno: un DTO

Per le letture non restituiremo le entità EF Core "grezze": le proietteremo in un **DTO** (Data Transfer Object) con LINQ `Select`. Così controlliamo esattamente cosa viaggia verso il modello, evitando di serializzare navigation property potenzialmente cicliche (una categoria che contiene i suoi prodotti, che contengono la categoria...) e dati non necessari:

```csharp
public sealed record ProductDto(int Id, string Name, decimal Price, string Category);
```

Il DTO è un `record` immutabile: pulito, serializzabile e facile da leggere. Il nome della categoria viene "appiattito" nel DTO, così il modello riceve già il dato pronto.

### 2.3.5 Il principio guida del capitolo

Tutto il codice che segue ruota attorno a un'idea: **il database resta nascosto dietro i tool**. Il modello non sa che c'è una tabella `Products`; sa che c'è un tool `list_products` con un parametro `category`. Il server decide quali query eseguire, come validare gli input e quali errori restituire. Questa separazione è ciò che rende l'integrazione sicura e manutenibile.
