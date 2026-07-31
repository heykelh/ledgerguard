import duckdb, pathlib
con = duckdb.connect("dbt/ledgerguard.duckdb")
out = pathlib.Path("reporting/powerbi"); out.mkdir(parents=True, exist_ok=True)
for t in ["rpt_credit_risk_by_grade", "rpt_default_by_vintage", "rpt_portfolio_by_status"]:
    con.execute(f"copy (select * from {t}) to '{out.as_posix()}/{t}.csv' (header, delimiter ',')")
    print("exporté :", t)
