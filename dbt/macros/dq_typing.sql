{% macro dq_typing() %}
    try_cast(loan_amount as decimal(12,2))                 as loan_amount,
    try_cast(funded_amount as decimal(12,2))               as funded_amount,
    try_cast(trim(replace(term, 'months', '')) as integer) as term_months,
    try_cast(interest_rate as decimal(6,3))                as interest_rate,
    try_cast(installment as decimal(12,2))                 as installment,
    grade,
    sub_grade,
    case
        when employment_length like '10+%' then 10
        when employment_length like '< 1%' then 0
        else try_cast(regexp_extract(employment_length, '[0-9]+') as integer)
    end                                                     as employment_years,
    home_ownership,
    try_cast(annual_income as decimal(14,2))               as annual_income,
    verification_status,
    try_strptime(issue_date, '%b-%Y')::date                as issue_date,
    loan_status                                             as loan_status_raw,
    case
        when loan_status like 'Does not meet the credit policy. Status:%'
            then trim(split_part(loan_status, ':', 2))
        else loan_status
    end                                                     as loan_status,
    (loan_status like 'Does not meet the credit policy%')   as flag_off_policy,
    purpose,
    try_cast(dti as decimal(8,2))                          as dti,
    borrower_state,
    application_type,
    try_cast(revolving_utilization as decimal(8,2))        as revolving_utilization
{% endmacro %}
