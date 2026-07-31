-- Gold : analyse par millésime (vintage). Le taux de défaut d'un millésime récent
-- est biaisé bas tant que peu de prêts sont arrivés à terme → pct_matured le signale.
{{ config(materialized = 'table') }}

with base as (
    select
        year(c.issue_date)  as vintage_year,
        c.funded_amount,
        r.is_default,
        r.is_resolved
    from {{ ref('int_loans_conformed') }} c
    left join {{ ref('ref_loan_status') }} r on c.loan_status = r.loan_status
    where c.issue_date is not null
)

select
    vintage_year,
    count(*)                                                      as n_loans,
    sum(funded_amount)                                            as total_exposure,
    count(*) filter (where is_resolved)                           as n_resolved,
    count(*) filter (where is_default)                            as n_defaulted,
    round(100.0 * count(*) filter (where is_default)
          / nullif(count(*) filter (where is_resolved), 0), 2)    as default_rate_pct,
    round(100.0 * count(*) filter (where is_resolved)
          / count(*), 1)                                          as pct_matured
from base
group by vintage_year
order by vintage_year
