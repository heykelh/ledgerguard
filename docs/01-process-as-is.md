# Process as-is — Production manuelle du reporting risque de crédit

Chaîne actuelle et points de friction (🔴 = coût / risque).

```mermaid
flowchart TD
    A[Extraction manuelle<br/>des données source] --> B[Consolidation<br/>dans Excel]
    B --> C{Contrôles<br/>manuels à l'œil}
    C -->|anomalie repérée| D[🔴 Correction manuelle<br/>~60% du temps]
    D --> C
    C -->|semble OK| E[Agrégation<br/>des indicateurs]
    E --> F[Mise en forme<br/>du reporting]
    F --> G{Validation<br/>Data Owner}
    G -->|erreur détectée tardivement| B
    G -->|validé| H[Diffusion du reporting]

    C -.->|🔴 anomalies ratées| E
    E -.->|🔴 aucune traçabilité<br/>source → KPI| F
```

**Points de douleur identifiés**
1. 🔴 Corrections manuelles répétées (~60% du temps) — cf. note de cadrage.
2. 🔴 Contrôles non exhaustifs → anomalies qui passent en aval.
3. 🔴 Aucune traçabilité source → indicateur (non-conformité BCBS 239 principe 6).
4. 🔴 Boucles de re-travail quand l'erreur est vue à la validation finale.

Le process **to-be** (P4) remplace les étapes C/D/E par un pipeline dbt à contrôles
bloquants + lineage automatique.
