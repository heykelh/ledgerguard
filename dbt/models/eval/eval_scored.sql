-- Désactivé par défaut : ne tourne que sur demande (--vars '{"run_eval": true}').
{{ config(enabled = var('run_eval', false), materialized = 'table') }}

with typed as (
    select
        eval_id,
        label_is_anomaly,
        injected_rule,
        {{ dq_typing() }}
    from eval_injected          -- table produite par inject_anomalies.py
),

controlled as (
    select *, {{ dq_flags() }}
    from typed
)

select *, {{ dq_verdict() }}
from controlled
