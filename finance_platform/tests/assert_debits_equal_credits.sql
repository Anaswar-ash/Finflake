-- RECONCILIATION TEST: Every journal must have debits = credits
-- This is the fundamental law of double-entry bookkeeping.
-- If this test fails, data integrity is compromised.

with journal_balances as (
    select
        journal_id,
        sum(debit_amount)   as total_debits,
        sum(credit_amount)  as total_credits,
        abs(sum(debit_amount) - sum(credit_amount)) as variance
    from {{ ref('stg_gl_journal_entries') }}
    group by journal_id
)

-- Return rows that FAIL (variance > 0.01 tolerance for rounding)
select
    journal_id,
    total_debits,
    total_credits,
    variance
from journal_balances
where variance > 0.01
