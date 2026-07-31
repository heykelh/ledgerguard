# LEDGERGUARD — Data Quality Gate & Regulatory Reporting

> Contrôle qualité déterministe et reporting réglementaire automatisé sur un
> périmètre **risque de crédit** bancaire, aligné **BCBS 239** et **DAMA-DMBOK**.
> Une donnée non conforme est mise en quarantaine *avant* d'atteindre le reporting.

Projet portfolio — Data Engineering / Data Quality / Gouvernance appliquée au secteur bancaire.
Données réelles, métriques mesurées, pipeline reproductible.

---

## Le problème

Dans une banque, le reporting réglementaire risque de crédit est souvent produit
manuellement sur une donnée hétérogène : extractions, consolidation Excel, contrôles
à l'œil. Conséquences : délais, corrections répétées, et risque de non-conformité
BCBS 239 (exactitude, exhaustivité, traçabilité). LEDGERGUARD industrialise cette
chaîne : la donnée est typée, contrôlée par des règles déterministes, et la donnée
toxique est isolée et comptée au lieu de corrompre les indicateurs.

---

## Résultats mesurés

| Métrique | Résultat | Méthode |
|---|---|---|
| Couverture de détection (F1) | **1.00** — precision 1.0, recall 1.0 | harness d'éval : 900 anomalies injectées (9 règles × 100) + 5 000 lignes réelles conformes, rejouées dans le pipeline de production |
| Faux positifs sur donnée propre | **0 / 5 000** | le Guard ne bloque jamais une ligne saine |
| Enregistrements mis en quarantaine | **4 314 / 2 260 701** (0,19 %) | contrôles de plausibilité sur données réelles ; 4 274 dus à des ratios d'endettement (DTI) aberrants |
| Volumétrie traitée | **2 260 701 prêts** | dataset Lending Club 2007–2018 |
| Temps de production du reporting | 5 j-homme → **< 10 min** | pipeline dbt automatisé *(P3)* |
| Traçabilité source → indicateur | **100 %** | lineage dbt auto-généré, BCBS 239 *(P4)* |

> **« Couverture de détection »** = chaque règle attrape la corruption qu'elle cible.
> Ce n'est pas une garantie d'exhaustivité face à toutes les anomalies possibles du
> monde réel ; c'est la preuve que le dispositif de contrôle fait ce qu'il déclare,
> sur un jeu étiqueté reproductible et auto-vérifié.

---

## Données

Dataset ouvert **Lending Club** (`wordsforthewise/lending-club` sur Kaggle),
fichier `accepted_2007_to_2018Q4.csv.gz` — ~2,26 M de prêts, ~150 variables,
licence **CC0 1.0** (domaine public). Données réelles, « sales » par nature
(types texte, référentiels incohérents, valeurs aberrantes), non versionnées dans ce repo.

---

## Architecture — médaillon + Guard + harness

Source CSV (brut, ~2,26M lignes)
│
▼
stg_loans bronze — copie fidèle, tout en VARCHAR (la donnée sale ne casse pas le chargement)
│
▼
int_loans_typed silver — typage (try_cast), normalisation du référentiel, flags de contrôle → is_valid / dq_reasons
│
├──────────────► Quarantaine (is_valid = false, comptée)
▼
int_loans_conformed le GUARD — seule la donnée valide franchit ce point
│
▼
Reporting réglementaire (P3)

dq_score mesure le score qualité (% par dimension DAMA)
Harness d'éval injecte des anomalies connues et mesure precision / recall / F1 du Guard

Les règles de qualité sont définies **une seule fois** dans des macros
(`macros/dq_typing.sql`, `dq_flags.sql`, `dq_verdict.sql`), appelées à la fois par
le modèle de production et par le modèle d'évaluation — aucun écart possible entre
ce qui tourne et ce qui est évalué.

---

## Stack & justification

| Techno | Rôle | Pourquoi |
|---|---|---|
| **SQL** | toutes les transformations | compétence socle du reporting bancaire, non négociable |
| **DuckDB** | moteur analytique local | zéro serveur, zéro coût, rapide sur du columnar → repo clonable et exécutable tel quel |
| **dbt (dbt-duckdb)** | transformations, tests, lineage | transformations *as-code* versionnées + tests natifs + lineage auto (preuve BCBS 239) |
| **dbt_utils** | tests génériques | `accepted_range`, contrôles de bornes prêts à l'emploi |
| **Python** | scoring DAMA + harness d'éval | scoring multi-dimensionnel et mesure precision/recall/F1 |
| **Power BI (Publish to web)** | dashboard public | *(P3)* — l'outil standard réclamé en BFA, embarquable en page web |
| **GitHub Actions** | CI | *(P4)* — rejoue contrôles + build à chaque commit, pipeline rouge si un contrôle casse |
| **BPMN / Jira / Confluence** | cadrage & exigences | modélisation de process + backlog + spécifications fonctionnelles |

> En contexte bancaire réel : bascule sur Snowflake + Power BI Embedded (RLS, sécurité).
> DuckDB et Publish to web sont les équivalents à coût nul pour un projet portfolio.

---

## État d'avancement

- [x] **P0** — Cadrage & backlog (note de cadrage, process as-is BPMN, user stories)
- [x] **P1** — Socle & ingestion (DuckDB + dbt, bronze `stg_loans`)
- [x] **P2** — Moteur de contrôle qualité (silver typée, contrôles, quarantaine, scoring DAMA)
- [x] **P2b** — Harness d'évaluation (injection d'anomalies, precision/recall/F1, garde-fous)
- [ ] **P3** — Reporting risque de crédit & dashboard Power BI
- [ ] **P4** — Lineage, CI GitHub Actions, documentation BCBS 239

---

## Structure du repo

ledgerguard/
├── docs/
│ ├── 00-note-de-cadrage.md
│ ├── 01-process-as-is.md
│ └── 02-user-stories.md
├── dbt/
│ ├── models/
│ │ ├── staging/ # bronze : stg_loans
│ │ ├── intermediate/ # silver : int_loans_typed, int_loans_conformed
│ │ ├── quality/ # dq_score
│ │ └── eval/ # eval_scored (harness, désactivé par défaut)
│ ├── macros/ # règles de qualité partagées (source unique)
│ ├── seeds/ # ref_loan_status.csv (référentiel MDM)
│ ├── dbt_project.yml
│ ├── profiles.yml
│ └── packages.yml
├── quality/python/
│ ├── inject_anomalies.py # génère le jeu étiqueté
│ └── evaluate.py # mesure precision/recall/F1 → reporting/eval_metrics.json
├── reporting/ # sorties (métriques, dashboard)
└── README.md

---

## Reproduire

**1. Environnement** (Windows / PowerShell, Python 3.12+)
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install dbt-duckdb duckdb pandas
```

**2. Données** — créer un compte Kaggle (gratuit), télécharger
`accepted_2007_to_2018Q4.csv.gz` depuis `wordsforthewise/lending-club` et le placer
dans `dbt/data/`.

**3. Pipeline**
```powershell
cd dbt
dbt deps  --profiles-dir .
dbt seed  --profiles-dir .
dbt build --profiles-dir .
```

**4. Harness d'évaluation**
```powershell
python quality\python\inject_anomalies.py
cd dbt
dbt run --select eval_scored --vars '{"run_eval": true}' --profiles-dir .
cd ..
python quality\python\evaluate.py
```

---

## Documentation

- [Note de cadrage](docs/00-note-de-cadrage.md) — business case, périmètre, référentiel BCBS 239
- [Process as-is](docs/01-process-as-is.md) — chaîne manuelle actuelle et points de friction
- [Backlog produit](docs/02-user-stories.md) — epics & user stories

---

## Auteur

Heykel Hachiche — [heykelhachiche.com](https://heykelhachiche.com) · [github.com/heykelh](https://github.com/heykelh)
