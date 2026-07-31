import duckdb
con = duckdb.connect("dbt/ledgerguard.duckdb")

print("— Faux négatifs : total, et combien ont une règle nulle —")
print(con.sql("""
    select
        count(*)                                        as fn_total,
        count(*) filter (where injected_rule is null)   as fn_regle_nulle
    from eval_scored
    where label_is_anomaly = 1 and is_valid
"""))

print("— FN par règle injectée (NULL inclus) —")
print(con.sql("""
    select coalesce(injected_rule, '(NULL)') as regle, count(*) as fn
    from eval_scored
    where label_is_anomaly = 1 and is_valid
    group by 1 order by 2 desc
"""))

print("— Échantillon de FN : valeurs après typage —")
print(con.sql("""
    select coalesce(injected_rule,'(NULL)') as regle,
           loan_amount, funded_amount, term_months, dti,
           annual_income, interest_rate, issue_date, loan_status
    from eval_scored
    where label_is_anomaly = 1 and is_valid
    limit 15
"""))
