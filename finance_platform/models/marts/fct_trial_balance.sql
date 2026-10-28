-- Mart: Trial Balance
-- Period-level account balances for financial reporting

select
    fiscal_period,
    fiscal_year,
    fiscal_month,
    entity_code,
    entity_name,
    account_code,
    account_name,
    account_type,
    account_subtype,
    statement_type,
    natural_balance,
    total_debits,
    total_credits,
    balance,
    journal_count,
    line_count,
    late_posting_count,
    restatement_count

from {{ ref('int_trial_balance') }}
