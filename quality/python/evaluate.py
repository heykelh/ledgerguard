"""Lit eval_scored (donnée injectée passée dans le vrai pipeline) et mesure
precision / recall / F1 du Guard, plus le recall par règle. Écrit un JSON pour le README/CI."""
import duckdb, json, pathlib

con = duckdb.connect("dbt/ledgerguard.duckdb")
df = con.sql("select label_is_anomaly, is_valid, injected_rule from eval_scored").df()

caught  = ~df["is_valid"].astype(bool)
anomaly = df["label_is_anomaly"] == 1

tp = int((anomaly & caught).sum())
fn = int((anomaly & ~caught).sum())
fp = int((~anomaly & caught).sum())
tn = int((~anomaly & ~caught).sum())

precision = tp / (tp + fp) if (tp + fp) else 0.0
recall    = tp / (tp + fn) if (tp + fn) else 0.0
f1        = 2*precision*recall/(precision+recall) if (precision+recall) else 0.0

per_rule = (
    df[anomaly]
    .assign(caught=lambda d: ~d["is_valid"].astype(bool))
    .groupby("injected_rule")["caught"]
    .mean().round(3).to_dict()
)

metrics = {
    "n_eval": int(len(df)),
    "confusion": {"tp": tp, "fp": fp, "fn": fn, "tn": tn},
    "precision": round(precision, 4),
    "recall": round(recall, 4),
    "f1": round(f1, 4),
    "recall_par_regle": per_rule,
}

out = pathlib.Path("reporting/eval_metrics.json")
out.write_text(json.dumps(metrics, indent=2, ensure_ascii=False), encoding="utf-8")

print(json.dumps(metrics, indent=2, ensure_ascii=False))
print(f"\n→ Guard : precision={precision:.3f}  recall={recall:.3f}  F1={f1:.3f}")
