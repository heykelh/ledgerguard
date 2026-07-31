import duckdb
con = duckdb.connect("dbt/ledgerguard.duckdb")
print("eval_injected :", con.sql("select count(*) as n from eval_injected").fetchone())
print("eval_scored   :", con.sql("select count(*) as n from eval_scored").fetchone())
print(con.sql("""
    select label_is_anomaly, count(*) as n,
           sum(case when is_valid then 1 else 0 end) as valides,
           sum(case when not is_valid then 1 else 0 end) as bloques
    from eval_scored group by 1 order by 1
"""))
