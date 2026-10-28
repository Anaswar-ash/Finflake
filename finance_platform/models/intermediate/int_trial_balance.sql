-- Intermediate: Trial Balance
-- Aggregates all journal entries by account and period
-- The trial balance MUST balance (total debits = total credits)

with enriched as (
    select * from {{ ref('int_journal_entries_enriched') }}
    where is_reversed = false  -- Exclude reversed entries
),

trial_balance as (
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

        sum(debit_amount)                           as total_debits,
        sum(credit_amount)                          as total_credits,
        sum(debit_amount) - sum(credit_amount)      as balance,

        count(distinct journal_id)                  as journal_count,
        count(*)                                    as line_count,

        -- Data quality metrics
        sum(case when is_late_posting then 1 else 0 end)    as late_posting_count,
        sum(case when is_restatement then 1 else 0 end)     as restatement_count

    from enriched
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
)

select * from trial_balance
