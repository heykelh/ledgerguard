import duckdb
con = duckdb.connect("dbt/ledgerguard.duckdb")

print("— Volumétrie —")
print(con.sql("select count(*) as n_rows, count(distinct loan_sk) as n_keys from stg_loans"))

print("— Répartition loan_status —")
print(con.sql("""
    select loan_status, count(*) as n
    from stg_loans group by 1 order by 2 desc
"""))

print("— Taux de vide sur colonnes critiques (%) —")
print(con.sql("""
    select
      round(100.0*sum(case when loan_amount   is null or loan_amount=''   then 1 else 0 end)/count(*),2) as null_loan_amount,
      round(100.0*sum(case when annual_income is null or annual_income='' then 1 else 0 end)/count(*),2) as null_annual_income,
      round(100.0*sum(case when dti           is null or dti=''           then 1 else 0 end)/count(*),2) as null_dti,
      round(100.0*sum(case when interest_rate is null or interest_rate='' then 1 else 0 end)/count(*),2) as null_interest_rate,
      round(100.0*sum(case when loan_status   is null or loan_status=''   then 1 else 0 end)/count(*),2) as null_loan_status
    from stg_loans
"""))
