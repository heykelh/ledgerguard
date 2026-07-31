"""Génère un jeu étiqueté : lignes réelles conformes (label 0) + copies corrompues
par règle (label 1), écrit dans la table eval_injected. Tout en SQL/VARCHAR : aucun
drift de type, la donnée reste dans le monde de DuckDB comme en prod."""
import duckdb

con = duckdb.connect("dbt/ledgerguard.duckdb")
con.execute("select setseed(0.42)")  # reproductible

# 1) Base propre : 5000 lignes réelles validées par le pipeline
con.execute("""
create or replace table eval_clean as
select
    row_number() over () as eval_id,
    0                     as label_is_anomaly,
    cast(null as varchar) as injected_rule,
    s.*
from stg_loans s
where s.loan_sk in (select loan_sk from int_loans_conformed)
order by random()
limit 5000
""")

# 2) Anomalies : 900 lignes propres réparties en 9 groupes EXACTS via ntile,
#    une corruption ciblée par groupe.
con.execute("""
create or replace table eval_anomalies as
with pool as (
    select *
    from eval_clean
    order by random()
    limit 900
),
grouped as (
    select *, ntile(9) over (order by random()) - 1 as grp
    from pool
)
select
    eval_id + 1000000 as eval_id,
    1                 as label_is_anomaly,
    case grp
        when 0 then 'PLAUSIBILITE_amount_positif'
        when 1 then 'COHERENCE_funded_le_loan'
        when 2 then 'PLAUSIBILITE_dti'
        when 3 then 'PLAUSIBILITE_income'
        when 4 then 'PLAUSIBILITE_rate'
        when 5 then 'VALIDITE_term'
        when 6 then 'VALIDITE_issue_date'
        when 7 then 'COMPLETUDE_status'
        when 8 then 'COMPLETUDE_amount'
    end as injected_rule,
    loan_sk,
    loan_id_source,
    case when grp = 8 then '' when grp = 0 then '-500' else loan_amount end          as loan_amount,
    case when grp = 1 then (try_cast(loan_amount as double)*3)::varchar
         else funded_amount end                                                       as funded_amount,
    case when grp = 5 then ' 48 months' else term end                                 as term,
    case when grp = 4 then '99' else interest_rate end                                as interest_rate,
    installment, grade, sub_grade, employment_length, home_ownership,
    case when grp = 3 then '20000000' else annual_income end                          as annual_income,
    verification_status,
    case when grp = 6 then 'not-a-date' else issue_date end                           as issue_date,
    case when grp = 7 then '' else loan_status end                                    as loan_status,
    purpose,
    case when grp = 2 then '150' else dti end                                         as dti,
    borrower_state, application_type, open_accounts, revolving_balance,
    revolving_utilization, total_accounts
from grouped
""")

# 3) Jeu final étiqueté
con.execute("""
create or replace table eval_injected as
select * from eval_clean
union all
select * from eval_anomalies
""")

# Garde-fou : aucune ligne 'anomalie' ne doit rester sans règle ni non corrompue.
orphelins = con.sql("""
    select count(*) from eval_anomalies where injected_rule is null
""").fetchone()[0]
assert orphelins == 0, f"{orphelins} anomalies sans injected_rule — injection cassée"

repartition = con.sql("""
    select injected_rule, count(*) n from eval_anomalies group by 1 order by 1
""")
print(repartition)

print(con.sql("select label_is_anomaly, count(*) n from eval_injected group by 1 order by 1"))
print("eval_injected prête.")
