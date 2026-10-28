-- RECONCILIATION TEST: Entity-level source-to-target reconciliation
-- Ensures no data is lost or duplicated between staging and mart layers.
-- Compares total amounts in staging vs the trial balance mart.

with staging_totals as (
    select
        entity_code,
        sum(debit_amount)   as stg_debits,
        sum(credit_amount)  as stg_credits
    from {{ ref('stg_gl_journal_entries') }}
    where is_reversed = false
    group by entity_code
),

mart_totals as (
    select
        entity_code,
        sum(total_debits)   as mart_debits,
        sum(total_credits)  as mart_credits
    from {{ ref('fct_trial_balance') }}
    group by entity_code
),

reconciliation as (
    select
        s.entity_code,
        s.stg_debits,
        m.mart_debits,
        abs(s.stg_debits - m.mart_debits)       as debit_variance,
        s.stg_credits,
        m.mart_credits,
        abs(s.stg_credits - m.mart_credits)     as credit_variance
    from staging_totals s
    join mart_totals m on s.entity_code = m.entity_code
)

-- Return rows that FAIL
select *
from reconciliation
where debit_variance > 0.01 or credit_variance > 0.01
