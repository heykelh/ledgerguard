import duckdb
con = duckdb.connect("dbt/ledgerguard.duckdb")
print("— Risque par grade —")
print(con.sql("select grade, n_loans, total_exposure, avg_interest_rate, default_rate_pct from rpt_credit_risk_by_grade order by grade"))
print("— Défaut par millésime —")
print(con.sql("select vintage_year, n_loans, default_rate_pct, pct_matured from rpt_default_by_vintage order by vintage_year"))
print("— Portefeuille par statut —")
print(con.sql("select loan_status, n_loans, outstanding_exposure, pct_of_portfolio from rpt_portfolio_by_status order by n_loans desc"))
