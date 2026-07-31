import pathlib
rows = [
    "loan_status,status_group,is_default,is_performing,is_resolved",
    "Fully Paid,Closed,false,true,true",
    "Current,Open,false,true,false",
    "Charged Off,Closed,true,false,true",
    "Late (31-120 days),Open,false,false,false",
    "In Grace Period,Open,false,true,false",
    "Late (16-30 days),Open,false,false,false",
    "Default,Closed,true,false,true",
]
p = pathlib.Path("dbt/seeds/ref_loan_status.csv")
# utf-8 SANS BOM, fins de ligne \n
p.write_text("\n".join(rows) + "\n", encoding="utf-8")
print("seed réécrit sans BOM :", p)
