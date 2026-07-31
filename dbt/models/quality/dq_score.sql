-- Score qualité par dimension DAMA + global, mesuré sur la donnée réelle.
with f as (select * from {{ ref('int_loans_typed') }})

select 'Complétude' as dimension,
    round(100.0 * avg(case when ok_complete_status and ok_complete_amount then 1 else 0 end), 3) as score_pct,
    count(*) as n_total
from f
union all
select 'Validité',
    round(100.0 * avg(case when ok_valid_term and ok_valid_issue_date then 1 else 0 end), 3),
    count(*)
from f
union all
select 'Plausibilité',
    round(100.0 * avg(case when ok_amount_positive and ok_funded_le_loan and ok_dti_range
                            and ok_income_range and ok_rate_range then 1 else 0 end), 3),
    count(*)
from f
union all
select 'Unicité',
    round(100.0 * (count(distinct loan_sk)::double / count(*)), 3),
    count(*)
from f
union all
select 'GLOBAL (part conforme)',
    round(100.0 * avg(case when is_valid then 1 else 0 end), 3),
    count(*)
from f
