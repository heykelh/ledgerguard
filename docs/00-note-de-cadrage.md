# Note de cadrage — LEDGERGUARD

## 1. Contexte
La production du reporting réglementaire **risque de crédit** repose sur une chaîne
manuelle (extractions, consolidation Excel, contrôles à l'œil). La donnée d'entrée
est incomplète et incohérente. Conséquences : délais, corrections répétées, et
risque de non-conformité **BCBS 239**.

## 2. Problème & enjeu chiffré (business case — hypothèses explicites)
Modélisation de travail, hypothèses assumées et documentées :
- Production mensuelle du reporting : **5 j-homme**, dont ~**60% en corrections**
  manuelles de qualité de données → ~**3 j-homme/mois** de pure non-qualité.
- Coût chargé analyste : **~500 €/jour** → **~1 500 €/mois**, soit **~18 000 €/an**
  de temps perdu sur un seul reporting.
- Risque réglementaire : une anomalie non détectée sur un indicateur réglementaire
  peut déclencher revue ACPR et remédiation (coût non modélisé, mais non nul).

> Ces € sont un **scénario à hypothèses visibles**, destinés à cadrer la valeur.
> Les métriques techniques (score DQ, temps pipeline, precision/recall) seront, elles,
> **mesurées sur données réelles**.

## 3. Objectifs
1. Score qualité de données **≥ 98,5%** (6 dimensions DAMA).
2. Temps de production du reporting **< 10 min** (vs 5 j-homme).
3. **100%** de traçabilité source → KPI (lineage BCBS 239).
4. Moteur de détection d'anomalies à **precision/recall mesurés**.

## 4. Périmètre
**Inclus** : risque de crédit (encours, statut, défaut), contrôles qualité,
reporting agrégé, lineage, CI.
**Exclu** : autres domaines (marché, liquidité), row-level security, données réelles
clients (dataset ouvert uniquement), déploiement Power BI Embedded (cité, non déployé).

## 5. Référentiel réglementaire (BCBS 239)
- **Principe 3 — Exactitude & intégrité** : contrôles bloquants sur la donnée.
- **Principe 5 — Exhaustivité** : détection des trous (complétude).
- **Principe 6 — Traçabilité** : lineage automatique source → indicateur.

## 6. Parties prenantes (rôles)
| Rôle | Responsabilité |
|---|---|
| Data Owner | Valide définitions et seuils des indicateurs |
| Data Steward | Suit le score qualité, arbitre les anomalies |
| BA (moi) | Recueil du besoin, spécifications, contrôles, reporting |
| IT / Data Eng | Exploite le pipeline |

## 7. Livrables
Note de cadrage · Process as-is/to-be (BPMN) · Backlog · Pipeline dbt +
contrôles · Rapport DQ chiffré · Dashboard reporting · Lineage · CI · Spéc. fonctionnelle.

## 8. Risques & hypothèses
- Dataset ouvert ≠ données bancaires réelles → on l'assume et on le dit.
- Publish to web = données publiques uniquement → OK car dataset ouvert.
