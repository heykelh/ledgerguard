# LEDGERGUARD — Data Quality Gate & Regulatory Reporting

> Contrôle qualité déterministe et reporting réglementaire automatisé pour un
> périmètre **risque de crédit** bancaire, aligné **BCBS 239** et **DAMA-DMBOK**.
> Une donnée non conforme est bloquée *avant* d'atteindre le reporting.

## Le problème
Dans une banque, le reporting réglementaire risque de crédit est produit à la main
sur une donnée incomplète et incohérente : retards, corrections manuelles, exposition
au risque de non-conformité BCBS 239 (exactitude, exhaustivité, traçabilité).

## Les 4 objectifs mesurés
| Métrique | Avant | Cible | Méthode |
|---|---|---|---|
| Score qualité de données (6 dim. DAMA) | ~72% | **≥ 98,5%** | scoring Python sur données réelles |
| Temps de production du reporting | 5 j-homme | **< 10 min** | pipeline dbt automatisé |
| Traçabilité source → KPI | partielle | **100%** | lineage dbt auto-généré (BCBS 239) |
| Détection d'anomalies (precision / recall) | n/a | **mesuré** | harness d'éval sur anomalies injectées connues |

> Les scores DQ et de détection sont **mesurés sur données réelles**.
> L'impact € (voir note de cadrage) est un **business case explicite à hypothèses visibles**,
> pas un chiffre réel présenté comme tel.

## Donnée
Dataset ouvert **Lending Club** (prêts accordés). Déjà « sale » par nature
(valeurs manquantes, taux au format texte, incohérences de référentiel).

## Stack
`SQL` · `Python 3.12` · `DuckDB` · `dbt (dbt-duckdb)` · `Power BI (Publish to web)` ·
`GitHub Actions` · `BPMN` · `Jira / Confluence`
> En contexte bancaire réel : bascule sur Snowflake + Power BI Embedded (RLS, sécurité).

## État d'avancement
- [x] **P0 — Cadrage & backlog** *(en cours)*
- [ ] P1 — Socle & ingestion (DuckDB + dbt)
- [ ] P2 — Moteur de contrôle qualité + scoring DAMA + eval harness
- [ ] P3 — Reporting & dashboard Power BI (Publish to web)
- [ ] P4 — Lineage, CI, doc BCBS 239

## Docs
- [Note de cadrage](docs/00-note-de-cadrage.md)
- [Process as-is](docs/01-process-as-is.md)
- [Backlog produit](docs/02-user-stories.md)
