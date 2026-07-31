-- Gold : profil de risque par grade. Lit uniquement la donnée conforme.
-- Taux de défaut = défauts / prêts à l'issue connue (resolved) — les prêts en cours sont exclus.
{{ config(materialized = 'table') }}

with base as (
    select
        c.grade,
        c.funded_amount,
        c.interest_rate,
        c.dti,
        r.is_default,
        r.is_resolved
    from {{ ref('int_loans_conformed') }} c
    left join {{ ref('ref_loan_status') }} r on c.loan_status = r.loan_status
)

select
    grade,
    count(*)                                                      as n_loans,
    sum(funded_amount)                                            as total_exposure,
    round(avg(interest_rate), 2)                                  as avg_interest_rate,
    round(avg(dti), 2)                                            as avg_dti,
    count(*) filter (where is_resolved)                           as n_resolved,
    count(*) filter (where is_default)                            as n_defaulted,
    round(100.0 * count(*) filter (where is_default)
          / nullif(count(*) filter (where is_resolved), 0), 2)    as default_rate_pct
from base
group by grade
order by grade
