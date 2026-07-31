{% macro dq_verdict() %}
    (ok_complete_status and ok_complete_amount and ok_valid_term and ok_valid_issue_date
     and ok_amount_positive and ok_funded_le_loan and ok_dti_range and ok_income_range
     and ok_rate_range)                                                as is_valid,
    nullif(trim(concat_ws(' | ',
        case when not ok_complete_status   then 'COMPLETUDE_status'          end,
        case when not ok_complete_amount   then 'COMPLETUDE_amount'          end,
        case when not ok_valid_term        then 'VALIDITE_term'              end,
        case when not ok_valid_issue_date  then 'VALIDITE_issue_date'        end,
        case when not ok_amount_positive   then 'PLAUSIBILITE_amount_positif'end,
        case when not ok_funded_le_loan    then 'COHERENCE_funded_le_loan'   end,
        case when not ok_dti_range         then 'PLAUSIBILITE_dti'           end,
        case when not ok_income_range      then 'PLAUSIBILITE_income'        end,
        case when not ok_rate_range        then 'PLAUSIBILITE_rate'          end
    )), '')                                                            as dq_reasons
{% endmacro %}
