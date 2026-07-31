-- Silver : typage + contrôles, via macros partagées (source unique des règles).
with typed as (
    select
        loan_sk,
        loan_id_source,
        {{ dq_typing() }}
    from {{ ref('stg_loans') }}
),

controlled as (
    select *, {{ dq_flags() }}
    from typed
)

select *, {{ dq_verdict() }}
from controlled
