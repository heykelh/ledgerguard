-- Bronze : prêts Lending Club acceptés, colonnes curées au périmètre risque de crédit.
-- Medallion : bronze = fidèle à la source, tout en VARCHAR, AUCUN cast.
-- Le typage/nettoyage (silver) + les contrôles qualité arrivent en P2.

with source as (

    select *
    from read_csv(
        '{{ var("raw_loans_file") }}',
        all_varchar   = true,     -- on lit tout en texte : la donnée sale ne casse pas le chargement
        header        = true,
        compression   = 'gzip',
        ignore_errors = true      -- on saute les lignes malformées (footers/junk)
    )

)

select
    row_number() over (order by issue_d) as loan_sk,  -- clé de substitution : la source n'a pas d'ID exploitable (finding P2)
    id                    as loan_id_source,
    loan_amnt             as loan_amount,
    funded_amnt           as funded_amount,
    term                  as term,
    int_rate              as interest_rate,
    installment           as installment,
    grade                 as grade,
    sub_grade             as sub_grade,
    emp_length            as employment_length,
    home_ownership        as home_ownership,
    annual_inc            as annual_income,
    verification_status   as verification_status,
    issue_d               as issue_date,
    loan_status           as loan_status,
    purpose               as purpose,
    dti                   as dti,
    addr_state            as borrower_state,
    application_type      as application_type,
    open_acc              as open_accounts,
    revol_bal             as revolving_balance,
    revol_util            as revolving_utilization,
    total_acc             as total_accounts
from source
