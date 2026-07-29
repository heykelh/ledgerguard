# Backlog produit — LEDGERGUARD

Format : *En tant que [rôle], je veux [action] afin de [valeur].*

## EPIC 1 — Socle de données fiable
- **US-1.1** — En tant que Data Engineer, je veux ingérer le dataset Lending Club dans
  DuckDB afin de disposer d'une source requêtable et reproductible.
  *Critères* : `dbt build` vert ; table `stg_loans` créée ; volumétrie loguée.
- **US-1.2** — En tant que BA, je veux une couche staging normalisée (types, formats,
  taux en numérique) afin que les règles métier s'appliquent sur une base propre.
  *Critères* : colonnes typées ; taux converti en float ; tests `not_null` sur clés.

## EPIC 2 — Moteur de contrôle qualité (le "Guard")
- **US-2.1** — En tant que Data Steward, je veux des contrôles bloquants sur les données
  critiques afin d'empêcher toute donnée non conforme d'atteindre le reporting.
  *Critères* : ≥ 6 tests dbt (unicité, non-nullité, plage, référentiel, cohérence
  temporelle, intégrité) ; pipeline rouge si un test casse.
- **US-2.2** — En tant que Data Steward, je veux un score qualité par dimension DAMA
  afin de piloter la qualité dans le temps.
  *Critères* : score global + 6 sous-scores ; rapport généré.
- **US-2.3** — En tant que BA, je veux mesurer la détection sur des anomalies injectées
  connues afin de prouver l'efficacité du moteur.
  *Critères* : precision & recall calculés sur jeu d'anomalies étiquetées.

## EPIC 3 — Reporting réglementaire automatisé
- **US-3.1** — En tant que Data Owner, je veux les indicateurs risque de crédit agrégés
  (encours par tranche, taux de défaut) afin de piloter l'exposition.
  *Critères* : mart `rpt_credit_risk` ; indicateurs définis et documentés.
- **US-3.2** — En tant que lecteur externe, je veux un dashboard consultable en ligne
  afin de voir le reporting sans compte ni licence.
  *Critères* : dashboard Power BI publié (Publish to web) + embarqué.

## EPIC 4 — Traçabilité & industrialisation
- **US-4.1** — En tant qu'auditeur, je veux un lineage source → KPI afin de vérifier
  la conformité BCBS 239 (principe 6).
  *Critères* : `dbt docs` génère le graphe ; lineage complet visible.
- **US-4.2** — En tant qu'équipe, je veux une CI qui rejoue contrôles et build à chaque
  commit afin de garantir la non-régression.
  *Critères* : workflow GitHub Actions ; badge de statut dans le README.
