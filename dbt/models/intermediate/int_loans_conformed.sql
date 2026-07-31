-- Silver conforme : uniquement les enregistrements valides, admissibles au reporting.
-- C'est le "Guard" : la donnée non conforme n'atteint jamais le reporting réglementaire.
select *
from {{ ref('int_loans_typed') }}
where is_valid
