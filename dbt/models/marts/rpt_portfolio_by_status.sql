-- Gold : encours et répartition du portefeuille par statut.
{{ config(materialized = 'table') }}

with base as (
    select
        c.loan_status,
        c.funded_amount,
        r.status_group,
        r.is_performing
    from {{ ref('int_loans_conformed') }} c
    left join {{ ref('ref_loan_status') }} r on c.loan_status = r.loan_status
)

select
    loan_status,
    status_group,
    is_performing,
    count(*)                                                      as n_loans,
    sum(funded_amount)                                            as outstanding_exposure,
    round(100.0 * sum(funded_amount) / sum(sum(funded_amount)) over (), 2) as pct_of_portfolio
from base
group by loan_status, status_group, is_performing
order by n_loans desc
