{% macro dq_flags() %}
    coalesce(loan_status is not null and loan_status <> '', false) as ok_complete_status,
    coalesce(loan_amount is not null, false)                       as ok_complete_amount,
    coalesce(term_months in (36, 60), false)                       as ok_valid_term,
    coalesce(issue_date is not null, false)                        as ok_valid_issue_date,
    coalesce(loan_amount > 0, false)                               as ok_amount_positive,
    coalesce(funded_amount <= loan_amount, false)                  as ok_funded_le_loan,
    coalesce(dti between 0 and 100, false)                         as ok_dti_range,
    coalesce(annual_income between 0 and 10000000, false)          as ok_income_range,
    coalesce(interest_rate between 0 and 40, false)                as ok_rate_range
{% endmacro %}
